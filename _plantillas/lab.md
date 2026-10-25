---
title: "__TITULO__"
date: __FECHA__
categories: [__CATEGORIAS__]
# Etiquetas: tipo de vulnerabilidad y nivel (sqli, xss, ssrf, apprentice, practitioner, expert...)
tags: [sqli, apprentice]
description: Resumen de una línea que aparece en la portada.
info:
  platform: __PLATAFORMA__
  type: Lab
  category: SQL injection
  difficulty: Apprentice    # PortSwigger: Apprentice | Practitioner | Expert
  link: __LINK__
---

{% include writeup-info.html %}

> **TL;DR:** vulnerabilidad, dónde estaba y el payload que la explota.
{: .prompt-info }

## Objetivo del laboratorio

> Enunciado del laboratorio.

## Análisis

Qué parámetro o funcionalidad es vulnerable y cómo lo detectaste.

## Explotación

```http
GET /filter?category=Gifts'+OR+1=1-- HTTP/2
Host: LAB-ID.web-security-academy.net
```

## Cómo se previene

- Qué cambio en el código o configuración lo evita.

## Lecciones aprendidas

- Qué aprendiste.

<!--
NOTAS (no se ven en la página):
- Si un payload lleva llaves dobles o llave+porcentaje (por ejemplo SSTI), envuélvelo
  con las etiquetas raw/endraw de Liquid (ver README).
-->
