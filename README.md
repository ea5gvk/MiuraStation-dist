# MiuraStation

**Estación base TETRA por software para Raspberry Pi.** Este repositorio es la
**distribución binaria** de MiuraStation: los paquetes listos para instalar
(en [Releases](https://github.com/ea5gvk/MiuraStation-dist/releases)), el
instalador, la configuración de ejemplo, el registro de cambios y las licencias.
El código fuente de MiuraStation no se publica.

> **Solo uso no comercial.** MiuraStation es gratuito y se distribuye solo en
> forma binaria. Incluye componentes de Nexus-BS con licencia PolyForm
> Noncommercial 1.0.0, así que solo puede usarse con fines no comerciales:
> radioafición, hobby, investigación, enseñanza y organismos públicos o sin
> ánimo de lucro, sí; vender equipos o dar servicios de pago con MiuraStation,
> no. Ver [Licencias](#licencias).

[English summary](#english-summary)

---

## Qué es

MiuraStation es una estación base TETRA completa hecha por software. Con una
Raspberry Pi, una SDR (SXceiver o LimeSDR) y tus radios TETRA tienes una célula
TETRA privada:

- llamadas de grupo e individuales (dúplex y semidúplex), loro (eco privado) y
  prioridad de emergencia;
- mensajes SDS, Home Mode Display y alarma de emergencia;
- interconexión con Brew (TetraPack / BrandMeister);
- datos por paquetes (SNDCP) con canales de hasta 4 slots y pasarela WAP;
- varias portadoras, también encendidas solo cuando hacen falta;
- panel web propio en el puerto 8080, control remoto desde la radio y
  vigilancia de systemd.

El detalle de cada versión está en el [registro de cambios](CHANGELOG.md).

Junto a la estación, el instalador pone el panel
[tetra-live-monitor](https://github.com/ea5gvk/tetra-live-monitor) (puerto 5000):
monitor en directo, editor de configuración y actualizaciones.

## Créditos

MiuraStation la desarrollan **Joaquin EA5GVK**, **Rafa EA7KEN** e
**Iñaki EA8DJI**. Es un proyecto independiente, construido sobre el trabajo de
otros (no está avalado por sus autores):

- **FlowStation**, de **Răzvan Zeceș YO6RZV**: la base directa de MiuraStation
  (Apache 2.0). https://github.com/razvanzeces/flowstation
- **BlueStation** (tetra-bluestation), de **Wouter Bokslag / Midnight Blue**: la
  pila TETRA en Rust de la que parten FlowStation y MiuraStation (Apache 2.0).
  https://github.com/MidnightBlueLabs/tetra-bluestation
- **Nexus-BS**, de **Chris YO3TCO**: loro, pasarela WAP, datos por paquetes,
  enlace avanzado LLC y canales de varios slots, usados con su permiso
  (PolyForm Noncommercial 1.0.0). https://github.com/invictus737/nexus-bs

  Required Notice: Copyright (c) Chris YO3TCO / Nexus-BS Project.

Gracias también a todos los que aparecen en [CREDITS.md](CREDITS.md) y
[NOTICE](NOTICE).

## Hardware

| Placa | Sistema | Estado |
|---|---|---|
| Raspberry Pi 5 | Raspberry Pi OS 64 bits, Bookworm o Trixie | Probada (estación de referencia) |
| Raspberry Pi 4 / 400 / CM4 | Raspberry Pi OS 64 bits, Bookworm o Trixie | Soportada |
| Raspberry Pi 3 B / B+ | Raspberry Pi OS 64 bits, Bookworm o Trixie | Solo **una portadora** hasta que se pruebe en campo |

- Hace falta el sistema de **64 bits** (arm64). Para el de 32 bits (armhf)
  todavía no hay paquete; Pi 1, Pi 2 y Pi Zero no están soportadas.
- SDR: **SXceiver** (HAT, módulo SoapySX) o **LimeSDR** (módulo LimeSuite de
  SoapySDR). Otras SDR con módulo SoapySDR pueden funcionar.
- En una Pi 3 usa una sola portadora (sin `extra_carriers` ni portadora de
  datos), refrigeración y el registro en nivel INFO.

## Instalación

En la Raspberry Pi, con Internet:

```bash
curl -fsSL https://raw.githubusercontent.com/ea5gvk/MiuraStation-dist/main/contrib/install/install-miurastation.sh | sudo bash
```

Opciones (detrás de `sudo bash -s --`) o variables de entorno:

| Opción | Variable | Qué hace |
|---|---|---|
| `--version vX.Y.Z` | `MIURA_VERSION` | Instala esa versión en vez de la última estable |
| `--beta` | `MIURA_CHANNEL=beta` | La versión más reciente, betas incluidas |
| `--sdr sx\|lime\|none` | `MIURA_SDR` | Módulo de la SDR (por defecto se detecta) |
| `--no-monitor` | `MIURA_NO_MONITOR=1` | No instala el panel tetra-live-monitor |
| `--yes` | `MIURA_YES=1` | No pregunta nada |
| | `TLM_PASSWORD` | Contraseña de administración del panel |
| | `TLM_BRANCH` | Rama de tetra-live-monitor (por defecto `main`) |

Por ejemplo: `curl -fsSL …/install-miurastation.sh | sudo bash -s -- --version v1.1.0 --sdr sx`

El instalador:

1. comprueba que es un sistema arm64 Bookworm o Trixie, la red y el espacio libre;
2. instala SoapySDR y el módulo de la SDR (SoapySX se compila desde
   [tejeez/sxxcvr](https://github.com/tejeez/sxxcvr); si el SXceiver no tiene
   EEPROM, añade el overlay y el SPI a `config.txt` y avisa de que hay que
   reiniciar);
3. descarga el `.deb` y `SHA256SUMS` de la versión, comprueba la suma e
   instala el paquete;
4. instala o actualiza el panel tetra-live-monitor (Node.js, pm2) en
   `/opt/tetra-live-monitor`;
5. muestra la dirección del panel. Registro: `/var/log/miurastation-install.log`.

Después edita `/root/miurastation/config.toml` (frecuencias, potencia,
identidad de la red; también desde el panel) y arranca la estación:

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
| `/lib/systemd/system/miurastation.service` | Servicio (cambios locales en `/etc/systemd/system/miurastation.service.d/`) |
| `/usr/share/doc/miurastation/` | Licencias, avisos y `THIRD-PARTY-LICENSES` |

## Actualizar

Vuelve a ejecutar el instalador (el mismo comando): instala la última versión
estable, o la que pidas con `--version` / `--beta`, y actualiza el panel.
También se puede actualizar desde el panel, o con el botón de actualización
del dashboard de la propia estación (puerto 8080), que comprueba el `.deb` con
`SHA256SUMS` antes de instalarlo (con `update_channel = "beta"` en la sección
`[dashboard]` también instala las versiones de pruebas). `config.toml` no se
toca y la estación solo se reinicia si estaba en marcha.

A mano: descarga de [Releases](https://github.com/ea5gvk/MiuraStation-dist/releases)
el `.deb` y `SHA256SUMS`, y:

```bash
sha256sum -c --ignore-missing SHA256SUMS
sudo apt install ./miurastation_X.Y.Z_arm64.deb
```

Canales: **estable** = la última versión publicada (*latest*); **beta** = las
versiones marcadas como *pre-release*.

## Desinstalar

```bash
curl -fsSL https://raw.githubusercontent.com/ea5gvk/MiuraStation-dist/main/contrib/install/uninstall-miurastation.sh | sudo bash
```

Quita el paquete y conserva `/root/miurastation` (con `config.toml`). El panel,
SoapySDR y el módulo de la SDR siguen instalados.

## Descargas de cada versión

| Fichero | Contenido |
|---|---|
| `miurastation_X.Y.Z_arm64.deb` | Paquete para Raspberry Pi OS 64 bits |
| `miurastation-X.Y.Z-aarch64.tar.gz` | Programa, configuración de ejemplo y licencias, sin instalador |
| `SHA256SUMS` | Sumas SHA-256 de los anteriores |

Los paquetes no incluyen el códec ACELP de ETSI ni la telefonía Asterisk
SIP/RTPC.

## Licencias

- [LICENSE](LICENSE): Apache License 2.0 (MiuraStation, FlowStation, BlueStation).
- [LICENSES/PolyForm-Noncommercial-1.0.0.txt](LICENSES/PolyForm-Noncommercial-1.0.0.txt):
  los ficheros de Nexus-BS; [LICENSES/Nexus-BS-LICENSE-OVERVIEW.md](LICENSES/Nexus-BS-LICENSE-OVERVIEW.md)
  y [CHANGES-NEXUS.md](CHANGES-NEXUS.md).
- [NOTICE](NOTICE): origen, avisos de modificación y lista de componentes de Nexus-BS.
- [THIRD-PARTY-LICENSES](THIRD-PARTY-LICENSES) (dentro de cada paquete; aquí, el
  de la última versión estable): licencias de las bibliotecas de Rust enlazadas
  en el programa.

MiuraStation no es software de código abierto: es una distribución binaria
gratuita para uso no comercial. Las condiciones de uso y de redistribución son
las de estos ficheros.

---

## English summary

MiuraStation is a software TETRA base station for the Raspberry Pi, developed by
Joaquin EA5GVK, Rafa EA7KEN and Iñaki EA8DJI. It is based on FlowStation by
Răzvan Zeceș YO6RZV, which builds on BlueStation by Wouter Bokslag / Midnight
Blue, and includes Nexus-BS components by Chris YO3TCO (PolyForm Noncommercial
1.0.0). This repository is its **binary distribution**: packages in Releases,
the installer, the example configuration, the changelog and the licences. The
source code is not published. **Free for noncommercial use only**; it is not
open source.

- **Hardware:** Raspberry Pi 5, 4/400/CM4 and 3 B/B+ with **64-bit** Raspberry
  Pi OS Bookworm or Trixie (Pi 3: single carrier only until field-tested);
  SXceiver or LimeSDR.
- **Install / update** (run it again to update):
  `curl -fsSL https://raw.githubusercontent.com/ea5gvk/MiuraStation-dist/main/contrib/install/install-miurastation.sh | sudo bash`
  — options `--version vX.Y.Z`, `--beta`, `--sdr sx|lime|none`, `--no-monitor`, `--yes`.
  It installs SoapySDR and the SDR module, the verified `.deb` and the
  tetra-live-monitor panel (port 5000). Then edit `/root/miurastation/config.toml`
  and `sudo systemctl start miurastation`.
- **Uninstall:** `.../contrib/install/uninstall-miurastation.sh | sudo bash`
  (keeps `/root/miurastation/config.toml`).
- **Licences:** LICENSE (Apache 2.0), NOTICE, LICENSES/ (PolyForm Noncommercial
  1.0.0 and the Nexus-BS overview), CHANGES-NEXUS.md, CREDITS.md, and
  THIRD-PARTY-LICENSES inside every package.
