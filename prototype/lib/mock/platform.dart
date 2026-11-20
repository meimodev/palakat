// mock-data.md 2.16 (notifications, KotakMasuk, BerandaJabatan), 2.17
// (modules) and 2.21 (settings, sessions, history).
import 'model.dart';

// ---------- 2.16 Round-1 Pemberitahuan (phone and web) ----------

const pemberitahuan = [
  Pemberitahuan(
    id: 'n1',
    jenis: 'tindak',
    judul: 'Oktober 2026 belum ditutup',
    sub: '1 hambatan · bulan berikutnya untuk tutup buku',
    waktu: 'Hari ini 08.00',
  ),
  Pemberitahuan(
    id: 'n2',
    jenis: 'file',
    judul: 'File Excel laporan gagal dibuat',
    sub: 'Laporan resmi September 2026 · cukup dibuat lagi',
    waktu: 'Hari ini 07.42',
  ),
  Pemberitahuan(
    id: 'n3',
    jenis: 'tempo',
    judul: 'Uang muka lewat jatuh tempo',
    sub: 'Retret Pemuda · sisa Rp500.000 · jatuh tempo 10/11/2026',
    waktu: '11/11/2026',
  ),
  Pemberitahuan(
    id: 'n4',
    jenis: 'tindak',
    judul: '1 dokumen pendukung wajib, belum ada',
    sub: 'BKU-2026-0143 · Sewa sound system',
    waktu: '11/11/2026',
  ),
  Pemberitahuan(
    id: 'n5',
    jenis: 'ai',
    judul: 'AI sedang tidak tersedia',
    sub: 'Pencatatan berjalan seperti biasa',
    waktu: '09/11/2026',
  ),
];

/// Settings default.
const pemberitahuanSetelan = {
  'tindak': true,
  'tempo': true,
  'file': true,
  'ai': false,
};

// ---------- Board links built in the logic classes ----------

// ---------- KotakMasuk (round 2), `keadaan` sets ----------

/// `Ada pemberitahuan`: (perlu tindakan, untuk diketahui). Shared with
/// WebKotakMasuk (the same Layar targets).
const kotakMasukAda = (
  tindak: [
    ItemKotak(
      judul: '3 permohonan surat',
      sub: 'Dokumen gereja · belum dibaca',
      label: 'Belum dibaca',
      gaya: GayaLabel.tinta,
    ),
    ItemKotak(
      judul: 'Warta edisi 22/11/2026 belum diterbitkan',
      sub: 'Warta Jemaat · dibaca 16/11/2026',
      label: 'Dibaca',
      gaya: GayaLabel.garis,
    ),
  ],
  tahu: [
    ItemKotak(
      judul: 'Pengumuman “Kerja bakti” berakhir 20/11/2026',
      sub: 'Pengumuman',
    ),
    ItemKotak(
      judul: 'Surat keterangan Novita Wenas diterbitkan',
      sub: 'Sudah ditindaklanjuti 15/11/2026',
      label: 'Selesai',
      gaya: GayaLabel.abu,
    ),
  ],
);

/// `Hanya modul Keuangan`. Section 3 row 36: "2 draf belum dibukukan ·
/// Keuangan · Oktober 2026" while Main says the 2 drafts are November.
const kotakMasukKeuangan = (
  tindak: [
    ItemKotak(
      judul: '2 draf belum dibukukan',
      sub: 'Keuangan · Oktober 2026',
      label: 'Belum dibaca',
      gaya: GayaLabel.tinta,
    ),
    ItemKotak(
      judul: 'Rekonsiliasi Bank BNI ··4821 belum dipastikan',
      sub: 'Keuangan',
      label: 'Dibaca',
      gaya: GayaLabel.garis,
    ),
  ],
  tahu: [ItemKotak(judul: '2 uang muka lewat jatuh tempo', sub: 'Keuangan')],
);

// ---------- BerandaJabatan / WebBerandaJabatan (`keadaan`) ----------

/// One person's home: name, post chips, perlu tindakan, untuk diketahui.
/// Shared with WebBerandaJabatan.
typedef BerandaOrang = ({
  String orang,
  List<String> jabatan,
  List<ItemKotak> tindak,
  List<ItemKotak> tahu,
});

/// Options 0–4 of `keadaan`, in order: "Beberapa jabatan", "Bendahara
/// Jemaat", "Sekretaris Jemaat", "Operator", "Anggota jemaat".
const berandaJabatan = <BerandaOrang>[
  (
    orang: 'Pnt. Hendrik Rumagit',
    jabatan: ['Penatua Kolom 7', 'Ketua Komisi Diakonia'],
    tindak: [
      ItemKotak(
        judul: '5 data menunggu verifikasi',
        sub: 'Sebagai Penatua Kolom 7 · 2 permohonan · 2 peristiwa · 1 perubahan data',
        label: 'Diajukan',
        gaya: GayaLabel.garis,
      ),
      ItemKotak(
        judul: 'Ibadah Kolom 7, 19/11/2026',
        sub: 'Sebagai Penatua Kolom 7 · menunggu persetujuan Anda',
        label: 'Draf',
        gaya: GayaLabel.draf,
      ),
      ItemKotak(
        judul: 'Permintaan dana Komisi Diakonia',
        sub: 'Sebagai Ketua Komisi Diakonia · menunggu persetujuan',
        label: 'Diajukan',
        gaya: GayaLabel.garis,
      ),
    ],
    tahu: [
      ItemKotak(
        judul: '12 anggota Kolom 7 belum dikonfirmasi',
        sub: 'Sebagai Penatua Kolom 7 · belum tampil di publikasi apa pun',
      ),
    ],
  ),

  /// Section 3 row 1: Rp38.415.000 is the November saldo.
  (
    orang: 'Meiske Lumentut',
    jabatan: ['Bendahara Jemaat'],
    tindak: [
      ItemKotak(
        judul: 'Keuangan: 4 hal perlu tindakan',
        sub: 'Saldo buku Rp38.415.000 · Oktober 2026 belum ditutup',
      ),
      ItemKotak(
        judul: '1 hambatan dari unit',
        sub: 'Kolom 7 · menghalangi tutup buku Oktober 2026',
        label: 'Hambatan',
        gaya: GayaLabel.bata,
      ),
    ],
    tahu: [
      ItemKotak(
        judul: '2 uang muka dengan sisa belum dipertanggungjawabkan',
        sub: 'Tidak menghalangi tutup buku',
      ),
    ],
  ),
  (
    orang: 'Olvie Pangemanan',
    jabatan: ['Sekretaris Jemaat'],
    tindak: [
      ItemKotak(
        judul: '2 pengumuman masih Draf',
        sub: 'Belum diterbitkan',
        label: 'Draf',
        gaya: GayaLabel.draf,
      ),
      ItemKotak(
        judul: '3 permohonan surat',
        sub: 'Diajukan anggota dan dicatat Operator',
        label: 'Diajukan',
        gaya: GayaLabel.garis,
      ),
      ItemKotak(
        judul: 'Warta Jemaat edisi 22/11/2026',
        sub: 'Belum diterbitkan',
        label: 'Draf',
        gaya: GayaLabel.draf,
      ),
    ],
    tahu: [
      ItemKotak(
        judul: '1 pengumuman berakhir pada 20/11/2026',
        sub: 'Setelah itu diarsipkan sendiri',
      ),
    ],
  ),
  (
    orang: 'Yanti Sumual',
    jabatan: ['Operator', 'Menjalankan jabatan kosong: Penatua Kolom 2'],
    tindak: [
      ItemKotak(
        judul: '4 formulir kertas belum dimasukkan',
        sub: 'Sebagai Operator · dari anggota tanpa ponsel',
      ),
      ItemKotak(
        judul: '2 permohonan surat dicatat di kantor',
        sub: 'Sebagai Operator · menunggu Sekretaris Jemaat',
        label: 'Diajukan',
        gaya: GayaLabel.garis,
      ),
      ItemKotak(
        judul: '3 data Kolom 2 menunggu verifikasi',
        sub: 'Menjalankan jabatan kosong Penatua Kolom 2 sejak 01/11/2026',
        label: 'Jabatan kosong',
        gaya: GayaLabel.bata,
      ),
    ],
    tahu: [
      ItemKotak(
        judul: 'Buku anggota: 318 baris sudah diimpor',
        sub: '241 belum dikonfirmasi',
      ),
    ],
  ),
  (
    orang: 'Novita Wenas',
    jabatan: ['Anggota jemaat'],
    tindak: [
      ItemKotak(
        judul: 'Permohonan surat keterangan',
        sub: 'Diajukan 14/11/2026',
        label: 'Diajukan',
        gaya: GayaLabel.garis,
      ),
    ],
    tahu: [
      ItemKotak(
        judul: 'Warta Jemaat edisi 15/11/2026',
        sub: 'Diterbitkan untuk semua anggota',
        label: 'Diterbitkan',
        gaya: GayaLabel.tinta,
      ),
      ItemKotak(
        judul: '2 pengumuman untuk Kolom 7',
        sub: 'Ditujukan untuk: Kolom 7',
      ),
      ItemKotak(
        judul: 'Persembahan saya',
        sub: 'Hanya yang dicatat atas nama Anda',
      ),
    ],
  ),
];

/// `keadaan` "Jabatan dipilih otomatis": Pnt. Hendrik Rumagit as Penatua
/// Kolom 7.
const berandaOtomatis = (
  judul: 'Baptisan · Gabriel Wenas',
  sub: 'Diajukan oleh Novita Wenas, 15/11/2026',
  keluarga: 'Keluarga Wenas-Lasut',
  kolom: 'Kolom 7',
);

/// `keadaan` "Dua jabatan dapat bertindak".
const berandaDuaJabatan = (
  judul: 'Setujui jadwal · Ibadah Kolom 7 bersama Komisi Diakonia',
  sub: 'Kamis, 19/11/2026 19.00 · rumah Kel. Wenas-Lasut',
);

// ---------- 2.17 Modules (Modul) ----------

/// Section 3 row 33: Modul shows the activation story; member, worship and
/// Panitia boards still behave as active.
const semuaModul = [
  Modul(
    nama: 'Keuangan',
    status: 'Aktif',
    gaya: GayaLabel.laut,
    keterangan: 'Diaktifkan 15/09/2026 oleh Pdt. Lidya Rondonuwu',
  ),
  Modul(
    nama: 'Dokumen gereja',
    status: 'Aktif',
    gaya: GayaLabel.laut,
    keterangan: 'Diaktifkan 03/11/2026',
  ),
  Modul(
    nama: 'Pengumuman',
    status: 'Aktif',
    gaya: GayaLabel.laut,
    keterangan: 'Diaktifkan 03/11/2026',
  ),
  Modul(
    nama: 'Warta Jemaat',
    status: 'Aktif',
    gaya: GayaLabel.laut,
    keterangan: 'Perlu: Pengumuman aktif',
  ),
  Modul(
    nama: 'Data jemaat',
    status: 'Tidak aktif',
    gaya: GayaLabel.draf,
    keterangan: 'Siap diaktifkan · Kategori BIPRA mengikuti ketentuan GMIM',
  ),
  Modul(
    nama: 'Ibadah dan kegiatan',
    status: 'Tidak aktif',
    gaya: GayaLabel.draf,
    keterangan: 'Perlu: Data jemaat aktif',
  ),
  Modul(
    nama: 'Jumlah kehadiran',
    status: 'Tidak aktif',
    gaya: GayaLabel.draf,
    keterangan: 'Perlu: Ibadah dan kegiatan aktif',
  ),
  Modul(
    nama: 'Panitia',
    status: 'Hanya baca',
    gaya: GayaLabel.garis,
    keterangan: 'Dinonaktifkan 01/11/2026; riwayat tetap dapat dibaca',
  ),
  Modul(
    nama: 'Keuangan unit',
    status: 'Tidak aktif',
    gaya: GayaLabel.draf,
    keterangan: 'Perlu: Keuangan aktif dan Kas/Bank yang dikelola unit',
  ),
  Modul(
    nama: 'Persetujuan di aplikasi',
    status: 'Tidak aktif',
    gaya: GayaLabel.draf,
    keterangan: 'Perlu: tabel pemberi persetujuan Jemaat',
  ),
];

/// Warta Jemaat module: "46 edisi yang sudah diterbitkan".
const modulWartaEdisi = '46 edisi yang sudah diterbitkan';

/// Prerequisites drawn.
const modulNaskahIzin = 'Naskah bawaan · versi 1 · 12/11/2026';
const modulPenatuaKolom = 'Penatua Kolom untuk setiap Kolom 11 dari 12 terisi';

/// PemberiPersetujuan table, all empty at start: unit · choices.
const pemberiPersetujuan = [
  ('Kolom', ['Penatua Kolom', 'Ketua Jemaat']),
  ('BIPRA', ['Ketua BIPRA', 'Ketua Jemaat']),
  ('Komisi', ['Ketua Komisi', 'Ketua Jemaat']),
  ('Panitia', ['Ketua Panitia', 'Ketua Jemaat']),
];

// ---------- 2.21 Settings, sessions, history ----------

/// Lainnya riwayat: (teks, waktu), newest first. Section 3 row 21: format
/// persetujuan 03/10/2026 10.15 here.
const riwayatLainnya = [
  ('Meiske L. membukukan BKU-2026-0146', '15/11/2026 12.20'),
  ('Meiske L. membuat pembalikan BKU-2026-0144', '12/11/2026 09.31'),
  ('Meiske L. menonaktifkan Kas Panitia HUT', '28/10/2026 16.44'),
  ('Meiske L. menutup buku September 2026', '05/10/2026 19.02'),
  ('Meiske L. mencatat persetujuan format laporan', '03/10/2026 10.15'),
  ('Petugas verifikasi mengaktifkan wewenang Bendahara', '15/09/2026 10.15'),
];

/// WebPengaturan riwayat (board `R`): (waktu, oleh, teks), newest first.
/// The vacancy state prepends the revocation line (by Petugas verifikasi) and drops
/// the 16/11/2026 rows.
const riwayatPengaturan = [
  ('16/11/2026 10.42', 'Meiske L.', 'Membukukan BKU-2026-0147'),
  (
    '12/11/2026 09.31',
    'Meiske L.',
    'Membuat pembalikan BKU-2026-0144 · alasan: Mata Anggaran keliru',
  ),
  (
    '28/10/2026 16.44',
    'Meiske L.',
    'Menonaktifkan Kas Panitia HUT · berlaku mulai November 2026',
  ),
  ('05/10/2026 19.02', 'Meiske L.', 'Menutup buku September 2026'),
  ('03/10/2026 10.15', 'Meiske L.', 'Mencatat persetujuan format laporan'),
  (
    '15/09/2026 10.15',
    'Petugas verifikasi',
    'Mengaktifkan wewenang Bendahara untuk Meiske Lumentut',
  ),
];

/// Bendahara sessions: (perangkat, keterangan).
const sesiBendahara = [
  ('Ponsel ini', 'Sesi ini · aktif sekarang'),
  ('Chrome di laptop', 'Terakhir dipakai 14/11/2026 20.15'),
];
const sesiPengaturan = [
  ('Browser ini', 'Sesi ini · aktif sekarang'),
  ('Ponsel Android', 'Terakhir dipakai 16/11/2026 10.42'),
];
const sesiKeluar = 'Masuk sejak 16/11/2026 08.02';
const sesiSambunganDiakhiri =
    'Diakhiri oleh Meiske L. dari perangkat lain, 16/11/2026 11.40.';

/// Masuk (`setelahMasuk`).
const masukSebagai = [
  'Meiske Lumentut · Wewenang Bendahara aktif',
  'Dkn. Olga Tamba · Akses terbatas: Peruntukan Diakonia',
];

/// Bendahara handover. The old SK has "2 halaman" (Awal, WebVerifikasi).
const skBendaharaBaru = 'SK-BPMJ-09-2026.pdf';
const skBendaharaLama = 'SK-BPMJ-04-2026.pdf';

const pemulihanTercatat =
    'Tercatat di Riwayat aktivitas sebagai pemulihan akun, 16/11/2026 12.05.';
