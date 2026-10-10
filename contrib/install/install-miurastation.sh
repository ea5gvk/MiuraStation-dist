#!/usr/bin/env bash
# MiuraStation installer and updater for a Raspberry Pi 3/4/5 with 64-bit Raspberry Pi OS (Bookworm or
# Trixie). Installs the miurastation .deb of a release of ea5gvk/MiuraStation-dist (checked against its
# SHA256SUMS), the SoapySDR runtime and the SDR module, and the tetra-live-monitor panel.
#
#   curl -fsSL https://raw.githubusercontent.com/ea5gvk/MiuraStation-dist/main/contrib/install/install-miurastation.sh | sudo bash
#   curl -fsSL .../install-miurastation.sh | sudo bash -s -- --version v1.1.0 --sdr sx --yes
#
# Options (or environment variables):
#   --version vX.Y.Z     MIURA_VERSION=vX.Y.Z  that release instead of the latest stable one
#   --beta               MIURA_CHANNEL=beta    the newest release, pre-releases (beta) included
#   --no-monitor         MIURA_NO_MONITOR=1    do not install or update tetra-live-monitor
#   --sdr sx|lime|none   MIURA_SDR=...         SoapySDR module of the SDR (default: detected)
#   --yes                MIURA_YES=1           do not ask for confirmation
#   TLM_BRANCH=main      tetra-live-monitor branch     TLM_PASSWORD=...  panel admin password
#   SXX_REF=<commit>     tejeez/sxxcvr commit built for SoapySX
#
# Running it again updates. /root/miurastation/config.toml is never overwritten.
# Log: /var/log/miurastation-install.log
set -euo pipefail

DIST_REPO=ea5gvk/MiuraStation-dist
STATION_DIR=/root/miurastation
SOURCE_UNIT=/etc/systemd/system/miurastation.service
LOG=/var/log/miurastation-install.log
TLM_REPO=https://github.com/ea5gvk/tetra-live-monitor.git
TLM_DIR=/opt/tetra-live-monitor
SXX_REPO=https://github.com/tejeez/sxxcvr.git
SXX_DIR=/root/sxxcvr
# The SoapySX commit running on the reference station.
SXX_REF_DEFAULT=9705147dd8c189625071f3f163ea56119bda4a05
SX_MODULE=/usr/local/lib/SoapySDR/modules0.8/libSXSupport.so

VERSION_REQ=${MIURA_VERSION:-}
CHANNEL=${MIURA_CHANNEL:-stable}
NO_MONITOR=${MIURA_NO_MONITOR:-0}
SDR=${MIURA_SDR:-auto}
YES=${MIURA_YES:-0}
TLM_BRANCH=${TLM_BRANCH:-main}
SXX_REF=${SXX_REF:-$SXX_REF_DEFAULT}

TAG="" VERSION="" CODENAME="" WORK="" TMP_SWAP=""
LEGACY_ACTIVE="" LEGACY_ENABLED=""
REBOOT_NEEDED=0
NOTES=()

say()  { printf '\n=== %s\n' "$*"; }
info() { printf '  %s\n' "$*"; }
warn() { printf '  AVISO: %s\n' "$*"; NOTES+=("$*"); }
die()  { printf '\nERROR: %s\nRegistro: %s\n' "$*" "$LOG" >&2; exit 1; }

usage() {
  sed -n '2,20p' "$0" 2>/dev/null | sed 's/^# \{0,1\}//' || true
  cat <<'EOF'
Uso: install-miurastation.sh [--version vX.Y.Z] [--beta] [--no-monitor] [--sdr sx|lime|none] [--yes]
EOF
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --version) [ $# -ge 2 ] || die "--version necesita un valor (vX.Y.Z)"; VERSION_REQ=$2; shift 2 ;;
      --version=*) VERSION_REQ=${1#*=}; shift ;;
      --beta) CHANNEL=beta; shift ;;
      --no-monitor) NO_MONITOR=1; shift ;;
      --sdr) [ $# -ge 2 ] || die "--sdr necesita un valor (sx, lime o none)"; SDR=$2; shift 2 ;;
      --sdr=*) SDR=${1#*=}; shift ;;
      -y|--yes) YES=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "opción desconocida: $1 (usa --help)" ;;
    esac
  done
  case "$SDR" in auto|sx|lime|none) ;; *) die "--sdr admite sx, lime o none" ;; esac
  case "$CHANNEL" in stable|beta) ;; *) die "MIURA_CHANNEL admite stable o beta" ;; esac
  if [ -n "$VERSION_REQ" ]; then
    VERSION_REQ=v${VERSION_REQ#v}
    [[ "$VERSION_REQ" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?$ ]] || die "versión no válida: $VERSION_REQ (formato vX.Y.Z)"
  fi
}

# Yes with --yes; otherwise asks on the terminal (stdin is the script when piped from curl).
confirm() {
  [ "$YES" = 1 ] && return 0
  local reply=""
  read -r -p "  $1 [s/N] " reply < /dev/tty 2>/dev/null || return 1
  case "$reply" in s|S|si|SI|Si|sí|Sí|y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

apt_install() { DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"; }

# Product name in the EEPROM of the HAT on the GPIO header ("SXceiver" for the SXceiver), or nothing.
hat_product() { cat /proc/device-tree/hat/product 2>/dev/null | tr -d '\0' || true; }

cleanup() {
  if [ -n "$TMP_SWAP" ]; then swapoff "$TMP_SWAP" 2>/dev/null || true; rm -f "$TMP_SWAP"; fi
  if [ -n "$WORK" ]; then rm -rf "$WORK"; fi
}

check_system() {
  say "Comprobando el sistema"
  command -v dpkg >/dev/null 2>&1 || die "solo para Raspberry Pi OS / Debian"
  local arch model avail need pretty
  arch=$(dpkg --print-architecture)
  [ "$arch" = arm64 ] || die "arquitectura $arch no soportada: hace falta Raspberry Pi OS de 64 bits (arm64). La de 32 bits (armhf) todavía no tiene paquete."
  # In subshells: /etc/os-release also sets VERSION.
  # shellcheck disable=SC1091
  CODENAME=$(. /etc/os-release && echo "${VERSION_CODENAME:-}")
  # shellcheck disable=SC1091
  pretty=$(. /etc/os-release && echo "${PRETTY_NAME:-desconocido}")
  case "$CODENAME" in
    bookworm|trixie) ;;
    *) die "sistema no soportado: $pretty. Hace falta Raspberry Pi OS (Debian) Bookworm o Trixie de 64 bits." ;;
  esac
  model=$(cat /proc/device-tree/model 2>/dev/null | tr -d '\0' || true)
  info "Placa:   ${model:-desconocida}"
  info "Sistema: $pretty ($arch)"
  case "$model" in
    *"Raspberry Pi 3"*) warn "Raspberry Pi 3: usa una sola portadora (sin extra_carriers ni portadora de datos) mientras no se haya probado en campo." ;;
  esac
  need=400
  [ "$NO_MONITOR" = 1 ] || need=1500
  avail=$(df -Pm / | awk 'NR == 2 { print $4 }')
  [ "$avail" -ge "$need" ] || die "poco espacio libre en /: ${avail} MB (hacen falta unos ${need} MB)"
  info "Espacio libre: ${avail} MB"
  getent hosts github.com >/dev/null 2>&1 || die "sin red: no se resuelve github.com"
}

install_base() {
  say "Paquetes base"
  DEBIAN_FRONTEND=noninteractive apt-get update || die "apt-get update ha fallado (¿red?)"
  apt_install ca-certificates curl python3 git
  curl -fsS --max-time 20 -o /dev/null https://api.github.com/ || die "sin acceso a GitHub (https://api.github.com)"
}

resolve_release() {
  say "Versión de MiuraStation"
  local api="https://api.github.com/repos/$DIST_REPO"
  if [ -n "$VERSION_REQ" ]; then
    TAG=$VERSION_REQ
  elif [ "$CHANNEL" = beta ]; then
    TAG=$(curl -fsSL --retry 3 --max-time 30 "$api/releases?per_page=30" | python3 -c '
import json, sys
rels = [r for r in json.load(sys.stdin) if not r.get("draft")]
print(rels[0]["tag_name"] if rels else "")') || die "no se ha podido consultar las versiones de $DIST_REPO"
  else
    TAG=$(curl -fsSL --retry 3 --max-time 30 "$api/releases/latest" | python3 -c '
import json, sys
print(json.load(sys.stdin).get("tag_name", ""))') || die "no se ha podido consultar la última versión de $DIST_REPO"
  fi
  [ -n "$TAG" ] || die "$DIST_REPO no tiene ninguna versión publicada"
  VERSION=${TAG#v}
  info "Versión: $VERSION ($([ -n "$VERSION_REQ" ] && echo pedida || echo "canal $CHANNEL"))"
}

detect_sdr() {
  [ "$SDR" = auto ] || return 0
  local usb
  usb=$(lsusb 2>/dev/null || true)
  if grep -qi sxceiver <<< "$(hat_product)" || [ -e "$SX_MODULE" ]; then
    SDR=sx
  elif grep -qiE '1d50:6108|0403:601f|limesdr' <<< "$usb" || dpkg -s soapysdr0.8-module-lms7 >/dev/null 2>&1; then
    SDR=lime
  else
    SDR=none
    warn "no se ha detectado el SDR: si es un SXceiver o un LimeSDR, vuelve a ejecutar el instalador con --sdr sx o --sdr lime."
  fi
  info "SDR detectado: $SDR"
}

install_soapysdr() {
  say "SoapySDR"
  apt_install libsoapysdr0.8 soapysdr-tools
  case "$SDR" in
    sx) install_soapysx ;;
    lime) apt_install soapysdr0.8-module-lms7 ;;
    none) info "Sin módulo de SDR (--sdr none)" ;;
  esac
  info "Módulos de SoapySDR: $(SoapySDRUtil --info 2>/dev/null | sed -n 's/^Available factories\.\.\. *//p')"
}

# SoapySX (the SXceiver module), built from tejeez/sxxcvr as on the reference station. The HAT's EEPROM
# loads its device-tree overlay; a board without EEPROM gets the overlay and SPI in config.txt.
install_soapysx() {
  say "Módulo SoapySX (SXceiver)"
  apt_install git make g++ cmake libsoapysdr-dev libasound2-dev
  if [ -d "$SXX_DIR/.git" ]; then
    git -C "$SXX_DIR" fetch -q origin || warn "no se ha podido actualizar $SXX_DIR desde GitHub"
  elif [ -e "$SXX_DIR" ]; then
    die "$SXX_DIR existe y no es un clon git de sxxcvr"
  else
    git clone -q "$SXX_REPO" "$SXX_DIR"
  fi
  local want
  want=$(git -C "$SXX_DIR" rev-parse --verify -q "$SXX_REF^{commit}") || die "sxxcvr no tiene el commit $SXX_REF"
  if [ -f "$SX_MODULE" ] && [ "$(git -C "$SXX_DIR" rev-parse HEAD)" = "$want" ]; then
    info "SoapySX ya compilado (${want:0:8})"
  else
    git -C "$SXX_DIR" -c advice.detachedHead=false checkout -q "$want" \
      || die "no se puede pasar $SXX_DIR a ${want:0:8} (¿cambios locales?)"
    cmake -S "$SXX_DIR/SoapySX" -B "$SXX_DIR/SoapySX/build" -DCMAKE_BUILD_TYPE=Release
    make -C "$SXX_DIR/SoapySX/build" -j"$(nproc)"
    make -C "$SXX_DIR/SoapySX/build" install
    ldconfig
    info "SoapySX ${want:0:8} instalado en $SX_MODULE"
  fi
  sx_overlay
}

sx_overlay() {
  if grep -qi sxceiver <<< "$(hat_product)"; then
    info "La EEPROM del HAT SXceiver carga el overlay del SX1255: config.txt no necesita cambios"
    return 0
  fi
  local cfg=/boot/firmware/config.txt add=()
  [ -f "$cfg" ] || cfg=/boot/config.txt
  if [ ! -f "$cfg" ]; then warn "no se encuentra config.txt: añade a mano el overlay del SX1255 y dtparam=spi=on"; return 0; fi
  grep -Eq '^[[:space:]]*dtparam=spi=on' "$cfg" || add+=("dtparam=spi=on")
  grep -Eq '^[[:space:]]*dtoverlay=sx1255' "$cfg" || add+=("dtoverlay=sx1255-raspberrypi")
  if [ ${#add[@]} -eq 0 ]; then info "config.txt ya tiene el overlay del SX1255 y el SPI"; return 0; fi
  info "No hay HAT con EEPROM: se añade a $cfg: ${add[*]}"
  if [[ " ${add[*]} " == *" dtoverlay="* ]]; then
    apt_install device-tree-compiler
    dtc -Wno-unit_address_vs_reg -I dts -O dtb -o "$(dirname "$cfg")/overlays/sx1255-raspberrypi.dtbo" \
      "$SXX_DIR/dts/sx1255_raspberrypi.dts"
  fi
  cp -p "$cfg" "$cfg.bak-miurastation-$(date +%Y%m%d%H%M%S)"
  { echo; echo "# MiuraStation: SXceiver (SX1255) sin EEPROM de HAT"; echo "[all]"; printf '%s\n' "${add[@]}"; } >> "$cfg"
  REBOOT_NEEDED=1
}

# A station installed from source has its own unit in /etc/systemd/system, which hides the package's.
migrate_source_unit() {
  [ -f "$SOURCE_UNIT" ] && [ ! -L "$SOURCE_UNIT" ] || return 0
  grep -q '^ExecStart=.*target/release/' "$SOURCE_UNIT" || return 0
  say "MiuraStation instalada desde el código fuente"
  info "$SOURCE_UNIT ($(sed -n 's/^ExecStart=//p' "$SOURCE_UNIT" | head -n1))"
  info "Esa unidad taparía la del paquete. Se guarda una copia en $STATION_DIR/ y se usa la del paquete;"
  info "config.toml, registros y cachés de $STATION_DIR se conservan."
  confirm "¿Pasar la estación al paquete?" || die "cancelado. Vuelve a ejecutarlo con --yes para pasar la estación al paquete."
  LEGACY_ACTIVE=$(systemctl is-active miurastation.service 2>/dev/null || true)
  LEGACY_ENABLED=$(systemctl is-enabled miurastation.service 2>/dev/null || true)
  mkdir -p "$STATION_DIR"
  cp -p "$SOURCE_UNIT" "$STATION_DIR/miurastation.service.source-install.bak"
  systemctl disable miurastation.service >/dev/null 2>&1 || true
  rm -f "$SOURCE_UNIT"
  systemctl daemon-reload
}

install_station() {
  say "Paquete miurastation $VERSION"
  local base="https://github.com/$DIST_REPO/releases/download/$TAG"
  local deb="miurastation_${VERSION}_arm64.deb"
  WORK=$(mktemp -d /tmp/miurastation-install.XXXXXX)
  chmod 755 "$WORK"   # apt reads the .deb as the _apt user
  curl -fsSL --retry 3 -o "$WORK/SHA256SUMS" "$base/SHA256SUMS" || die "la versión $TAG no existe en $DIST_REPO (o no hay red)"
  curl -fSL --retry 3 --progress-bar -o "$WORK/$deb" "$base/$deb" || die "no se ha podido descargar $deb"
  chmod 644 "$WORK/$deb"
  awk -v f="$deb" '$2 == f || $2 == "*" f' "$WORK/SHA256SUMS" > "$WORK/deb.sha256"
  [ -s "$WORK/deb.sha256" ] || die "SHA256SUMS no incluye $deb"
  (cd "$WORK" && sha256sum -c deb.sha256) || die "la suma SHA-256 de $deb no coincide: descarga corrupta o manipulada"

  local new cur
  new=$(dpkg-deb -f "$WORK/$deb" Version)
  cur=$(dpkg-query -W -f='${db:Status-Abbrev}|${Version}' miurastation 2>/dev/null || true)
  if [ "${cur%%|*}" = "ii " ] && [ "${cur#*|}" = "$new" ]; then
    info "La versión $VERSION ya está instalada"
    return 0
  fi
  local flags=()
  if [ "${cur%%|*}" = "ii " ] && dpkg --compare-versions "$new" lt "${cur#*|}"; then
    info "Se vuelve a una versión anterior (${cur#*|} -> $new)"
    flags+=(--allow-downgrades)
  fi
  DEBIAN_FRONTEND=noninteractive apt-get install -y "${flags[@]}" "$WORK/$deb"

  # A station moved over from a source install keeps its enabled/running state.
  if [ -n "$LEGACY_ENABLED" ] && [ "$LEGACY_ENABLED" != enabled ]; then
    systemctl disable miurastation.service >/dev/null 2>&1 || true
  fi
  if [ "$LEGACY_ACTIVE" = active ]; then
    info "Reiniciando la estación con el binario del paquete"
    systemctl restart miurastation.service || warn "la estación no ha arrancado: journalctl -u miurastation"
  fi
}

install_node() {
  local major=0
  if command -v node >/dev/null 2>&1; then major=$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0); fi
  if [ "$major" -ge 20 ] && command -v npm >/dev/null 2>&1; then
    info "Node.js $(node --version) ya instalado"
    return 0
  fi
  if [ "$CODENAME" = trixie ]; then
    apt_install nodejs npm
  else
    # Bookworm ships Node.js 18: NodeSource repository (Node.js 22 LTS).
    apt_install gnupg
    install -d -m 0755 /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
      | gpg --dearmor --yes -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" \
      > /etc/apt/sources.list.d/nodesource.list
    DEBIAN_FRONTEND=noninteractive apt-get update
    apt_install nodejs
  fi
  major=$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)
  [ "$major" -ge 20 ] || die "hace falta Node.js 20 o posterior y hay $(node --version 2>/dev/null || echo ninguno)"
  info "Node.js $(node --version)"
}

# The panel's build needs about 1.5 GB: a Pi with less RAM + swap gets a temporary swap file.
ensure_build_swap() {
  local mem swap
  mem=$(awk '/^MemTotal:/ { print int($2 / 1024) }' /proc/meminfo)
  swap=$(awk '/^SwapTotal:/ { print int($2 / 1024) }' /proc/meminfo)
  [ $((mem + swap)) -lt 2048 ] || return 0
  TMP_SWAP=/var/swap.miurastation-install
  info "RAM ${mem} MB + swap ${swap} MB: swap temporal de 1 GB para compilar el panel"
  fallocate -l 1G "$TMP_SWAP" 2>/dev/null || dd if=/dev/zero of="$TMP_SWAP" bs=1M count=1024 status=none
  chmod 600 "$TMP_SWAP"
  mkswap -q "$TMP_SWAP" >/dev/null
  swapon "$TMP_SWAP" || { warn "no se ha podido activar la swap temporal"; rm -f "$TMP_SWAP"; TMP_SWAP=""; }
}

install_monitor() {
  say "Panel tetra-live-monitor"
  export HOME=/root PM2_HOME=/root/.pm2
  install_node
  apt_install python3 python3-requests
  command -v pm2 >/dev/null 2>&1 || npm install -g pm2

  local before="" after
  if [ -d "$TLM_DIR/.git" ]; then
    before=$(git -C "$TLM_DIR" rev-parse HEAD)
    git -C "$TLM_DIR" fetch -q origin "$TLM_BRANCH" || die "no se ha podido actualizar $TLM_DIR"
    if [ "$(git -C "$TLM_DIR" rev-parse --abbrev-ref HEAD)" != "$TLM_BRANCH" ]; then
      git -C "$TLM_DIR" checkout -q "$TLM_BRANCH" || die "no se puede pasar $TLM_DIR a la rama $TLM_BRANCH"
    fi
    git -C "$TLM_DIR" merge -q --ff-only "origin/$TLM_BRANCH" \
      || warn "tetra-live-monitor tiene cambios locales que impiden actualizarlo: sigue en la versión instalada"
  elif [ -e "$TLM_DIR" ]; then
    die "$TLM_DIR existe y no es un clon git de tetra-live-monitor"
  else
    git clone -q -b "$TLM_BRANCH" "$TLM_REPO" "$TLM_DIR"
  fi
  after=$(git -C "$TLM_DIR" rev-parse HEAD)

  if [ "$before" != "$after" ] || [ ! -f "$TLM_DIR/dist/index.cjs" ]; then
    ensure_build_swap
    info "Instalando dependencias y compilando (en una Pi 3 tarda varios minutos)"
    # On a 1 GB Pi, Node's default heap limit is too small for the build: let it use the swap.
    local mem
    mem=$(awk '/^MemTotal:/ { print int($2 / 1024) }' /proc/meminfo)
    (cd "$TLM_DIR" && unset NODE_ENV && { [ "$mem" -ge 1536 ] || export NODE_OPTIONS=--max-old-space-size=1024; } \
      && npm ci --no-audit --no-fund && npm run build)
  else
    info "tetra-live-monitor ya está al día (${after:0:8})"
  fi

  # What the panel reads from its working directory: the station in use and the admin password.
  if [ ! -f "$TLM_DIR/active-station.json" ]; then
    printf '{\n  "station": "miurastation"\n}' > "$TLM_DIR/active-station.json"
  elif ! grep -q '"miurastation"' "$TLM_DIR/active-station.json"; then
    warn "el panel tiene seleccionada otra estación: elige MIURA en su selector de estación."
  fi
  [ -f "$TLM_DIR/flowstation-source.json" ] || printf '{"source":"miura"}' > "$TLM_DIR/flowstation-source.json"
  if [ -n "${TLM_PASSWORD:-}" ]; then
    TLM_PASSWORD=$TLM_PASSWORD python3 - "$TLM_DIR/config.json" <<'PY'
import json, os, sys
path = sys.argv[1]
try:
    with open(path) as f:
        cfg = json.load(f)
except (OSError, ValueError):
    cfg = {}
cfg["systemPassword"] = os.environ["TLM_PASSWORD"]
with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")
PY
    info "Contraseña de administración del panel cambiada"
  elif git -C "$TLM_DIR" diff --quiet -- config.json 2>/dev/null; then
    warn "el panel usa la contraseña de administración por defecto: cámbiala en $TLM_DIR/config.json (\"systemPassword\") o vuelve a ejecutar el instalador con TLM_PASSWORD=..."
  fi

  if pm2 describe tetra-monitor >/dev/null 2>&1; then
    [ "$before" = "$after" ] || pm2 restart tetra-monitor
  else
    (cd "$TLM_DIR" && NODE_ENV=production pm2 start dist/index.cjs --name tetra-monitor --cwd "$TLM_DIR")
  fi
  pm2 save
  pm2 startup systemd -u root --hp /root >/dev/null
}

summary() {
  local ips host state
  ips=$(hostname -I 2>/dev/null | tr ' ' '\n' | grep -E '^[0-9]+\.' || true)
  host=$(hostname)
  state=$(systemctl is-active miurastation.service 2>/dev/null || true)
  say "MiuraStation $VERSION instalada"
  info "Configuración: $STATION_DIR/config.toml (nunca se sobrescribe)"
  info "Estado de la estación: $state"
  if [ "$state" != active ]; then
    info "Revisa config.toml (frecuencias, potencia, identidad de la red) y arranca con:"
    info "  sudo systemctl start miurastation"
  fi
  info "Registro: journalctl -u miurastation -f"
  if [ "$NO_MONITOR" != 1 ]; then
    info "Panel tetra-live-monitor:"
    for ip in $ips; do info "  http://$ip:5000"; done
    info "  http://$host.local:5000"
  fi
  info "Panel propio de la estación (con [dashboard] activado en config.toml): http://<IP>:8080"
  if [ "$REBOOT_NEEDED" = 1 ]; then
    printf '\n  *** Hay que REINICIAR la Raspberry Pi (sudo reboot) para cargar el overlay del SXceiver. ***\n'
  fi
  if [ ${#NOTES[@]} -gt 0 ]; then
    printf '\n  Avisos:\n'
    printf '  - %s\n' "${NOTES[@]}"
  fi
  printf '\n  MiuraStation es gratuito y solo para uso no comercial (ver /usr/share/doc/miurastation/NOTICE).\n\n'
}

main() {
  parse_args "$@"
  [ "$(id -u)" -eq 0 ] || die "hay que ejecutarlo como root: ... | sudo bash"
  exec < /dev/null
  touch "$LOG" && chmod 600 "$LOG"
  exec > >(tee -a "$LOG") 2>&1
  printf '\n##### %s install-miurastation.sh %s\n' "$(date -Is)" "$*"
  trap cleanup EXIT

  check_system
  install_base
  resolve_release
  detect_sdr
  install_soapysdr
  migrate_source_unit
  install_station
  if [ "$NO_MONITOR" = 1 ]; then info "Panel tetra-live-monitor omitido (--no-monitor)"; else install_monitor; fi
  summary
}

main "$@"
