---
title: "__TITULO__"
date: __FECHA__
categories: [__CATEGORIAS__]
# Etiquetas en minúsculas y con guiones: SO, dificultad y técnicas.
tags: [linux, easy, nmap]
description: Resumen de una línea que aparece en la portada.
# Imagen de portada opcional (1200x630). Ponla en la carpeta del borrador y quita los "#":
# image:
#   path: banner.png
#   alt: __NOMBRE__
info:
  platform: __PLATAFORMA__
  type: Machine
  os: Linux                 # Linux | Windows | FreeBSD | Android | Other
  difficulty: Easy          # Easy | Medium | Hard | Insane
  release: 2025-01-01       # fecha de lanzamiento
  retired: 2025-06-01       # fecha de retiro (¡solo publica retiradas!)
  creators: autor
  # logo: logo.png          # imagen cuadrada de la máquina, en la carpeta del borrador
  link: __LINK__
---

{% include writeup-info.html %}

> **TL;DR:** puerto/servicio expuesto → vulnerabilidad → acceso inicial → escalada a root.
{: .prompt-info }

## Reconocimiento

### Escaneo de puertos

```console
$ nmap -p- --open --min-rate 5000 -n -Pn 10.10.11.X -oG allPorts
```

```console
$ nmap -sCV -p22,80 10.10.11.X -oN targeted
```

| Puerto | Servicio | Versión |
| --- | --- | --- |
| 22 | ssh | |
| 80 | http | |

## Enumeración

### Puerto 80: HTTP

Qué viste en la web, tecnologías, rutas, fuzzing...

![Página principal](web.png)

## Acceso inicial

Cómo conseguiste la primera shell.

## Escalada de privilegios

Cómo llegaste a root / SYSTEM.

```console
$ cat /root/root.txt
a1b2c3d4************************
```

## Lecciones aprendidas

- Qué aprendiste.
- Qué te costó y qué harías diferente.

## Referencias

- [Nombre del recurso](https://ejemplo.com)

<!--
NOTAS (no se ven en la página):
- Pega capturas en esta misma carpeta y enlázalas así: ![descripción](captura.png)
- Si un comando o payload lleva llaves dobles o llave+porcentaje (por ejemplo SSTI),
  envuelve el bloque con las etiquetas raw/endraw de Liquid (ver README), o Jekyll
  intentará interpretarlo y el build falla.
- Censura las flags: deja los primeros 8 caracteres y el resto con *.
- Avisos disponibles: {: .prompt-tip }  {: .prompt-info }  {: .prompt-warning }  {: .prompt-danger }
-->
