---
title: "__TITULO__"
date: __FECHA__
categories: [__CATEGORIAS__]
# Etiquetas: categoría del reto y técnicas (web, pwn, crypto, rev, forensics, misc...)
tags: [web]
description: Resumen de una línea que aparece en la portada.
# image:
#   path: banner.png
#   alt: __NOMBRE__
info:
  platform: __PLATAFORMA__
  event: __EVENTO__
  type: Challenge
  category: Web             # Web | Pwn | Crypto | Reversing | Forensics | Misc | OSINT
  difficulty: Easy
  creators: autor
  link: __LINK__
---

{% include writeup-info.html %}

> **TL;DR:** en qué consistía el reto y cuál fue la clave para resolverlo.
{: .prompt-info }

## Descripción del reto

> Enunciado del reto.

**Archivos:** `archivo.zip`

## Análisis

Qué revisaste primero y qué te llamó la atención.

## Solución

Paso a paso hasta la flag.

```python
#!/usr/bin/env python3
# script de la solución
```
{: file="solve.py" }

## Flag

```text
HTB{************************}
```

## Lecciones aprendidas

- Qué aprendiste.

<!--
NOTAS (no se ven en la página):
- Si un payload lleva llaves dobles o llave+porcentaje (por ejemplo SSTI), envuélvelo
  con las etiquetas raw/endraw de Liquid (ver README).
- Solo publica cuando el CTF ya terminó o el reto ya está retirado.
-->
