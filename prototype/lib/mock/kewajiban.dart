// mock-data.md 2.10: Uang Muka, Titipan, Penggantian biaya.
import 'model.dart';

const _ptj = 'Pertanggungjawaban uang muka';

/// Phone Kewajiban and WebKasus (`state.kasus`). Section 3 row 12: WebKewajiban
/// adds Ibu Selvie Kalalo's advance and overspend claim ([kewajibanWeb]).
/// Row 13: the Rp850.000 settlement is November's own advance, not October.
/// Row 34: Panitia Natal advance sisa Rp650.000 here; Panitia / AlurPanitia
/// print their own figures.
const semuaKasus = [
  Kasus(
    id: 'um1',
    jenis: JenisKasus.uangMuka,
    judul: 'Panitia Natal',
    pihak: 'Sdr. Rivo Mandagi',
    awal: 1500000,
    awalCatatan: 'BKU-2026-0129 · 01/11/2026 · dari peruntukan Umum Jemaat',
    jatuhTempo: '30/11/2026',
    entri: [
      EntriKasus(
        nama: _ptj,
        noBukti: 'BKU-2026-0138',
        tanggal: '08/11/2026',
        catatan: 'menjadi Belanja',
        jumlah: 850000,
      ),
    ],
  ),
  Kasus(
    id: 'um2',
    jenis: JenisKasus.uangMuka,
    judul: 'Retret Pemuda',
    pihak: 'Sdri. Natalia Rumengan',
    awal: 800000,
    awalCatatan: 'BKU-2026-0112 · 20/10/2026 · dari peruntukan Umum Jemaat',
    jatuhTempo: '10/11/2026',
    lewatJatuhTempo: true,
    entri: [
      EntriKasus(
        nama: _ptj,
        noBukti: 'BKU-2026-0150',
        tanggal: '05/11/2026',
        catatan: 'menjadi Belanja',
        jumlah: 300000,
      ),
    ],
  ),
  Kasus(
    id: 'um3',
    jenis: JenisKasus.uangMuka,
    judul: 'Perjalanan dinas Wilayah',
    pihak: 'Pnt. Jefry Wowor',
    awal: 400000,
    awalCatatan: 'BKU-2026-0103 · 07/10/2026',
    entri: [
      EntriKasus(
        nama: _ptj,
        noBukti: 'BKU-2026-0149',
        tanggal: '03/11/2026',
        catatan: 'menjadi Belanja',
        jumlah: 400000,
      ),
    ],
  ),
  Kasus(
    id: 'tt1',
    jenis: JenisKasus.titipan,
    judul: 'Sentralisasi November',
    pihak: 'Sinode',
    awal: 2400000,
    awalCatatan: 'Dari 4 persembahan · disimpan di Bank BNI ··4821',
    entri: [
      EntriKasus(
        nama: 'Penyaluran',
        noBukti: 'BKU-2026-0136',
        tanggal: '07/11/2026',
        catatan: 'bukan Belanja',
        jumlah: 1000000,
      ),
    ],
  ),
  Kasus(
    id: 'tt2',
    jenis: JenisKasus.titipan,
    judul: 'Persembahan khusus',
    pihak: 'Wilayah',
    awal: 450000,
    awalCatatan: 'Dari persembahan khusus 9 November · disimpan di Kas',
  ),
  Kasus(
    id: 'pb1',
    jenis: JenisKasus.penggantianBiaya,
    judul: 'Alat kebersihan gereja',
    pihak: 'Ibu Selvie Kalalo',
    awal: 185000,
    awalCatatan: 'Nota 12/11/2026 terlampir · belum masuk saldo',
  ),
  Kasus(
    id: 'pb2',
    jenis: JenisKasus.penggantianBiaya,
    judul: 'Bensin antar jemput',
    pihak: 'Sdr. Rivo Mandagi',
    awal: 120000,
    awalCatatan: 'Nota 02/11/2026 terlampir',
    entri: [
      EntriKasus(
        nama: 'Penggantian biaya dibayar',
        noBukti: 'BKU-2026-0134',
        tanggal: '05/11/2026',
        catatan: 'Belanja, dicatat satu kali',
        jumlah: 120000,
      ),
    ],
  ),
];

/// New entries on Kewajiban/WebKasus are numbered from BKU-2026-0150
/// (`nomor: 150`, section 3 row 8) and dated 16/11/2026.
const kasusNomorBerikut = 150;

/// WebKewajiban rows `[jenis, judul, catatan, pihak, awal, terpakai, tempo,
/// lewat]`. Section 3 row 12.
const kewajibanWeb = [
  (
    jenis: 'um',
    judul: 'Panitia Natal',
    catatan: 'BKU-2026-0129 · 01/11/2026',
    pihak: 'Sdr. Rivo Mandagi',
    awal: 1500000,
    terpakai: 850000,
    tempo: 'Jatuh tempo 30/11/2026',
    lewat: false,
  ),
  (
    jenis: 'um',
    judul: 'Retret Pemuda',
    catatan: 'BKU-2026-0112 · 20/10/2026',
    pihak: 'Sdri. Natalia Rumengan',
    awal: 800000,
    terpakai: 300000,
    tempo: 'Lewat jatuh tempo (jatuh tempo: 10/11/2026)',
    lewat: true,
  ),
  (
    jenis: 'um',
    judul: 'Konsumsi syukur HUT',
    catatan: 'BKU-2026-0119 · 25/10/2026',
    pihak: 'Ibu Selvie Kalalo',
    awal: 300000,
    terpakai: 375000,
    tempo: '',
    lewat: false,
  ),
  (
    jenis: 'um',
    judul: 'Perjalanan dinas Wilayah',
    catatan: 'BKU-2026-0103 · 07/10/2026',
    pihak: 'Pnt. Jefry Wowor',
    awal: 400000,
    terpakai: 400000,
    tempo: '',
    lewat: false,
  ),
  (
    jenis: 'tt',
    judul: 'Sentralisasi November',
    catatan: 'Disimpan di Bank BNI ··4821',
    pihak: 'Sinode',
    awal: 2400000,
    terpakai: 1000000,
    tempo: '',
    lewat: false,
  ),
  (
    jenis: 'tt',
    judul: 'Persembahan khusus',
    catatan: 'Disimpan di Kas',
    pihak: 'Wilayah',
    awal: 450000,
    terpakai: 0,
    tempo: '',
    lewat: false,
  ),
  (
    jenis: 'pb',
    judul: 'Alat kebersihan gereja',
    catatan: 'Nota 12/11/2026 · klaim sudah dicek',
    pihak: 'Ibu Selvie Kalalo',
    awal: 185000,
    terpakai: 0,
    tempo: '',
    lewat: false,
  ),
  (
    jenis: 'pb',
    judul: 'Kelebihan konsumsi syukur HUT',
    catatan: 'Dari uang muka BKU-2026-0119',
    pihak: 'Ibu Selvie Kalalo',
    awal: 75000,
    terpakai: 0,
    tempo: '',
    lewat: false,
  ),
  (
    jenis: 'pb',
    judul: 'Bensin antar jemput',
    catatan: 'BKU-2026-0134 · 05/11/2026',
    pihak: 'Sdr. Rivo Mandagi',
    awal: 120000,
    terpakai: 120000,
    tempo: '',
    lewat: false,
  ),
];

/// KasusBaru: Kas/Bank choices with balances, and due dates.
const kasusBaruKasBank = [
  ('Kas', 8420000),
  ('Bank BNI ··4821', 24615000),
  ('Bank SulutGo ··1107', 5380000),
];
const kasusBaruJatuhTempo = [
  '30 November 2026',
  '15 Desember 2026',
  '31 Desember 2026',
];
