// Minimal stand-in for the design canvas runtime that the boards in
// docs/design/handoff/canvas/boards/*.dc.html load as ./support.js.
// See prototype/tool/SHOTS.md. Query parameters:
//   <tweak>=<value>   override a data-props tweak (booleans: true/false)
//   _w, _h            override this.props.$preview
//   klik=a|b          after mount, click the element whose text contains a, then b;
//                     a step `ketik:TEXT` types TEXT, `tunggu:MS` waits MS before the next
// After rendering, <html data-dc="ok|error"> and data-dc-error="…" report the result.
(function () {
  'use strict';
  var BASE = document.currentScript ? document.currentScript.src : location.href;
  var errors = [];
  var BOOL_ATTRS = { disabled: 1, checked: 1, readonly: 1, selected: 1, hidden: 1, open: 1, required: 1, multiple: 1, autofocus: 1 };

  function fail(msg) {
    errors.push(String(msg));
    console.error('[dc] ' + msg);
    var html = document.documentElement;
    html.setAttribute('data-dc', 'error');
    html.setAttribute('data-dc-error', errors.join(' | '));
    if (!document.body) return;
    var b = document.getElementById('dc-error-banner');
    if (!b) {
      b = document.createElement('div');
      b.id = 'dc-error-banner';
      b.style.cssText = 'position:fixed;left:0;right:0;top:0;z-index:2147483647;background:#c00;color:#fff;font:12px/1.4 monospace;padding:4px 8px;white-space:pre-wrap';
      document.body.appendChild(b);
    }
    b.textContent = 'support.js: ' + errors.join('\n');
  }
  window.addEventListener('error', function (e) { fail(e.message + (e.error && e.error.stack ? '\n' + e.error.stack.split('\n')[1] : '')); });
  window.addEventListener('unhandledrejection', function (e) { fail('unhandled rejection: ' + e.reason); });

  // Base class of every board's `class Component extends DCLogic`.
  function DCLogic(props) { this.props = props || {}; this.state = {}; }
  DCLogic.prototype.setState = function (partial) {
    if (typeof partial === 'function') partial = partial(this.state, this.props);
    if (partial) Object.assign(this.state, partial);
    schedule();
  };
  DCLogic.prototype.forceUpdate = function () { schedule(); };
  window.DCLogic = DCLogic;

  var comp, tpl, root, scheduled = false, missing = {};

  function schedule() {
    if (scheduled || !root) return;
    scheduled = true;
    queueMicrotask(function () { scheduled = false; render(); });
  }

  // {{a.b}} lookup through the scope chain (innermost sc-for variable first).
  function lookup(expr, scope) {
    expr = expr.trim();
    if (expr === 'true') return true;
    if (expr === 'false') return false;
    if (expr === 'null') return null;
    if (/^-?\d+(\.\d+)?$/.test(expr)) return Number(expr);
    var parts = expr.split('.'), v, s = scope;
    while (s && !(parts[0] in s.vars)) s = s.parent;
    if (!s) { missing[parts[0]] = 1; return undefined; }
    v = s.vars[parts[0]];
    for (var i = 1; i < parts.length && v != null; i++) v = v[parts[i]];
    return v;
  }
  var ONE = /^\{\{([^{}]+)\}\}$/, ANY = /\{\{([^{}]+)\}\}/g;
  function str(v) { return v == null ? '' : String(v); }
  function interp(text, scope) { return text.replace(ANY, function (_, e) { return str(lookup(e, scope)); }); }

  function eventName(el, attr) {
    var n = attr.slice(2);
    if (n === 'change') {
      var t = (el.getAttribute('type') || '').toLowerCase();
      // React semantics: onChange on text fields fires on every keystroke.
      if (el.localName === 'textarea' || (el.localName === 'input' && t !== 'checkbox' && t !== 'radio' && t !== 'file')) return 'input';
    }
    if (n === 'doubleclick') return 'dblclick';
    return n;
  }

  function renderNodes(nodes, scope, out) {
    for (var i = 0; i < nodes.length; i++) renderNode(nodes[i], scope, out);
  }

  function renderNode(node, scope, out) {
    if (node.nodeType === 3) { out.appendChild(document.createTextNode(node.data.indexOf('{{') < 0 ? node.data : interp(node.data, scope))); return; }
    if (node.nodeType !== 1) return;
    var tag = node.localName;
    if (tag === 'helmet' || tag === 'script') return;
    if (tag === 'sc-if') {
      if (bindingValue(node.getAttribute('value'), scope)) renderNodes(node.childNodes, scope, out);
      return;
    }
    if (tag === 'sc-for') {
      var list = bindingValue(node.getAttribute('list'), scope), as = node.getAttribute('as') || 'item';
      if (list && !Array.isArray(list)) list = typeof list === 'object' ? Object.values(list) : [];
      (list || []).forEach(function (item, idx) {
        var vars = {}; vars[as] = item; vars.$index = idx;
        renderNodes(node.childNodes, { vars: vars, parent: scope }, out);
      });
      return;
    }
    if (tag.indexOf('sc-') === 0) { fail('unsupported tag <' + tag + '>'); return; }
    var el = node.cloneNode(false), val = null, chk = null;
    for (var a = node.attributes.length - 1; a >= 0; a--) {
      var at = node.attributes[a], name = at.name, raw = at.value;
      if (name.indexOf('on') === 0 && name.length > 2) {
        el.removeAttribute(name);
        var fn = bindingValue(raw, scope);
        if (typeof fn === 'function') {
          var ev = eventName(node, name);
          el.addEventListener(ev, guard(fn));
          if (ev === 'click') el.setAttribute('data-dc-click', '');
        } else if (fn != null && raw.indexOf('{{') >= 0) fail('handler ' + raw + ' is not a function');
        continue;
      }
      if (raw.indexOf('{{') < 0) continue;
      var m = raw.match(ONE), v = m ? lookup(m[1], scope) : interp(raw, scope);
      if (name === 'value') val = v;
      if (name === 'checked') chk = v;
      if (m && BOOL_ATTRS[name]) { if (v && v !== 'false') el.setAttribute(name, ''); else el.removeAttribute(name); continue; }
      if (m && v == null) { el.removeAttribute(name); continue; }
      if (at.namespaceURI) el.setAttributeNS(at.namespaceURI, name, str(v)); else el.setAttribute(name, str(v));
    }
    renderNodes(node.childNodes, scope, el);
    // Live form state is a property, not an attribute (textarea ignores value="").
    if (val != null && (tag === 'textarea' || tag === 'input' || tag === 'select')) el.value = str(val);
    if (chk != null && tag === 'input') el.checked = !!chk && chk !== 'false';
    out.appendChild(el);
  }

  function bindingValue(raw, scope) {
    if (raw == null) return undefined;
    var m = raw.match(ONE);
    return m ? lookup(m[1], scope) : (raw.indexOf('{{') >= 0 ? interp(raw, scope) : raw);
  }

  function guard(fn) {
    return function (e) { try { fn.call(comp, e); } catch (err) { fail('handler: ' + (err && err.stack || err)); } };
  }

  function render() {
    var vals;
    try { vals = comp.renderVals ? comp.renderVals() : {}; } catch (err) { fail('renderVals: ' + (err && err.stack || err)); return; }
    // Keep focus and caret across re-renders so typing works.
    var act = document.activeElement, idx = -1, selS, selE;
    if (act && root.contains(act)) {
      idx = Array.prototype.indexOf.call(root.querySelectorAll('*'), act);
      try { selS = act.selectionStart; selE = act.selectionEnd; } catch (e) { /* not a text field */ }
    }
    var frag = document.createDocumentFragment();
    missing = {};
    renderNodes(tpl.childNodes, { vars: vals || {}, parent: null }, frag);
    root.replaceChildren(frag);
    var miss = Object.keys(missing);
    if (miss.length) document.documentElement.setAttribute('data-dc-missing', miss.join(','));
    if (idx >= 0) {
      var nu = root.querySelectorAll('*')[idx];
      if (nu && nu.localName === act.localName) {
        nu.focus();
        try { if (selS != null) nu.setSelectionRange(selS, selE); } catch (e) { /* not a text field */ }
      }
    }
    if (root.innerHTML.indexOf('{{') >= 0) fail('unreplaced {{ in render');
  }

  function readProps(script) {
    var decl = {}, props = {}, q = new URLSearchParams(location.search);
    try { decl = JSON.parse(script.getAttribute('data-props') || '{}'); } catch (err) { fail('data-props: ' + err); }
    Object.keys(decl).forEach(function (k) { props[k] = k === '$preview' ? Object.assign({}, decl[k]) : decl[k].default; });
    q.forEach(function (v, k) {
      if (k === 'klik') return;
      if (k === '_w' || k === '_h') { props.$preview = props.$preview || {}; props.$preview[k === '_w' ? 'width' : 'height'] = Number(v); return; }
      var d = decl[k];
      if (!d) { fail('unknown tweak "' + k + '" (have: ' + Object.keys(decl).filter(function (n) { return n !== '$preview'; }).join(', ') + ')'); return; }
      if (d.editor === 'boolean') {
        if (v !== 'true' && v !== 'false') { fail('tweak ' + k + ' must be true or false'); return; }
        props[k] = v === 'true';
      } else if (d.editor === 'enum' && d.options && d.options.indexOf(v) < 0) {
        fail('tweak ' + k + '=' + v + ' is not one of: ' + d.options.join(' / '));
      } else if (d.editor === 'number') props[k] = Number(v);
      else props[k] = v;
    });
    return props;
  }

  // Click by visible text: the first clickable element (document order) whose text is exactly it,
  // else the first clickable containing it, else the deepest match.
  function klik(text) {
    var all = root.querySelectorAll('*'), exact = null, best = null, deep = null;
    function texts(el) {
      return [(el.textContent || '').replace(/\s+/g, ' ').trim(), el.getAttribute('aria-label') || '', el.getAttribute('placeholder') || ''];
    }
    for (var i = 0; i < all.length; i++) {
      var el = all[i], t = texts(el);
      if (!t.some(function (s) { return s.indexOf(text) >= 0; })) continue;
      deep = el;
      if (el.hasAttribute('data-dc-click') || /^(a|button|label|input|select|summary)$/.test(el.localName) || /^(button|tab|checkbox|switch|radio|link)$/.test(el.getAttribute('role') || '')) {
        best = best || el;
        if (t.indexOf(text) >= 0) { exact = el; break; }
      }
    }
    var t = exact || best || deep;
    if (!t) { fail('klik: no element contains "' + text + '"'); return; }
    if (t.focus) t.focus();
    t.click();
  }

  // Type into the focused text field, else the first one, as a user would (fires `input`).
  function ketik(text) {
    var el = document.activeElement;
    if (!el || !root.contains(el) || !/^(input|textarea)$/.test(el.localName)) {
      el = root.querySelector('textarea, input:not([type=checkbox]):not([type=radio]):not([type=file]):not([type=hidden])');
    }
    if (!el) { fail('ketik: no text field for "' + text + '"'); return; }
    el.focus();
    el.value = text;
    el.dispatchEvent(new Event('input', { bubbles: true }));
  }

  function fonts() {
    var F = [['Plus Jakarta Sans', 'PlusJakartaSans', [[400, 'Regular'], [500, 'Medium'], [600, 'SemiBold'], [700, 'Bold']]],
      ['IBM Plex Mono', 'IBMPlexMono', [[400, 'Regular'], [500, 'Medium'], [600, 'SemiBold']]]];
    var css = '';
    F.forEach(function (f) {
      f[2].forEach(function (w) {
        css += "@font-face{font-family:'" + f[0] + "';font-style:normal;font-weight:" + w[0] + ";src:url('" + new URL('fonts/' + f[1] + '-' + w[1] + '.ttf', BASE) + "') format('truetype')}\n";
      });
    });
    // Under reduced motion the boards cut durations, not delays; an `animation: x .4s 1s both`
    // would then stay at its first keyframe (invisible), since virtual time does not run CSS animations.
    if (matchMedia('(prefers-reduced-motion: reduce)').matches) css += '*,*::before,*::after{animation-delay:0s!important}\n';
    var s = document.createElement('style');
    s.setAttribute('data-dc-fonts', '');
    s.textContent = css;
    document.head.appendChild(s);
  }

  function mount() {
    var x = document.querySelector('x-dc'), script = document.querySelector('script[data-dc-script]');
    if (!x || !script) { fail('no <x-dc> or data-dc-script'); return; }
    // Helmet styles go to <head>; the Google Fonts link is replaced by the same TTFs Flutter bundles.
    var helmet = x.querySelector('helmet');
    if (helmet) Array.prototype.slice.call(helmet.children).forEach(function (n) {
      if (n.localName === 'link' && /fonts\.googleapis/.test(n.href)) return;
      document.head.appendChild(n);
    });
    fonts();
    tpl = x;
    // A taller (or shorter) frame: the board root's inline height is the $preview size, so follow _h.
    var H = new URLSearchParams(location.search).get('_h'), pv;
    try { pv = JSON.parse(script.getAttribute('data-props') || '{}').$preview; } catch (err) { pv = null; }
    if (H && pv && pv.height) Array.prototype.forEach.call(x.children, function (n) {
      if (n.style && n.style.height === pv.height + 'px') n.style.height = H + 'px';
    });
    root = document.createElement('div');
    root.id = 'dc-root';
    root.style.display = 'contents';
    x.replaceWith(root);
    var Component;
    try { Component = new Function('DCLogic', script.textContent + '\n;return Component;')(DCLogic); } catch (err) { fail('logic: ' + (err && err.stack || err)); return; }
    try { comp = new Component(readProps(script)); } catch (err) { fail('constructor: ' + (err && err.stack || err)); return; }
    render();
    try { if (comp.componentDidMount) comp.componentDidMount(); } catch (err) { fail('componentDidMount: ' + err); }
    window.addEventListener('pagehide', function () { if (comp.componentWillUnmount) comp.componentWillUnmount(); });
    var steps = (new URLSearchParams(location.search).get('klik') || '').split('|').filter(Boolean);
    (function next() {
      if (!steps.length) {
        // Rendered and every klik done: harnesses wait for this.
        document.fonts.ready.then(function () { if (!errors.length) document.documentElement.setAttribute('data-dc', 'ok'); });
        return;
      }
      var step = steps.shift(), w = /^tunggu:(\d+)$/.exec(step);
      if (w) { setTimeout(next, Number(w[1])); return; }
      setTimeout(function () {
        if (step.indexOf('ketik:') === 0) ketik(step.slice(6)); else klik(step);
        setTimeout(next, 0);
      }, 400);
    })();
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', mount); else mount();
})();
