#!/usr/bin/env bash
# Uninstalls MiuraStation (the miurastation .deb) from a Raspberry Pi or a PC.
#
#   curl -fsSL https://raw.githubusercontent.com/ea5gvk/MiuraStation-dist/main/contrib/install/uninstall-miurastation.sh | sudo bash
#   ... | sudo bash -s -- --yes
#
# Keeps /root/miurastation (config.toml, logs, caches), so a later install picks the configuration up
# again. Leaves the tetra-live-monitor panel, SoapySDR and the SDR module installed.
set -euo pipefail

STATION_DIR=/root/miurastation
YES=${MIURA_YES:-0}

die() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }

main() {
  while [ $# -gt 0 ]; do
    case "$1" in
      -y|--yes) YES=1; shift ;;
      -h|--help) echo "Uso: uninstall-miurastation.sh [--yes]"; exit 0 ;;
      *) die "opción desconocida: $1" ;;
    esac
  done
  [ "$(id -u)" -eq 0 ] || die "hay que ejecutarlo como root: ... | sudo bash"
  exec < /dev/null

  local state
  state=$(dpkg-query -W -f='${db:Status-Abbrev}' miurastation 2>/dev/null || true)
  if [ -z "$state" ] || [ "$state" = "un " ]; then
    echo "El paquete miurastation no está instalado."
  else
    if [ "$YES" != 1 ]; then
      local reply=""
      read -r -p "Se va a desinstalar MiuraStation ($STATION_DIR se conserva). ¿Seguir? [s/N] " reply < /dev/tty 2>/dev/null \
        || die "sin terminal para confirmar: ejecútalo con --yes"
      case "$reply" in s|S|si|SI|Si|sí|Sí|y|Y|yes|YES) ;; *) echo "Cancelado."; exit 0 ;; esac
    fi
    DEBIAN_FRONTEND=noninteractive apt-get purge -y miurastation
    echo "MiuraStation desinstalada."
  fi

  if [ -f /etc/systemd/system/miurastation.service ] && [ ! -L /etc/systemd/system/miurastation.service ]; then
    echo "Queda /etc/systemd/system/miurastation.service: es de una instalación desde el código fuente, no del paquete; no se toca."
  fi
  if [ -f "$STATION_DIR/config.toml" ]; then
    echo "Se conserva la configuración: $STATION_DIR/config.toml (y el resto de $STATION_DIR)."
  fi
  echo "El panel tetra-live-monitor sigue instalado. Para quitarlo: pm2 delete tetra-monitor && pm2 save && rm -rf /opt/tetra-live-monitor"
}

main "$@"
