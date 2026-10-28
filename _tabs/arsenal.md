---
title: Arsenal
icon: fas fa-toolbox
order: 4
---

Base de datos de comandos y técnicas que uso, con su fase y el writeup donde los apliqué.
Busca por texto o filtra por fase. Se alimenta de
[`_data/arsenal.yml`](https://github.com/ZefBoner/zefboner.github.io/blob/main/_data/arsenal.yml){:target="_blank"}.

<input type="text" id="arsenal-search" class="arsenal-search" placeholder="Buscar comando, técnica o etiqueta..." autocomplete="off" aria-label="Buscar en el arsenal">

<div class="arsenal-filters" id="arsenal-filters">
  <button type="button" data-fase="" class="active">Todas</button>
  {%- assign fases = site.data.arsenal | map: 'fase' | uniq | sort -%}
  {%- for f in fases -%}
  <button type="button" data-fase="{{ f | escape }}">{{ f }}</button>
  {%- endfor -%}
</div>

<p class="arsenal-count" id="arsenal-count"></p>

<div class="arsenal-wrap">
<table class="arsenal-table">
  <thead>
    <tr><th>Comando / técnica</th><th>Fase</th><th>Descripción</th><th>Usado en</th></tr>
  </thead>
  <tbody>
  {%- for e in site.data.arsenal -%}
    <tr data-fase="{{ e.fase | escape }}" data-search="{{ e.cmd | downcase | escape }} {{ e.desc | downcase | escape }} {{ e.tags | join: ' ' | downcase | escape }} {{ e.fase | downcase | escape }}">
      <td><code>{{ e.cmd | escape }}</code></td>
      <td><span class="arsenal-fase">{{ e.fase }}</span></td>
      <td>{{ e.desc }}{%- if e.tags and e.tags.size > 0 -%}<div class="arsenal-tags">{%- for t in e.tags -%}<span>#{{ t }}</span>{%- endfor -%}</div>{%- endif -%}</td>
      <td>{%- if e.refs and e.refs.size > 0 -%}{%- for r in e.refs -%}<div class="arsenal-ref"><a href="{{ r.url }}">{{ r.nombre }}</a>{%- if r.seccion -%}<span class="arsenal-seccion">{{ r.seccion }}</span>{%- endif -%}</div>{%- endfor -%}{%- else -%}<span class="arsenal-muted">—</span>{%- endif -%}</td>
    </tr>
  {%- endfor -%}
  </tbody>
</table>
</div>

<p class="arsenal-empty" id="arsenal-empty" hidden>Sin resultados. Prueba otra búsqueda o fase.</p>

<script>
(function () {
  var search = document.getElementById('arsenal-search');
  var buttons = Array.prototype.slice.call(document.querySelectorAll('#arsenal-filters button'));
  var rows = Array.prototype.slice.call(document.querySelectorAll('.arsenal-table tbody tr'));
  var count = document.getElementById('arsenal-count');
  var empty = document.getElementById('arsenal-empty');
  var activeFase = '';

  function apply() {
    var q = (search.value || '').trim().toLowerCase();
    var shown = 0;
    rows.forEach(function (r) {
      var okFase = !activeFase || r.getAttribute('data-fase') === activeFase;
      var okText = !q || r.getAttribute('data-search').indexOf(q) !== -1;
      var vis = okFase && okText;
      r.style.display = vis ? '' : 'none';
      if (vis) shown++;
    });
    count.textContent = shown + ' de ' + rows.length + ' entradas';
    empty.hidden = shown !== 0;
  }

  search.addEventListener('input', apply);
  buttons.forEach(function (b) {
    b.addEventListener('click', function () {
      buttons.forEach(function (x) { x.classList.remove('active'); });
      b.classList.add('active');
      activeFase = b.getAttribute('data-fase');
      apply();
    });
  });
  apply();
})();
</script>
