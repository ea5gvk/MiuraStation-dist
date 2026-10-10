# Changelog

Todos los cambios importantes de MiuraStation se anotan en este fichero.
All notable changes to MiuraStation are documented in this file.

El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y
la numeración sigue [Semantic Versioning](https://semver.org/lang/es/).

## [1.2.0] - 2026-10-10

MiuraStation se publica también para PC: paquetes `.deb` amd64 para Debian 12/13
y Ubuntu 22.04/24.04, con una SDR USB por SoapySDR y el mismo instalador de una
línea que en la Raspberry Pi. El paquete de PC se instala, arranca y encuentra
sus bibliotecas, pero **todavía no se ha probado en el aire**.

*English summary: MiuraStation is now also published for a PC: amd64 `.deb`
packages and tarballs for Debian 12/13 and Ubuntu 22.04/24.04 with a USB SDR
through SoapySDR (such as the LimeSDR Mini 2.0), set up by the same one-line
installer. The PC build installs, starts and finds its libraries, but it has not
been tested on air yet. The Raspberry Pi (arm64) packages are unchanged.*

### Añadido

- **Paquetes para PC (amd64)**: cada release publica también
  `miurastation_X.Y.Z_amd64.deb` y `miurastation-X.Y.Z-x86_64.tar.gz`, junto a
  los de arm64, y un solo `SHA256SUMS` para los cuatro ficheros. El paquete de
  PC tiene el mismo contenido, rutas y dependencias que el de la Raspberry Pi
  (`libsoapysdr0.8` de la distribución). Antes de publicar, cada versión se
  instala con `apt` en Debian 12 y 13 y Ubuntu 22.04 y 24.04 y se comprueba que
  arranca.
- **Instalador en un PC**: `install-miurastation.sh` acepta un PC amd64 con
  Debian 12/13 o Ubuntu 22.04/24.04. Se salta todo lo de la Raspberry Pi (HAT,
  overlay, SPI y SoapySX), instala por defecto el módulo LimeSuite de SoapySDR
  (`--sdr lime`; `--sdr none` no instala ninguno) y avisa de que Ubuntu 22.04
  trae un LimeSuite (20.10) que no reconoce la LimeSDR Mini 2.0. El panel
  tetra-live-monitor se instala como en la Raspberry Pi.
- La actualización desde el panel de la estación instala el `.deb` de su
  arquitectura: arm64 en la Raspberry Pi, amd64 en un PC.

### Cambiado

- El instalador busca el `.deb` de su arquitectura en `SHA256SUMS` antes de
  descargarlo: una versión sin paquete para ella se detiene con un aviso claro.
- El `.deb` incluye el logo en `/usr/share/doc/miurastation/assets/`, para la
  imagen del README.
- Las notas de cada release enumeran los ficheros de las dos arquitecturas.

## [1.1.0] - 2026-10-10

MiuraStation se distribuye desde esta versión solo en binario: paquetes `.deb`
para Raspberry Pi en https://github.com/ea5gvk/MiuraStation-dist, con un
instalador de una línea y actualización desde el panel. Los bloques de
codificación de la capa MAC inferior se han reescrito desde las normas ETSI.

*English summary: binary-only distribution from now on: arm64 `.deb` packages and
tarballs for the Raspberry Pi in ea5gvk/MiuraStation-dist, a one-line installer,
dashboard updates from those releases, `--license` and the Nexus-BS Required
Notice in the banner. The lower MAC coding blocks are a clean-room rewrite from
the ETSI standards, bit for bit the same on air as v1.0.0.*

### Añadido

- **Releases binarias** en https://github.com/ea5gvk/MiuraStation-dist, una por
  etiqueta `vX.Y.Z` que no se reemplaza nunca: `miurastation_X.Y.Z_arm64.deb`,
  `miurastation-X.Y.Z-aarch64.tar.gz` (binario, plantilla de configuración y
  todas las licencias) y `SHA256SUMS`. Las pre-releases son el canal beta. Solo
  arm64 (Raspberry Pi 3/4/5 con Raspberry Pi OS de 64 bits, Bookworm o Trixie).
- **Paquete `.deb`**: `/usr/bin/miurastation`, la plantilla en
  `/usr/share/miurastation/example_config/config.toml`, la unidad
  `/lib/systemd/system/miurastation.service` (con la vigilancia de systemd) y
  las licencias en `/usr/share/doc/miurastation/`. La estación sigue en
  `/root/miurastation`: la primera instalación copia la plantilla a
  `config.toml` solo si no existe, y el paquete nunca sobrescribe ni borra
  `config.toml`. La primera instalación no arranca la estación; una
  actualización la reinicia solo si estaba en marcha.
- **Instalador** `contrib/install/install-miurastation.sh` (una línea con
  `curl ... | sudo bash`): instala el `.deb` de la release comprobando su
  SHA-256, el módulo SoapySDR del SDR (SoapySX para el SXceiver, LimeSuite) y
  el panel tetra-live-monitor. Admite `--version`, `--beta`, `--no-monitor` y
  `--sdr`. `uninstall-miurastation.sh` quita el paquete y conserva
  `/root/miurastation`.
- **Actualización desde el panel en instalaciones con paquete**: el botón de
  actualizar descarga el `.deb` más reciente de las releases, lo comprueba con
  `SHA256SUMS`, lo instala con `apt-get` y reinicia la estación. Nunca instala
  una versión anterior. Claves nuevas opcionales en `[dashboard]`:
  `update_repo` (por defecto `ea5gvk/MiuraStation-dist`) y `update_channel`
  (`stable` o `beta`). Las instalaciones compiladas siguen con git + cargo.
- `miurastation --license` muestra `NOTICE`, el texto de la licencia PolyForm
  Noncommercial 1.0.0 y el de Apache-2.0, y dónde están los demás avisos.
- `THIRD-PARTY-LICENSES`: licencias y avisos de todas las bibliotecas Rust
  incluidas en el binario, generado con cargo-about en cada release.

### Cambiado

- **Reescritura en sala limpia** de los bloques de codificación de la capa MAC
  inferior (CRC-16, aleatorizado, entrelazado, Reed-Muller (30,14), código
  convolucional y perforado, reordenado TCH/S, parámetros de codificación,
  Viterbi de BSCH/AACH, montaje de ráfagas y ajuste de fase, canales
  obligatorios BSCH/BNCH/CLCH y separación dúplex), hecha solo a partir de
  ETSI EN 300 392-2, EN 300 395-2 y TS 100 392-15. Lo que sale al aire es bit a
  bit igual que en la v1.0.0 (comprobado con 419 vectores de referencia
  grabados de esa versión).
- El arranque muestra la línea
  `Required Notice: Copyright (c) Chris YO3TCO / Nexus-BS Project.` y la URL de
  la licencia PolyForm.
- Referencias al repositorio: los enlaces para usuarios (banner, ayuda, pie del
  panel, unidad de systemd, `NOTICE`, `CHANGES-NEXUS.md`, plantilla de
  configuración, avisos de actualización) apuntan a
  https://github.com/ea5gvk/MiuraStation-dist. El código fuente es privado.
- La versión del binario (`MiuraStation v1.1.0-<commit>`) lleva el commit del
  código también en las compilaciones de la CI.

### Corregido

- Un bloque recibido más corto de lo esperado se descarta con un aviso en vez de
  hacer caer la estación.

## [1.0.0] - 2026-10-07

Primera versión de MiuraStation como proyecto propio. Parte de FlowStation, de
Răzvan Zeceș YO6RZV (estado del 24-07-2026), a quien agradecemos la base sobre la
que está hecho todo esto (ver `CREDITS.md` y `NOTICE`). Aquí se resume lo que
MiuraStation añade sobre esa base. MiuraStation parte de la rama `miura` del
fork ea5gvk/flowstation en el commit ed2b244; esa rama ya no está publicada.

*English summary: first release of MiuraStation as its own project. On top of its
base it adds packet data for TETRA radios (SNDCP over the MCCH or over packet-data
channels of up to 4 slots, also on a dedicated packet-data carrier), a WAP gateway
with weather and radioid.net lookups, a third and further carriers, carriers on
the air on demand, the parrot (echo) service, SDS command control with station
info, the systemd watchdog and a long list of ETSI conformance and field fixes.*

### Añadido

- **Datos por paquetes (SNDCP)** para terminales TETRA (sección `[packet_data]`,
  desactivada por defecto):
  - portador por el MCCH (`bearer = "mcch"`) o por canales de datos (PDCH) de la
    portadora principal (`bearer = "pdch"`), que la voz recupera cuando los
    necesita;
  - **canales multislot** de hasta 4 slots por radio (`pdch_max_slots`), con
    concesiones de subida contadas sobre todos los slots del canal, reensamblado
    de fragmentos entre slots y guarda semidúplex para radios sin conmutación
    rápida;
  - **portadora de datos** (`pdch_carrier`, `pdch_carrier_timeslots`,
    `pdch_carrier_exclusive`): PDCH de hasta 4 slots en una portadora sin MCCH,
    o una portadora solo para datos;
  - **enlace avanzado LLC** (AL-SETUP, AL-DATA / AL-FINAL, AL-ACK / AL-RNR) con
    segmentación, reensamblado y acuse selectivo.
- **Pasarela WAP** para radios con navegador (sección `[wap]`): sesiones
  WTP/WSP con segmentación, páginas web convertidas a XHTML-MP paginado,
  descargas con política de red solo pública, páginas de inicio y de estado de
  la estación en español, **el tiempo** de cualquier lugar (Open-Meteo, en
  español) y **búsqueda de indicativos e ID DMR en radioid.net**. Incluye un
  portador UDP de depuración y `contrib/wap-debug/wtp_client.py`.
- **Más de dos portadoras**: `extra_carriers` añade una tercera portadora y
  siguientes (voz y BCCH como la secundaria), con un planificador por portadora,
  reglas de copia del enlace de subida entre portadoras y reparto de potencia de
  TX por portadora.
- **Portadoras bajo demanda** (`secondary_carrier_on_demand`): las portadoras
  que no son la principal solo salen al aire mientras hacen falta (una llamada o
  un PDCH en ellas, o la siguiente llamada va a ellas), con calentamiento y
  apagado por inactividad; el panel muestra si están en el aire, calentando o
  apagadas.
- **Loro** (servicio de eco privado: `parrot_enabled`, `parrot_issi`,
  `parrot_max_secs`): llamada privada símplex al ISSI del loro, se graba lo que
  dices y se reproduce al soltar el PTT.
- **Control por SDS ampliado**: los comandos `info` e `ip` responden con la
  versión, la salud, los tiempos en marcha, las portadoras, Brew, la IP local y
  la IP pública (consultada cada 10 minutos) y datos del equipo; ejemplos en
  los códigos 33001-33012 enviados como STATUS al 9999; aviso al arrancar de un
  código de estado que una radio no puede usar.
- **Vigilancia de systemd** (`Type=notify` + `WatchdogSec`): READY y WATCHDOG
  desde el tic del núcleo, para que systemd reinicie la estación si el bucle
  principal se cuelga; la actualización OTA compila protegida por la vigilancia.
- **Panel web**: sesiones y dominios de la pasarela WAP en la página de Salud,
  slots PDCH y actividad de datos, portadoras extra y portadoras bajo demanda,
  el ISSI del loro etiquetado como "Parrot".
- Hangtime de 13 s para llamadas individuales símplex.
- Registro de salud: el estado del enlace Brew llega desde la entidad Brew.

### Cambiado

- Nombre del producto, binario y servicio: **MiuraStation**, binario
  `miurastation`, servicio `miurastation.service`, instalación en
  `/root/miurastation`, paquete `.deb` `miurastation`.
- Versión propia: `MiuraStation v1.0.0-<commit>` en el arranque, el panel, las
  respuestas SDS y las páginas WAP.
- User-Agent de Brew, de telemetría y de control: `MiuraStation/<versión>`.
  Los subprotocolos `bluestation-telemetry-v2` y `bluestation-control-v1` no
  cambian.
- Marcador de vigilancia en el binario: `miurastation-sd-notify-v1`.
- `[geoalarm]`: la posición de la estación es `station_lat` / `station_lon`
  (se siguen aceptando las claves antiguas de configuraciones anteriores).
- Usuarios por defecto de Asterisk (`local_user`, `auth_user`):
  `miurastation`. Si tu Asterisk usa el nombre antiguo, ponlo de forma
  explícita en `config.toml` o cambia `pjsip.conf`. `ami_username` no tiene
  valor por defecto (el ejemplo y el panel proponen `miurastation`).
- Variables de entorno: `MIURASTATION_SERVICE_UNIT` y `MIURASTATION_PANIC_FATAL`.
- Unidad de reserva por defecto: `miurastation.service`.
- La actualización OTA y el aviso de actualización siguen la rama que está
  descargada.
- Un grupo grande en un attach se confirma entero, con un PDU de ACK por cada
  trozo de hasta 12 grupos (sin techo de grupos).
- Licencias declaradas en los metadatos: `Apache-2.0` y, en los crates y
  binarios que incluyen ficheros de Nexus-BS,
  `Apache-2.0 AND PolyForm-Noncommercial-1.0.0`. El `.deb` incluye `LICENSE`,
  `NOTICE`, `CREDITS.md`, `CHANGES-NEXUS.md` y el texto PolyForm.

### Corregido

- Conformidad ETSI (EN 300 392-2) y fallos de campo, entre otros:
  - D-RELEASE por robo de FACCH; respuesta D-RELEASE a un U-SETUP de grupo
    rechazado; no se libera una llamada por un U-INFO;
  - no se libera una llamada de grupo de red mientras una radio local tiene el
    turno; el temporizador de inactividad de subida solo corta un turno local;
  - interrupción de un hablante local adelantado por prioridad y respeto de
    una petición retirada; respuesta a U-TX CEASED repetidos;
  - D-SETUP correcto en llamadas que llegan de la red; separación de al menos
    5 s entre repeticiones de entrada tardía de llamadas distintas; una llamada
    individual de red conserva la portadora de su circuito;
  - informes de entrega SDS, codificación de texto y estados de grupo; un SDS
    diferido descartado se informa como fallido;
  - MM: respuesta a peticiones que quedaban sin contestar o mal etiquetadas,
    registro de un terminal que vuelve a su red, rechazo de una actualización de
    ubicación que pide cifrado; al reconectar Brew se reenvía el registro en vez
    de volver a registrar las radios;
  - MAC: longitud de MAC-RESOURCE redondeada hacia arriba, trama 18 contada en
    las concesiones como la cuenta la radio, un PDU robado nunca se fragmenta en
    más de un slot, robo solo en las tramas que el hablante escucha, ventana de
    monitorización de la radio para el slot real de salida, acuse de un acceso
    aleatorio en hangtime;
  - LLC: cada ACK de capa 2 en el canal que la radio escucha, BL-ACK en su
    slot y ACK emparejados por SSI;
  - PHY: TX y RX siguen en marcha al dar la vuelta la hipertrama; cada ráfaga
    de bajada va al modulador de su portadora;
  - patrón de monitorización mejorado para la Sepura SRP2000.
- WX: METAR que empiezan por su tipo de informe; la tendencia y las
  observaciones de un METAR no se toman como el tiempo actual.

[1.2.0]: https://github.com/ea5gvk/MiuraStation-dist/releases/tag/v1.2.0
[1.1.0]: https://github.com/ea5gvk/MiuraStation-dist/releases/tag/v1.1.0
