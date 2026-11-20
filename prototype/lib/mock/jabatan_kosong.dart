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
