# Blog de writeups — Angxdes

Sitio para publicar writeups de máquinas, Sherlocks, CTFs y laboratorios, hecho con
[Jekyll](https://jekyllrb.com/) + el tema [Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy)
y alojado gratis en **GitHub Pages**. Fondo oscuro, acento verde, categorías, etiquetas,
buscador y resaltado de código.

- **URL final:** `https://zefboner.github.io`
- **Escribes:** archivos Markdown en `_posts/`.
- **Publicas:** `git push` → GitHub construye y sube el sitio solo.

---

## 1. Subirlo a GitHub (solo la primera vez)

1. Crea una cuenta en [github.com](https://github.com) con el usuario **Angxdes** (si aún no la tienes).
2. Crea un repositorio **público** llamado exactamente:

   ```text
   angxdes.github.io
   ```

   > El nombre tiene que coincidir con tu usuario. Si tu usuario fuera otro, el repo sería
   > `<tu-usuario>.github.io` y la URL `https://<tu-usuario>.github.io`.
   {: .prompt-tip }

3. Conecta esta carpeta con ese repo y haz el primer push. Desde esta carpeta, en PowerShell:

   ```bash
   git remote add origin https://github.com/ZefBoner/ZefBoner.github.io.git
   git branch -M main
   git push -u origin main
   ```

   Ya hay un commit inicial hecho, así que esto sube todo de una.

4. En GitHub, entra al repo → **Settings** → **Pages** → en **Source** elige
   **GitHub Actions** (no "Deploy from a branch").
5. Espera 1-2 minutos. Tu sitio queda en `https://zefboner.github.io`.

> Si el usuario de GitHub NO es exactamente `Angxdes`, cambia también `url` y `github.username`
> en [`_config.yml`](_config.yml) y la URL en los scripts.
{: .prompt-warning }

---

## 2. Crear un writeup

### La forma rápida (script)

En PowerShell, desde esta carpeta:

```bash
.\scripts\nuevo-writeup.ps1 -Tipo maquina -Titulo "HTB: Codify"
```

`-Tipo` puede ser: `maquina`, `sherlock`, `challenge` o `lab`.

Eso crea:

- El post en `_posts/2026-10-25-htb-codify.md` con la fecha, el título y las categorías puestas.
- La carpeta `assets/img/posts/htb-codify/` para las capturas de ese writeup.

Puedes pasar categorías propias:

```bash
.\scripts\nuevo-writeup.ps1 -Tipo challenge -Titulo "Flag Command" -Categorias "CTF,Cyber Apocalypse 2025"
```

### La forma manual

1. Copia la plantilla que quieras de [`_plantillas/`](_plantillas/) a `_posts/`.
2. Renómbrala con el formato **`AAAA-MM-DD-titulo-en-minusculas.md`** (importante, Jekyll lo exige).
3. Rellena el front matter (lo de arriba entre `---`) y escribe.

---

## 3. Cómo se nombra y organiza

### Nombre del archivo

```text
_posts/2026-10-25-htb-codify.md
        └─ fecha ─┘ └── slug ──┘
```

### Categorías (máximo 2, de general a específico)

Aparecen en el menú **Categorías**. Sugerencia:

| Tipo | `categories` |
| --- | --- |
| Máquina HTB | `[HackTheBox, Machines]` |
| Sherlock HTB | `[HackTheBox, Sherlocks]` |
| Challenge HTB | `[HackTheBox, Challenges]` |
| Reto de CTF | `[CTF, Nombre del evento]` |
| TryHackMe | `[TryHackMe]` |
| Lab PortSwigger | `[Labs, PortSwigger]` |

### Etiquetas (las que quieras)

Son el verdadero índice con el tiempo. Ponlas en minúsculas y con guiones:
`active-directory`, `kerberoasting`, `ssti`, `suid`, `linux`, `windows`, `easy`, `dfir`...

---

## 4. La tarjeta de información

Cada plantilla trae un bloque `info:` en el front matter y la línea
`{% raw %}{% include writeup-info.html %}{% endraw %}` al inicio del cuerpo. Eso dibuja una
tarjeta con los datos (sistema, dificultad, fechas, enlace...). Solo se muestran los campos que
rellenes; borra los que no uses. La dificultad se colorea sola
(`Very Easy`, `Easy`, `Medium`, `Hard`, `Insane`).

---

## 5. Imágenes

- Guarda las capturas de un writeup en `assets/img/posts/<slug>/`.
- El script ya pone `media_subpath` en el post, así que dentro del Markdown basta con el
  nombre del archivo:

  ```markdown
  ![Descripción de la captura](login.png)
  _Texto opcional debajo de la imagen_
  ```

- Imagen de portada (sale en la lista y al compartir): en el front matter,

  ```yaml
  image:
    path: banner.png
    alt: Nombre
  ```

> Si usas **Obsidian**, actívale "Usar enlaces de Markdown" (Settings → Files & Links) para
> que genere `![](imagen.png)` y no `![[imagen.png]]`, que Jekyll no entiende.
{: .prompt-tip }

---

## 6. Vista previa local (opcional)

No es obligatorio: al hacer `git push`, GitHub construye el sitio igual. Pero si quieres verlo
antes en tu máquina:

```bash
.\scripts\servir.ps1
```

Luego abre `http://localhost:4000`. El script usa Ruby/Bundler si lo tienes; si no, usa Docker
(abre Docker Desktop primero). Para instalar Ruby en Windows: [RubyInstaller + Devkit](https://rubyinstaller.org/).

---

## 7. Publicar

```bash
.\scripts\publicar.ps1 "HTB: Codify"
```

Hace `commit` + `push`. En 1-2 minutos el writeup está en línea. El avance del build se ve en
`https://github.com/ZefBoner/ZefBoner.github.io/actions`.

---

## 8. Reglas importantes (léelas)

- **Solo contenido retirado.** HTB prohíbe writeups de máquinas, Sherlocks y challenges
  **activos**. En CTFs, espera a que el evento termine.
- **El repo es público.** Con cuenta gratis, GitHub Pages necesita el repo público. Lo que
  pongas aquí lo puede ver cualquiera, **aunque no esté enlazado todavía** (incluso en
  `_drafts/`). Para contenido de cosas activas, guárdalo fuera de este repo hasta que se retire
  (por ejemplo en la carpeta `borradores/`, que está excluida del sitio y del git, o en un repo
  privado aparte).
- **Censura las flags.** En el texto y en las capturas. Por ejemplo `HTB{REDACTED}` o solo los
  primeros caracteres: `a1b2c3d4************************`.

---

## 9. Trucos de escritura

- **Avisos de colores** (callouts):

  ```markdown
  > Un consejo útil.
  {: .prompt-tip }
  ```

  Disponibles: `.prompt-tip` (verde), `.prompt-info` (azul), `.prompt-warning` (amarillo),
  `.prompt-danger` (rojo).

- **Nombre de archivo sobre un bloque de código:**

  ````markdown
  ```python
  print("hola")
  ```
  {: file="solve.py" }
  ````

- **Spoiler** (oculta una pista hasta pasar el cursor): `<span class="spoiler">la pista</span>`.
  No sirve para flags: el texto sigue en el HTML.

- **Payloads con llaves** (SSTI, plantillas): si un bloque tiene `{{ ... }}` o `{%  %}`, Jekyll
  intenta interpretarlo y el build falla. Envuelve ese bloque con las etiquetas `raw` de Liquid:

  ````markdown
  {% raw %}
  ```
  {{7*7}}
  ```
  {% endraw %}
  ````

---

## 10. Personalización

- **Avatar:** reemplaza [`assets/img/avatar.svg`](assets/img/avatar.svg) por tu foto o logo
  (o cambia la ruta `avatar:` en [`_config.yml`](_config.yml)).
- **Redes/contacto:** descomenta y completa tus enlaces en [`_config.yml`](_config.yml)
  (`social.links`) y en [`_data/contact.yml`](_data/contact.yml) (iconos de la barra lateral).
- **Página "whoami":** edítala en [`_tabs/whoami.md`](_tabs/whoami.md).
- **Color de acento:** cambia `--angx-accent` arriba en
  [`assets/css/jekyll-theme-chirpy.scss`](assets/css/jekyll-theme-chirpy.scss).
- **Comentarios** (opcional): puedes activar [giscus](https://giscus.app) (comentarios con
  GitHub Discussions) llenando el bloque `comments:` → `giscus` en `_config.yml`.

---

## Estructura del proyecto

```text
_config.yml            Configuración del sitio
_tabs/whoami.md        Página "sobre mí"
_posts/                Tus writeups publicados (Markdown)
_plantillas/           Plantillas en blanco (no se publican)
borradores/            Borradores privados (fuera del sitio y de git)
scripts/               nuevo-writeup.ps1, servir.ps1, publicar.ps1
assets/img/            Imágenes (avatar, portadas, capturas por writeup)
assets/css/            Estilo propio (modo oscuro + tarjeta de info)
_includes/             writeup-info.html (la tarjeta) y la fuente mono
```

Basado en [Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) (MIT).
