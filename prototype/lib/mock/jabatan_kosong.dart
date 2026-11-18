// mock-data.md 4.2: the vacancy scenario (R04, global switch
// `jabatanKosong`): the Operator Yanti Sumual runs the vacant Bendahara
// Jemaat post.

const jkPencabutan =
    'Wewenang Meiske Lumentut dicabut pada 16/11/2026 08.10 oleh Petugas verifikasi, atas permintaan BPMJ. Semua sesinya sudah diakhiri.'; // Bendahara

/// WebPengaturan / WebSerahTerima: plain text, then a bold part. The bold
/// part ends with a period on WebSerahTerima, without one on WebPengaturan.
const jkPencabutanWeb = (
  'Wewenang Meiske Lumentut dicabut pada 16/11/2026 08.10 oleh Petugas verifikasi. Semua data hanya dapat dilihat. ',
  'Yang perlu bertindak: BPMJ Jemaat Karunia',
);

/// Riwayat line prepended in the vacant state (WebPengaturan also drops its
/// 16/11 rows).
const jkRiwayat = (
  waktu: '16/11/2026 08.10',
  teks: 'Mencabut wewenang Bendahara Meiske Lumentut · semua sesi diakhiri',
);
const jkDiambilAlihPada = '16/11/2026 08.15';

/// Phone strip (finance boards): bold part, then the rest.
const jkPita = ('Menjalankan jabatan kosong', ' · Bendahara Jemaat');

/// Web side-nav footer user: (bold name, role, second line).
const navPenggunaNormal = (
  'Meiske L.',
  ' · Bendahara',
  'Wewenang Bendahara aktif',
);
const navPenggunaJk = (
  'Yanti Sumual',
  ' · Operator',
  'Menjalankan jabatan kosong Bendahara Jemaat',
);

const jkPitaWeb =
    'Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15. Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual.';

/// The boards' `plk`.
String plk(bool jabatanKosong) =>
    jabatanKosong ? 'Yanti Sumual, Operator' : 'Meiske L.';

/// The boards' `plk2`.
String plk2(bool jabatanKosong) => jabatanKosong
    ? 'Yanti Sumual, Operator (menjalankan jabatan kosong Bendahara Jemaat)'
    : 'Meiske L.';

/// TutupBuku, WebTutupBuku; "Yanti Sumual, Operator" is bold. mock-data.md
/// 4.2 says a space comes before the comma, but every board source reads
/// "Operator</strong>, yang": the board wins, no space.
const jkDitutupOleh =
    'Ditutup oleh Yanti Sumual, Operator, yang menjalankan jabatan kosong Bendahara Jemaat. Nama dan keadaan ini tercatat pada tutup buku.';
const jkPemeriksaKedua =
    'Menjalankan jabatan kosong tidak menggantikan orang kedua. Yang dapat memeriksa: Pnt. Jefry Wowor.';

/// JabatanKosong. Section 3 row 18: Bendahara/WebSerahTerima name Yohanis
/// Tumbelaka instead.
const jkTerisi =
    'Bendahara Jemaat sudah terisi: Deitje Kawengian, wewenang aktif sejak 18/11/2026.';

/// The other vacancy: Penatua Kolom 2, run by Yanti Sumual since 01/11/2026
/// (Penugasan, BerandaJabatan, AntreanVerifikasi, AlurJabatanKosong).
const jkLain = 'Penatua Kolom 2';

/// Boards whose logic class runs `tukarJk` (`if (jk && true)`). Every other
/// board with the `jabatanKosong` tweak shows the strip, band and plk/plk2
/// names but rewrites no other string.
const papanTukarJk = {
  'AIMataAnggaran', 'Draf', 'Dokumen', 'Koreksi', 'Main', 'LihatDokumen', //
  'MataAnggaran', 'RekonIsi', 'TutupBuku', 'WebAIMataAnggaran', 'WebDokumen',
  'WebDraf', 'WebKoreksi', 'WebLihatDokumen', 'WebMataAnggaran',
  'WebRekonIsi', 'WebRekonsiliasi', 'WebTutupBuku',
};

final _tanggal = RegExp(r'\d\d/\d\d/\d{4}');

/// The boards' `tukarJk` on one string: when it contains "Meiske L." and
/// every dd/mm/yyyy date in it is 16/11/2026 (or it has none), each
/// "Meiske L." becomes "Yanti Sumual, Operator". A trailing period is not
/// special: "oleh Meiske L." becomes "oleh Yanti Sumual, Operator" (the dot
/// is part of the name).
String tukarJk(String s) {
  if (!s.contains('Meiske L.')) return s;
  if (_tanggal.allMatches(s).any((m) => m[0] != '16/11/2026')) return s;
  return s.replaceAll('Meiske L.', 'Yanti Sumual, Operator');
}

/// [tukarJk] applied only where [stem]'s board enables it and the switch is
/// on; otherwise [s] unchanged.
String tukarJkPapan(String stem, bool jabatanKosong, String s) =>
    jabatanKosong && papanTukarJk.contains(stem) ? tukarJk(s) : s;

/// The board walk: strings inside nested Lists and Maps (values only, depth
/// at most 6 as on the canvas) go through [tukarJk]; a new structure is
/// returned, other values are kept.
Object? tukarJkDalam(Object? o, [int d = 0]) {
  if (o is String) return tukarJk(o);
  if (d > 5) return o;
  Object? satu(Object? v) => v is String ? tukarJk(v) : tukarJkDalam(v, d + 1);
  if (o is List) return [for (final v in o) satu(v)];
  if (o is Map) return {for (final e in o.entries) e.key: satu(e.value)};
  return o;
}
