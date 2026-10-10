# Créditos y agradecimientos / Credits and thanks

## Español

**MiuraStation** es una estación base TETRA por software desarrollada por
**Joaquin EA5GVK**, **Rafa EA7KEN** e **Iñaki EA8DJI**.

MiuraStation no parte de cero. Existe gracias al trabajo de otros, a quienes
damos las gracias de corazón:

- **Răzvan Zeceș (YO6RZV) y FlowStation**: la base directa de MiuraStation.
  Nuestro proyecto nació como la rama `miura` de un fork de FlowStation y lleva
  dentro su trabajo en el panel web, las integraciones y la estabilidad en
  campo. Gracias, Răzvan, por FlowStation y por publicarlo con licencia libre.
  https://github.com/razvanzeces/flowstation
- **Wouter Bokslag / Midnight Blue y BlueStation**: el origen de todo, la pila
  TETRA en Rust sobre la que se construyeron FlowStation y MiuraStation.
  https://github.com/MidnightBlueLabs/tetra-bluestation
- **Chris YO3TCO y Nexus-BS**: por permitirnos usar su código del loro, la
  pasarela WAP, los datos por paquetes (SNDCP), el enlace avanzado LLC y los
  canales de datos de varios slots. Esos ficheros mantienen su licencia
  PolyForm Noncommercial 1.0.0 (solo uso no comercial); la lista está en
  `NOTICE`.
  https://github.com/invictus737/nexus-bs
- **Mihajlo YU4MSH (misadeks)** por las llamadas dúplex P2P, Home Mode Display
  y DGNA; **Torben DJ2TH** por DAPNET, la telefonía Asterisk SIP/RTPC, los
  avisos en teléfonos Snom y GeoAlarm; **M0UPM** y el resto de contribuidores
  de FlowStation y BlueStation.
- **Harald Welte y el equipo de osmocom** por osmocom-tetra; **Tatu Peltola**
  por rust-soapysdr, el codificador/decodificador Viterbi en Rust y SXCEIVER;
  **Stichting NLnet** por financiar en parte BlueStation con la subvención
  RETETRA3; **Dennis DB2OE** por la inspiración del tema del panel (crédito de
  Nexus-BS).
- La comunidad que prueba y reporta fallos: ON6RF, BU2GQ, DK5RTA, DO5MF,
  ES4TIX y muchos más.

## English

**MiuraStation** is a software TETRA base station developed by
**Joaquin EA5GVK**, **Rafa EA7KEN** and **Iñaki EA8DJI**.

MiuraStation does not start from scratch. It exists thanks to the work of
others, whom we warmly thank:

- **Răzvan Zeceș (YO6RZV) and FlowStation**: the direct base of MiuraStation.
  Our project started as the `miura` branch of a FlowStation fork and carries
  its dashboard, integration and field-hardening work. Thank you, Răzvan, for
  FlowStation and for releasing it under a free licence.
  https://github.com/razvanzeces/flowstation
- **Wouter Bokslag / Midnight Blue and BlueStation**: where it all began, the
  Rust TETRA stack that FlowStation and MiuraStation were built on.
  https://github.com/MidnightBlueLabs/tetra-bluestation
- **Chris YO3TCO and Nexus-BS**: for letting us use his parrot, WAP gateway,
  packet data (SNDCP), LLC advanced link and multislot packet-data code. Those
  files keep their PolyForm Noncommercial 1.0.0 licence (noncommercial use
  only); they are listed in `NOTICE`.
  https://github.com/invictus737/nexus-bs
- **Mihajlo YU4MSH (misadeks)** for full-duplex P2P calls, Home Mode Display
  and DGNA; **Torben DJ2TH** for DAPNET, Asterisk SIP/PSTN telephony, Snom
  desk-phone notifications and GeoAlarm; **M0UPM** and all other FlowStation
  and BlueStation contributors.
- **Harald Welte and the osmocom team** for osmocom-tetra; **Tatu Peltola** for
  rust-soapysdr, the Rust Viterbi encoder/decoder and SXCEIVER; **Stichting
  NLnet** for partly funding BlueStation through the RETETRA3 grant; **Dennis
  DB2OE** for dashboard-theme inspiration (Nexus-BS credit).
- The testing community: ON6RF, BU2GQ, DK5RTA, DO5MF, ES4TIX and many others.
