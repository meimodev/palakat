// mock-data.md 2.2 (people, families, other parties) and 2.3 (posts,
// Pelimpahan). Names are invented (R02).
import 'model.dart';

/// Bendahara Jemaat, aktif sejak 15/09/2026 · SK-BPMJ-04-2026. Verified by
/// Petugas verifikasi 15/09/2026 10.15. Penunjukan sent 13/09/2026 09.05 and
/// 14/09/2026 15.20. Authority revoked 16/11/2026 08.10 in the vacancy
/// scenario (jabatan_kosong.dart).
const orangMeiske = Orang(
  id: 'meiske',
  nama: 'Meiske Lumentut',
  namaPendek: 'Meiske L.',
  email: 'meiske@contoh.id', // WebVerifikasi
);

/// Sekretaris Jemaat, sejak 03/11/2026 · SK BPMJ No. 12/2026 (WebAkunSaya).
const orangOlvie = Orang(
  id: 'olvie',
  nama: 'Olvie Pangemanan',
  ponsel: '081355512204',
  email: 'olvie@contoh.id',
);

/// Operator sejak 01/11/2026; runs the vacant Penatua Kolom 2 since
/// 01/11/2026 and the vacant Bendahara Jemaat since 16/11/2026 08.15
/// (scenario). "Yanti Sumual, Operator"; "Yanti S." on Kehadiran. Keluarga
/// Sumual is her own family (Kolom 2).
const orangYanti = Orang(
  id: 'yanti',
  nama: 'Yanti Sumual',
  namaPendek: 'Yanti S.',
  kolom: 'Kolom 2',
  keluarga: 'Keluarga Sumual',
);

/// Ketua Jemaat sejak 01/01/2026 · Ketua BPMJ; Pimpinan Jemaat yang
/// berwenang. Gives the persetujuan for the format, Belanja, Panitia and
/// modules (R01).
const orangLidya = Orang(id: 'lidya', nama: 'Pdt. Lidya Rondonuwu');

/// Wakil Ketua BPMJ sejak 01/01/2026; Pemeriksa kedua; Petugas penghitung;
/// Uang Muka "Perjalanan dinas Wilayah"; readiness of Umum Jemaat 02/11/2026.
const orangJefry = Orang(id: 'jefry', nama: 'Pnt. Jefry Wowor');

/// Penatua Kolom 7 sejak 01/01/2026; Ketua Komisi Diakonia sejak 01/03/2026.
/// No backup email (AkunSaya).
const orangHendrik = Orang(
  id: 'hendrik',
  nama: 'Pnt. Hendrik Rumagit',
  kolom: 'Kolom 7',
  keluarga: 'Keluarga Rumagit',
  ponsel: '081234567890',
);

/// Bendahara Kolom 7; manages Kas Kolom 7.
const orangDeasy = Orang(id: 'deasy', nama: 'Deasy Tumbelaka');

/// Ketua Panitia Natal 2026.
const orangStevi = Orang(
  id: 'stevi',
  nama: 'Sdr. Stevi Lengkong',
  namaPendek: 'Stevi Lengkong',
);

/// Sekretaris Panitia Natal 2026; Uang Muka "Retret Pemuda".
const orangNatalia = Orang(
  id: 'natalia',
  nama: 'Sdri. Natalia Rumengan',
  namaPendek: 'Natalia Rumengan',
);

/// Bendahara Panitia Natal 2026; "Ketua Pemuda" (PermintaanDana); preparer
/// of peruntukan Pembangunan (Kesiapan). Uang Muka "Panitia Natal"; claim
/// "Bensin antar jemput".
const orangRivo = Orang(
  id: 'rivo',
  nama: 'Sdr. Rivo Mandagi',
  namaPendek: 'Rivo Mandagi',
);

/// Anggota jemaat. Kolom 7 sejak 01/06/2021 (Kolom 4 12/02/2009 –
/// 31/05/2021); BIPRA Pemuda ("Dasar: 30 tahun dan belum pernah menikah.");
/// Baptisan 19/05/1996, Sidi 13/04/2014; old number "0812 ···· 7741", new
/// 081298765432 (AlurPulihkan).
/// Section 3 row 31: DataAnggota, ImporBuku show her Aktif in Kolom 7 since
/// 2021; PermohonanAnggota, AntreanVerifikasi replay her joining
/// (16/11/2026, verified 17/11/2026). Row 30: display name differs by board.
const orangNovita = Orang(
  id: 'novita',
  nama: 'Novita Wenas',
  kolom: 'Kolom 7',
  keluarga: 'Keluarga Wenas-Lasut',
  lahir: '14/03/1996',
  statusPernikahan: 'Belum pernah menikah',
  statusData: 'Aktif',
  ponsel: '081298765432',
);

/// Wakil keluarga Wenas-Lasut.
const orangAgustina = Orang(
  id: 'agustina',
  nama: 'Agustina Lasut',
  kolom: 'Kolom 7',
  keluarga: 'Keluarga Wenas-Lasut',
  lahir: '12/12/1974',
);

/// "WENAS FERRY, lhr 3-8-71, Kol 7", diimpor 12/11/2026.
/// Section 3 row 28: ImporBuku, KonfirmasiKeluarga, AlurKeluarga → Kolom 7;
/// CariOrang → "Data jemaat · Kolom 2"; AlurJabatanKosong → a Kolom 2
/// membership request. Each board keeps its own.
const orangFerry = Orang(
  id: 'ferry',
  nama: 'Ferry Wenas',
  kolom: 'Kolom 7',
  keluarga: 'Keluarga Wenas-Lasut',
  lahir: '03/08/1971',
  statusData: 'Belum dikonfirmasi',
);

/// Child; Baptisan 08/11/2026, name on certificate "Gabriel J. Wenas".
const orangGabriel = Orang(
  id: 'gabriel',
  nama: 'Gabriel Wenas',
  kolom: 'Kolom 7',
  keluarga: 'Keluarga Wenas-Lasut',
);

/// Bendahara Komisi Diakonia; "Akses terbatas: Peruntukan Diakonia";
/// Petugas penghitung.
const orangOlga = Orang(id: 'olga', nama: 'Dkn. Olga Tamba');

/// Syamas Kolom 7; Pelimpahan "Verifikasi data Kolom 7".
const orangGreis = Orang(
  id: 'greis',
  nama: 'Sym. Greis Mamahit',
  namaPendek: 'Greis M.',
);

/// Penatua Kolom 2, 01/01/2022 – 31/10/2026; assigned again from 16/11/2026
/// in AlurJabatanKosong.
const orangAltje = Orang(id: 'altje', nama: 'Pnt. Altje Rompas');

/// Kolom 2, 03/02/1948 – 14/11/2026.
const orangYohanisR = Orang(
  id: 'yohanisR',
  nama: 'Yohanis Rompas',
  kolom: 'Kolom 2',
  lahir: '03/02/1948',
  statusData: 'Meninggal dunia',
);

/// Permohonan menjadi anggota, Kolom 2, diajukan 15/11/2026.
const orangKevin = Orang(id: 'kevin', nama: 'Kevin Rompas', kolom: 'Kolom 2');

/// Peristiwa Sidi, Kolom 2, diajukan 12/11/2026.
const orangGabriela = Orang(
  id: 'gabriela',
  nama: 'Gabriela Rompas',
  kolom: 'Kolom 2',
);

/// Uang Muka "Konsumsi syukur HUT"; claim "Alat kebersihan gereja".
const orangSelvie = Orang(id: 'selvie', nama: 'Ibu Selvie Kalalo');

/// Section 3 row 18: new Bendahara Jemaat on Bendahara/WebSerahTerima,
/// "aktif sejak 16/11/2026 · SK-BPMJ-09-2026".
const orangYohanisT = Orang(id: 'yohanisT', nama: 'Yohanis Tumbelaka');

/// Section 3 row 18: new Bendahara Jemaat on JabatanKosong/WebJabatanKosong,
/// "wewenang aktif sejak 18/11/2026".
const orangDeitje = Orang(id: 'deitje', nama: 'Deitje Kawengian');

const semuaOrang = [
  orangMeiske,
  orangOlvie,
  orangYanti,
  orangLidya,
  orangJefry,
  orangHendrik,
  orangDeasy,
  orangStevi,
  orangNatalia,
  orangRivo,
  orangNovita,
  orangAgustina,
  orangFerry,
  orangGabriel,
  orangOlga,
  orangGreis,
  orangAltje,
  orangYohanisR,
  orangKevin,
  orangGabriela,
  orangSelvie,
  orangYohanisT,
  orangDeitje,
];

// ---------- Families and other parties ----------

/// Kolom 7, diimpor 12/11/2026; display "Kel. Wenas-Lasut — Kolom 7".
const keluargaWenasLasut = Keluarga(
  nama: 'Keluarga Wenas-Lasut',
  kolom: 'Kolom 7',
  wakil: 'Agustina Lasut',
  anggota: ['Ferry', 'Agustina', 'Novita', 'Gabriel'],
);
const keluargaWenasLasutTeks = '4 orang: Ferry, Agustina, Novita, Gabriel';
const keluargaWenasLasutTampil = 'Kel. Wenas-Lasut — Kolom 7';

/// Kolom 4 → Kolom 7, "berlaku 01/12/2026"; Atestasi "pindah ke Jemaat lain".
const keluargaLasut = Keluarga(nama: 'Keluarga Lasut', kolom: 'Kolom 4');

/// Perubahan data diajukan 14/11/2026, forwarded to the Syamas.
const keluargaRumagit = Keluarga(nama: 'Keluarga Rumagit', kolom: 'Kolom 7');

/// Perubahan data diajukan 15/11/2026.
const keluargaSumual = Keluarga(nama: 'Keluarga Sumual', kolom: 'Kolom 2');

/// Sampul syukur shown by exception (BukaNama).
const keluargaMamahitTampil = 'Kel. Mamahit — Kolom 4';

/// Bank mutation "TRF MASUK IBU RUNTU" 28/10/2026.
const pihakIbuRuntu = 'Ibu Runtu';

/// Toko Sinar is the October split payment and the September duplicate.
const tokoSinar = (nama: 'TOKO SINAR', alamat: 'Jl. Pierre Tendean 7');

/// Receipt of the sound system, 11/11/2026, "LUNAS".
const cvNadaPrima = (nama: 'CV NADA PRIMA', alamat: 'Jl. Sam Ratulangi 14');

/// Titipan recipients.
const penerimaTitipan = ['Sinode', 'Wilayah'];

/// Appoints the Bendahara; "Pdt. Lidya Rondonuwu, Ketua".
const bpmj = 'BPMJ Jemaat Karunia';

/// Verifies treasurer and secretary appointments.
const petugasVerifikasi = 'Petugas verifikasi';

// ---------- 2.3 Posts (Penugasan board), in board order ----------

const penugasan = [
  Penugasan(
    jabatan: 'Bendahara Jemaat',
    orangId: 'meiske',
    status: StatusPenugasan.aktif,
    keterangan: 'Sejak 15/09/2026 · wewenang sudah diverifikasi',
  ),

  /// Section 3 row 16: AlurJabatanKosong tells it as "Kosong sejak
  /// 31/10/2026", filled by Altje Rompas from 16/11/2026; DataAnggota,
  /// Peristiwa tie it to the death of Yohanis Rompas (14/11/2026).
  Penugasan(
    jabatan: 'Penatua Kolom 2',
    status: StatusPenugasan.jabatanKosong,
    keterangan: 'Dijalankan Operator Yanti Sumual sejak 01/11/2026',
  ),

  /// Section 3 row 40: state `Menunggu verifikasi wewenang` uses
  /// [penugasanSekretarisMenunggu].
  Penugasan(
    jabatan: 'Sekretaris Jemaat',
    orangId: 'olvie',
    status: StatusPenugasan.aktif,
    keterangan: 'Sejak 03/11/2026 · SK BPMJ No. 12/2026',
    dasar: 'SK BPMJ No. 12/2026',
  ),
  Penugasan(
    jabatan: 'Ketua Jemaat',
    orangId: 'lidya',
    status: StatusPenugasan.aktif,
    keterangan: 'Sejak 01/01/2026 · Ketua BPMJ',
  ),
  Penugasan(
    jabatan: 'Wakil Ketua BPMJ',
    orangId: 'jefry',
    status: StatusPenugasan.aktif,
    keterangan: 'Sejak 01/01/2026',
  ),
  Penugasan(
    jabatan: 'Ketua Komisi Diakonia',
    orangId: 'hendrik',
    status: StatusPenugasan.aktif,
    keterangan: 'Sejak 01/03/2026',
  ),
  Penugasan(
    jabatan: 'Operator',
    orangId: 'yanti',
    status: StatusPenugasan.aktif,
    keterangan: 'Sejak 01/11/2026',
  ),
  Penugasan(
    jabatan: 'Penatua Kolom 7',
    orangId: 'hendrik',
    status: StatusPenugasan.aktif,
    keterangan: 'Sejak 01/01/2026',
  ),
  Penugasan(
    jabatan: 'Syamas Kolom 3',
    status: StatusPenugasan.jabatanKosong,
    keterangan: 'Belum ada yang menjalankan',
  ),
  Penugasan(
    jabatan: 'Penatua Kolom 2',
    orangId: 'altje',
    status: StatusPenugasan.berakhir,
    keterangan: '01/01/2022 – 31/10/2026',
  ),
];

const penugasanSekretarisMenunggu = Penugasan(
  jabatan: 'Sekretaris Jemaat',
  orangId: 'olvie',
  status: StatusPenugasan.menungguVerifikasi,
  keterangan: 'Olvie Pangemanan · dicatat 03/11/2026',
  dasar: 'SK BPMJ No. 12/2026',
);

/// Other posts drawn outside the Penugasan list.
const penugasanLain = [
  (jabatan: 'Syamas Kolom 7', nama: 'Sym. Greis Mamahit'),
  (jabatan: 'Bendahara Kolom 7', nama: 'Deasy Tumbelaka'),
  (jabatan: 'Bendahara Komisi Diakonia', nama: 'Dkn. Olga Tamba'),
];

/// AlurPenugasan's own table: jabatan · unit · orang · sejak ('' = empty).
const alurPenugasanBaris = [
  (jabatan: 'Syamas', unit: 'Kolom 3', orang: '', sejak: ''),
  (jabatan: 'Penatua', unit: 'Kolom 2', orang: '', sejak: ''),
  (
    jabatan: 'Ketua',
    unit: 'Komisi Diakonia',
    orang: 'Pnt. Hendrik Rumagit',
    sejak: '01/03/2026',
  ),
  (
    jabatan: 'Operator',
    unit: 'Jemaat',
    orang: 'Yanti Sumual',
    sejak: '01/11/2026',
  ),
];
const alurPenugasanSaran = [
  'Sym. Greis Mamahit',
  'Pnt. Altje Rompas',
  'Pdt. Lidya Rondonuwu',
];
const alurPenugasanDokumen = ['SK BPMJ No. 14/2026', 'Belum ada dokumen'];

const pelimpahan = [
  Pelimpahan(
    dari: 'Penatua Kolom 7',
    kepada: 'Sym. Greis Mamahit',
    tugas: 'Verifikasi data Kolom 7',
    mulai: '16/11/2026',
    sampai: '30/11/2026',
    status: 'Aktif',
  ),
  Pelimpahan(
    dari: 'Sekretaris Jemaat',
    kepada: 'Yanti Sumual',
    tugas: 'Menyusun draf pengumuman',
    mulai: '03/11/2026',
    sampai: '10/11/2026',
    status: 'Berakhir',
  ),
];
