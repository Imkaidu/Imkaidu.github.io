/* Colour theme: Auto (follow the system), Light or Dark.
 *
 * Loaded synchronously from <head> (templates/default.html) so the saved choice
 * is applied before first paint -- otherwise a dark-mode visitor gets a white
 * flash on every page load. "Auto" means NO data-theme attribute: css/custom.css
 * then follows prefers-color-scheme by itself, which is also the no-JavaScript
 * behaviour. Storage can be blocked or throw (private windows), so every access
 * is wrapped and the page still works, just without remembering the choice. */
(function () {
  var KEY = 'theme';
  var root = document.documentElement;
  root.classList.remove('no-js');   // the theme picker is hidden without JavaScript

  function stored() {
    try {
      var v = localStorage.getItem(KEY);
      return v === 'light' || v === 'dark' ? v : 'auto';
    } catch (e) {
      return 'auto';
    }
  }

  function apply(theme) {
    if (theme === 'light' || theme === 'dark') {
      root.setAttribute('data-theme', theme);
    } else {
      root.removeAttribute('data-theme');
    }
  }

  apply(stored());

  document.addEventListener('DOMContentLoaded', function () {
    var select = document.getElementById('theme-select');
    if (!select) { return; }
    select.value = stored();
    select.addEventListener('change', function () {
      var theme = select.value;
      try {
        if (theme === 'auto') { localStorage.removeItem(KEY); }
        else { localStorage.setItem(KEY, theme); }
      } catch (e) { /* choice applies for this page view only */ }
      apply(theme);
    });
  });
})();
