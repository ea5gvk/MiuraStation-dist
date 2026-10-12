<p align="center"><img src="assets/miurastation-logo.png" alt="MiuraStation" width="240"></p>

<div align="center">

# MiuraStation

### Estación base TETRA por software, escrita en Rust, que funciona en una Raspberry Pi.

[![Licencia](https://img.shields.io/badge/licencia-Apache%202.0%20%2B%20PolyForm--NC-blue.svg)](#licencia--license)
[![Uso](https://img.shields.io/badge/uso-no%20comercial-red.svg)](#licencia--license)
[![Rust](https://img.shields.io/badge/hecho%20con-Rust-orange.svg)](https://www.rust-lang.org)

**[Instalación](#instalación) · [PC](#instalar-en-un-pc-debian--ubuntu-amd64) · [Configuración](#configuración) · [Panel web](#panel-web) · [Preguntas frecuentes](#preguntas-frecuentes) · [Novedades](CHANGELOG.md) · [Créditos](#créditos) · [Incidencias](https://github.com/ea5gvk/MiuraStation-dist/issues) · [English summary](#english-summary)**

</div>

---

Este repositorio es la **distribución binaria** de MiuraStation: los paquetes
listos para instalar (en [Releases](https://github.com/ea5gvk/MiuraStation-dist/releases)),
el instalador, la configuración de ejemplo, el registro de cambios y las
licencias. El código fuente de MiuraStation no se publica.

> **Solo uso no comercial.** MiuraStation es gratuito y se distribuye solo en
> forma binaria. Incluye componentes de Nexus-BS con licencia PolyForm
> Noncommercial 1.0.0, así que solo puede usarse con fines no comerciales:
> radioafición, hobby, investigación, enseñanza y organismos públicos o sin
> ánimo de lucro, sí; vender equipos o dar servicios de pago con MiuraStation,
> no. Ver [Licencia](#licencia--license).

---

## ¿Qué es MiuraStation?

MiuraStation es una **estación base TETRA completa hecha por software**. Con una
Raspberry Pi (o un PC con Debian o Ubuntu, aún sin probar en el aire), una SDR
(SXceiver o LimeSDR) y tus radios TETRA tienes una célula TETRA privada:
llamadas de grupo e individuales, mensajes SDS, interconexión con Brew
(TetraPack / BrandMeister), datos por paquetes con pasarela WAP, varias
portadoras y un panel web en directo. No hace falta infraestructura propietaria.

La desarrollan **Joaquin EA5GVK**, **Rafa EA7KEN** e **Iñaki EA8DJI**. Está
basada en FlowStation, de Răzvan Zeceș YO6RZV, que a su vez parte de BlueStation
(Wouter Bokslag / Midnight Blue), e incluye componentes de Nexus-BS (Chris
YO3TCO). Ver [Créditos](#créditos).

**Equipos probados:** LimeSDR Mini 2.0 · SXceiver · Motorola MXP600 · Motorola
MTM800E · Motorola MTM5400 · Sepura SRP2000

Junto a la estación, el instalador pone el panel
[tetra-live-monitor](https://github.com/ea5gvk/tetra-live-monitor) (puerto 5000):
monitor en directo, editor de configuración y actualizaciones.

El detalle de cada versión está en el [registro de cambios](CHANGELOG.md).

---

## Funciones

✅ disponible · 🔜 en preparación

### Voz y llamadas
| Función | Estado |
|---|---|
| Llamadas de grupo locales y por Brew (TetraPack / BrandMeister) | ✅ |
| Llamadas individuales dúplex (P2P), locales y por Brew | ✅ |
| Llamadas individuales semidúplex (PTT símplex) con hangtime | ✅ |
| Hangtime de grupo configurable | ✅ |
| Duración máxima de llamada con D-RELEASE forzado | ✅ |
| Detección de inactividad de subida (TX-CEASED forzado) | ✅ |
| Loro: eco privado que reproduce lo que dices | ✅ |
| Prioridad de emergencia (una llamada prioritaria desaloja a otra si la célula está llena) | ✅ |
| Portadora secundaria, portadoras extra (tercera y siguientes) y portadoras bajo demanda | ✅ |
| Traspaso coordinado | 🔜 |

### Mensajes y datos
| Función | Estado |
|---|---|
| SDS locales y por Brew | ✅ |
| Cola de difusión SDS en directo (a todas las radios, con repetición) | ✅ |
| Home Mode Display (texto en la pantalla de la radio, PID 220) | ✅ |
| Difusión SDS suplementaria (PID propio) | ✅ |
| Alarma de emergencia (U-STATUS): aviso fijo en el panel y alerta por Telegram | ✅ |
| Datos por paquetes SNDCP: por el MCCH, por PDCH de hasta 4 slots o por una portadora de datos | ✅ |
| Pasarela WAP: webs en XHTML-MP, el tiempo (Open-Meteo) y radioid.net en la radio | ✅ |

### Red e interconexión
| Función | Estado |
|---|---|
| Interconexión Brew / TetraPack / BrandMeister | ✅ |
| Hora UTC por el aire (D-NWRK-BROADCAST) | ✅ |
| Difusión de células vecinas | ✅ |
| Rerregistro periódico T351 | ✅ |
| DAPNET, avisos en teléfonos Snom, GeoAlarm y disparador TPG2200 (ver [Integraciones](#integraciones)) | ✅ |

### Seguridad y control de acceso
| Función | Estado |
|---|---|
| Lista blanca de ISSI | ✅ |
| Rangos de SSI locales (tráfico solo local) | ✅ |
| Autenticación (TEA) / cifrado AIE | 🔜 |

### Gestión y panel web
| Función | Estado |
|---|---|
| Panel web (radios, llamadas, últimos oídos, log, configuración, sistema, salud) | ✅ |
| Acceso con usuario y contraseña | ✅ |
| Visor de timeslots en directo | ✅ |
| Expulsar terminal / enviar SDS desde el panel | ✅ |
| DGNA: asignar o quitar un grupo a una radio por el aire | ✅ |
| Editor de configuración con copias de seguridad y perfiles | ✅ |
| Configuración de reserva si la principal tiene un error | ✅ |
| Control remoto desde la radio por U-STATUS (reiniciar, apagar, expulsar, `ip`, `info`…) | ✅ |
| Actualización con un botón: descarga el `.deb`, lo comprueba con `SHA256SUMS`, lo instala y reinicia | ✅ |
| Vigilancia de systemd (reinicio si el núcleo se cuelga) | ✅ |

---

## Hardware

| Equipo | Sistema | Estado |
|---|---|---|
| Raspberry Pi 5 | Raspberry Pi OS 64 bits, Bookworm o Trixie | Probada (estación de referencia) |
| Raspberry Pi 4 / 400 / CM4 | Raspberry Pi OS 64 bits, Bookworm o Trixie | Soportada |
| Raspberry Pi 3 B / B+ | Raspberry Pi OS 64 bits, Bookworm o Trixie | Solo **una portadora** hasta que se pruebe en campo |
| PC de 64 bits (amd64) | Debian 12 / 13 o Ubuntu 22.04 / 24.04 | **Sin probar en el aire** (ver [Instalar en un PC](#instalar-en-un-pc-debian--ubuntu-amd64)) |

- En la Raspberry Pi hace falta el sistema de **64 bits** (arm64). Para el de 32
  bits (armhf) todavía no hay paquete; Pi 1, Pi 2 y Pi Zero no están soportadas.
- SDR: **SXceiver** (HAT de la Raspberry Pi, módulo SoapySX) o **LimeSDR**
  (módulo LimeSuite de SoapySDR); la LimeSDR Mini 2.0 está probada. Otras SDR
  con módulo SoapySDR pueden funcionar.
- En una Pi 3 usa una sola portadora (sin `extra_carriers` ni portadora de
  datos), refrigeración y el registro en nivel INFO.

---

## Instalación

En la Raspberry Pi, con Internet (en un PC, ver
[Instalar en un PC](#instalar-en-un-pc-debian--ubuntu-amd64)):

```bash
curl -fsSL https://raw.githubusercontent.com/ea5gvk/MiuraStation-dist/main/contrib/install/install-miurastation.sh | sudo bash
```

Opciones (detrás de `sudo bash -s --`) o variables de entorno:

| Opción | Variable | Qué hace |
|---|---|---|
| `--version vX.Y.Z` | `MIURA_VERSION` | Instala esa versión en vez de la última estable |
| `--beta` | `MIURA_CHANNEL=beta` | La versión más reciente, betas incluidas |
| `--sdr sx\|lime\|none` | `MIURA_SDR` | Módulo de la SDR (por defecto se detecta; en un PC, `lime`) |
| `--no-monitor` | `MIURA_NO_MONITOR=1` | No instala el panel tetra-live-monitor |
| `--yes` | `MIURA_YES=1` | No pregunta nada |
| | `TLM_PASSWORD` | Contraseña de administración del panel |
| | `TLM_BRANCH` | Rama de tetra-live-monitor (por defecto `main`) |

Por ejemplo: `curl -fsSL …/install-miurastation.sh | sudo bash -s -- --version v1.2.0 --sdr sx`

El instalador:

1. comprueba el sistema (arm64 con Bookworm o Trixie, o un PC amd64 con
   Debian 12/13 o Ubuntu 22.04/24.04), la red y el espacio libre;
2. instala SoapySDR y el módulo de la SDR (SoapySX se compila desde
   [tejeez/sxxcvr](https://github.com/tejeez/sxxcvr); si el SXceiver no tiene
   EEPROM, añade el overlay y el SPI a `config.txt` y avisa de que hay que
   reiniciar);
3. descarga el `.deb` de su arquitectura y `SHA256SUMS` de la versión,
   comprueba la suma e instala el paquete;
4. instala o actualiza el panel tetra-live-monitor (Node.js, pm2) en
   `/opt/tetra-live-monitor`;
5. muestra la dirección del panel. Registro: `/var/log/miurastation-install.log`.

La primera instalación **no arranca la estación**. Edita
`/root/miurastation/config.toml` (como mínimo las frecuencias, `mcc` y `mnc`;
ver [Configuración](#configuración); también se puede hacer desde el panel) y
arráncala:

```bash
sudo systemctl start miurastation
journalctl -u miurastation -f
```

| Ruta | Contenido |
|---|---|
| `/usr/bin/miurastation` | Programa |
| `/root/miurastation/config.toml` | Configuración (se crea en la primera instalación y nunca se sobrescribe) |
| `/root/miurastation/` | Registros y cachés de la estación |
| `/usr/share/miurastation/example_config/config.toml` | Plantilla de la versión instalada |
| `/lib/systemd/system/miurastation.service` | Servicio, con la vigilancia de systemd (cambios locales en `/etc/systemd/system/miurastation.service.d/`) |
| `/usr/share/doc/miurastation/` | Licencias, avisos y `THIRD-PARTY-LICENSES` |

`miurastation --version` muestra la versión (`MiuraStation v1.3.0-<commit>`) y
`miurastation --license` muestra `NOTICE`, las licencias PolyForm Noncommercial
1.0.0 y Apache 2.0, y dónde están los demás avisos.

### Instalar en un PC (Debian / Ubuntu, amd64)

> **Todavía no se ha probado en el aire.** En cada versión, el paquete de PC se
> instala en Debian 12 y 13 y en Ubuntu 22.04 y 24.04, arranca y encuentra sus
> bibliotecas, pero nadie lo ha probado aún transmitiendo con radios. Si lo
> pruebas, cuéntanos cómo va en las
> [incidencias](https://github.com/ea5gvk/MiuraStation-dist/issues).

Requisitos:

- Un PC de 64 bits (x86-64, amd64) con **Debian 12 (Bookworm) o 13 (Trixie)**, o
  con **Ubuntu 22.04 o 24.04** (con el componente `universe`, activado por
  defecto). Ubuntu 20.04 y Debian 11 no sirven: no tienen SoapySDR 0.8.
- Una SDR USB con módulo SoapySDR, por ejemplo la **LimeSDR Mini 2.0** (la
  probada en la Raspberry Pi), con el módulo LimeSuite de la distribución
  (`soapysdr0.8-module-lms7`). La LimeSDR Mini 2.0 necesita LimeSuite 22.09 o
  posterior: Debian 12/13 y Ubuntu 24.04 lo traen; Ubuntu 22.04 trae el 20.10,
  que no la reconoce. El SXceiver es un HAT de la Raspberry Pi y no sirve en un
  PC.

El mismo comando que en la Raspberry Pi:

```bash
curl -fsSL https://raw.githubusercontent.com/ea5gvk/MiuraStation-dist/main/contrib/install/install-miurastation.sh | sudo bash
```

En un PC el instalador se salta todo lo de la Raspberry Pi (HAT, overlay, SPI y
SoapySX), instala por defecto el módulo de la LimeSDR (`--sdr lime`; con
`--sdr none` no instala ninguno), el paquete `miurastation_X.Y.Z_amd64.deb` y el
panel tetra-live-monitor (con Node.js 22 de NodeSource si la distribución trae
uno anterior). Las rutas, la configuración, el servicio y el botón de
actualización del panel de la estación son los mismos que en la Raspberry Pi.

### Actualizar

Vuelve a ejecutar el instalador (el mismo comando): instala la última versión
estable, o la que pidas con `--version` / `--beta`, y actualiza el panel.
También se puede actualizar desde el panel tetra-live-monitor, o con el botón de
actualización del panel de la propia estación (puerto 8080), que descarga el
`.deb` más reciente de las releases, lo comprueba con `SHA256SUMS` antes de
instalarlo y nunca instala una versión anterior (con `update_channel = "beta"`
en la sección `[dashboard]` también instala las versiones de pruebas).
`config.toml` no se toca y la estación solo se reinicia si estaba en marcha.

A mano: descarga de [Releases](https://github.com/ea5gvk/MiuraStation-dist/releases)
el `.deb` y `SHA256SUMS`, y:

```bash
sha256sum -c --ignore-missing SHA256SUMS
sudo apt install ./miurastation_X.Y.Z_arm64.deb   # en un PC, miurastation_X.Y.Z_amd64.deb
```

Canales: **estable** = la última versión publicada (*latest*); **beta** = las
versiones marcadas como *pre-release*.

### Desinstalar

```bash
curl -fsSL https://raw.githubusercontent.com/ea5gvk/MiuraStation-dist/main/contrib/install/uninstall-miurastation.sh | sudo bash
```

Quita el paquete y conserva `/root/miurastation` (con `config.toml`). El panel,
SoapySDR y el módulo de la SDR siguen instalados.

### Descargas de cada versión

| Fichero | Contenido |
|---|---|
| `miurastation_X.Y.Z_arm64.deb` | Paquete para Raspberry Pi OS 64 bits |
| `miurastation-X.Y.Z-aarch64.tar.gz` | Programa para Raspberry Pi, configuración de ejemplo y licencias, sin instalador |
| `miurastation_X.Y.Z_amd64.deb` | Paquete para PC con Debian 12/13 o Ubuntu 22.04/24.04 (desde la v1.2.0) |
| `miurastation-X.Y.Z-x86_64.tar.gz` | Programa para PC, configuración de ejemplo y licencias, sin instalador |
| `SHA256SUMS` | Sumas SHA-256 de los anteriores |

Los paquetes no incluyen el códec ACELP de ETSI ni la telefonía Asterisk
SIP/RTPC.

---

## Configuración

La configuración está en `/root/miurastation/config.toml`. El fichero de
referencia, con todos los parámetros comentados, es
[`example_config/config.toml`](example_config/config.toml) (en la estación,
`/usr/share/miurastation/example_config/config.toml`). Aquí van los básicos.
Después de cambiar algo, reinicia la estación
(`sudo systemctl restart miurastation`).

### Obligatorio

```toml
[phy_io.soapysdr]
tx_freq = 438025000   # Frecuencia de bajada en Hz
rx_freq = 433025000   # Frecuencia de subida en Hz

[net_info]
mcc = 204             # Mobile Country Code
mnc = 1337            # Mobile Network Code

[cell_info]
freq_band = 4         # 4 = banda de 400 MHz
main_carrier = 1521
duplex_spacing = 4
location_area = 2
colour_code = 1
```

### Tiempos

| Parámetro | Por defecto | Descripción |
|---|---|---|
| `hangtime_secs` | `5` | Mantiene el circuito de grupo tras soltar el turno (0–300 s) |
| `call_timeout_secs` | `120` | Duración máxima de llamada antes de D-RELEASE (0 = sin límite) |
| `ul_inactivity_secs` | `3` | Silencio de subida antes de TX-CEASED forzado (1–30 s) |
| `periodic_registration_secs` | `3600` | Intervalo T351; `0` = desactivado |

Las llamadas individuales símplex tienen un hangtime de 13 s.

### Portadoras

Además de la portadora principal (`main_carrier`), la célula puede tener una
portadora secundaria y, con `extra_carriers`, una tercera y siguientes, con voz y
BCCH como la secundaria; cada portadora tiene su propio planificador y la
potencia de TX se reparte entre ellas. Con `secondary_carrier_on_demand` las
portadoras que no son la principal solo salen al aire mientras hacen falta (una
llamada o un PDCH en ellas, o la siguiente llamada va a ellas), con calentamiento
y apagado por inactividad; el panel muestra si están en el aire, calentando o
apagadas. Las claves y sus reglas están explicadas en la plantilla. En una
Raspberry Pi 3 usa una sola portadora.

### Interconexión Brew (TetraPack / BrandMeister)

```toml
[brew]
host = "brew.example.org"
port = 9000
tls = true
username = 123456700
password = "tu_contraseña"
```

La estación se presenta ante Brew, y ante los servidores de telemetría y de
control, como `MiuraStation/<versión>`.

### Control de acceso

```toml
[security]
issi_whitelist = [2260571, 2260572]   # Solo estos ISSI pueden registrarse
```

### Home Mode Display (texto en la pantalla de la radio)

```toml
[cell_info.home_mode_display]
text = "EA5GVK"
interval_multiframes = 96
protocol_id = 220
text_coding_scheme = "LATIN"
```

### Control remoto desde la radio (U-STATUS)

La radio envía un STATUS (no un SDS de texto) con el `status_code` configurado al
ISSI individual 9999. Usa códigos entre 32768 y 65535 (los ejemplos usan
33001-33012): el 0 es emergencia y 31744-32767 son acuses SDS-TL. Al arrancar,
la estación avisa si hay un código de estado que una radio no puede usar.

```toml
[cell_info.sds_command_control]
authorized_issis = [2260570, 2260571]

[[cell_info.sds_command_control.commands]]
status_code = 33001
action = "restart"

[[cell_info.sds_command_control.commands]]
status_code = 33012
action = "info"      # responde con 3 SDS: versión y salud, radio, equipo
```

Los comandos `info` e `ip` responden con la versión, la salud, los tiempos en
marcha, las portadoras, Brew, la IP local y la IP pública (consultada cada 10
minutos) y datos del equipo.

### Loro (eco privado)

```toml
[cell_info]
parrot_enabled = true
parrot_issi = 99999       # llama a este ISSI en símplex, habla y suelta el PTT
parrot_max_secs = 20
```

Se graba lo que dices y se reproduce al soltar el PTT. En el panel, el ISSI del
loro aparece como "Parrot".

### Datos por paquetes y pasarela WAP

Las secciones `[packet_data]` y `[wap]` están desactivadas por defecto.

- **Datos por paquetes (SNDCP).** Con `bearer = "mcch"` los datos van por el
  canal de control; con `bearer = "pdch"` van por canales de datos (PDCH) de la
  portadora principal, que la voz recupera cuando los necesita. Cada radio
  puede usar hasta `pdch_max_slots` slots (hasta 4, con una radio multislot).
  Con `pdch_carrier` los PDCH de hasta 4 slots van en una portadora sin MCCH
  (`pdch_carrier_timeslots`), y con `pdch_carrier_exclusive` esa portadora
  queda solo para datos. Incluye el enlace avanzado LLC (segmentación,
  reensamblado y acuse selectivo).
- **Pasarela WAP** para radios con navegador: páginas web convertidas a
  XHTML-MP paginado, descargas solo desde la red pública, páginas de inicio y de
  estado de la estación en español, **el tiempo** de cualquier lugar
  (Open-Meteo, en español) y **búsqueda de indicativos e ID DMR en
  radioid.net**.

La página de Salud del panel muestra las sesiones y dominios de la pasarela WAP,
y el panel los slots PDCH y la actividad de datos. Todos los parámetros están
explicados en la plantilla.

### Panel web y actualizaciones

El panel de la estación funciona cuando existe la sección `[dashboard]` (el
usuario, la contraseña y el resto de claves están en la plantilla). El botón de
actualización usa estas claves opcionales:

```toml
[dashboard]
update_repo = "ea5gvk/MiuraStation-dist"   # por defecto
update_channel = "stable"                  # "beta" también instala las pre-releases
```

### Configuración de reserva

Si MiuraStation no puede leer `config.toml` al arrancar (por ejemplo, tras una
mala edición desde el panel), usa `config.toml.fallback`. Créala una vez, cuando
la configuración funcione:

```bash
sudo cp /root/miurastation/config.toml /root/miurastation/config.toml.fallback
```

El panel muestra un aviso rojo con el error para que puedas arreglarlo a
distancia sin perder la célula.

---

## Integraciones

MiuraStation puede conectar TETRA con redes de mensáfonos y mandar avisos a
teléfonos de sobremesa, paneles y Telegram. DAPNET, los avisos en teléfonos
Snom, GeoAlarm y el disparador TPG2200 vienen en los paquetes: basta con
rellenar su sección (ver la plantilla). La telefonía Asterisk SIP/RTPC (el
puente de llamadas entre TETRA y teléfonos de Asterisk) **no** está en los
paquetes.

### Alertas por Telegram

La estación manda un mensaje a tu bot de Telegram cuando una radio se conecta,
se desconecta o deja de contestar al T351, cuando llega una posición LIP/APRS o
una emergencia, cuando cae o vuelve el enlace Brew, cuando cambia la salud de la
estación y cuando el log da un aviso o un error. Se configura en el menú
Telegram del panel (token de @BotFather y Chat ID) o en la sección
`[telegram_alerts]`. Desde la v1.3.0 los mensajes salen **en español**; para
recibirlos en inglés, elige *English* en ese menú o añade:

```toml
[telegram_alerts]
language = "en"   # "es" (por defecto) o "en"
```

### DAPNET

La recepción de DAPNET usa el núcleo RWTH (TCP 43434 de salida). Cada mensaje
puede ir a SDS normales, a Call-Out / SDS tipo 4 de Motorola TPG2200 y a
Telegram, según los mapas de RIC y las listas permitidas de la sección
`[dapnet]`. Con `rwth_core_device = "MiuraStation"` la estación se presenta así
ante el núcleo. No compartas `password` ni `rwth_core_authkey`.

### Disparador TPG2200 (ActionURL)

Un endpoint HTTP protegido con un token para que una tecla de un teléfono Snom
lance un Call-Out de Motorola TPG2200:

```text
http://<estación>:8080/api/action/tpg2200?token=<token>
http://<estación>:8080/api/action/tpg2200?token=<token>&text=ALARMA
```

### Avisos en teléfonos Snom

MiuraStation muestra SDS, mensajes DAPNET y de Telegram en teléfonos Snom como
`SnomIPPhoneText`, pidiendo a Asterisk por AMI que ejecute `PJSIPNotify`
(sección `[snom_notify]`, con `title_prefix = "MiuraStation"` por defecto).
`ami_username` no tiene valor por defecto y hay que ponerlo (la plantilla y el
panel proponen `miurastation`). Solo necesita el AMI de Asterisk, no el puente
SIP/RTP.

```bash
sudo apt install -y asterisk
sudo systemctl enable --now asterisk
sudo touch /etc/asterisk/pjsip_notify.conf
sudo asterisk -rx "module load res_pjsip_notify.so"
```

AMI en `/etc/asterisk/manager.conf`:

```ini
[general]
enabled = yes
webenabled = no
bindaddr = 127.0.0.1
port = 5038

[miurastation]
secret = cambia-esta-contraseña
read = system,call,log,verbose,command,agent,user
write = system,call,command,agent,user,originate
```

### GeoAlarm

GeoAlarm vigila las posiciones LIP de las radios. Cuando una radio permitida
entra en el radio configurado alrededor de la estación, puede lanzar un Call-Out
TPG2200, un SDS, un aviso Snom/SIP y un mensaje de Telegram:

```toml
[geoalarm]
enabled = true
station_lat = 38.3452
station_lon = -0.4810
radius_m = 500
cooldown_secs = 300
forward_sds = true
sds_dest_issi = 2260571
```

---

## Panel web

### Panel de la estación (puerto 8080)

Disponible en `http://<ip-de-la-estación>:8080` cuando existe la sección
`[dashboard]`.

- **Radios**: terminales registrados con ISSI, grupos, señal, ahorro de energía y
  última vez visto; botones para expulsar y mandar SDS; visor de timeslots.
- **Llamadas**: llamadas activas con origen, destino, duración y modo.
- **Últimos oídos**: historial de llamadas y SDS.
- **Log**: registro en directo con filtro por nivel.
- **Configuración**: editor de `config.toml` con copias de seguridad y perfiles.
- **Sistema**: estado de la estación y de Brew, tiempo en marcha, CPU, RAM,
  temperatura, SDR, cola de SDS y botón de actualización.
- **Salud**: estado de cada parte de la estación, pasarela WAP y datos por
  paquetes.

También muestra los slots PDCH, las portadoras extra y el estado de las
portadoras bajo demanda, y un aviso fijo cuando llega una alarma de emergencia.

### tetra-live-monitor (puerto 5000)

El instalador pone también
[tetra-live-monitor](https://github.com/ea5gvk/tetra-live-monitor) en
`/opt/tetra-live-monitor` (salvo con `--no-monitor`): monitor en directo, editor
de configuración y actualizaciones de MiuraStation. Al terminar, el instalador
muestra su dirección. Para fijar la contraseña de administración, ejecuta el
instalador con la variable `TLM_PASSWORD`
(`curl -fsSL …/install-miurastation.sh | sudo TLM_PASSWORD='…' bash`). Cada vez
que vuelves a ejecutar el instalador, el panel se actualiza.

---

## Preguntas frecuentes

**He instalado MiuraStation y no transmite.** La primera instalación no arranca
la estación. Edita `/root/miurastation/config.toml` (frecuencias, `mcc`, `mnc`)
y ejecuta `sudo systemctl start miurastation`. Mira el registro con
`journalctl -u miurastation -f`.

**¿Se pierde mi configuración al actualizar o desinstalar?** No. El paquete
nunca sobrescribe ni borra `/root/miurastation/config.toml`; la desinstalación
conserva `/root/miurastation`. La plantilla de cada versión queda en
`/usr/share/miurastation/example_config/config.toml` para comparar.

**He editado `config.toml` y la estación ya no arranca.** Si creaste
`config.toml.fallback`, la estación arranca con ella y el panel muestra un aviso
rojo con el error de `config.toml`. Si no, `journalctl -u miurastation -f`
muestra el error.

**El instalador dice que hay que reiniciar.** Un SXceiver sin EEPROM necesita el
overlay y el SPI en `config.txt`; el instalador los añade, pero solo se aplican
tras reiniciar la Raspberry Pi.

**¿Cómo instalo una versión concreta o una beta?** Con
`sudo bash -s -- --version vX.Y.Z` o `--beta` detrás del comando de instalación,
o con `update_channel = "beta"` en `[dashboard]` para el botón del panel. El
botón del panel nunca instala una versión anterior.

**¿Funciona en una Raspberry Pi 3 o con un sistema de 32 bits?** En una Pi 3,
con una sola portadora hasta que se pruebe en campo. El sistema de 32 bits
(armhf) todavía no tiene paquete.

**¿Funciona en un PC?** Desde la v1.2.0 hay paquete amd64 para Debian 12/13 y
Ubuntu 22.04/24.04 con una SDR USB como la LimeSDR Mini 2.0, pero todavía no se
ha probado en el aire. Ver [Instalar en un PC](#instalar-en-un-pc-debian--ubuntu-amd64).

**El control remoto desde la radio no hace nada.** La radio tiene que mandar un
STATUS (no un SDS de texto) al ISSI 9999, desde un ISSI de `authorized_issis`,
con un código entre 32768 y 65535. Al arrancar, la estación avisa de los códigos
que una radio no puede usar.

**¿Puedo usar la telefonía Asterisk SIP/RTPC?** No con estos paquetes: no
incluyen el puente SIP/RTP ni el códec ACELP. Los avisos en teléfonos Snom sí
funcionan (solo necesitan el AMI de Asterisk).

**¿Qué versión tengo?** `miurastation --version`. Las licencias y avisos, con
`miurastation --license`.

**¿Dónde informo de un fallo?** En las
[incidencias de este repositorio](https://github.com/ea5gvk/MiuraStation-dist/issues),
con la versión y el registro (`journalctl -u miurastation`).

---

## Créditos

MiuraStation la desarrollan **Joaquin EA5GVK**, **Rafa EA7KEN** e
**Iñaki EA8DJI**. Es un proyecto independiente, construido sobre el trabajo de
otros (no está avalado por sus autores). Nuestro agradecimiento a:

- **Răzvan Zeceș YO6RZV** por **FlowStation**, la base directa de MiuraStation
  (Apache 2.0). https://github.com/razvanzeces/flowstation
- **Wouter Bokslag / Midnight Blue** por **BlueStation** (tetra-bluestation), la
  pila TETRA en Rust de la que parten FlowStation y MiuraStation, el origen de
  todo (Apache 2.0). https://github.com/MidnightBlueLabs/tetra-bluestation
- **Chris YO3TCO** por **Nexus-BS** y por permitirnos usar su código: loro,
  pasarela WAP, datos por paquetes (SNDCP), enlace avanzado LLC y canales de
  varios slots (PolyForm Noncommercial 1.0.0).
  https://github.com/invictus737/nexus-bs

  Required Notice: Copyright (c) Chris YO3TCO / Nexus-BS Project.
- **Mihajlo YU4MSH (misadeks)** por las llamadas dúplex P2P, Home Mode Display
  y DGNA; **Torben DJ2TH** por DAPNET, la telefonía Asterisk SIP/RTPC, los
  avisos en teléfonos Snom y GeoAlarm; **M0UPM** y el resto de contribuidores de
  FlowStation y BlueStation.
- **Harald Welte y el equipo de osmocom** por osmocom-tetra; **Tatu Peltola** por
  rust-soapysdr, el codificador/decodificador Viterbi en Rust y SXCEIVER;
  **Stichting NLnet** por financiar en parte BlueStation con la subvención
  RETETRA3; **Dennis DB2OE** por la inspiración del tema del panel.
- La comunidad que prueba y reporta fallos: ON6RF, BU2GQ, DK5RTA, DO5MF, ES4TIX
  y muchos más.

La lista completa está en [CREDITS.md](CREDITS.md) y [NOTICE](NOTICE).

---

## Licencia / License

- [LICENSE](LICENSE): Apache License 2.0 (MiuraStation, FlowStation, BlueStation).
- [LICENSES/PolyForm-Noncommercial-1.0.0.txt](LICENSES/PolyForm-Noncommercial-1.0.0.txt):
  los ficheros de Nexus-BS; [LICENSES/Nexus-BS-LICENSE-OVERVIEW.md](LICENSES/Nexus-BS-LICENSE-OVERVIEW.md)
  y [CHANGES-NEXUS.md](CHANGES-NEXUS.md).
- [NOTICE](NOTICE): origen, avisos de modificación y lista de componentes de Nexus-BS.
- [THIRD-PARTY-LICENSES](THIRD-PARTY-LICENSES) (dentro de cada paquete; aquí, el
  de la última versión estable): licencias de las bibliotecas de Rust enlazadas
  en el programa.

MiuraStation se distribuye bajo **Apache 2.0**, salvo los componentes de
Nexus-BS (Chris YO3TCO), que se usan con su permiso y son **solo para uso no
comercial** (PolyForm Noncommercial 1.0.0). Van incluidos en todos los binarios,
así que **MiuraStation no puede usarse con fines comerciales**. MiuraStation no
es software de código abierto: es una distribución binaria gratuita para uso no
comercial. Las condiciones de uso y de redistribución son las de estos ficheros.

MiuraStation is distributed under **Apache 2.0**, except for the Nexus-BS
components (Chris YO3TCO): they are used with his permission, are
**noncommercial only** (PolyForm Noncommercial 1.0.0) and are built into every
binary, so MiuraStation may be used for noncommercial purposes only. It is not
open source: it is a free binary distribution for noncommercial use.

---

## English summary

**MiuraStation** is a software-defined TETRA base station written in Rust that
runs on a Raspberry Pi with an SXceiver or LimeSDR (and, not yet tested on air,
on a PC with a LimeSDR): group and individual calls (full duplex and simplex),
SDS, Home Mode Display and emergency alarms, Brew interconnect (TetraPack /
BrandMeister), packet data (SNDCP over the MCCH or over packet-data channels of
up to 4 slots, also on a dedicated packet-data carrier) with a WAP gateway
(weather and radioid.net lookups on the radio), dual, extra and on-demand
carriers, a parrot (echo) service, SDS remote control with station info, DAPNET,
Snom notifications, GeoAlarm, Telegram alerts (in Spanish by default,
`language = "en"` in `[telegram_alerts]` for English), the systemd watchdog and a
live web dashboard (port 8080). Tested with LimeSDR Mini 2.0, SXceiver, Motorola MXP600, MTM800E,
MTM5400 and Sepura SRP2000.

It is developed by **Joaquin EA5GVK**, **Rafa EA7KEN** and **Iñaki EA8DJI**. It
is based on FlowStation by Răzvan Zeceș YO6RZV, which builds on BlueStation by
Wouter Bokslag / Midnight Blue, and includes Nexus-BS components by Chris YO3TCO
(PolyForm Noncommercial 1.0.0). This repository is its **binary distribution**:
packages in Releases, the installer, the example configuration, the changelog
and the licences. The source code is not published. **Free for noncommercial use
only**; it is not open source.

- **Hardware:** Raspberry Pi 5, 4/400/CM4 and 3 B/B+ with **64-bit** Raspberry
  Pi OS Bookworm or Trixie (Pi 3: single carrier only until field-tested);
  SXceiver or LimeSDR.
- **PC (amd64)**, since v1.2.0: Debian 12/13 or Ubuntu 22.04/24.04 with a USB
  SDR through SoapySDR, such as the LimeSDR Mini 2.0 (it needs LimeSuite 22.09 or
  later: Debian 12/13 or Ubuntu 24.04). Same one-line installer, which skips the
  Raspberry Pi parts and defaults to `--sdr lime` there. The PC build installs,
  starts and finds its libraries, but it **has not been tested on air yet**.
- **Install / update** (run it again to update):
  `curl -fsSL https://raw.githubusercontent.com/ea5gvk/MiuraStation-dist/main/contrib/install/install-miurastation.sh | sudo bash`
  — options `--version vX.Y.Z`, `--beta`, `--sdr sx|lime|none`, `--no-monitor`, `--yes`.
  It installs SoapySDR and the SDR module, the verified `.deb` of the machine's
  architecture (`arm64` or `amd64`) and the tetra-live-monitor panel (port
  5000). The first install does not start the station: edit `/root/miurastation/config.toml` (frequencies, `mcc`, `mnc`) and
  `sudo systemctl start miurastation`. The station's dashboard and
  tetra-live-monitor can also update it; `config.toml` is never overwritten.
- **Configuration:** the fully commented reference is
  [`example_config/config.toml`](example_config/config.toml). Asterisk SIP/PSTN
  telephony and the ETSI ACELP codec are not included in the packages.
- **Uninstall:** `.../contrib/install/uninstall-miurastation.sh | sudo bash`
  (keeps `/root/miurastation/config.toml`).
- **Licences:** LICENSE (Apache 2.0), NOTICE, LICENSES/ (PolyForm Noncommercial
  1.0.0 and the Nexus-BS overview), CHANGES-NEXUS.md, CREDITS.md, and
  THIRD-PARTY-LICENSES inside every package. Changes: [CHANGELOG.md](CHANGELOG.md).
  Bug reports: [GitHub issues](https://github.com/ea5gvk/MiuraStation-dist/issues).
