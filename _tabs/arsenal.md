---
title: Arsenal
icon: fas fa-toolbox
order: 4
---

Base de datos de comandos y técnicas que uso: su fase, para qué sirven y **en qué lab y sección**
los apliqué. Busca por comando, etiqueta o lab (por ejemplo `shadowbait` o `tarea 8`), o filtra
por fase. Se alimenta de
[`_data/arsenal.yml`](https://github.com/ZefBoner/zefboner.github.io/blob/main/_data/arsenal.yml){:target="_blank"}.

<input type="text" id="arsenal-search" class="arsenal-search" placeholder="Buscar comando, etiqueta o lab..." autocomplete="off" aria-label="Buscar en el arsenal">

<div class="arsenal-filters" id="arsenal-filters">
  <button type="button" data-fase="" class="active">Todas</button>
  {%- assign fases = site.data.arsenal | map: 'fase' | uniq | sort -%}
  {%- for f in fases -%}
  <button type="button" data-fase="{{ f | escape }}">{{ f }}</button>
  {%- endfor -%}
</div>

<p class="arsenal-count" id="arsenal-count"></p>

<div class="arsenal-list" id="arsenal-list">
  {%- for e in site.data.arsenal -%}
  <div class="arsenal-item" data-fase="{{ e.fase | escape }}" data-search="{{ e.cmd | downcase | escape }} {{ e.desc | downcase | escape }} {{ e.tags | join: ' ' | downcase | escape }} {{ e.fase | downcase | escape }} {{ e.refs | map: 'nombre' | join: ' ' | downcase | escape }} {{ e.refs | map: 'seccion' | join: ' ' | downcase | escape }}">
    <div class="arsenal-item__head">
      <span class="arsenal-fase">{{ e.fase }}</span>
      <div class="arsenal-item__refs">
        {%- if e.refs and e.refs.size > 0 -%}
        {%- for r in e.refs -%}
        <a class="arsenal-ref" href="{{ r.url }}"><span class="arsenal-ref__lab">{{ r.nombre }}</span>{%- if r.seccion -%}<span class="arsenal-ref__sec">{{ r.seccion }}</span>{%- endif -%}</a>
        {%- endfor -%}
        {%- else -%}
        <span class="arsenal-muted arsenal-ref--none">Sin writeup aún</span>
        {%- endif -%}
      </div>
    </div>
    <div class="arsenal-item__cmd">
      <code>{{ e.cmd | escape }}</code>
      <button type="button" class="arsenal-copy" aria-label="Copiar comando" title="Copiar"><i class="far fa-clipboard"></i></button>
    </div>
    <p class="arsenal-item__desc">{{ e.desc | escape }}</p>
    {%- if e.tags and e.tags.size > 0 -%}
    <div class="arsenal-tags">{%- for t in e.tags -%}<span>#{{ t | escape }}</span>{%- endfor -%}</div>
    {%- endif -%}
  </div>
  {%- endfor -%}
</div>

<p class="arsenal-empty" id="arsenal-empty" hidden>Sin resultados. Prueba otra búsqueda o fase.</p>

<script>
(function () {
  var search = document.getElementById('arsenal-search');
  var buttons = Array.prototype.slice.call(document.querySelectorAll('#arsenal-filters button'));
  var items = Array.prototype.slice.call(document.querySelectorAll('#arsenal-list .arsenal-item'));
  var count = document.getElementById('arsenal-count');
  var empty = document.getElementById('arsenal-empty');
  var activeFase = '';

  function apply() {
    var q = (search.value || '').trim().toLowerCase();
    var shown = 0;
    items.forEach(function (it) {
      var okFase = !activeFase || it.getAttribute('data-fase') === activeFase;
      var okText = !q || it.getAttribute('data-search').indexOf(q) !== -1;
      var vis = okFase && okText;
      it.style.display = vis ? '' : 'none';
      if (vis) { shown++; }
    });
    count.textContent = shown + ' de ' + items.length + ' entradas';
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

  // Copia con el API moderno y, si el navegador lo bloquea, con execCommand.
  function legacyCopy(text) {
    var ta = document.createElement('textarea');
    ta.value = text;
    ta.setAttribute('readonly', '');
    ta.style.position = 'absolute';
    ta.style.left = '-9999px';
    document.body.appendChild(ta);
    ta.select();
    var ok = false;
    try { ok = document.execCommand('copy'); } catch (e) { ok = false; }
    document.body.removeChild(ta);
    return ok;
  }

  items.forEach(function (it) {
    var btn = it.querySelector('.arsenal-copy');
    var code = it.querySelector('.arsenal-item__cmd code');
    if (!btn || !code) { return; }
    btn.addEventListener('click', function () {
      var icon = btn.querySelector('i');
      function done() {
        btn.classList.add('copied');
        icon.className = 'fas fa-check';
        setTimeout(function () {
          btn.classList.remove('copied');
          icon.className = 'far fa-clipboard';
        }, 1500);
      }
      var text = code.textContent;
      if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(text).then(done, function () {
          if (legacyCopy(text)) { done(); }
        });
      } else if (legacyCopy(text)) {
        done();
      }
    });
  });

  apply();
})();
</script>
