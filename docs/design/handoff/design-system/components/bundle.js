(function () {
  // Palakat tidak punya pustaka komponen web: aplikasinya Flutter, dan pratinjau di sini HTML biasa yang memakai token.
  // Berkas ini hanya memuat pemformat rupiah yang dipakai layar purwarupa.
  function rp(n) { var s = String(Math.abs(Math.round(n))).replace(/\B(?=(\d{3})+(?!\d))/g, '.'); return (n < 0 ? '\u2212' : '') + 'Rp' + s; }
  window.Palakat = Object.assign(window.Palakat || {}, { rp: rp });
})();
