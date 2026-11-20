// mock-data.md 2.18: member data.
import 'model.dart';

/// LaporanLintas counts, Seluruh Jemaat.
const lintasSeluruhJemaat = (
  anggotaAktif: '1.284',
  anggotaKeterangan: 'di 12 Kolom',
  keluarga: '412',
  peristiwa: '7',
  peristiwaKeterangan: '2 kelahiran · 3 baptisan · 1 pernikahan · 1 kematian',
  kehadiran: '412', // Jumlah kehadiran Minggu 15/11/2026
);

/// LaporanLintas counts, Kolom 7.
const lintasKolom7 = (
  anggotaAktif: '96',
  anggotaKeterangan: 'Kolom 7 saja',
  keluarga: '31',
  peristiwa: '2',
  kehadiran: '38',
);

/// Paper-book import (ImporBuku). `keadaan` is a code, not display text:
/// 'ok', 'ganda' (possible duplicate of the Aktif record), 'tidak' (not
/// imported).
const imporBukuRingkasan =
    '28 baris · 26 sudah diimpor · 1 kemungkinan ganda · 1 tidak diimpor';
const imporBukuBaris = [
  (
    nama: 'Ferry Wenas',
    sumber: 'WENAS FERRY, lhr 3-8-71, Kol 7',
    keadaan: 'ok',
  ),
  (
    nama: 'Agustina Lasut',
    sumber: 'LASUT AGUSTINA (istri), 12-12-74',
    keadaan: 'ok',
  ),
  (nama: 'Novita Wenas', sumber: 'WENAS NOVITA, 14-3-96', keadaan: 'ganda'),
  (nama: '—', sumber: 'RUMAGIT H., tgl lhr tdk terbaca', keadaan: 'tidak'),
];

/// AlurKeluarga: the value of the "Sumber" row.
const alurKeluargaSumber = 'Buku anggota Kolom 7 · 2019–2026';
const alurKeluargaHasil = '3 orang';
const alurKeluargaHasilDigabung =
    '3 orang (Novita Wenas digabung dengan data yang sudah ada)';

/// KonfirmasiKeluarga: confirmed by Agustina Lasut 16/11/2026 19.30; paper
/// form uploaded by Pnt. Hendrik Rumagit 16/11/2026, entered by Yanti
/// Sumual; verified 17/11/2026 19.05 (section 3 row 35: after "today").
const konfirmasiKeluarga = (
  dikonfirmasiOleh: 'Agustina Lasut',
  dikonfirmasiPada: '16/11/2026 19.30',
  formulirDiunggahOleh: 'Pnt. Hendrik Rumagit',
  formulirDiunggahPada: '16/11/2026',
  dimasukkanOleh: 'Yanti Sumual',
  diverifikasiPada: '17/11/2026 19.05',
);

/// Peristiwa. Baptisan of Gabriel Wenas: Diajukan by Novita Wenas
/// 15/11/2026, Dikembalikan 16/11/2026, Diverifikasi 17/11/2026.
/// Section 3 row 17: Peristiwa shows the death Diverifikasi
/// ("14/11/2026 · diajukan keluarga"); AntreanVerifikasi shows it Diajukan
/// ("Kolom 2 · diajukan keluarga 16/11/2026").
const semuaPeristiwa = [
  Peristiwa(
    jenis: 'Baptisan',
    untuk: 'Gabriel Wenas',
    tanggal: '08/11/2026',
    status: 'Diajukan',
  ),
  Peristiwa(
    jenis: 'Kematian',
    untuk: 'Yohanis Rompas',
    tanggal: '14/11/2026',
    status: 'Diverifikasi',
  ),
  Peristiwa(
    jenis: 'Pindah Kolom',
    untuk: 'Keluarga Lasut',
    tanggal: '01/12/2026', // Kolom 4 → Kolom 7, berlaku 01/12/2026
    status: 'Diajukan',
  ),
  Peristiwa(
    jenis: 'Sidi',
    untuk: 'Gabriela Rompas',
    tanggal: '12/11/2026', // Kolom 2, diajukan
    status: 'Diajukan',
  ),
];
const baptisanGabriel = (
  diajukanOleh: 'Novita Wenas',
  diajukan: '15/11/2026',
  dikembalikan: '16/11/2026',
  diverifikasi: '17/11/2026',
  namaSertifikat: 'Gabriel J. Wenas',
);

/// AntreanVerifikasi, Kolom 7 (board `antre`).
const antreanKolom7 = [
  ItemKotak(
    judul: 'Permohonan menjadi anggota · Novita Wenas',
    sub: 'Diajukan 16/11/2026 · izin data pribadi diberikan',
    label: 'Diajukan',
    gaya: GayaLabel.garis,
  ),
  ItemKotak(
    judul: 'Konfirmasi keluarga · Wenas-Lasut',
    sub: '4 orang dari buku anggota',
    label: 'Diajukan',
    gaya: GayaLabel.garis,
  ),
  ItemKotak(
    judul: 'Peristiwa: Baptisan · Gabriel Wenas',
    sub: 'Diajukan 15/11/2026',
    label: 'Diajukan',
    gaya: GayaLabel.garis,
  ),
  ItemKotak(
    judul: 'Peristiwa: Pindah Kolom · Keluarga Lasut',
    sub: 'Dari Kolom 4 ke Kolom 7 · berlaku 01/12/2026',
    label: 'Diajukan',
    gaya: GayaLabel.garis,
  ),
  ItemKotak(
    judul: 'Perubahan data · Keluarga Rumagit',
    sub: 'Milik keluarga Anda sendiri · diteruskan ke Syamas Kolom 7',
    label: 'Ke Syamas',
    gaya: GayaLabel.abu,
  ),
];

/// AntreanVerifikasi, Kolom 2 (vacant; board `antre2`). Section 3 row 17.
const antreanKolom2 = [
  ItemKotak(
    judul: 'Permohonan menjadi anggota · Kevin Rompas',
    sub: 'Kolom 2 · diajukan 15/11/2026',
    label: 'Diajukan',
    gaya: GayaLabel.garis,
  ),
  ItemKotak(
    judul: 'Peristiwa: Kematian · Yohanis Rompas',
    sub: 'Kolom 2 · diajukan keluarga 16/11/2026',
    label: 'Diajukan',
    gaya: GayaLabel.garis,
  ),
];

/// AlurJabatanKosong (Kolom 2): (judul, sub). Section 3 row 28: Ferry Wenas
/// applies in Kolom 2 here.
const alurJabatanKosongAntrean = [
  (
    'Permohonan menjadi anggota · Ferry Wenas',
    'Diajukan 14/11/2026 · izin data pribadi diberikan',
  ),
  ('Peristiwa: Sidi · Gabriela Rompas', 'Diajukan 12/11/2026'),
  ('Perubahan data · Keluarga Sumual', 'Diajukan 15/11/2026'), // own family
];

/// PermohonanAnggota (section 3 row 31: replays Novita joining).
const permohonanAnggota = (
  diajukan: 'Diajukan 16/11/2026 10.12',
  dikembalikan: '17/11/2026 08.40',
  diverifikasi: '17/11/2026 19.05',
  izin: 'Naskah versi 1 · 12/11/2026',
);

/// Display name (TampilanNama, AlurNama): (pilihan, tampil). Where
/// TampilanNama prints differently it is the third field ('' = same).
/// Section 3 row 30: Novita's display name differs by board and state.
const tampilanNama = [
  ('Nama lengkap', 'Novita Wenas', ''),
  ('Nama keluarga', 'Kel. Wenas-Lasut', ''),
  ('Keluarga + Kolom', 'Kel. Wenas-Lasut — Kolom 7', ''),
  ('Kolom', 'Anggota Kolom 7', 'Kolom 7'),
  ('BIPRA', 'Pemuda', ''),
  ('BIPRA + Kolom', 'Anggota Pemuda Kolom 7', 'Pemuda — Kolom 7'),
  ('Tanpa nama', 'Tanpa nama', ''),
];
const tampilanNamaPeringatan = 'Kolom 7 hanya punya dua anggota Pemuda.';
const tampilanNamaPeringatanContoh = 'Tampil sebagai: Remaja — Kolom 11';

/// CariOrang, query "Wenas" (board `H[0]`; the second `keadaan` shows the
/// first two rows). `Tidak ada hasil`: query "Rumengan". Section 3 rows
/// 28–29: Ferry in Kolom 2, sampul syukur 08/11/2026 on this board.
const cariOrangKueri = 'Wenas';
const cariOrangKueriKosong = 'Rumengan';
const cariOrangHasil = [
  ItemKotak(
    judul: 'Novita Wenas',
    sub: 'Data jemaat · Keluarga Wenas-Lasut · Kolom 7',
    label: 'Aktif',
    gaya: GayaLabel.laut,
  ),
  ItemKotak(
    judul: 'Keluarga Wenas-Lasut',
    sub: 'Data jemaat · 4 orang · Kolom 7',
  ),
  ItemKotak(
    judul: 'Ferry Wenas',
    sub: 'Data jemaat · Kolom 2',
    label: 'Belum dikonfirmasi',
    gaya: GayaLabel.draf,
  ),
  ItemKotak(
    judul: 'Novita Wenas',
    sub: 'Dokumen gereja · Surat keterangan 15/11/2026',
    label: 'Diterbitkan',
    gaya: GayaLabel.tinta,
  ),
  ItemKotak(
    judul: 'Kel. Wenas-Lasut',
    sub: 'Keuangan · Sampul syukur 08/11/2026',
    label: 'Dibukukan',
    gaya: GayaLabel.tinta,
  ),
];

/// Persembahan saya (Novita): (judul, jumlah, sub, noBukti).
const persembahanSaya = [
  (
    'Sampul syukur',
    100000,
    '01/11/2026 · Ibadah Minggu Pagi · Umum Jemaat',
    'BKU-2026-0132',
  ),
  (
    'Persembahan persepuluhan',
    300000,
    '04/10/2026 · Ibadah Minggu Pagi · Umum Jemaat',
    '',
  ),
  ('Sampul syukur', 150000, '20/09/2026 · Ibadah Minggu Pagi · Diakonia', ''),
];

/// Cabut izin.
const cabutIzin = (
  judul: 'Permintaan hapus · Ferry Wenas',
  dicatatOleh: 'Yanti Sumual',
  dicatatPada: '16/11/2026',
  dihapusPada: '17/11/2026 20.15',
  dihapusOleh: 'Pnt. Hendrik Rumagit',
);

/// Data ganda: Novita Wenas, Belum dikonfirmasi.
const dataGandaOleh = 'Oleh Yanti Sumual, Operator · 17/11/2026 09.20';

/// Recovery (AlurPulihkan).
const alurPulihkan = (
  nama: 'Novita Wenas',
  kolom: 'Kolom 7',
  nomorLama: '0812 ···· 7741',
  nomorBaru: '081298765432',
  dimintaOleh: 'Yanti Sumual',
  dipastikanOleh: 'Pnt. Hendrik Rumagit',
);

/// Sign-in (AlurMasuk). The code 123456 is prototype-only (Keadaan panel).
const alurMasuk = (
  contohNomor: '081234567890',
  kode: '123456',
  cocok: 'Novita Wenas, 14/03/1996',
  cocokKolom: 'Kolom 7', // chip after the "Satu data cocok" label
);

/// Akun saya (Hendrik, phone) and WebAkunSaya (Olvie).
const akunSaya = (
  ponsel: '081234567890',
  emailCadangan: '', // no backup email
  perangkatLain: 'Ponsel lain · Samsung A15 · terakhir 12/11/2026',
  nomorBaruContoh: '081298765432',
);
const akunSayaWeb = (ponsel: '081355512204', email: 'olvie@contoh.id');
