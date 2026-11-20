import '../widgets/lencana_status.dart' show GayaLabel;

export '../widgets/lencana_status.dart' show GayaLabel;

// The Dart model of docs/build/mock-data.md section 1: plain immutable
// classes with const constructors, only what the boards show.
//
// Dates are kept as the strings the boards print ('16/11/2026'), not
// DateTime: DateTime has no const constructor and every seed value here is
// const. Parse with bacaTgl() of format.dart when a screen needs to compare.

// ---------- Common ----------

class Gereja {
  final String nama; // 'Jemaat Karunia'
  final String namaWarta; // 'GMIM Jemaat Karunia' (A4Warta only)
  final String zonaWaktu; // 'WITA'
  final String tahunBukuMulai; // '1 Januari'
  final String mulaiPencatatan; // '15/09/2026'
  const Gereja({
    required this.nama,
    required this.namaWarta,
    required this.zonaWaktu,
    required this.tahunBukuMulai,
    required this.mulaiPencatatan,
  });
}

// ---------- People, posts, units ----------

enum JenisUnit { jemaat, kolom, bipra, komisi, panitia }

class Unit {
  final String id; // 'kolom7', 'komisiDiakonia', 'panitiaNatal2026'
  final JenisUnit jenis;
  final String nama; // 'Kolom 7', 'Komisi Diakonia', 'Panitia Natal 2026'
  const Unit({required this.id, required this.jenis, required this.nama});
}

class Orang {
  final String id;
  final String nama; // as drawn with title: 'Pnt. Hendrik Rumagit'
  final String? namaPendek; // 'Meiske L.' where a board shortens it
  final String? kolom; // 'Kolom 7'
  final String? keluarga; // 'Keluarga Wenas-Lasut'
  final String? lahir; // '14/03/1996'
  final String? statusPernikahan; // 'Belum pernah menikah'
  final String?
  statusData; // 'Aktif' · 'Belum dikonfirmasi' · 'Meninggal dunia'
  final String? ponsel; // '081234567890'
  final String? email; // 'olvie@contoh.id'
  const Orang({
    required this.id,
    required this.nama,
    this.namaPendek,
    this.kolom,
    this.keluarga,
    this.lahir,
    this.statusPernikahan,
    this.statusData,
    this.ponsel,
    this.email,
  });
}

enum StatusPenugasan {
  aktif('Aktif', GayaLabel.laut),
  jabatanKosong('Jabatan kosong', GayaLabel.bata),
  berakhir('Berakhir', GayaLabel.abu),
  menungguVerifikasi('Menunggu verifikasi wewenang', GayaLabel.draf);

  final String label;
  final GayaLabel gaya;
  const StatusPenugasan(this.label, this.gaya);
}

/// A post held by a person in a unit.
class Penugasan {
  final String jabatan; // 'Penatua Kolom 7'
  final String? orangId; // null when vacant ('—')
  final StatusPenugasan status;
  final String keterangan; // 'Sejak 01/01/2026', '01/01/2022 – 31/10/2026', …
  final String? dasar; // 'SK BPMJ No. 12/2026'
  const Penugasan({
    required this.jabatan,
    this.orangId,
    required this.status,
    required this.keterangan,
    this.dasar,
  });
}

class Pelimpahan {
  final String dari; // 'Penatua Kolom 7'
  final String kepada; // 'Sym. Greis Mamahit'
  final String tugas; // 'Verifikasi data Kolom 7'
  final String mulai, sampai; // '16/11/2026', '30/11/2026'
  final String status; // 'Aktif' · 'Berakhir'
  const Pelimpahan({
    required this.dari,
    required this.kepada,
    required this.tugas,
    required this.mulai,
    required this.sampai,
    required this.status,
  });
}

// ---------- Finance setup ----------

enum JenisKasBank { kas, bank }

class KasBank {
  final String id; // 'kas' · 'bni' · 'bsg' (ids used by the boards)
  final String nama; // 'Kas' · 'Bank BNI ··4821' · 'Bank SulutGo ··1107'
  final String
  namaPendek; // 'Kas' · 'Bank BNI' · 'Bank SulutGo' (transfer labels)
  final JenisKasBank jenis;
  final String dikelolaOleh; // 'Dikelola Jemaat' · 'Dikelola oleh Kolom 7 · Bendahara: Deasy Tumbelaka'
  final bool aktif;
  final String?
  keterangan; // 'Nonaktif sejak November 2026 · tetap tampil di laporan lama'
  const KasBank({
    required this.id,
    required this.nama,
    required this.namaPendek,
    required this.jenis,
    required this.dikelolaOleh,
    required this.aktif,
    this.keterangan,
  });
}

class Peruntukan {
  final String id;
  final String nama;
  const Peruntukan(this.id, this.nama);
}

class Lingkup {
  final String nama;
  const Lingkup(this.nama);
}

enum Pohon {
  pendapatan('Pendapatan'),
  belanja('Belanja');

  final String label;
  const Pohon(this.label);
}

enum BolehUntuk {
  milikSendiri('Milik sendiri'),
  titipan('Titipan'),
  keduanya('Keduanya'),

  /// shown as 'belum diisi'
  kosong('');

  final String label;
  const BolehUntuk(this.label);
}

class MataAnggaran {
  final String kode; // '1.3.53.07.00'
  final String nama; // 'Persembahan Ibadah Minggu'
  final Pohon?
  pohon; // null where no board draws the tree (2.2.01.02.00 in 2026.1)
  final bool judulKelompok; // 'Judul kelompok, tidak dapat dibukukan'
  final BolehUntuk bolehUntuk;
  final String? tanda; // 'Baru' · 'Nama berubah' (version 2026.2 draft only)
  const MataAnggaran({
    required this.kode,
    required this.nama,
    this.pohon,
    this.judulKelompok = false,
    this.bolehUntuk = BolehUntuk.kosong,
    this.tanda,
  });
}

class VersiMataAnggaran {
  final String kode; // '2026.1'
  final String status; // 'Diterbitkan' · 'Draf' · 'Sudah diperiksa'
  final String berlaku; // 'Berlaku mulai September 2026'
  final int? barisPendapatan, barisBelanja; // 131, 158 (not drawn for 2026.2)
  final List<MataAnggaran> contoh; // the sample rows drawn
  const VersiMataAnggaran({
    required this.kode,
    required this.status,
    required this.berlaku,
    this.barisPendapatan,
    this.barisBelanja,
    required this.contoh,
  });
}

// ---------- Transactions ----------

/// Badge: Dibukukan = GayaLabel.tinta; Draf = draf; Dibalik = garis;
/// Dibatalkan = fill kertas, text tinta2, border kertas, row text tinta3
/// struck through (no GayaLabel, so [gaya] is null).
enum StatusTransaksi {
  draf('Draf', GayaLabel.draf),
  dibukukan('Dibukukan', GayaLabel.tinta),
  dibalik('Dibalik', GayaLabel.garis),
  dibatalkan('Dibatalkan', null);

  final String label;
  final GayaLabel? gaya;
  const StatusTransaksi(this.label, this.gaya);
}

enum JenisTransaksi {
  pendapatan,
  belanja,

  /// 'Pindah antar Kas/Bank' (incl. 'Setoran ke bank')
  pindah,

  /// 'Titipan untuk: …'
  titipanMasuk,

  /// 'Penyaluran'
  titipanDisalurkan,
  uangMukaDiberikan,
  pertanggungjawaban,
  pengembalianSisaUangMuka,
  penggantianBiaya,
  alihPeruntukan,
  pembalikan,
  koreksi,
  saldoAwal,
  pengembalian,
}

/// Named apart from the PanelDokumen widget's `StatusDokumen`
/// (components.md) so both can be imported together. Every value name here
/// exists there too: `StatusDokumen.values.byName(s.name)` maps one to the
/// other.
enum StatusDokumenPendukung {
  wajibBelumAda('Wajib, belum ada'),
  diunggah('Diunggah, belum diverifikasi'),
  terverifikasi('Terverifikasi (oleh Meiske L.)'),

  /// Some boards add ' (alasan: kuitansi menyusul, oleh Ketua BPMJ)'.
  dikecualikan('Dikecualikan'),
  gagalDiunggah('Gagal diunggah'),
  ditahan('Ditahan (alasan keamanan)'),
  tidakDiperlukan('Tidak diperlukan (aturan: pembalikan)');

  final String label;
  const StatusDokumenPendukung(this.label);
}

/// One part of a split payment or a multi-part offering.
class BagianTransaksi {
  final String? kodeMA; // null for transfers and advances
  final int jumlah;
  final String? kasBankId;
  final String? peruntukanId;
  const BagianTransaksi({
    this.kodeMA,
    required this.jumlah,
    this.kasBankId,
    this.peruntukanId,
  });
}

class Transaksi {
  final String? noBukti; // 'BKU-2026-0098'; null = 'Belum ada No. Bukti' / '—'
  final String? noBuktiAsal; // 'KW-0412'
  final String? tanggal; // '04/10/2026'; null where no board draws it
  final String uraian;
  final JenisTransaksi jenis;
  final StatusTransaksi status;
  final String
  kasBank; // as printed: 'Kas', 'Bank BNI ··4821', 'Kas ke Bank BNI'
  final int masuk, keluar; // F02 columns (transfers fill both)
  final String? kodeMA; // F02 "No. MA" as printed: '1.3.53.07.00; 1.3.55.01.00'
  final List<BagianTransaksi> bagian; // >1 when split or multi-part
  final String? tandaRantai; // 'Dibalik oleh BKU-2026-0109' · 'Pembalikan' · 'Koreksi dari BKU-2026-0105'
  final String? lingkup;
  final String? peruntukan; // 'Umum Jemaat', 'Diakonia', …
  final StatusDokumenPendukung? dokumen;
  final String? persetujuan; // 'Tidak diperlukan (aturan: transaksi rutin)'
  final String? dibukukanPada; // '16/11/2026 10.42'
  final String? catatan; // other text a board draws on the row
  const Transaksi({
    this.noBukti,
    this.noBuktiAsal,
    this.tanggal,
    required this.uraian,
    required this.jenis,
    this.status = StatusTransaksi.dibukukan,
    this.kasBank = '',
    this.masuk = 0,
    this.keluar = 0,
    this.kodeMA,
    this.bagian = const [],
    this.tandaRantai,
    this.lingkup,
    this.peruntukan,
    this.dokumen,
    this.persetujuan,
    this.dibukukanPada,
    this.catatan,
  });

  /// Signed, as the boards' `jm` fields: positive in, negative out.
  int get jumlah => masuk - keluar;
}

enum StatusBulan {
  belumDitutup('Belum ditutup'),
  sudahDitutup('Sudah ditutup');

  final String label;
  const StatusBulan(this.label);
}

class Bulan {
  final int tahun, bulan;
  final StatusBulan status;
  final String
  keterangan; // 'Periode laporan 15–30 September 2026 · 21 transaksi'
  const Bulan({
    required this.tahun,
    required this.bulan,
    required this.status,
    required this.keterangan,
  });
}

class DokumenPendukung {
  final String id; // the board's row id 'a' … 'f'
  final String noBukti;
  final String uraian;
  final int jumlah;
  final String bulan; // 'November 2026 · Belum ditutup'
  final StatusDokumenPendukung?
  status; // null: 'per board' (each board sets it)
  final String? file; // 'nota-16-11.jpg'
  final List<String> riwayat;
  const DokumenPendukung({
    required this.id,
    required this.noBukti,
    required this.uraian,
    required this.jumlah,
    required this.bulan,
    this.status,
    this.file,
    this.riwayat = const [],
  });
}

/// The photographed receipt drawn on Kamera / LihatDokumen.
class Nota {
  final String toko, alamat, total, tanggal, kaki;
  final List<(String, String)> baris;
  const Nota({
    required this.toko,
    required this.alamat,
    required this.total,
    required this.tanggal,
    required this.kaki,
    required this.baris,
  });
}

// ---------- Advances, deposits, claims ----------

enum JenisKasus {
  uangMuka('Uang Muka'),
  titipan('Titipan'),
  penggantianBiaya('Penggantian biaya');

  final String label;
  const JenisKasus(this.label);
}

class EntriKasus {
  final String nama; // 'Pertanggungjawaban uang muka'
  final String noBukti, tanggal, catatan; // catatan: 'menjadi Belanja'
  final int jumlah;
  const EntriKasus({
    required this.nama,
    required this.noBukti,
    required this.tanggal,
    required this.catatan,
    required this.jumlah,
  });
}

class Kasus {
  final String id;
  final JenisKasus jenis;
  final String judul, pihak;
  final int awal; // amount given / collected / claimed
  final String
  awalCatatan; // 'BKU-2026-0129 · 01/11/2026 · dari peruntukan Umum Jemaat'
  final String? jatuhTempo; // '30/11/2026'
  final bool lewatJatuhTempo;
  final List<EntriKasus> entri;
  int get sisa => awal - entri.fold(0, (a, e) => a + e.jumlah);
  const Kasus({
    required this.id,
    required this.jenis,
    required this.judul,
    required this.pihak,
    required this.awal,
    required this.awalCatatan,
    this.jatuhTempo,
    this.lewatJatuhTempo = false,
    this.entri = const [],
  });
}

// ---------- Month end ----------

class MutasiBank {
  final String id, nama, tanggal;
  final int jumlah;
  const MutasiBank({
    required this.id,
    required this.nama,
    required this.tanggal,
    required this.jumlah,
  });
}

class Rekonsiliasi {
  final String kasBankId, bulan;
  final int saldoBuku; // before the bank fee is posted
  final int saldoRekeningKoran;
  final int dalamPerjalanan; // 500000 once marked
  final int cocokLain; // '12 mutasi bank lain sudah cocok'
  final List<MutasiBank> mutasi;
  final List<Transaksi> belumCocok;
  const Rekonsiliasi({
    required this.kasBankId,
    required this.bulan,
    required this.saldoBuku,
    required this.saldoRekeningKoran,
    required this.dalamPerjalanan,
    required this.cocokLain,
    required this.mutasi,
    required this.belumCocok,
  });
}

class HitungKas {
  static const pecahan = [100000, 50000, 20000, 10000, 5000, 2000, 1000];
  final List<int> lembar; // count per denomination
  final List<String> petugas;
  int get jumlah {
    var t = 0;
    for (var i = 0; i < pecahan.length; i++) {
      t += lembar[i] * pecahan[i];
    }
    return t;
  }

  const HitungKas({required this.lembar, required this.petugas});
}

/// Event after month close.
class Kejadian {
  final String no, judul, periode, transaksi, penjelasan, dampak;
  final String penanggungJawab;
  final String? eskalasi, penyelesaian;
  const Kejadian({
    required this.no,
    required this.judul,
    required this.periode,
    required this.transaksi,
    required this.penjelasan,
    required this.dampak,
    required this.penanggungJawab,
    this.eskalasi,
    this.penyelesaian,
  });
}

// ---------- Reports ----------

class LaporanResmi {
  final String id; // 'SNP-2026-10-01'
  final String periode; // 'Periode laporan 1–31 Oktober 2026'
  final String dibekukan; // '16/11/2026 11.05'
  final String versiMA; // '2026.1'
  final Map<String, List<List<String>>> tabel; // 'F01' → rows, exact strings
  const LaporanResmi({
    required this.id,
    required this.periode,
    required this.dibekukan,
    required this.versiMA,
    required this.tabel,
  });
}

// ---------- Notifications ----------

class Pemberitahuan {
  final String id, jenis; // jenis: 'tindak' · 'tempo' · 'file' · 'ai'
  final String judul, sub, waktu;
  const Pemberitahuan({
    required this.id,
    required this.jenis,
    required this.judul,
    required this.sub,
    required this.waktu,
  });
}

/// KotakMasuk, BerandaJabatan, AntreanVerifikasi, … rows.
class ItemKotak {
  final String judul, sub;
  final String? label; // 'Diajukan', 'Draf', 'Hambatan', …
  final GayaLabel? gaya;
  const ItemKotak({
    required this.judul,
    required this.sub,
    this.label,
    this.gaya,
  });
}

// ---------- Member data ----------

class Keluarga {
  final String nama; // 'Keluarga Wenas-Lasut'
  final String kolom;
  final String? wakil; // 'Agustina Lasut'
  final List<String> anggota; // ['Ferry', 'Agustina', 'Novita', 'Gabriel']
  final String?
  status; // 'Belum dikonfirmasi' · 'Menunggu verifikasi' · 'Aktif'
  const Keluarga({
    required this.nama,
    required this.kolom,
    this.wakil,
    this.anggota = const [],
    this.status,
  });
}

class Peristiwa {
  final String
  jenis; // 'Baptisan' · 'Sidi' · 'Pernikahan' · 'Kematian' · 'Pindah Kolom'
  final String untuk, tanggal;
  final String status; // 'Diajukan' · 'Diverifikasi' · 'Dikembalikan'
  const Peristiwa({
    required this.jenis,
    required this.untuk,
    required this.tanggal,
    required this.status,
  });
}

// ---------- Secretariat ----------

class DokumenGereja {
  final String judul, jenisTanggalUntuk, status;
  final GayaLabel gaya;
  const DokumenGereja({
    required this.judul,
    required this.jenisTanggalUntuk,
    required this.status,
    required this.gaya,
  });
}

class Pengumuman {
  final String judul, untuk, status;
  final GayaLabel gaya;
  const Pengumuman({
    required this.judul,
    required this.untuk,
    required this.status,
    required this.gaya,
  });
}

class EdisiWarta {
  final String edisi, terbit, status;
  final GayaLabel gaya;
  const EdisiWarta({
    required this.edisi,
    required this.terbit,
    required this.status,
    required this.gaya,
  });
}

class PermohonanSurat {
  final String judul, sub, status;
  final GayaLabel gaya;
  const PermohonanSurat({
    required this.judul,
    required this.sub,
    required this.status,
    required this.gaya,
  });
}

// ---------- Collaboration ----------

class Panitia {
  final String nama; // 'Panitia Natal 2026'
  final String ketua, sekretaris, bendahara, peruntukan, dasar;
  static const tahap = [
    '1 · Perencanaan',
    '2 · Aktif',
    '3 · Acara selesai',
    '4 · Penutupan keuangan',
    '5 · Ditutup',
    '6 · Diarsipkan',
  ];
  const Panitia({
    required this.nama,
    required this.ketua,
    required this.sekretaris,
    required this.bendahara,
    required this.peruntukan,
    required this.dasar,
  });
}

class Ibadah {
  final String judul, jenis, waktu, untuk, tempat, status;
  const Ibadah({
    required this.judul,
    required this.jenis,
    required this.waktu,
    required this.untuk,
    required this.tempat,
    required this.status,
  });
}

class Kehadiran {
  final String ibadah; // 'Ibadah Minggu pagi · 15/11/2026'
  final Map<String, int> perPos; // 'Pintu depan · Yanti S.': 142, …
  final String status; // 'Sedang dihitung' · 'Sudah diperiksa' · 'Ditetapkan'
  const Kehadiran({
    required this.ibadah,
    required this.perPos,
    required this.status,
  });
}

class PermintaanDana {
  final String perlu; // 'Konsumsi Natal Pemuda'
  final int jumlah;
  final String peruntukan, diajukanOleh, status;
  const PermintaanDana({
    required this.perlu,
    required this.jumlah,
    required this.peruntukan,
    required this.diajukanOleh,
    required this.status,
  });
}

class Modul {
  final String nama, status, keterangan;
  final GayaLabel gaya;
  const Modul({
    required this.nama,
    required this.status,
    required this.keterangan,
    required this.gaya,
  });
}
