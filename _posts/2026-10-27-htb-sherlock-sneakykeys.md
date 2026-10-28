---
title: "Sherlock: SneakyKeys"
date: 2026-10-27 11:00:00 -0600
categories: [HackTheBox, Sherlocks]
tags: [malware-analysis, reversing, ghidra, chacha20, keylogger, irc, windows, cyberchef]
description: Análisis estático en Ghidra de un keylogger en Windows que cifra con ChaCha20 y exfiltra por IRC.
media_subpath: /assets/img/posts/htb-sherlock-sneakykeys
image:
  path: logo.png
  alt: SneakyKeys
info:
  platform: HackTheBox
  type: Sherlock
  category: Malware Analysis
  os: Windows
  difficulty: Medium
  logo: logo.png
---

{% include writeup-info.html %}

> **Escenario.** Alice, empleada de la empresa, descargó un malware disfrazado de
> actualización de seguridad. El malware capturó sus contraseñas y filtró información
> sensible. Como parte del equipo de IT, la tarea es identificar qué información crítica se
> filtró y asegurar las cuentas comprometidas.
{: .prompt-info }

> **Resumen.** `SneakyKeys.exe` es un keylogger que cifra sus cadenas y su tráfico con
> **ChaCha20**, se copia a la carpeta Startup para persistir, y exfiltra lo capturado por
> **IRC** (puerto 6697) al canal `#key_storrage`. La clave de red es el UUID de la máquina
> infectada.
{: .prompt-tip }

> Algunas respuestas (aplicación objetivo, destinatario y contraseña filtrada) van
> **censuradas** porque contienen el *payload* sensible del reto. Las capturas muestran el
> método completo.
{: .prompt-warning }

**Herramientas:** Ghidra (análisis estático), Wireshark (pcap) y un script de Python/CyberChef
para ChaCha20.

## 1. Algoritmo de cifrado

**Pregunta:** ¿Qué algoritmo de cifrado usa el malware para proteger sus cadenas y comandos
(ver constantes)?

Revisando las secciones del binario en Ghidra:

- `.data`: variables globales/estáticas inicializadas.
- `.rdata`: datos inicializados de solo lectura.

Entre las constantes aparece la firma de inicialización de ChaCha20, un cifrado simétrico de
flujo de 20 rondas.

![Constantes de ChaCha20 en las secciones del binario](01.png)

**Respuesta:** `chacha20`

## 2. Directorio de la copia duplicada

**Pregunta:** ¿Qué directorio usa el malware para dejar su copia duplicada?

Entre las funciones importadas destaca `SHGetFolderPathA`, que obtiene la ruta de una carpeta
identificada por un valor **CSIDL**.

![Import de SHGetFolderPathA](02.png)
![Definición de SHGetFolderPathA](03.png)

Siguiendo las referencias cruzadas, al CSIDL se le pasa el entero `7`, que corresponde a la
carpeta de inicio (Startup) del usuario.

![CSIDL 7 pasado a SHGetFolderPathA](04.png)

**Respuesta:** `\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\`

## 3. Protocolo de C2

**Pregunta:** ¿En qué protocolo se apoya el malware para comunicarse con su servidor de mando?

En los imports de `WS2_32` llama la atención `htons` (define el puerto de conexión). Se le
pasa el valor `1A29` (hex) = `6697` en decimal, el puerto por defecto de **IRC**. Justo
después aparecen `inet_addr` (IP) y `connect` (establecer el socket).

![htons con el puerto 6697 (IRC)](05.png)

**Respuesta:** `IRC`

## 4. Canal de almacenamiento de datos

**Pregunta:** ¿Qué canal usa el malware para almacenar los datos capturados?

Sabiendo el puerto, filtramos el pcap y seguimos la traza TCP. Se observa la conexión al
servidor IRC y el canal usado.

![Traza TCP del IRC mostrando el canal](06.png)

**Respuesta:** `#key_storrage`

## 5. Aplicación objetivo

**Pregunta:** ¿Qué aplicación es el objetivo del malware?

Localizamos la función que inicializa ChaCha20 por su constante `expand 32-byte k`
(`FUN_14001faa0`), que arma la matriz de inicialización 4x4. Sus parámetros son la **key**
(`param_2`) y el **nonce** (`param_3`).

![Matriz de inicialización de ChaCha20 (expand 32-byte k)](07.png)
![Función que pasa key y nonce a la inicialización](08.png)

Rastreando quién provee esos parámetros llegamos a `FUN_14001fce0`, y las referencias apuntan
a las direcciones `1400d4000` (key) y `1400d4010` (nonce).

![FUN_14001fce0 con los punteros a key y nonce](09.png)
![Direcciones de disco de la key y el nonce](10.png)

Recordatorio: en ChaCha20 la key son 32 bytes y el nonce 8 bytes. Los valores:

```text
Key (hex):   4d795f64557033725f73757033725f6b6f6e335f6e306e63291a000000000000
Nonce (hex): 6f6e335f6e306e63

Key (ASCII):   My_dUp3r_sup3r_kon3_n0nc)
Nonce (ASCII): on3_n0nc
```

![Valores de key y nonce en hexadecimal y ASCII](11.png)

Las referencias a esta key/nonce se usan en `FUN_140001f4d`, la función del **keylogger**:
solo se activa al presionar una tecla (`WM_KEYDOWN = 0x100`, `WM_SYSKEYDOWN = 0x104`).
Descifra un texto de 13 caracteres (`0xd`) en `DAT_1400d4040` con esa key y nonce, espera un
`Enter` (`\r`) para detectar el fin de la entrada, cifra lo capturado con una key distinta
(mismo nonce) y devuelve el control con `CallNextHookEx`.

![FUN_140001f4d: lógica del keylogger (WM_KEYDOWN / WM_SYSKEYDOWN)](12.png)

Descifrando el contenido de `DAT_1400d4040` con la key y el nonce obtenemos la aplicación
objetivo:

![Bytes de DAT_1400d4040 en Ghidra](13.png)
![Descifrado ChaCha20 del nombre de la aplicación (salida censurada)](14.png)

**Respuesta:** `[censurada en el writeup original]`

## 6. Clave de cifrado de la exfiltración

**Pregunta:** Identifica la clave de cifrado que el malware aplica antes de enviar datos
desde el sistema víctima.

La key/nonce anterior solo descifra las "herramientas" internas. Para los datos de red, la
función `receta_chacha20` recibe como segundo argumento la key de cifrado (`puVar4`), que el
malware construye en ejecución; por eso cada equipo usa una key distinta.

![receta_chacha20 y la variable puVar4 como key de red](15.png)

Siguiendo las referencias a esa dirección reservada llegamos a `FUN_1400289b` →
`FUN_1400b1fc0` → `FUN_1400024aa`, donde se **extrae el UUID de la máquina infectada**. Si no
se puede obtener el UUID, se usa la frase `Error: Unable to retrive UUID` como key.

![Referencias a la dirección que contiene la key de red](16.png)
![Cadena de funciones hasta la key](17.png)
![Extracción del UUID de la máquina](18.png)
![Rama else: "Error: Unable to retrive UUID" como key alternativa](19.png)

La key que cifra lo capturado es el **UUID sin guiones** (32 bytes), que también se puede
obtener de la captura de tráfico:

```text
Key (hex):   3964396135316266623338663439363439396164333163313234396435613730
Nonce (hex): 6f6e335f6e306e63

Key (ASCII):   9d9a51bfb38f496499ad31c1249d5a70
Nonce (ASCII): on3_n0nc
```

![Key de red derivada del UUID](20.png)

**Respuesta:** `9d9a51bfb38f496499ad31c1249d5a70:on3_n0nc`

## 7. ¿Con quién se comunica Alice?

**Pregunta:** ¿Con quién se está comunicando Alice?

Con la key y el nonce de red ya conocidos, desciframos cada mensaje `PRIVMSG #key_storrage`
del tráfico IRC. Los mensajes van desde el nick `ALICE_9d9a51bf`.

![Mensajes PRIVMSG cifrados en el canal IRC](21.png)
![Mensaje descifrado HEY ... I AM SENDING YOU THIS EMAIL, con el destinatario censurado](22.png)

**Respuesta:** `[censurada en el writeup original]`

## 8. Contraseña filtrada de Alice

**Pregunta:** ¿Cuál es la contraseña filtrada asociada a Alice?

Descifrando el resto de los mensajes aparece la contraseña filtrada por el keylogger.

![Mensaje descifrado MY WORDPRESS PASSWORD IS, con la contraseña censurada](23.png)

**Respuesta:** `[censurada en el writeup original]`

## Indicadores de compromiso (IOCs)

| Tipo | Valor |
| --- | --- |
| Cifrado | ChaCha20 |
| Persistencia | Copia en `...\Start Menu\Programs\Startup\` |
| Protocolo C2 | IRC (puerto `6697`) |
| Canal C2 | `#key_storrage` |
| Nick | `ALICE_9d9a51bf` |
| Key interna | `My_dUp3r_sup3r_kon3_n0nc)` / nonce `on3_n0nc` |
| Key de red | UUID de la máquina sin guiones + nonce `on3_n0nc` |

## MITRE ATT&CK (resumen)

| Táctica | Técnica | ID |
| --- | --- | --- |
| Collection | Input Capture: Keylogging | T1056.001 |
| Persistence | Boot or Logon Autostart (Startup Folder) | T1547.001 |
| Command and Control | Application Layer Protocol (IRC) | T1071 |
| Exfiltration | Exfiltration Over C2 Channel | T1041 |
| Defense Evasion | Obfuscated/Encrypted Strings (ChaCha20) | T1027 |

## Lecciones aprendidas

- La constante `expand 32-byte k` es la pista inmediata para identificar ChaCha20 en un
  binario.
- Derivar la key de cifrado del UUID de la máquina hace que cada infección use una clave
  distinta, pero el mismo UUID viaja en el tráfico y permite recuperarla.
- Un keylogger que solo filtra ante una app concreta (la ventana objetivo) reduce ruido y
  cuesta más de detectar.
