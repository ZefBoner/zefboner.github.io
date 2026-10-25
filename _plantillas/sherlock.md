---
title: "__TITULO__"
date: __FECHA__
categories: [__CATEGORIAS__]
# Etiquetas: tipo de análisis y artefactos (dfir, soc, evtx, wireshark, memoria...)
tags: [dfir, very-easy]
description: Resumen de una línea que aparece en la portada.
# image:
#   path: banner.png
#   alt: __NOMBRE__
info:
  platform: __PLATAFORMA__
  type: Sherlock
  category: DFIR            # DFIR | SOC | Malware Analysis | Threat Intelligence | Cloud
  difficulty: Very Easy     # Very Easy | Easy | Medium | Hard | Insane
  release: 2025-01-01
  retired: 2025-06-01
  creators: autor
  # logo: logo.png
  link: __LINK__
---

{% include writeup-info.html %}

> **TL;DR:** qué pasó, cómo entró el atacante y qué hizo después.
{: .prompt-info }

## Escenario

> Resume aquí el escenario que da el Sherlock.

## Artefactos

| Archivo | Tipo | Notas |
| --- | --- | --- |
| `archivo.evtx` | Windows Event Log | |

**Herramientas:** EvtxECmd, Timeline Explorer, Wireshark, ...

## Análisis

### Tarea 1

**Pregunta:** texto de la pregunta.

Cómo llegaste a la respuesta: filtros, comandos, capturas.

```console
$ comando que usaste
```

**Respuesta:** `respuesta`

### Tarea 2

**Pregunta:** texto de la pregunta.

**Respuesta:** `respuesta`

## Línea de tiempo

| Hora (UTC) | Evento | Fuente |
| --- | --- | --- |
| 2025-01-01 10:00:00 | Primer acceso del atacante | auth.log |

## IOCs

| Tipo | Valor | Contexto |
| --- | --- | --- |
| IP | `203.0.113.10` | Origen del ataque |

## MITRE ATT&CK

| Táctica | Técnica | ID |
| --- | --- | --- |
| Initial Access | Valid Accounts | T1078 |

## Lecciones aprendidas

- Qué detección habría parado esto antes.

<!--
NOTAS (no se ven en la página):
- Pega capturas en esta misma carpeta y enlázalas así: ![descripción](captura.png)
- Si algo lleva llaves dobles o llave+porcentaje, envuélvelo con las etiquetas
  raw/endraw de Liquid (ver README).
-->
