# Mock data

This file is the shared dataset of the prototype: the Dart model, the seed values drawn on the boards, the places where boards disagree, and the formatting helpers. `CONVENTIONS.md` is fixed and wins over this file. The board source wins over this file on what a screen shows.

Everything below comes from the board files in `docs/design/handoff/canvas/boards/`, the A4 pages, and `03-screens-and-flows.md` / `04-decision-log.md`. Nothing here is invented. Where a value is derived (not drawn on any board) it says **derived**, and no screen displays it.

## 0. How to use this file

- Code lives in `prototype/lib/mock/`:
  - `model.dart`: the classes and enums of section 1.
  - `seed_keuangan.dart`, `seed_jemaat.dart`, `seed_sekretariat.dart`, `seed_kolaborasi.dart`: the `const` values of section 2.
  - `format.dart`: the helpers of section 4.
  - `laporan_oktober.dart`: the Laporan board's F01–F14 tables (spec `screens/03-webrekonsiliasi.md`, Laporan).
  - `excel.dart`: the WebExcel board's `F` list and `LAP` object (spec `screens/08-cari.md`, WebExcel).
  - These two both hold October report tables, drawn on different boards: separate, verbatim per board; do not merge (section 3 rule).
- Seed values are `const` top-level values. No repository layer, no streams, no persistence. A screen that changes data (posting, matching, closing) copies what it needs into its own `State` and changes the copy, exactly as the board's logic class does with `setState`. Leaving the screen drops the change. That matches the canvas, where each board keeps its own state.
- **Rule for figures:** a screen shows its own board's figure. A screen reads a seed value only when the seed value equals what its board draws. Where boards disagree (section 3), the screen uses the value listed for its board, kept as a board-local constant in the screen file with a one-line comment naming this file's section 3 row.
- The A4 pages, the report package (`WebPaketLaporan`, `Laporan`, `WebLaporan`, `WebExcel`, `WebExcelTerbatas`) and the tables in section 2.10 print strings exactly as drawn. Keep them as `const` string tables, not computed totals. The totals in this file were checked and add up, but the screens must not recompute them.
- Money is an `int` in rupiah, signed: positive is money in, negative is money out, as the boards' `jm` fields are.

## 1. Dart model sketch

Plain immutable classes with `const` constructors. No codegen, no `copyWith` unless a screen needs one. Only what the boards show.

```dart
// Constructors are written `(...)` here: one named `required` parameter per field.

// ---------- Common ----------

/// Status label styles shared by the platform boards (round 2–5 `LS` map)
/// and the finance status badges. Colours are tokens.
enum GayaLabel {
  draf,   // text tinta2, 1.5 dashed putus, no fill
  garis,  // text tinta2, 1.5 solid tinta3, fill permukaan
  tinta,  // text permukaan, fill tinta, 1.5 solid tinta
  laut,   // text diLaut, fill laut, 1.5 solid laut
  lautg,  // text laut, fill permukaan, 1.5 solid laut
  bata,   // text bata, fill permukaan, 1.5 solid bata
  abu,    // text tinta2, fill garis, 1.5 solid garis
}

class Gereja {
  final String nama;            // 'Jemaat Karunia'
  final String namaWarta;       // 'GMIM Jemaat Karunia' (A4Warta only)
  final String zonaWaktu;       // 'WITA'
  final String tahunBukuMulai;  // '1 Januari'
  final DateTime mulaiPencatatan; // 15/09/2026
  const Gereja(...);
}

// ---------- People, posts, units ----------

enum JenisUnit { jemaat, kolom, bipra, komisi, panitia }

class Unit {
  final String id;      // 'kolom7', 'komisiDiakonia', 'panitiaNatal2026'
  final JenisUnit jenis;
  final String nama;    // 'Kolom 7', 'Komisi Diakonia', 'Panitia Natal 2026'
  const Unit(...);
}

class Orang {
  final String id;
  final String nama;          // as drawn with title: 'Pnt. Hendrik Rumagit'
  final String? namaPendek;   // 'Meiske L.' where a board shortens it
  final String? kolom;        // 'Kolom 7'
  final String? keluarga;     // 'Keluarga Wenas-Lasut'
  final DateTime? lahir;
  final String? statusPernikahan; // 'Belum pernah menikah'
  final String? statusData;   // 'Aktif' · 'Belum dikonfirmasi' · 'Meninggal dunia'
  final String? ponsel;       // '081234567890'
  final String? email;        // 'olvie@contoh.id'
  const Orang(...);
}

enum StatusPenugasan { aktif, jabatanKosong, berakhir, menungguVerifikasi }
// labels: 'Aktif' · 'Jabatan kosong' · 'Berakhir' · 'Menunggu verifikasi wewenang'

class Penugasan {          // a post held by a person in a unit
  final String jabatan;    // 'Penatua Kolom 7'
  final String? orangId;   // null when vacant ('—')
  final StatusPenugasan status;
  final String keterangan; // 'Sejak 01/01/2026', '01/01/2022 – 31/10/2026', …
  final String? dasar;     // 'SK BPMJ No. 12/2026'
  const Penugasan(...);
}

class Pelimpahan {
  final String dari;       // 'Penatua Kolom 7'
  final String kepada;     // 'Sym. Greis Mamahit'
  final String tugas;      // 'Verifikasi data Kolom 7'
  final String mulai, sampai; // '16/11/2026', '30/11/2026'
  final String status;     // 'Aktif' · 'Berakhir'
  const Pelimpahan(...);
}

// ---------- Finance setup ----------

enum JenisKasBank { kas, bank }

class KasBank {
  final String id;          // 'kas' · 'bni' · 'bsg' (ids used by the boards)
  final String nama;        // 'Kas' · 'Bank BNI ··4821' · 'Bank SulutGo ··1107'
  final String namaPendek;  // 'Kas' · 'Bank BNI' · 'Bank SulutGo' (transfer labels)
  final JenisKasBank jenis;
  final String dikelolaOleh; // 'Dikelola Jemaat' · 'Dikelola oleh Kolom 7 · Bendahara: Deasy Tumbelaka'
  final bool aktif;
  final String? keterangan; // 'Nonaktif sejak November 2026 · tetap tampil di laporan lama'
  const KasBank(...);
}

class Peruntukan { final String id; final String nama; const Peruntukan(this.id, this.nama); }
// 'umum' Umum Jemaat · 'diak' Diakonia · 'bang' Pembangunan

class Lingkup { final String nama; const Lingkup(this.nama); }

enum Pohon { pendapatan, belanja } // 'Pendapatan' · 'Belanja'
enum BolehUntuk { milikSendiri, titipan, keduanya, kosong }
// 'Milik sendiri' · 'Titipan' · 'Keduanya' · '' (shown as 'belum diisi')

class MataAnggaran {
  final String kode;        // '1.3.53.07.00'
  final String nama;        // 'Persembahan Ibadah Minggu'
  final Pohon pohon;
  final bool judulKelompok; // group heading: 'Judul kelompok, tidak dapat dibukukan'
  final BolehUntuk bolehUntuk;
  final String? tanda;      // 'Baru' · 'Nama berubah' (version 2026.2 draft only)
  const MataAnggaran(...);
}

class VersiMataAnggaran {
  final String kode;        // '2026.1'
  final String status;      // 'Diterbitkan' · 'Draf' · 'Sudah diperiksa'
  final String berlaku;     // 'Berlaku mulai September 2026'
  final int barisPendapatan, barisBelanja; // 131, 158
  final List<MataAnggaran> contoh;         // the sample rows drawn
  const VersiMataAnggaran(...);
}

// ---------- Transactions ----------

enum StatusTransaksi { draf, dibukukan, dibalik, dibatalkan }
// labels 'Draf' · 'Dibukukan' · 'Dibalik' · 'Dibatalkan'
// badge: Dibukukan = GayaLabel.tinta; Draf = draf; Dibalik = garis;
// Dibatalkan = fill kertas, text tinta2, border kertas, row text tinta3 struck through.

enum JenisTransaksi {
  pendapatan, belanja, pindah,          // 'Pindah antar Kas/Bank' (incl. 'Setoran ke bank')
  titipanMasuk, titipanDisalurkan,      // 'Titipan untuk: …', 'Penyaluran'
  uangMukaDiberikan, pertanggungjawaban, pengembalianSisaUangMuka,
  penggantianBiaya, alihPeruntukan, pembalikan, koreksi, saldoAwal, pengembalian,
}

enum StatusDokumen {
  wajibBelumAda,   // 'Wajib, belum ada'
  diunggah,        // 'Diunggah, belum diverifikasi'
  terverifikasi,   // 'Terverifikasi (oleh Meiske L.)'
  dikecualikan,    // 'Dikecualikan' (+ ' (alasan: kuitansi menyusul, oleh Ketua BPMJ)')
  gagal,           // 'Gagal diunggah'
  ditahan,         // 'Ditahan (alasan keamanan)'
  tidakDiperlukan, // 'Tidak diperlukan (aturan: pembalikan)'
}

class BagianTransaksi {     // one part of a split payment or a multi-part offering
  final String? kodeMA;     // null for transfers and advances
  final int jumlah;
  final String? kasBankId;
  final String? peruntukanId;
  const BagianTransaksi(...);
}

class Transaksi {
  final String? noBukti;        // 'BKU-2026-0098'; null = 'Belum ada No. Bukti' / '—'
  final String? noBuktiAsal;    // 'KW-0412'
  final DateTime tanggal;
  final String uraian;
  final JenisTransaksi jenis;
  final StatusTransaksi status;
  final String kasBank;         // as printed: 'Kas', 'Bank BNI ··4821', 'Kas ke Bank BNI'
  final int masuk, keluar;      // F02 columns (transfers fill both)
  final List<BagianTransaksi> bagian; // >1 when split or multi-part
  final String? tandaRantai;    // 'Dibalik oleh BKU-2026-0109' · 'Pembalikan' · 'Koreksi dari BKU-2026-0105'
  final String? lingkup;
  final StatusDokumen? dokumen;
  final String? persetujuan;    // 'Tidak diperlukan (aturan: transaksi rutin)'
  final String? dibukukanPada;  // '16/11/2026 10.42'
  const Transaksi(...);
}

enum StatusBulan { belumDitutup, sudahDitutup } // 'Belum ditutup' · 'Sudah ditutup'

class Bulan {
  final int tahun, bulan;
  final StatusBulan status;
  final String keterangan; // 'Periode laporan 15–30 September 2026 · 21 transaksi'
  const Bulan(...);
}

class DokumenPendukung {
  final String noBukti;
  final String uraian;
  final int jumlah;
  final String bulan;        // 'November 2026 · Belum ditutup'
  final StatusDokumen status;
  final String? file;        // 'nota-16-11.jpg'
  final List<String> riwayat;
  const DokumenPendukung(...);
}

class Nota { // the photographed receipt drawn on Kamera / LihatDokumen
  final String toko, alamat, total, tanggal, kaki;
  final List<(String, String)> baris;
  const Nota(...);
}

// ---------- Advances, deposits, claims ----------

enum JenisKasus { uangMuka, titipan, penggantianBiaya } // tabs 'Uang Muka' · 'Titipan' · 'Penggantian biaya'

class EntriKasus {
  final String nama;   // 'Pertanggungjawaban uang muka'
  final String noBukti, tanggal, catatan; // 'menjadi Belanja'
  final int jumlah;
  const EntriKasus(...);
}

class Kasus {
  final String id;
  final JenisKasus jenis;
  final String judul, pihak;
  final int awal;              // amount given / collected / claimed
  final String awalCatatan;    // 'BKU-2026-0129 · 01/11/2026 · dari peruntukan Umum Jemaat'
  final String? jatuhTempo;    // '30/11/2026'
  final bool lewatJatuhTempo;
  final List<EntriKasus> entri;
  int get sisa => awal - entri.fold(0, (a, e) => a + e.jumlah);
  const Kasus(...);
}

// ---------- Month end ----------

class MutasiBank { final String id, nama, tanggal; final int jumlah; const MutasiBank(...); }

class Rekonsiliasi {
  final String kasBankId, bulan;
  final int saldoBuku;             // before the bank fee is posted
  final int saldoRekeningKoran;
  final int dalamPerjalanan;       // 500000 once marked
  final int cocokLain;             // '12 mutasi bank lain sudah cocok'
  final List<MutasiBank> mutasi;
  final List<Transaksi> belumCocok;
  const Rekonsiliasi(...);
}

class HitungKas {
  static const pecahan = [100000, 50000, 20000, 10000, 5000, 2000, 1000];
  final List<int> lembar;          // count per denomination
  final List<String> petugas;
  int get jumlah {
    var t = 0;
    for (var i = 0; i < pecahan.length; i++) t += lembar[i] * pecahan[i];
    return t;
  }
  const HitungKas(...);
}

class Kejadian { // event after month close
  final String no, judul, periode, transaksi, penjelasan, dampak, penanggungJawab, eskalasi;
  final String? penyelesaian;
  const Kejadian(...);
}

// ---------- Reports ----------

class LaporanResmi {
  final String id;              // 'SNP-2026-10-01'
  final String periode;         // 'Periode laporan 1–31 Oktober 2026'
  final String dibekukan;       // '16/11/2026 11.05'
  final String versiMA;         // '2026.1'
  final Map<String, List<List<String>>> tabel; // 'F03' → rows, exact strings
  const LaporanResmi(...);
}

// ---------- Notifications ----------

class Pemberitahuan {
  final String id, jenis;       // jenis: 'tindak' · 'tempo' · 'file' · 'ai'
  final String judul, sub, waktu;
  const Pemberitahuan(...);
}

class ItemKotak { // KotakMasuk, BerandaJabatan, AntreanVerifikasi, … rows
  final String judul, sub;
  final String? label;          // 'Diajukan', 'Draf', 'Hambatan', …
  final GayaLabel? gaya;
  final String ke;              // target board stem, for Tautan(ke: …)
  const ItemKotak(...);
}

// ---------- Member data ----------

class Keluarga {
  final String nama;            // 'Keluarga Wenas-Lasut'
  final String kolom;
  final String? wakil;          // 'Agustina Lasut'
  final List<String> anggota;   // ['Ferry', 'Agustina', 'Novita', 'Gabriel']
  final String status;          // 'Belum dikonfirmasi' · 'Menunggu verifikasi' · 'Aktif'
  const Keluarga(...);
}

class Peristiwa {
  final String jenis;           // 'Baptisan' · 'Sidi' · 'Pernikahan' · 'Kematian' · 'Pindah Kolom'
  final String untuk, tanggal, status; // 'Diajukan' · 'Diverifikasi' · 'Dikembalikan'
  const Peristiwa(...);
}

// ---------- Secretariat ----------

class DokumenGereja { final String judul, jenisTanggalUntuk, status; final GayaLabel gaya; const DokumenGereja(...); }
class Pengumuman { final String judul, untuk, status; final GayaLabel gaya; const Pengumuman(...); }
class EdisiWarta { final String edisi, terbit, status; final GayaLabel gaya; const EdisiWarta(...); }
class PermohonanSurat { final String judul, sub, status; final GayaLabel gaya; const PermohonanSurat(...); }

// ---------- Collaboration ----------

class Panitia {
  final String nama;            // 'Panitia Natal 2026'
  final String ketua, sekretaris, bendahara, peruntukan, dasar;
  static const tahap = ['1 · Perencanaan', '2 · Aktif', '3 · Acara selesai',
      '4 · Penutupan keuangan', '5 · Ditutup', '6 · Diarsipkan'];
  const Panitia(...);
}

class Ibadah { final String judul, jenis, waktu, untuk, tempat, status; const Ibadah(...); }

class Kehadiran {
  final String ibadah;          // 'Ibadah Minggu pagi · 15/11/2026'
  final Map<String, int> perPos; // 'Pintu depan · Yanti S.': 142, 'Pintu samping · Greis M.': 89
  final String status;          // 'Sedang dihitung' · 'Sudah diperiksa' · 'Ditetapkan'
  const Kehadiran(...);
}

class PermintaanDana {
  final String perlu;           // 'Konsumsi Natal Pemuda'
  final int jumlah;
  final String peruntukan, diajukanOleh, status;
  const PermintaanDana(...);
}

class Modul { final String nama, status, keterangan; final GayaLabel gaya; const Modul(...); }
```

## 2. Seed values

### 2.1 Today and the church

| Item | Value |
| --- | --- |
| Today | 16/11/2026. Flow boards hold it as `HARI = 20261116`, `HARI_T = '16/11/2026'` (34 boards) |
| Church | "Jemaat Karunia". A4Warta prints "GMIM Jemaat Karunia" |
| Time zone, fiscal year | "WITA · tahun buku mulai 1 Januari (tidak dapat diubah)" |
| Start of recording | 15 September 2026 ("Pencatatan dimulai 15 September 2026") |
| Month being closed | Oktober 2026. September 2026 is closed. November 2026 is the running month |
| Official report of October | ID `SNP-2026-10-01`, "Dibekukan 16/11/2026 11.05", Versi Mata Anggaran 2026.1 |
| Provisional report of October | "Belum punya ID laporan resmi", "Dibuat 14/11/2026 09.20" (A4Sementara) |
| Report format | "Bawaan Palakat v1"; approval of the format recorded 03/10/2026 by Pdt. Lidya Rondonuwu, Ketua BPMJ (see section 3, row 21) |
| Footer of every A4 page | "Palakat · format bawaan aplikasi, bukan formulir resmi GMIM · Jemaat Karunia" |
| Approval rule | "Wajib untuk Belanja Rp2.000.000 ke atas · berlaku mulai September 2026" |
| Supporting document rule | "Wajib untuk semua Belanja · Bendahara boleh memverifikasi unggahannya sendiri"; Pemberi pengecualian: Ketua BPMJ |
| Fund request threshold | "di bawah batas Rp250.000 yang ditetapkan Jemaat" (PermintaanDana) |
| AI cost cap | "Batas biaya AI per bulan · … dari Rp150.000" (AIBulan, WebAI; tweak `biayaAI` 40 · 75 · 95 · 100 %) |
| No. Bukti series | "BKU-2026-0001 Biasa · OPN-2026-0001 Saldo awal pencatatan · ADJ-2026-0001 Penyesuaian" (WebPengaturan); Lainnya prints "BKU-2026-0001 Biasa · OPN Saldo awal pencatatan · ADJ Penyesuaian" |
| Units | 12 Kolom ("di 12 Kolom", "11 dari 12 terisi"); named: Kolom 2, 3, 4, 5, 7, 11. BIPRA Pemuda, Remaja. Komisi Diakonia, Komisi Pembangunan. Panitia Natal 2026, Panitia HUT Jemaat, Panitia Paskah 2026 |

### 2.2 People

Names are invented (R02). "Short" is how finance boards abbreviate.

| id | Name as drawn | Short | Posts and roles drawn | Other facts |
| --- | --- | --- | --- | --- |
| meiske | Meiske Lumentut | Meiske L. | Bendahara Jemaat, aktif sejak 15/09/2026 · SK-BPMJ-04-2026 | Verified by Petugas verifikasi 15/09/2026 10.15. Email meiske@contoh.id (WebVerifikasi). Penunjukan sent 13/09/2026 09.05 and 14/09/2026 15.20. Authority revoked 16/11/2026 08.10 in the vacancy scenario (2.24) |
| olvie | Olvie Pangemanan | — | Sekretaris Jemaat, sejak 03/11/2026 · SK BPMJ No. 12/2026 | 081355512204, olvie@contoh.id (WebAkunSaya) |
| yanti | Yanti Sumual | "Yanti Sumual, Operator"; "Yanti S." on Kehadiran | Operator sejak 01/11/2026; menjalankan jabatan kosong Penatua Kolom 2 sejak 01/11/2026; menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15 (scenario) | Keluarga Sumual is her own family (Kolom 2) |
| lidya | Pdt. Lidya Rondonuwu | — | Ketua Jemaat sejak 01/01/2026 · Ketua BPMJ; Pimpinan Jemaat yang berwenang | Approves format, approvals, Panitia, modules (R01) |
| jefry | Pnt. Jefry Wowor | — | Wakil Ketua BPMJ sejak 01/01/2026; Pemeriksa kedua | Petugas penghitung; Uang Muka "Perjalanan dinas Wilayah"; readiness of Umum Jemaat 02/11/2026 |
| hendrik | Pnt. Hendrik Rumagit | — | Penatua Kolom 7 sejak 01/01/2026; Ketua Komisi Diakonia sejak 01/03/2026 | 081234567890, no backup email (AkunSaya). Keluarga Rumagit, Kolom 7 |
| deasy | Deasy Tumbelaka | — | Bendahara Kolom 7 | Manages Kas Kolom 7 |
| stevi | Sdr. Stevi Lengkong | Stevi Lengkong | Ketua Panitia Natal 2026 | |
| natalia | Sdri. Natalia Rumengan | Natalia Rumengan | Sekretaris Panitia Natal 2026 | Uang Muka "Retret Pemuda" |
| rivo | Sdr. Rivo Mandagi | Rivo Mandagi | Bendahara Panitia Natal 2026; "Ketua Pemuda" (PermintaanDana); preparer of peruntukan Pembangunan (Kesiapan) | Uang Muka "Panitia Natal"; claim "Bensin antar jemput" |
| novita | Novita Wenas | — | Anggota jemaat | Keluarga Wenas-Lasut, Kolom 7 sejak 01/06/2021 (Kolom 4 12/02/2009 – 31/05/2021); lahir 14/03/1996; "Belum pernah menikah"; BIPRA Pemuda ("Dasar: 30 tahun dan belum pernah menikah."); Baptisan 19/05/1996, Sidi 13/04/2014; old number "0812 ···· 7741", new 081298765432 (AlurPulihkan) |
| agustina | Agustina Lasut | — | Wakil keluarga Wenas-Lasut | lahir 12/12/1974, Kolom 7 |
| ferry | Ferry Wenas | — | — | lahir 03/08/1971 ("WENAS FERRY, lhr 3-8-71, Kol 7"), "Belum dikonfirmasi", diimpor 12/11/2026 |
| gabriel | Gabriel Wenas | — | — | child; Baptisan 08/11/2026, name on certificate "Gabriel J. Wenas" |
| olga | Dkn. Olga Tamba | — | Bendahara Komisi Diakonia; "Akses terbatas: Peruntukan Diakonia" | Petugas penghitung |
| greis | Sym. Greis Mamahit | Greis M. | Syamas Kolom 7 | Pelimpahan "Verifikasi data Kolom 7" |
| altje | Pnt. Altje Rompas | — | Penatua Kolom 2, 01/01/2022 – 31/10/2026; assigned again from 16/11/2026 in AlurJabatanKosong | |
| yohanisR | Yohanis Rompas | — | — | Kolom 2, 03/02/1948 – 14/11/2026, "Meninggal dunia" |
| kevin | Kevin Rompas | — | — | Permohonan menjadi anggota, Kolom 2, diajukan 15/11/2026 |
| gabriela | Gabriela Rompas | — | — | Peristiwa Sidi, Kolom 2, diajukan 12/11/2026 |
| selvie | Ibu Selvie Kalalo | — | — | Uang Muka "Konsumsi syukur HUT"; claim "Alat kebersihan gereja" |
| yohanisT | Yohanis Tumbelaka | — | New Bendahara Jemaat on Bendahara/WebSerahTerima, "aktif sejak 16/11/2026 · SK-BPMJ-09-2026" | |
| deitje | Deitje Kawengian | — | New Bendahara Jemaat on JabatanKosong/WebJabatanKosong, "wewenang aktif sejak 18/11/2026" | |

Families and other parties:

| Name | Facts |
| --- | --- |
| Keluarga Wenas-Lasut | Kolom 7, "4 orang: Ferry, Agustina, Novita, Gabriel"; wakil Agustina Lasut; diimpor 12/11/2026; display "Kel. Wenas-Lasut — Kolom 7" |
| Keluarga Lasut | Kolom 4 → Kolom 7, "berlaku 01/12/2026"; Atestasi "pindah ke Jemaat lain" |
| Keluarga Rumagit | Kolom 7, perubahan data diajukan 14/11/2026, forwarded to the Syamas |
| Keluarga Sumual | Kolom 2, perubahan data diajukan 15/11/2026 |
| Kel. Mamahit — Kolom 4 | Sampul syukur shown by exception (BukaNama) |
| Ibu Runtu | Bank mutation "TRF MASUK IBU RUNTU" 28/10/2026 |
| TOKO SINAR | "Jl. Pierre Tendean 7"; Toko Sinar is the October split payment and the September duplicate |
| CV NADA PRIMA | "Jl. Sam Ratulangi 14"; receipt of the sound system, 11/11/2026, "LUNAS" |
| Sinode, Wilayah | Titipan recipients |
| BPMJ Jemaat Karunia | Appoints the Bendahara; "Pdt. Lidya Rondonuwu, Ketua" |
| Petugas verifikasi | Verifies treasurer and secretary appointments |

### 2.3 Posts (Penugasan board)

| Jabatan | Status (label, style) | Orang | Keterangan |
| --- | --- | --- | --- |
| Bendahara Jemaat | Aktif, laut | Meiske Lumentut | "Sejak 15/09/2026 · wewenang sudah diverifikasi" |
| Penatua Kolom 2 | Jabatan kosong, bata, dashed card | — | "Dijalankan Operator Yanti Sumual sejak 01/11/2026" |
| Sekretaris Jemaat | Aktif, laut | Olvie Pangemanan | "Sejak 03/11/2026 · SK BPMJ No. 12/2026" (state "Menunggu verifikasi wewenang": "Olvie Pangemanan · dicatat 03/11/2026") |
| Ketua Jemaat | Aktif, laut | Pdt. Lidya Rondonuwu | "Sejak 01/01/2026 · Ketua BPMJ" |
| Wakil Ketua BPMJ | Aktif, laut | Pnt. Jefry Wowor | "Sejak 01/01/2026" |
| Ketua Komisi Diakonia | Aktif, laut | Pnt. Hendrik Rumagit | "Sejak 01/03/2026" |
| Operator | Aktif, laut | Yanti Sumual | "Sejak 01/11/2026" |
| Penatua Kolom 7 | Aktif, laut | Pnt. Hendrik Rumagit | "Sejak 01/01/2026" |
| Syamas Kolom 3 | Jabatan kosong, bata, dashed card | — | "Belum ada yang menjalankan" |
| Penatua Kolom 2 | Berakhir, abu | Pnt. Altje Rompas | "01/01/2022 – 31/10/2026" |

Also drawn: Syamas Kolom 7 Sym. Greis Mamahit; Bendahara Kolom 7 Deasy Tumbelaka; Bendahara Komisi Diakonia Dkn. Olga Tamba; Panitia Natal 2026 officers (2.20). AlurPenugasan's own table (jabatan · unit · orang · sejak): Syamas · Kolom 3 · empty; Penatua · Kolom 2 · empty; Ketua · Komisi Diakonia · Pnt. Hendrik Rumagit · 01/03/2026; Operator · Jemaat · Yanti Sumual · 01/11/2026; suggestions "Sym. Greis Mamahit", "Pnt. Altje Rompas", "Pdt. Lidya Rondonuwu"; documents "SK BPMJ No. 14/2026", "Belum ada…".

Pelimpahan:

| Dari → kepada | Tugas | Dates | Status |
| --- | --- | --- | --- |
| Penatua Kolom 7 → Sym. Greis Mamahit | Verifikasi data Kolom 7 | 16/11/2026 sampai 30/11/2026 | Aktif |
| Sekretaris Jemaat → Yanti Sumual | Menyusun draf pengumuman | 03/11/2026 sampai 10/11/2026 | Berakhir |

### 2.4 Kas/Bank, peruntukan, Lingkup

| id | Name | Managed by | State | Opening 15/09/2026 (OPN) | 1 Oct 2026 | 31 Oct 2026 saldo buku | November saldo buku (16/11) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| kas | Kas | Jemaat | Aktif · dipakai sejak September 2026 | Rp3.200.000 | Rp4.070.000 (F03) | Rp8.750.000 | Rp8.420.000 |
| bni | Bank BNI ··4821 | Jemaat | Aktif · dipakai sejak September 2026 | Rp24.000.000 | Rp28.565.000 (**derived**) | Rp24.600.000 | Rp24.615.000 |
| bsg | Bank SulutGo ··1107 | Jemaat | Aktif · dipakai sejak September 2026 | Rp5.100.000 | Rp3.615.000 (**derived**) | Rp5.115.000 | Rp5.380.000 |
| hut | Kas Panitia HUT | — | "Nonaktif sejak November 2026 · tetap tampil di laporan lama" (deactivated 28/10/2026 16.44) | — | — | — | — |
| kol7 | Kas Kolom 7 | "Dikelola oleh Kolom 7 · Bendahara: Deasy Tumbelaka" | Aktif | — | — | Rp920.000 (Oct rekon) | Rp1.240.000 |
| — | Kas Panitia Natal | Bendahara Panitia (Panitia board text only) | — | — | — | — | — |
| **All Jemaat Kas/Bank** | | | | **Rp32.300.000** | **Rp36.250.000** | **Rp38.465.000** | **Rp38.415.000** |

Opening sources: Kas "Sumber: berita acara hitung kas 14/09/2026"; BNI "Rekening koran 14/09/2026" (WebAwal). Kas split at opening (Awal): Umum Jemaat Rp2.000.000, Diakonia Rp700.000, Pembangunan empty ("Belum diisi. Kosong bukan Rp0."; Rp500.000 balances it). BNI "Rp24.000.000 · sudah dibagi", SulutGo "Rp5.100.000 · sudah dibagi". "Uang muka dan titipan yang masih berjalan: tidak ada". Posted as `OPN-2026-0001`, "Saldo awal pencatatan · semua Kas/Bank Rp32.300.000".

Bank BNI ··4821 by peruntukan on 16/11 (AlihPeruntukan): Umum Jemaat Rp18.115.000, Diakonia Rp4.200.000, Pembangunan Rp2.300.000 (sum Rp24.615.000; bar colours tinta, laut, #86B5B8).

Peruntukan: `umum` "Umum Jemaat", `diak` "Diakonia", `bang` "Pembangunan". Unit peruntukan: "Kolom 7", "Panitia Natal".

Lingkup (Catat forms, KasusBaru, TabCatat): "Jemaat", "Kolom 3", "BIPRA Pemuda", "Panitia Natal". Lainnya lists five: "Jemaat · Kolom 3 · BIPRA Pemuda · Komisi Diakonia · Panitia Natal" (section 3, row 22).

### 2.5 Mata Anggaran

Version 2026.1: "Diterbitkan", "Berlaku mulai September 2026", "Pendapatan 131 baris · Belanja 158 baris". Codes are mono. Rows drawn on any board:

| Kode | Nama | Pohon | Heading | Boleh untuk |
| --- | --- | --- | --- | --- |
| 1.3.53.00.00 | PERSEMBAHAN | Pendapatan | yes | — |
| 1.3.53.07.00 | Persembahan Ibadah Minggu | Pendapatan | | Milik sendiri |
| 1.3.53.09.00 | Persembahan syukur | Pendapatan | | Milik sendiri |
| 1.3.55.01.00 | Persembahan Diakonia | Pendapatan | | Milik sendiri |
| 1.4.10.00.00 | SUMBANGAN | Pendapatan | yes | — |
| 1.4.10.02.00 | Sumbangan donatur | Pendapatan | | Keduanya |
| 1.4.10.03.00 | Sumbangan natura | Pendapatan | | (F05 only) |
| 2.1.01.02.00 | DANA TRANSIT Sentralisasi Sinode ("Sentralisasi Sinode" on KasusBaru) | Pendapatan tab | | Titipan |
| 2.2.01.02.00 | "Persembahan khusus Wilayah" (KasusBaru) | — | | Titipan |
| 5.00.00.00 | BELANJA OPERASIONAL | Belanja | yes | — |
| 5.01.02.00 | Listrik, air dan telepon | Belanja | | Milik sendiri |
| 5.02.01.00 | Alat tulis dan fotokopi | Belanja | | Milik sendiri |
| 5.03.03.00 | Biaya administrasi bank | Belanja | | Milik sendiri |
| 5.04.01.00 | Konsumsi rapat | Belanja | | |
| 5.05.02.00 | Sewa peralatan | Belanja | | |
| 5.07.01.00 | Honorarium pelayan | Belanja | | |
| 5.08.02.00 | Pemeliharaan gedung | Belanja | | |
| 4.00.00.00 | BELANJA PELAYANAN | Belanja | yes | — |
| 4.03.03.00 | Diakonia duka | Belanja | | Milik sendiri |
| 4.03.04.00 | Diakonia sakit | Belanja | | |

Picker lists drawn on the Catat forms (Main, WebCatat, TabCatat), in this order: Belanja `5.00.00.00` (heading), `5.01.02.00`, `5.02.01.00`, `5.03.03.00`, `4.00.00.00` (heading), `4.03.03.00`; Pendapatan `1.3.53.00.00` (heading), `1.3.53.07.00`, `1.3.53.09.00`, `1.4.10.00.00` (heading), `1.4.10.02.00`. Bagi's list: `5.01.02.00`, `5.02.01.00`, `5.03.03.00`, `5.04.01.00`, `5.05.02.00`. Titipan list on KasusBaru: `2.1.01.02.00` "Sentralisasi Sinode", `2.2.01.02.00` "Persembahan khusus Wilayah".

Version 2026.2 (draft, "usulan berlaku mulai Desember 2026", "2 baris baru · 1 nama berubah · dibanding versi 2026.1"):

| Board | Belanja tab | Pendapatan tab |
| --- | --- | --- |
| MataAnggaran | `5.00.00.00` BELANJA OPERASIONAL (heading); `5.01.02.00` Listrik, air dan telepon; `5.03.03.00` Biaya administrasi bank; `5.06.01.00` Internet dan langganan aplikasi (Baru); `4.03.03.00` Diakonia duka dan sakit (Nama berubah) | `1.3.53.00.00` PERSEMBAHAN (heading); `1.3.53.07.00`; `1.3.53.09.00`; `2.1.01.02.00` DANA TRANSIT Sentralisasi Sinode (Baru); `1.4.10.02.00` Sumbangan donatur |
| WebMataAnggaran | same, plus `2.2.01.02.00` DANA TRANSIT Penyaluran Sentralisasi Sinode (Baru) | same, plus `1.4.10.03.00` Sumbangan natura (Baru) |

Default "Boleh untuk" state: `5.01.02.00` Milik sendiri, `5.03.03.00` Milik sendiri, `5.06.01.00` empty, `4.03.03.00` Milik sendiri, `1.3.53.07.00` Milik sendiri, `1.3.53.09.00` Milik sendiri, `2.1.01.02.00` Titipan, `1.4.10.02.00` Keduanya; web adds `2.2.01.02.00` Titipan, `1.4.10.03.00` empty. Published state: "Berlaku mulai Desember 2026 · diterbitkan oleh Meiske L., 16/11/2026".

### 2.6 Months

| Bulan | Status | Text drawn (PilihBulan unless noted) |
| --- | --- | --- |
| Desember 2026 | Belum ditutup | "Belum ada transaksi" |
| November 2026 | Belum ditutup | "Bulan berjalan · 12 transaksi"; on TutupBuku "Bulan berjalan · menunggu Oktober ditutup" |
| Oktober 2026 | Belum ditutup → Sudah ditutup 16/11/2026 11.05 | "Berikutnya untuk tutup buku · 33 transaksi"; after close "Periode laporan 1–31 Oktober 2026" |
| September 2026 | Sudah ditutup (05/10/2026 19.02 by Meiske L.) | "Periode laporan 15–30 September 2026 · 21 transaksi" |

### 2.7 October 2026 transactions (F02 Buku Kas Umum, 31 rows)

All are Dibukukan unless the Status column says otherwise. "In"/"Out" are the F02 columns; transfers fill both. "Saldo" is "Saldo semua Kas/Bank" after the row. Opening "Saldo awal Kas/Bank Rp36.250.000".

| Tanggal | No. Bukti | No. MA | Uraian | Kas/Bank | In | Out | Saldo | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 04/10/2026 | BKU-2026-0098 | 1.3.53.07.00; 1.3.55.01.00 | Persembahan Ibadah Minggu dan Diakonia | Kas; Bank BNI ··4821 | 4.150.000 | | 40.400.000 | Parts: 1.3.53.07.00 Rp3.200.000 to Kas; 1.3.55.01.00 Rp950.000 to Bank BNI, peruntukan Diakonia |
| 04/10/2026 | BKU-2026-0099 | 2.1.01.02.00 | Titipan untuk: Sinode · Sentralisasi | Kas | 600.000 | | 41.000.000 | |
| 05/10/2026 | BKU-2026-0100 | 5.07.01.00 | Honorarium pelayan | Bank BNI ··4821 | | 1.820.000 | 39.180.000 | |
| 06/10/2026 | BKU-2026-0101 | 5.01.02.00; 5.02.01.00 | Toko Sinar: listrik dan alat tulis, satu pembayaran | Bank BNI ··4821 | | 1.250.000 | 37.930.000 | Parts: 5.01.02.00 Rp1.000.000; 5.02.01.00 Rp250.000 |
| 06/10/2026 | BKU-2026-0102 | — | Setoran ke bank: ke Bank BNI ··4821 | Kas ke Bank BNI | 5.000.000 | 5.000.000 | 37.930.000 | |
| 07/10/2026 | BKU-2026-0103 | — | Uang Muka diberikan · Pnt. Jefry Wowor | Kas | | 400.000 | 37.530.000 | |
| 08/10/2026 | BKU-2026-0104 | — | Setoran ke bank: ke Bank SulutGo ··1107 | Kas ke Bank SulutGo | 1.500.000 | 1.500.000 | 37.530.000 | |
| 09/10/2026 | BKU-2026-0105 | 5.02.01.00 | Konsumsi rapat majelis | Kas | | 750.000 | 36.780.000 | Dibalik, "Dibalik oleh BKU-2026-0109" |
| 10/10/2026 | BKU-2026-0106 | — | Pengembalian sisa uang muka · Panitia HUT Jemaat | Kas | 350.000 | | 37.130.000 | |
| 11/10/2026 | BKU-2026-0107 | 1.3.53.07.00 | Persembahan Ibadah Minggu | Kas | 2.650.000 | | 39.780.000 | |
| 11/10/2026 | BKU-2026-0108 | 2.1.01.02.00 | Titipan untuk: Sinode · Sentralisasi | Kas | 600.000 | | 40.380.000 | page 1 total In 14.850.000, Out 10.720.000 |
| 12/10/2026 | BKU-2026-0109 | 5.02.01.00 | Pembalikan BKU-2026-0105 | Kas | | −750.000 | 41.130.000 | "Pembalikan"; reason "Mata Anggaran keliru" |
| 12/10/2026 | BKU-2026-0110 | 5.04.01.00 | Konsumsi rapat majelis | Kas | | 750.000 | 40.380.000 | "Koreksi dari BKU-2026-0105" |
| 18/10/2026 | BKU-2026-0114 | 1.3.53.07.00 | Persembahan Ibadah Minggu | Kas | 2.400.000 | | 42.780.000 | |
| 18/10/2026 | BKU-2026-0115 | 1.4.10.02.00 | Sumbangan donatur | Bank BNI ··4821 | 700.000 | | 43.480.000 | |
| 18/10/2026 | BKU-2026-0117 | 2.1.01.02.00 | Titipan untuk: Sinode · Sentralisasi | Kas | 600.000 | | 44.080.000 | |
| 20/10/2026 | BKU-2026-0112 | — | Uang Muka diberikan · Sdri. Natalia Rumengan | Kas | | 800.000 | 43.280.000 | |
| 20/10/2026 | BKU-2026-0113 | 1.3.53.09.00 | Persembahan syukur | Kas | 1.220.000 | | 44.500.000 | |
| 22/10/2026 | BKU-2026-0116 | 5.08.02.00 | Pemeliharaan atap gedung | Bank BNI ··4821 | | 5.500.000 | 39.000.000 | Approval "Sudah dicatat · Ketua BPMJ"; document "Dikecualikan · kuitansi menyusul", recorded 22/10/2026 |
| 25/10/2026 | BKU-2026-0119 | — | Uang Muka diberikan · Ibu Selvie Kalalo | Kas | | 300.000 | 38.700.000 | |
| 25/10/2026 | BKU-2026-0123 | 1.3.53.07.00 | Persembahan Ibadah Minggu | Kas | 2.700.000 | | 41.400.000 | |
| 25/10/2026 | BKU-2026-0125 | 2.1.01.02.00 | Titipan untuk: Sinode · Sentralisasi | Kas | 600.000 | | 42.000.000 | page 2 total In 23.070.000, Out 17.320.000 |
| 26/10/2026 | BKU-2026-0120 | 5.07.01.00 | Honorarium pelayan | Bank BNI ··4821 | | 1.820.000 | 40.180.000 | |
| 26/10/2026 | BKU-2026-0130 | — | Setoran ke bank: ke Bank BNI ··4821 | Kas ke Bank BNI | 2.690.000 | 2.690.000 | 40.180.000 | |
| 27/10/2026 | BKU-2026-0118 | 1.3.53.09.00 | Persembahan syukur | Bank BNI ··4821 | 500.000 | | 40.680.000 | |
| 27/10/2026 | BKU-2026-0122 | 4.03.04.00 | Diakonia sakit | Kas | | 300.000 | 40.380.000 | peruntukan Diakonia |
| 28/10/2026 | BKU-2026-0121 | 1.4.10.02.00 | Sumbangan donatur | Bank BNI ··4821 | 500.000 | | 40.880.000 | |
| 30/10/2026 | BKU-2026-0127 | — | Pindah antar Kas/Bank: Bank BNI ke Kas | Bank BNI ke Kas | 2.000.000 | 2.000.000 | 40.880.000 | |
| 30/10/2026 | BKU-2026-0128 | 2.1.01.02.00 | Penyaluran · Titipan untuk: Sinode | Bank BNI ··4821 | | 2.400.000 | 38.480.000 | |
| 31/10/2026 | BKU-2026-0131 | — | Setoran ke bank: ke Bank BNI ··4821 | Kas ke Bank BNI | 500.000 | 500.000 | 38.480.000 | In transit at month end |
| 31/10/2026 | BKU-2026-0133 | 5.03.03.00 | Biaya administrasi bank | Bank BNI ··4821 | | 15.000 | 38.465.000 | Created from the "BIAYA ADM" mutation |
| | | | Jumlah dan saldo akhir Kas/Bank | | 29.260.000 | 27.045.000 | 38.465.000 | |

Print each amount with `rp()`; F02 prints `Rp4.150.000`, the reversal `−Rp750.000`. F02 footnote: "31 baris. … Nomor di antara BKU-2026-0098 dan BKU-2026-0133 yang tidak tampil di sini bukan arus kas/bank Oktober 2026; semuanya terdaftar di F12 Daftar Bukti Kas."

Numbers in that range that are not October cash rows:

| No. Bukti | What it is |
| --- | --- |
| BKU-2026-0111 | Unused: "diberikan 14/10/2026 10.20, pembukuannya tidak selesai. Nomor ini tidak dipakai ulang." |
| BKU-2026-0124 | Unused: "diberikan 29/10/2026 16.05, …" |
| BKU-2026-0126 | Unused: "diberikan 30/10/2026 09.12, …" |
| BKU-2026-0129 | Uang Muka diberikan, Panitia Natal, 01/11/2026 (2.9) |
| BKU-2026-0132 | Sampul syukur Novita Wenas, 01/11/2026 (2.18) |

R03: the two advance settlements of October advances (Rp400.000 and Rp300.000, together Rp700.000) are dated November, so the October pack prints Rp0 for them and attachment 2 reads "Nihil".

September 2026 rows drawn (PilihBulan, Kejadian, Draf):

| No. Bukti | Tanggal | Uraian | Jumlah |
| --- | --- | --- | --- |
| OPN-2026-0001 | 15/09/2026 | Saldo awal pencatatan | Rp32.300.000 |
| BKU-2026-0019 | 18/09/2026 | Persembahan Ibadah Minggu | Rp2.900.000 |
| BKU-2026-0031 | 22/09/2026 | Alat tulis Toko Sinar | −Rp85.000 |
| (draf) | 28 September 2026 | Honor pemusik, Bank BNI ··4821, "Draf dicatat oleh Meiske L." 28/09/2026 16.10 | −Rp650.000 |

### 2.8 October report figures (SNP-2026-10-01)

F01 Laporan Perbendaharaan Bulanan (A4F01, A4Sementara, WebLaporan, Laporan):

| Baris | Oktober 2026 |
| --- | --- |
| Saldo awal Kas/Bank | Rp36.250.000 |
| Pendapatan ekonomi | Rp14.820.000 |
| Belanja ekonomi | −Rp11.455.000 |
| Dana Transit masuk · titipan masuk | Rp2.400.000 |
| Dana Transit keluar · titipan disalurkan | −Rp2.400.000 |
| Uang Muka diberikan | −Rp1.500.000 |
| Pengembalian sisa uang muka | Rp350.000 |
| Saldo akhir Kas/Bank | Rp38.465.000 |

F01 reconciliation block / F10 Posisi Kas & Bank "Per 31 Oktober 2026":

| Kas/Bank | Saldo buku | Pembanding | Selisih |
| --- | --- | --- | --- |
| Kas | Rp8.750.000 | Hitung kas Rp8.750.000 | Rp0 |
| Bank BNI ··4821 | Rp24.600.000 | Rekening koran Rp24.100.000 + setoran dalam perjalanan Rp500.000 | Rp0 |
| Bank SulutGo ··1107 | Rp5.115.000 | Rekening koran Rp5.115.000 | Rp0 |
| Jumlah | Rp38.465.000 | | Rp0 |

F03 Buku Kas Pembantu · Kas: "Saldo awal Kas" Rp4.070.000, 22 rows, "Saldo akhir Kas Rp8.750.000" (rows as in WebPaketLaporan `LAP.F03`). TERBATAS version: Diakonia saldo awal Rp3.050.000 → 0098 Rp950.000 → Rp4.000.000 → 0122 Rp300.000 → Rp3.700.000.

F05 Pendapatan: PERSEMBAHAN Rp13.620.000; Persembahan Ibadah Minggu Rp10.950.000; Persembahan syukur Rp1.720.000; Persembahan Diakonia Rp950.000; SUMBANGAN Rp1.200.000; Sumbangan donatur Rp1.200.000; Sumbangan natura Rp0; Jumlah Pendapatan Rp14.820.000.

F07 Belanja: BELANJA OPERASIONAL Rp11.155.000; Listrik, air dan telepon Rp1.000.000; Alat tulis dan fotokopi Rp250.000; Biaya administrasi bank Rp15.000; Konsumsi rapat Rp750.000; Sewa peralatan Rp0; Honorarium pelayan Rp3.640.000; Pemeliharaan gedung Rp5.500.000; BELANJA PELAYANAN Rp300.000; Diakonia sakit Rp300.000; Jumlah Belanja Rp11.455.000.

F08 Rekap Penerimaan (Pendapatan · Titipan masuk · Pengembalian sisa uang muka · Pindah masuk · Jumlah): Kas 12.170.000 · 2.400.000 · 350.000 · 2.000.000 · 16.920.000; BNI 2.650.000 · 0 · 0 · 8.190.000 · 10.840.000; SulutGo 0 · 0 · 0 · 1.500.000 · 1.500.000; Jumlah 14.820.000 · 2.400.000 · 350.000 · 11.690.000 · 29.260.000.

F09 Rekap Pengeluaran (Belanja · Titipan disalurkan · Uang Muka diberikan · Pindah keluar · Jumlah): Kas 1.050.000 · 0 · 1.500.000 · 9.690.000 · 12.240.000; BNI 10.405.000 · 2.400.000 · 0 · 2.000.000 · 14.805.000; SulutGo all 0; Jumlah 11.455.000 · 2.400.000 · 1.500.000 · 11.690.000 · 27.045.000.

F11 Rekonsiliasi (Kas · BNI · SulutGo): hasil hitung / rekening koran 8.750.000 · 24.100.000 · 5.115.000; setoran dalam perjalanan 0 · 500.000 · 0; pembayaran dalam perjalanan 0 · 0 · 0; saldo pembanding 8.750.000 · 24.600.000 · 5.115.000; saldo buku same; selisih 0 · 0 · 0; "Mutasi bank cocok / belum cocok" — · "13 / 0" · "1 / 0"; Status "Sudah dipastikan" × 3.

F12 Daftar Bukti Kas: "Contoh 5 dari 33 baris": 0098 Rp4.150.000 Tidak diperlukan / Terverifikasi; 0101 −Rp1.250.000 Tidak diperlukan / Terverifikasi; 0105 −Rp750.000 Tidak diperlukan / Terverifikasi; 0109 Rp750.000 Tidak diperlukan / Tidak diperlukan; 0116 −Rp5.500.000 "Sudah dicatat · Ketua BPMJ" / "Dikecualikan · kuitansi menyusul".

F13 Sentralisasi / Penyaluran: Sinode Rp0 · Rp2.400.000 · Rp2.400.000 · Rp0; Wilayah all Rp0; Jumlah titipan Rp0 · Rp2.400.000 · Rp2.400.000 · Rp0; "Sentralisasi dari uang milik sendiri (Belanja, bukan titipan)" Rp0.

F14 attachments: 1 Uang Muka "3 kasus"; 2 Rincian Pertanggungjawaban Uang Muka "Nihil"; 3 Penghitungan Persembahan "4 ibadah"; 4 Penggantian Biaya "Nihil"; 5 Pengecualian Dokumen Pendukung "1 dokumen" (BKU-2026-0116, "Alasan: kuitansi menyusul · Pemberi pengecualian: Ketua BPMJ · dicatat 22/10/2026", −Rp5.500.000); 6 Pembalikan dan Koreksi "1 rangkaian" (0105 Rp750.000 Dibalik · 0109 −Rp750.000 "alasan: Mata Anggaran keliru" · 0110 Rp750.000 "Transaksi koreksi"); 7 Saldo Awal Pencatatan "Nihil"; 8 Hasil Pengecekan Otomatis "8 syarat terpenuhi".

TERBATAS copy (A4Terbatas, WebPaketLaporan with `salinan` ≠ Seluruh Jemaat): F05 `1.3.55.01.00` Persembahan Diakonia Rp950.000; F07 `4.03.03.00` Diakonia duka Rp0, `4.03.04.00` Diakonia sakit Rp300.000; Saldo peruntukan Diakonia awal Rp3.050.000, akhir Rp3.700.000; F12 0098 Rp950.000 Terverifikasi, 0122 −Rp300.000 Terverifikasi.

Excel file name (WebExcel): `Paket-Laporan-GMIM_Jemaat-Karunia_2026-10.xlsx`.

Warta and Cari reuse: "Pendapatan Rp14.820.000", "Belanja Rp11.455.000" (Belanja printed positive on Warta). Cari: "persembahan Minggu pagi bulan Oktober" → 0098 Rp3.200.000, 0107 Rp2.650.000, 0114 Rp2.400.000, 0123 Rp2.700.000 = Rp10.950.000.

### 2.9 November 2026 (running month, as of 16/11/2026)

Beranda figures (Main, WebBeranda, TabBeranda):

| Item | Value |
| --- | --- |
| Saldo buku semua Kas/Bank | Rp38.415.000 (Kas Rp8.420.000, BNI Rp24.615.000, SulutGo Rp5.380.000) |
| Draf | "Rp800.000 · 2 draf · belum masuk saldo" |
| Pendapatan bulan ini | Rp7.540.000 ("tanpa titipan") |
| Belanja bulan ini | Rp7.940.000 |
| Surplus/Defisit bulan ini | −Rp400.000 |
| Perlu tindakan (4) | "Oktober 2026 belum ditutup" / "1 hambatan · bulan berikutnya untuk tutup buku" (bata, bold); "2 draf belum dibukukan" / "Belum masuk saldo · Rp800.000"; "1 dokumen pendukung wajib, belum ada" / "BKU-2026-0143 · Rp600.000"; "1 Mata Anggaran belum dipilih" / "Draf · Honor pemusik" |
| Untuk diketahui | "2 uang muka dengan sisa belum dipertanggungjawabkan · Rp1.150.000" |
| Posisi Kas & Bank | Kas "— Belum dihitung"; BNI and SulutGo "— Rekening koran belum diisi" |
| Tweak `bulan: sepi` | all November figures Rp0, no drafts, only the October action |

November transactions drawn (each board's own fields; this is the union):

| No. Bukti | Tanggal | Uraian | Kas/Bank | Jumlah | Status / details | Boards |
| --- | --- | --- | --- | --- | --- | --- |
| BKU-2026-0129 | 01/11/2026 | Uang Muka diberikan · Panitia Natal (Sdr. Rivo Mandagi) | — | −1.500.000 | "dari peruntukan Umum Jemaat" | Kewajiban, WebKewajiban |
| BKU-2026-0132 | 01/11/2026 | Sampul syukur (Novita Wenas), Ibadah Minggu Pagi | — | 100.000 | Umum Jemaat | PersembahanSaya |
| BKU-2026-0134 | 05/11/2026 | Penggantian biaya dibayar · Bensin antar jemput (Sdr. Rivo Mandagi) | — | −120.000 | "Belanja, dicatat satu kali" | Kewajiban |
| BKU-2026-0135 | 06/11/2026 | Persembahan Diakonia | — | 1.200.000 | 1.3.55.01.00 | Terbatas |
| BKU-2026-0136 | 07/11/2026 | Penyaluran · Sentralisasi November (Sinode) | — | −1.000.000 | "bukan Belanja" | Kewajiban |
| BKU-2026-0137 | 08/11/2026 | Renovasi pastori, termin 1 | — | −4.500.000 | No. bukti asal KW-0412; "Sudah dicatat · Pdt. Lidya Rondonuwu, Ketua BPMJ"; "Dikecualikan (alasan: kuitansi menyusul, oleh Ketua BPMJ)" | WebBukti, Bukti |
| BKU-2026-0138 | 08/11/2026 | Pertanggungjawaban uang muka · Panitia Natal | — | −850.000 | "menjadi Belanja" | Kewajiban |
| BKU-2026-0139 | 09/11/2026 | Konsumsi rapat majelis | Kas | −750.000 | Dibalik, "Dibalik oleh No. Bukti BKU-2026-0144"; 5.02.01.00; Dibukukan 09/11/2026 14.12; Terverifikasi (oleh Meiske L.) | Main, WebTransaksi, Koreksi |
| BKU-2026-0140 | — | Bensin operasional | — | −200.000 | document item | Dokumen |
| BKU-2026-0141 | 10/11/2026 | Diakonia duka | — | −500.000 | 4.03.03.00 | Terbatas |
| BKU-2026-0142 | — | Pindah antar Kas/Bank: Kas ke Bank BNI | — | 1.000.000 | document item | Dokumen |
| BKU-2026-0143 | 11/11/2026 | Sewa sound system | Kas | −600.000 | Lingkup Panitia Natal; 5.05.02.00 Sewa peralatan; "Wajib, belum ada"; Dibukukan 11/11/2026 16.05; receipt CV NADA PRIMA | WebTransaksi, Bukti, Dokumen, Kamera |
| BKU-2026-0144 | 12/11/2026 | Pembalikan BKU-2026-0139 | Kas | 750.000 | "Mata Anggaran keliru"; Dibukukan 12/11/2026 09.31 | Main, WebTransaksi |
| BKU-2026-0145 | — | Konsumsi rapat majelis (koreksi) | — | −750.000 | 5.04.01.00 Konsumsi rapat | WebTransaksi, Koreksi, Dokumen |
| BKU-2026-0146 | 15/11/2026 | Persembahan Ibadah Minggu | Kas | 3.450.000 | Umum Jemaat, Jemaat, 1.3.53.07.00; Terverifikasi; Dibukukan 15/11/2026 12.20 | Main, WebTransaksi, Bukti |
| BKU-2026-0147 | 16/11/2026 | Fotokopi warta jemaat | Kas | −150.000 | Umum Jemaat, Jemaat, 5.02.01.00; "Diunggah, belum diverifikasi"; nota-16-11.jpg (TOKO SINAR "300 lbr x 500" Rp150.000); Dibukukan 16/11/2026 10.42 | WebTransaksi (after Bukukan), Bukti, Dokumen, LihatDokumen |
| BKU-2026-0148 | 15/11/2026 | Persembahan Ibadah Minggu (multi-part) | per part (2.13) | 3.600.000 | posted on Persembahan / WebPersembahan, "Satu persembahan, satu No. Bukti, {{bagianN}} bagian." | Persembahan, WebPersembahan |
| BKU-2026-0149 | 03/11/2026 | Pertanggungjawaban uang muka · Perjalanan dinas Wilayah | — | −400.000 | "menjadi Belanja" | Kewajiban |
| BKU-2026-0150 | 05/11/2026 | Pertanggungjawaban uang muka · Retret Pemuda | — | −300.000 | "menjadi Belanja" | Kewajiban |
| BKU-2026-0151 | 12/11 or 17/11/2026 | Persembahan Ibadah Kolom | Kas Kolom 7 | 320.000 | "Dibukukan oleh Deasy Tumbelaka, Bendahara Kolom 7 · 17/11/2026 20.10" | KeuanganUnit, AlurUnit (see section 3) |
| BKU-2026-0152 | 16/11/2026 | Alih peruntukan | Bank BNI ··4821 | | "Dibukukan pada 16/11/2026 11.55" | AlihPeruntukan |
| BKU-2026-0155 | 16/11/2026 | Konsumsi rapat, Kas, Belanja 5.04.01.00 | Kas | −85.000 | "Dibukukan pada 16/11/2026 11.52 · satu kali" | Memuat |
| (draf) | 14/11/2026 or 16/11/2026 | Fotokopi warta jemaat | Kas | −150.000 | Draf, "Belum masuk saldo" | Main (14/11), WebTransaksi (16/11) |
| (draf) | 08/11/2026 | Honor pemusik | Bank BNI ··4821 | −650.000 | Draf; "Mata Anggaran belum dipilih", "Persetujuan belum dicatat", "Wajib, belum ada" | Main, WebTransaksi |
| (dibatalkan) | 05/11/2026 | Pembelian bunga altar | Kas | −200.000 | "Tercatat dua kali"; "Dibatalkan oleh Meiske L." 06/11/2026 08.02 | WebTransaksi |

The Catat flow on Main, TabCatat and WebCatat always posts as `BKU-2026-0147`, "Dibukukan pada 16/11/2026 10.42", "Dicatat pada 16/11/2026 10.39"; Riwayat "10.42 · Dibukukan oleh …", "10.41 · Dokumen pendukung diunggah", "10.39 · Draf dicatat oleh …". The uploaded file is "nota-16-11.jpg". The date line is "16 November 2026".

Bukti (phone) and WebBukti: "Daftar Bukti Kas · November 2026 · Belum ditutup", "Seri Biasa · BKU-2026-0001 sampai 0151", "Contoh 6 dari 51 baris" (web) / "Contoh 5 dari 51" (phone), "3 nomor tanpa transaksi" (0111, 0124, 0126), "Seri OPN … Tidak ada celah", "Seri ADJ Penyesuaian · Belum pernah dipakai".

Import rows (Impor, WebImpor), statuses "Ditampung · Lolos pengecekan · Sudah diperiksa · Sudah diimpor":

| Source text | Read as | Mata Anggaran | Result |
| --- | --- | --- | --- |
| "02/11/26 · Persembahan Mgg · 3.100.000" | 02/11/2026 · Kas · Rp3.100.000 masuk | Pendapatan 1.3.53.07.00 | ok |
| "04/11/26 · Bayar PLN · -1250000" | 04/11/2026 · Bank BNI ··4821 · Rp1.250.000 keluar | Belanja 5.01.02.00 | ok |
| "4 Nop · PLN nov · 1.250.000,-" | same as above | Belanja 5.01.02.00 | possible duplicate |
| "08/11/26 · Honor pemusik · 650rb" | 08/11/2026 · Kas · Rp650.000 keluar | — | ok |
| "31/11/26 · ATK · 85.000" | "tanggal tidak terbaca" · Kas · Rp85.000 keluar | Belanja 5.02.01.00 | refused |

Export (Ekspor): "Buku", "Versi", "Dokumen pendukung" ("214 file, masing-masing dengan checksum"), "Laporan" ("Laporan resmi September dan Oktober 2026"), "Daftar isi". WebEkspor: "2 file Ditahan (alasan keamanan) · BKU-2026-0117, BKU-2026-0130", "1 file gagal dibaca · BKU-2026-0102".

### 2.10 Uang Muka, Titipan, Penggantian biaya

Phone Kewajiban and WebKasus (`state.kasus`). New entries are numbered from `BKU-2026-0150` (`nomor: 150`) and dated 16/11/2026.

| id | Jenis | Judul | Pihak | Awal | Awal catatan | Jatuh tempo | Entri | Sisa |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| um1 | Uang Muka | Panitia Natal | Sdr. Rivo Mandagi | 1.500.000 | "BKU-2026-0129 · 01/11/2026 · dari peruntukan Umum Jemaat" | 30/11/2026 | Pertanggungjawaban uang muka · BKU-2026-0138 · 08/11/2026 · menjadi Belanja · 850.000 | 650.000 |
| um2 | Uang Muka | Retret Pemuda | Sdri. Natalia Rumengan | 800.000 | "BKU-2026-0112 · 20/10/2026 · dari peruntukan Umum Jemaat" | 10/11/2026, lewat | … · BKU-2026-0150 · 05/11/2026 · 300.000 | 500.000 |
| um3 | Uang Muka | Perjalanan dinas Wilayah | Pnt. Jefry Wowor | 400.000 | "BKU-2026-0103 · 07/10/2026" | — | … · BKU-2026-0149 · 03/11/2026 · 400.000 | 0 |
| tt1 | Titipan | Sentralisasi November | Sinode | 2.400.000 | "Dari 4 persembahan · disimpan di Bank BNI ··4821" | — | Penyaluran · BKU-2026-0136 · 07/11/2026 · bukan Belanja · 1.000.000 | 1.400.000 |
| tt2 | Titipan | Persembahan khusus | Wilayah | 450.000 | "Dari persembahan khusus 9 November · disimpan di Kas" | — | — | 450.000 |
| pb1 | Penggantian biaya | Alat kebersihan gereja | Ibu Selvie Kalalo | 185.000 | "Nota 12/11/2026 terlampir · belum masuk saldo" | — | — | 185.000 |
| pb2 | Penggantian biaya | Bensin antar jemput | Sdr. Rivo Mandagi | 120.000 | "Nota 02/11/2026 terlampir" | — | Penggantian biaya dibayar · BKU-2026-0134 · 05/11/2026 · 120.000 | 0 |

WebKewajiban rows `[jenis, judul, catatan, pihak, awal, terpakai, tempo, lewat]` (adds Ibu Selvie Kalalo's advance):

| Jenis | Judul | Catatan | Pihak | Awal | Terpakai | Tempo |
| --- | --- | --- | --- | --- | --- | --- |
| um | Panitia Natal | BKU-2026-0129 · 01/11/2026 | Sdr. Rivo Mandagi | 1.500.000 | 850.000 | "Jatuh tempo 30/11/2026" |
| um | Retret Pemuda | BKU-2026-0112 · 20/10/2026 | Sdri. Natalia Rumengan | 800.000 | 300.000 | "Lewat jatuh tempo (jatuh tempo: 10/11/2026)" |
| um | Konsumsi syukur HUT | BKU-2026-0119 · 25/10/2026 | Ibu Selvie Kalalo | 300.000 | 375.000 | — |
| um | Perjalanan dinas Wilayah | BKU-2026-0103 · 07/10/2026 | Pnt. Jefry Wowor | 400.000 | 400.000 | — |
| tt | Sentralisasi November | Disimpan di Bank BNI ··4821 | Sinode | 2.400.000 | 1.000.000 | — |
| tt | Persembahan khusus | Disimpan di Kas | Wilayah | 450.000 | 0 | — |
| pb | Alat kebersihan gereja | Nota 12/11/2026 · klaim sudah dicek | Ibu Selvie Kalalo | 185.000 | 0 | — |
| pb | Kelebihan konsumsi syukur HUT | Dari uang muka BKU-2026-0119 | Ibu Selvie Kalalo | 75.000 | 0 | — |
| pb | Bensin antar jemput | BKU-2026-0134 · 05/11/2026 | Sdr. Rivo Mandagi | 120.000 | 120.000 | — |

KasusBaru: Kas/Bank choices with balances Kas 8.420.000, Bank BNI ··4821 24.615.000, Bank SulutGo ··1107 5.380.000; due dates "30 November 2026", "15 Desember 2026", "31 Desember 2026".

### 2.11 Month-end: reconciliation of Bank BNI ··4821, October 2026

Used by TutupBuku (rekon screen), WebRekonsiliasi, RekonIsi, WebRekonIsi, AIBulan, WebAI.

| Item | Value |
| --- | --- |
| Saldo buku | Rp24.615.000 before the fee; Rp24.600.000 after "Buat transaksi dari mutasi ini" (BKU-2026-0133) |
| Saldo rekening koran | Rp24.100.000 (RekonIsi: typed by the user; "Saldo rekening koran per 31/10/2026") |
| Setoran dalam perjalanan | BKU-2026-0131 · 31/10/2026 · Rp500.000, "dibawa ke November 2026" |
| Starting selisih | Rp515.000 (= 24.615.000 − 24.100.000) |
| Matched already | "12 mutasi bank lain sudah cocok dengan transaksinya." (13 after the fee) |
| File | "mutasi-bni-okt.csv · 3 mutasi dibaca. Belum ada yang dicocokkan." |

Mutations: `m1` "TRF MASUK IBU RUNTU" 28/10/2026 Rp1.000.000 (matches t1 + t2); `m2` "TARIK TUNAI" 30/10/2026 −Rp2.000.000 (matches t3); `m3` "BIAYA ADM" 31/10/2026 −Rp15.000 (no transaction until created).
Transactions: `t1` BKU-2026-0118 Persembahan syukur 27/10/2026 Rp500.000; `t2` BKU-2026-0121 Sumbangan donatur 28/10/2026 Rp500.000; `t3` BKU-2026-0127 "Pindah antar Kas/Bank: Bank BNI ke Kas" 30/10/2026 −Rp2.000.000; `t4` BKU-2026-0131 "Setoran ke bank: Kas ke Bank BNI" 31/10/2026 Rp500.000. RekonIsi differs: its `t4` is BKU-2026-0133 "Biaya administrasi bank" −Rp15.000, and "BIAYA ADM" starts already matched to it; its mutations appear only after the CSV is "uploaded".
RekonIsi second checker: "Sudah diperiksa oleh Pnt. Jefry Wowor. Bendahara memastikan." `bukuBerubah`: "BKU-2026-0127 dibalik setelah rekonsiliasi dipastikan."

Other Kas/Bank on the October close: Kas and Bank SulutGo ··1107 "Sudah dipastikan". Kas Kolom 7 October: saldo buku Rp920.000, hasil hitung kas Rp920.000 (SelesaikanUnit state "Ada selisih": hitung Rp870.000, selisih Rp50.000).

Close checklist (TutupBuku, WebTutupBuku), in order: "bulan sebelumnya sudah ditutup", "semua 3 kas/bank sudah direkonsiliasi", "Mata Anggaran sudah dipilih untuk semua transaksi", "persetujuan yang wajib sudah dicatat", "dokumen pendukung wajib sudah terverifikasi atau dikecualikan", "tidak ada transaksi Draf atau Sudah diperiksa", "tidak ada baris impor yang tertunda", "persetujuan format laporan sudah dicatat". Late draft on `gagalDiCekTerakhir`: "Fotokopi liturgi · Rp85.000". Close time "16/11/2026 11.05"; PDF ready after 3600 ms, Excel "File gagal dibuat".

### 2.12 Hitung kas (HitungKas, WebHitungKas)

| Item | Value |
| --- | --- |
| Header | "Kas · 16 November 2026 · 11.30" |
| Saldo buku | Rp8.420.000 |
| Denominations | 100.000 · 50.000 · 20.000 · 10.000 · 5.000 · 2.000 · 1.000 |
| `contohTerisi` on (default) | sheets 80 · 5 · 5 · 1 · 2 · 0 · 0 = Rp8.370.000, selisih Rp50.000 ("Uang di kas kurang Rp50.000 dari buku.") |
| `contohTerisi` off | all 0, "Belum dihitung. Kosong bukan Rp0." |
| Petugas choices | "Meiske L.", "Pnt. Jefry Wowor", "Dkn. Olga Tamba" |
| File | "lembar-hitung-16-11.jpg" |

### 2.13 Persembahan with several parts (Persembahan, WebPersembahan)

"Ibadah Minggu · 15 November 2026". Parts: Tunai Rp2.350.000, Milik sendiri, Kas; QRIS Rp800.000, Milik sendiri, no Kas/Bank yet; Transfer bank Rp450.000, "Titipan untuk: Sinode", Bank BNI ··4821. Totals: Milik sendiri Rp3.150.000, Titipan Rp450.000, all Rp3.600.000. MA per part: own → "Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu"; titipan → "Pendapatan 2.1.01.02.00 DANA TRANSIT Sentralisasi Sinode". Petugas default "Dkn. Olga Tamba" (choices add "Pnt. Jefry Wowor", "Meiske L."). Named envelopes added in order: "Novita Wenas" Rp100.000, "Agustina Lasut" Rp250.000. File "lembar-penghitungan-15-11.jpg". Posts as BKU-2026-0148.

### 2.14 Supporting documents (Dokumen, WebDokumen)

| id | No. Bukti | Uraian | Jumlah | Bulan | Initial status |
| --- | --- | --- | --- | --- | --- |
| a | BKU-2026-0147 | Fotokopi warta jemaat | −Rp150.000 | November 2026 · Belum ditutup | Diunggah, belum diverifikasi ("16/11/2026 10.41 · nota-16-11.jpg diunggah oleh Meiske L.") |
| b | BKU-2026-0143 | Sewa sound system | −Rp600.000 | November 2026 · Belum ditutup | Wajib, belum ada |
| c | BKU-2026-0116 | Pemeliharaan atap gedung | −Rp5.500.000 | Oktober 2026 · Sudah ditutup | Dikecualikan (history from 22/10) |
| d | BKU-2026-0145 | Konsumsi rapat majelis | −Rp750.000 | November 2026 · Belum ditutup | per board |
| e | BKU-2026-0140 | Bensin operasional | −Rp200.000 | November 2026 · Belum ditutup | per board |
| f | BKU-2026-0142 | Pindah antar Kas/Bank: Kas ke Bank BNI | Rp1.000.000 | November 2026 · Belum ditutup | per board |

Receipts drawn: TOKO SINAR, "Jl. Pierre Tendean 7", "Fotokopi warta", "300 lbr x 500" "150.000", total Rp150.000, 16/11/2026, "Terima kasih"; CV NADA PRIMA, "Jl. Sam Ratulangi 14", "Sewa sound system", "1 hari" "600.000", total Rp600.000, 11/11/2026, "LUNAS". Receipt paper colour #FBFAF6 (illustration).

### 2.15 Corrections, approvals, events, refunds

| Board | Data |
| --- | --- |
| Koreksi, WebKoreksi | BKU-2026-0139 Konsumsi rapat majelis −Rp750.000, Kas, "Belanja 5.02.01.00 Alat tulis dan fotokopi · Versi Mata Anggaran 2026.1"; MA choices `5.02.01.00` Alat tulis dan fotokopi (asal), `5.04.01.00` Konsumsi rapat; approval "Pdt. Lidya Rondonuwu, Ketua BPMJ · 08/11/2026 · cara: notulen rapat", "Dicatat oleh …, 16/11/2026 11.20"; result 0144 (pembalikan) + 0145 (koreksi); effect "Rp0" (koreksi) or "+Rp750.000" (pembalikan only). `bulanTransaksi: Sudah ditutup` shows date 09/10/2026 |
| Persetujuan, WebPersetujuan | Belanja Rp2.500.000, Bank BNI ··4821, "Belanja 5.08.02.00 Pemeliharaan gedung · 16 November 2026"; record Pdt. Lidya Rondonuwu, Ketua BPMJ, 08/11/2026, notulen rapat, recorded 16/11/2026 11.20; replaced 16/11/2026 11.45; amount change to Rp2.750.000 at 16/11/2026 11.50 |
| Pemeriksa | "Sewa kursi ibadah padang" −Rp900.000, Kas, Umum Jemaat, Lingkup Jemaat, "Belanja 5.05.02.00 Sewa peralatan · 16 November 2026", "Meiske L. · 16/11/2026 09.40", checked "Pnt. Jefry Wowor · 16/11/2026 10.05", posts as BKU-2026-0151 |
| WebPemeriksa | a "Sewa kursi ibadah padang" 16/11/2026 −900.000 "Kas · Belanja 5.05.02.00 Sewa peralatan"; b "Honor pemusik" 15/11/2026 −650.000 "Bank BNI ··4821 · Belanja 5.07.01.00 Honorarium pelayan"; c "Fotokopi warta jemaat" 14/11/2026 −150.000 "Kas · Belanja 5.02.01.00 Alat tulis dan fotokopi"; posted numbers BKU-2026-0151/0152/0153 |
| Kejadian, WebKejadian | K-2026-01 "Nota tercatat dua kali", September 2026, BKU-2026-0031: "Nota Toko Sinar Rp85.000 tercatat dua kali pada 22/09/2026. Ditemukan saat hitung kas 31/10/2026."; dampak "Kas Oktober 2026: hasil hitung kas lebih Rp85.000 dari Saldo buku."; pj "Pdt. Lidya Rondonuwu, Ketua BPMJ"; "Dibahas di rapat BPMJ 09/11/2026. Belum ada keputusan." K-2026-02 "Dokumen pendukung menyusul", September 2026, BKU-2026-0019, "Kuitansi asli diterima 12/10/2026, setelah September ditutup.", dampak "Tidak ada.", pj "Meiske L., Bendahara" |
| Pengembalian, WebPengembalian | donatur: BKU-2026-0121 Sumbangan donatur Rp500.000, Pendapatan 1.4.10.02.00, Bank BNI ··4821; pemasok: BKU-2026-0116 Pemeliharaan atap gedung Rp5.500.000, Belanja 5.08.02.00, Bank BNI ··4821 |
| AlurPengembalian | three sources: 22/10/2026 5.500.000 Belanja 5.08.02.00 Pemeliharaan gedung; 11/11/2026 600.000 Belanja 5.05.02.00 Sewa peralatan; 28/10/2026 500.000 Pendapatan 1.4.10.02.00 Sumbangan donatur; date 16/11/2026 |
| Draf, WebDraf | Honor pemusik −Rp650.000, Bank BNI ··4821, "tanggal transaksi 28 September 2026"; conflict "oleh …, 16/11/2026 10.58"; cancelled "16/11/2026 11.20"; empty draft "dibuat 16/11/2026 11.02" |
| Bagi, WebBagi | payment Rp1.250.000; lines 5.01.02.00 Rp1.000.000 and 5.02.01.00 Rp200.000 (Rp50.000 still to split) |
| AIFoto, BantuanAI, AIMataAnggaran | Rp1.250.000 to 5.01.02.00 Rp1.000.000 + 5.02.01.00 Rp250.000; sentence "Bayar PLN Rp1.250.000 dari BNI tanggal 6 Oktober"; AIMataAnggaran −Rp480.000, split "Kertas HVS Rp300.000 dan token listrik Rp180.000" |
| AIBulan, WebAI | "Selisih Rp515.000 di Bank BNI …"; "TARIK TUNAI −Rp2.000.000" (30/10) ↔ BKU-2026-0127; possible duplicate BKU-2026-0101 and draft "Toko Sinar okt" Rp1.250.000 on 06/10/2026 |
| Tanggal, WebTanggal | "16/11/2026 11.40" |
| Memuat | Kas Rp8.420.000, BNI Rp24.615.000, SulutGo Rp5.380.000; BKU-2026-0155 −Rp85.000 |

### 2.16 Notifications

Round-1 Pemberitahuan (phone and web), settings default `tindak` on, `tempo` on, `file` on, `ai` off:

| id | Jenis | Judul | Sub | Waktu |
| --- | --- | --- | --- | --- |
| n1 | tindak | Oktober 2026 belum ditutup | 1 hambatan · bulan berikutnya untuk tutup buku | Hari ini 08.00 |
| n2 | file | File Excel laporan gagal dibuat | Laporan resmi September 2026 · cukup dibuat lagi | Hari ini 07.42 |
| n3 | tempo | Uang muka lewat jatuh tempo | Retret Pemuda · sisa Rp500.000 · jatuh tempo 10/11/2026 | 11/11/2026 |
| n4 | tindak | 1 dokumen pendukung wajib, belum ada | BKU-2026-0143 · Sewa sound system | 11/11/2026 |
| n5 | ai | AI sedang tidak tersedia | Pencatatan berjalan seperti biasa | 09/11/2026 |

KotakMasuk (round 2), `keadaan: Ada pemberitahuan`: Perlu tindakan "3 permohonan surat" (Dokumen gereja · belum dibaca, Belum dibaca, tinta → PermohonanSurat); "Warta edisi 22/11/2026 belum diterbitkan" (Warta Jemaat · dibaca 16/11/2026, Dibaca, garis → WartaEditor). Untuk diketahui "Pengumuman “Kerja bakti” berakhir 20/11/2026" (→ Pengumuman); "Surat keterangan Novita Wenas diterbitkan" (Sudah ditindaklanjuti 15/11/2026, Selesai, abu). `Hanya modul Keuangan`: "2 draf belum dibukukan" (Keuangan · Oktober 2026, Belum dibaca); "Rekonsiliasi Bank BNI ··4821 belum dipastikan" (Keuangan, Dibaca); "2 uang muka lewat jatuh tempo".

BerandaJabatan / WebBerandaJabatan home per person (`keadaan`):

| Keadaan | Orang, jabatan | Perlu tindakan | Untuk diketahui |
| --- | --- | --- | --- |
| Beberapa jabatan | Pnt. Hendrik Rumagit: Penatua Kolom 7, Ketua Komisi Diakonia | "5 data menunggu verifikasi" (Sebagai Penatua Kolom 7 · 2 permohonan · 2 peristiwa · 1 perubahan data; Diajukan) → AntreanVerifikasi; "Ibadah Kolom 7, 19/11/2026" (Draf) → Ibadah; "Permintaan dana Komisi Diakonia" (Sebagai Ketua Komisi Diakonia; Diajukan) → PermintaanDana | "12 anggota Kolom 7 belum dikonfirmasi" → KonfirmasiKeluarga |
| Bendahara Jemaat | Meiske Lumentut | "Keuangan: 4 hal perlu tindakan" (Saldo buku Rp38.415.000 · Oktober 2026 belum ditutup) → Main; "1 hambatan dari unit" (Kolom 7; Hambatan, bata) → SelesaikanUnit | "2 uang muka dengan sisa belum dipertanggungjawabkan" → Main |
| Sekretaris Jemaat | Olvie Pangemanan | "2 pengumuman masih Draf"; "3 permohonan surat"; "Warta Jemaat edisi 22/11/2026" (Draf) | "1 pengumuman berakhir pada 20/11/2026" |
| Operator | Yanti Sumual: Operator, "Menjalankan jabatan kosong: Penatua Kolom 2" | "4 formulir kertas belum dimasukkan"; "2 permohonan surat dicatat di kantor"; "3 data Kolom 2 menunggu verifikasi" (Jabatan kosong, bata) | "Buku anggota: 318 baris sudah diimpor" (241 belum dikonfirmasi) |
| Anggota jemaat | Novita Wenas | "Permohonan surat keterangan" (Diajukan 14/11/2026) | "Warta Jemaat edisi 15/11/2026"; "2 pengumuman untuk Kolom 7"; "Persembahan saya" |
| Jabatan dipilih otomatis | Hendrik | Baptisan · Gabriel Wenas, "Diajukan oleh Novita Wenas, 15/11/2026" | |
| Dua jabatan dapat bertindak | Hendrik | "Setujui jadwal · Ibadah Kolom 7 bersama Komisi Diakonia", "Kamis, 19/11/2026 19.00 · rumah Kel. Wenas-Lasut" | |

### 2.17 Modules (Modul)

| Modul | Status, style | Keterangan |
| --- | --- | --- |
| Keuangan | Aktif, laut | Diaktifkan 15/09/2026 oleh Pdt. Lidya Rondonuwu |
| Dokumen gereja | Aktif, laut | Diaktifkan 03/11/2026 |
| Pengumuman | Aktif, laut | Diaktifkan 03/11/2026 |
| Warta Jemaat | Aktif, laut | Perlu: Pengumuman aktif ("46 edisi yang sudah diterbitkan") |
| Data jemaat | Tidak aktif, draf | Siap diaktifkan · Kategori BIPRA mengikuti ketentuan GMIM |
| Ibadah dan kegiatan | Tidak aktif, draf | Perlu: Data jemaat aktif |
| Jumlah kehadiran | Tidak aktif, draf | Perlu: Ibadah dan kegiatan aktif |
| Panitia | Hanya baca, garis | Dinonaktifkan 01/11/2026; riwayat tetap dapat dibaca |
| Keuangan unit | Tidak aktif, draf | Perlu: Keuangan aktif dan Kas/Bank yang dikelola unit |
| Persetujuan di aplikasi | Tidak aktif, draf | Perlu: tabel pemberi persetujuan Jemaat |

Prerequisites drawn: "Naskah bawaan · versi 1 · 12/11/2026" (consent text), "Penatua Kolom untuk setiap Kolom 11 dari 12 terisi".

Pemberi persetujuan table (PemberiPersetujuan), all empty at start: Kolom → "Penatua Kolom" | "Ketua Jemaat"; BIPRA → "Ketua BIPRA" | "Ketua Jemaat"; Komisi → "Ketua Komisi" | "Ketua Jemaat"; Panitia → "Ketua Panitia" | "Ketua Jemaat".

### 2.18 Member data

| Item | Value |
| --- | --- |
| Counts (LaporanLintas, Seluruh Jemaat) | Anggota aktif 1.284 "di 12 Kolom"; Keluarga 412; Peristiwa diverifikasi November 2026: 7 ("2 kelahiran · 3 baptisan · 1 pernikahan · 1 kematian"); Jumlah kehadiran Minggu 15/11/2026: 412 |
| Counts (LaporanLintas, Kolom 7) | 96 "Kolom 7 saja"; 31; 2; 38 |
| Paper-book import (ImporBuku) | "28 baris · 26 sudah diimpor · 1 kemungkinan ganda · 1 tidak diimpor"; rows: Ferry Wenas ("WENAS FERRY, lhr 3-8-71, Kol 7"), Agustina Lasut ("LASUT AGUSTINA (istri), 12-12-74"), Novita Wenas ("WENAS NOVITA, 14-3-96", possible duplicate of Aktif record), "—" ("RUMAGIT H., tgl lhr tdk terbaca", not imported) |
| AlurKeluarga | "Sumber Buku anggota Kolom 7 · 2019–2026"; result "3 orang" or "3 orang (Novita Wenas digabung dengan data yang sudah ada)" |
| Family confirmation (KonfirmasiKeluarga) | confirmed by Agustina Lasut 16/11/2026 19.30; paper form uploaded by Pnt. Hendrik Rumagit 16/11/2026, entered by Yanti Sumual; verified 17/11/2026 19.05 |
| Peristiwa | Baptisan · Gabriel Wenas, 08/11/2026, Diajukan by Novita Wenas 15/11/2026, Dikembalikan 16/11/2026, Diverifikasi 17/11/2026; Kematian · Yohanis Rompas 14/11/2026; Pindah Kolom · Keluarga Lasut, Kolom 4 → Kolom 7, berlaku 01/12/2026; Sidi · Gabriela Rompas (Kolom 2) |
| AntreanVerifikasi (Kolom 7) | "Permohonan menjadi anggota · Novita Wenas" (Diajukan 16/11/2026 · izin data pribadi diberikan); "Konfirmasi keluarga · Wenas-Lasut" (4 orang dari buku anggota); "Peristiwa: Baptisan · Gabriel Wenas" (Diajukan 15/11/2026); "Peristiwa: Pindah Kolom · Keluarga Lasut"; "Perubahan data · Keluarga Rumagit" (Ke Syamas, abu). Kolom 2 (vacant): "Permohonan menjadi anggota · Kevin Rompas"; "Peristiwa: Kematian · Yohanis Rompas" |
| AlurJabatanKosong (Kolom 2) | "Permohonan menjadi anggota · Ferry Wenas" (Diajukan 14/11/2026 · izin data pribadi diberikan); "Peristiwa: Sidi · Gabriela Rompas" (Diajukan 12/11/2026); "Perubahan data · Keluarga Sumual" (Diajukan 15/11/2026, own family) |
| PermohonanAnggota | "Diajukan 16/11/2026 10.12"; returned "17/11/2026 08.40"; verified "17/11/2026 19.05"; consent "Naskah versi 1 · 12/11/2026" |
| Display name (TampilanNama, AlurNama) | "Nama lengkap" Novita Wenas; "Nama keluarga" Kel. Wenas-Lasut; "Keluarga + Kolom" Kel. Wenas-Lasut — Kolom 7; "Kolom" Anggota Kolom 7 (TampilanNama: "Kolom 7"); "BIPRA" Pemuda; "BIPRA + Kolom" Anggota Pemuda Kolom 7 (TampilanNama: "Pemuda — Kolom 7"); "Tanpa nama". Recognisable warning: "Kolom 7 hanya punya dua anggota Pemuda." / "Tampil sebagai: Remaja — Kolom 11" |
| CariOrang ("Wenas") | Novita Wenas (Data jemaat · Keluarga Wenas-Lasut · Kolom 7, Aktif); Keluarga Wenas-Lasut (4 orang · Kolom 7); Ferry Wenas (Data jemaat · Kolom 2, Belum dikonfirmasi); Novita Wenas (Dokumen gereja · Surat keterangan 15/11/2026, Diterbitkan); Kel. Wenas-Lasut (Keuangan · Sampul syukur 08/11/2026, Dibukukan). `Tidak ada hasil`: query "Rumengan" |
| Persembahan saya (Novita) | Sampul syukur Rp100.000, 01/11/2026 · Ibadah Minggu Pagi · Umum Jemaat, BKU-2026-0132; Persembahan persepuluhan Rp300.000, 04/10/2026 · Ibadah Minggu Pagi · Umum Jemaat; Sampul syukur Rp150.000, 20/09/2026 · Ibadah Minggu Pagi · Diakonia |
| Cabut izin | "Permintaan hapus · Ferry Wenas", recorded by Yanti Sumual 16/11/2026; deleted 17/11/2026 20.15 by Pnt. Hendrik Rumagit |
| Data ganda | Novita Wenas, Belum dikonfirmasi; "Oleh Yanti Sumual, Operator · 17/11/2026 09.20" |
| Recovery (AlurPulihkan) | Novita Wenas, Kolom 7, old "0812 ···· 7741", new 081298765432, requested by Yanti Sumual, confirmed by Pnt. Hendrik Rumagit |
| Sign-in (AlurMasuk) | example 081234567890; code 123456 (Keadaan panel); match "Novita Wenas, 14/03/1996", "Satu data cocok Kolom 7" |
| Akun saya | Hendrik 081234567890, no backup email, device "Ponsel lain · Samsung A15 · terakhir 12/11/2026"; web: Olvie, 081355512204, olvie@contoh.id; new-number example 081298765432 |

### 2.19 Secretariat

| Board | Rows |
| --- | --- |
| DokumenGereja | "SK BPMJ No. 14/2026 · Penugasan Syamas Kolom 3" (Keputusan dan surat edaran · 18/11/2026 · Pelayan dan pengurus, Diterbitkan); "Surat edaran jadwal ibadah Natal 2026" (Keputusan dan surat edaran · 12/11/2026 · Semua anggota, Revisi 2; "Diterbitkan oleh Olvie Pangemanan, 14/11/2026 09.10"); "Notulen rapat BPMJ 08/11/2026" (Notulen rapat · Pelayan dan pengurus); "Tata ibadah Minggu Adven I" (Tata gereja dan liturgi · Semua anggota); "Surat keterangan · Novita Wenas" (Surat untuk anggota · 15/11/2026 · hanya anggota dan keluarganya); "Serah terima aset Panitia Paskah 2026" (Serah terima aset panitia · 30/04/2026 · Pelayan dan pengurus). All Diterbitkan, tinta, except the Revisi 2 row. `Dilihat anggota jemaat` shows rows 2, 4, 5 |
| TerbitDokumen | "Ditujukan untuk: Semua anggota · 12/11/2026"; "Diterbitkan oleh Olvie Pangemanan, 12/11/2026 16.40"; correction "Jam ibadah malam Natal: 19.00, bukan 18.00." |
| Pengumuman | "Kerja bakti halaman gereja" (Semua anggota · berakhir pada 20/11/2026, Diterbitkan; body "Sabtu, 21 November 2026 pukul 07.00. Membawa alat kebersihan masing-masing."; "Diterbitkan oleh Olvie Pangemanan, 16/11/2026 08.15"); "Pendaftaran katekisasi sidi 2027" (Semua anggota · tanpa tanggal berakhir, Draf); "Rapat pelayan khusus" (Pelayan dan pengurus · berakhir pada 25/11/2026, Draf); "Latihan paduan suara Kolom 7" (Kolom 7 · berakhir 15/11/2026, Diarsipkan, abu). Draft by "Operator Yanti Sumual" |
| Warta 22/11/2026 (WartaEditor, A4Warta) | Ibadah "Subuh 05.00 · Pagi 09.00 · Malam 18.00"; Pengumuman "Kerja bakti halaman gereja · Pendaftaran katekisasi sidi 2027"; Kehadiran Minggu 15/11/2026 "412 orang (Subuh 96 · Pagi 231 · Malam 85)"; Peristiwa "Syukur HUT pernikahan: Keluarga Wenas-Lasut — Kolom 7", "Sampul syukur: Tanpa nama, Kolom 4" (exception: "Kel. Mamahit — Kolom 4"); Keuangan Oktober Pendapatan Rp14.820.000, Belanja Rp11.455.000; Diperiksa "Olvie Pangemanan, 20/11/2026 14.05"; Disetujui "20/11/2026 14.20"; Diterbitkan "21/11/2026 17.00" (A4: "Diterbitkan 21/11/2026 oleh Sekretaris Jemaat"). AlurWarta adds "Rabu, 25/11/2026 pukul 19.00" |
| BukaNama | reason "Persembahan khusus pembangunan diumumkan atas keputusan Sidang Majelis Jemaat 08/11/2026."; "Oleh Olvie Pangemanan, Sekretaris Jemaat · 20/11/2026 13.50" |
| WartaArsip | Edisi 15/11/2026 (Diterbitkan 14/11/2026 17.00, Diterbitkan); Edisi 08/11/2026 (Diterbitkan 07/11/2026 · 1 ralat; ralat "Jadwal ibadah Kolom 5 dipindah ke Kamis 12/11/2026.", 09/11/2026 08.30); Edisi 01/11/2026 (Diterbitkan 31/10/2026, Diarsipkan); Edisi 25/10/2026 (Diterbitkan 24/10/2026, Diarsipkan) |
| PermohonanSurat | "Surat keterangan · Novita Wenas" (Diajukan anggota 14/11/2026 · untuk melamar pekerjaan); "Atestasi · Keluarga Lasut" (Dicatat Operator Yanti Sumual 15/11/2026); "Atestasi · Ferry Wenas" (Diajukan 13/11/2026). Issued: "No. 027/SKet/XI/2026 · 15/11/2026". Refused Atestasi recorded 16/11/2026 |
| AlurSurat | Novita Wenas (Diajukan 14/11/2026 · untuk melamar pekerjaan · Wenas-Lasut · Kolom 7); Keluarga Lasut (Diajukan 15/11/2026 · pindah ke Jemaat lain · Lasut · Kolom 4); Agustina Lasut (Dicatat Operator di kantor, 16/11/2026 · Wenas-Lasut · Kolom 7) |

### 2.20 Collaboration

| Board | Data |
| --- | --- |
| Panitia | "Panitia Natal 2026"; Ketua Sdr. Stevi Lengkong, Sekretaris Sdri. Natalia Rumengan, Bendahara Sdr. Rivo Mandagi; Peruntukan Panitia Natal; Dasar "SK BPMJ No. 11/2026 · Dokumen gereja"; saldo buku (Aktif) Rp4.350.000; Penutupan: "Sisa uang Rp650.000", "Uang Muka belum dipertanggungjawabkan Rp0", "Aset tersisa 2 lampu sorot, 1 pohon Natal"; sisa approved by Meiske Lumentut, "Alih peruntukan ke Umum Jemaat", 05/01/2027; asset handover "kepada Komisi Pembangunan" |
| AlurPanitia | "Ketua: Stevi Lengkong · Bendahara: Rivo Mandagi"; Uang Muka Dekorasi Natal "Diberikan Rp300.000"; "Saldo peruntukan Panitia Natal 2026 Rp350.000" |
| AlurPanitiaBaru | choices Ketua [Stevi Lengkong, Rivo Mandagi], Sekretaris [Natalia Rumengan, Stevi Lengkong], Bendahara [Rivo Mandagi, Stevi Lengkong]; document "SK BPMJ No. 15/2026" |
| Ibadah | "Ibadah Kolom 7", Jenis Ibadah Kolom, "Kamis, 19/11/2026 19.00", Kolom 7, "Kel. Wenas-Lasut"; approvers Pnt. Hendrik Rumagit or Sym. Greis Mamahit; approved 16/11/2026; Ditutup "38 orang"; "Ibadah Minggu Adven I", "Minggu, 29/11/2026 · Subuh, Pagi, Malam", Semua anggota, approved by Pdt. Lidya Rondonuwu 15/11/2026 |
| Kehadiran | "Ibadah Minggu pagi · 15/11/2026"; "Pintu depan · Yanti S." 142 (counter starts at 142), "Pintu samping · Greis M." 89, Jumlah 231; Ditetapkan by Pnt. Hendrik Rumagit 15/11/2026 11.20; Koreksi 231 → 236, "Alasan: lembar pos balkon terlambat diserahkan.", 16/11/2026 08.05 |
| PermintaanDana | "Konsumsi Natal Pemuda" Rp1.500.000, Umum Jemaat, "Sdr. Rivo Mandagi, Ketua Pemuda"; approved by Pdt. Lidya Rondonuwu 17/11/2026 09.15; refused 17/11/2026 09.20 ("rincian konsumsi belum dilampirkan."); amount changed to Rp1.800.000; "Alat tulis" Rp85.000 (below Rp250.000); outside approval Pdt. Lidya Rondonuwu, Ketua BPMJ · 08/11/2026 · notulen rapat |
| AlurBeranda, AlurDana | Permintaan dana Komisi Diakonia Rp750.000 by Pnt. Hendrik Rumagit, Ketua Komisi Diakonia, waiting for Pdt. Lidya Rondonuwu, Ketua Jemaat; payment booked by Meiske Lumentut as Uang Muka diberikan |
| KeuanganUnit | "Kas Kolom 7 Rp1.240.000"; "Perlu tindakan 2"; BKU-2026-0151 Persembahan Ibadah Kolom Rp320.000 (peruntukan Kolom 7, Kas Kolom 7, Deasy Tumbelaka 17/11/2026 20.10); Draf "Konsumsi ibadah Kolom" −Rp150.000 on Bank BNI ··4821 (refused); Draf "Bantuan duka" −Rp200.000 from Diakonia (refused); rekon Oktober Rp920.000 / Rp920.000 / Rp0 |
| AlurUnit | BKU-2026-0151 · 12/11/2026 · Rp320.000; draft 28/10/2026 Rp185.000 moved to 02/11/2026 |
| SelesaikanUnit | "terhalang 2 hal dari Kolom 7"; draft "Kolom 7 · bertanggal 28/10/2026 · −Rp150.000"; rekon Kas Kolom 7 Rp920.000; reason "Bendahara Kolom 7 sedang di luar kota; nota baru diterima November."; resolved by Meiske Lumentut 16/11/2026 10.40 and 10.42 |
| KasUnit | Kas, Bank BNI ··4821, Bank SulutGo ··1107 "Dikelola Jemaat"; Kas Kolom 7 "Dikelola oleh Kolom 7 · Bendahara: Deasy Tumbelaka"; unit choice includes Kolom 4 |
| Kesiapan, WebKesiapan | Umum Jemaat "Sudah dinyatakan siap", "Pnt. Jefry Wowor · 02/11/2026"; Diakonia "Perlu dinyatakan lagi" ("Dinyatakan 01/11/2026, lalu ada transaksi Oktober yang berubah."), Dkn. Olga Tamba; Pembangunan "Pernyataan kesiapan belum ada", Sdr. Rivo Mandagi. `masukSebagai: Bendahara Komisi Diakonia` → "Dkn. Olga Tamba, Bendahara Komisi Diakonia" |
| Terbatas, WebTerbatas | "Saldo buku peruntukan Diakonia Rp4.200.000"; rows BKU-2026-0141 10/11/2026 Diakonia duka −500.000; BKU-2026-0135 06/11/2026 Persembahan Diakonia 1.200.000; BKU-2026-0122 27/10/2026 Diakonia sakit −300.000; BKU-2026-0098 04/10/2026 Persembahan Diakonia 950.000 |
| LaporanLintas money card | Seluruh Jemaat "Saldo buku semua Kas/Bank Rp38.415.000"; Kolom 7 "Saldo buku peruntukan Kolom 7 Rp1.240.000"; Panitia Natal 2026 "Saldo buku peruntukan Panitia Natal Rp4.350.000"; Modul tidak aktif → same as Seluruh Jemaat |
| PersembahanBernama | Sampul syukur Rp100.000, 01/11/2026, Pemberi Novita Wenas; refused for Ferry Wenas (Belum dikonfirmasi) |

### 2.21 Settings, sessions, history

| Board | Data |
| --- | --- |
| Lainnya riwayat | "Meiske L. membukukan BKU-2026-0146" 15/11/2026 12.20; "Meiske L. membuat pembalikan BKU-2026-0144" 12/11/2026 09.31; "Meiske L. menonaktifkan Kas Panitia HUT" 28/10/2026 16.44; "Meiske L. menutup buku September 2026" 05/10/2026 19.02; "Meiske L. mencatat persetujuan format laporan" 03/10/2026 10.15; "Petugas verifikasi mengaktifkan wewenang Bendahara" 15/09/2026 10.15 |
| WebPengaturan riwayat | 16/11/2026 10.42 "Membukukan BKU-2026-0147"; 12/11/2026 09.31; 28/10/2026 16.44; 05/10/2026 19.02; 03/10/2026 10.15; 15/09/2026 10.15 "Mengaktifkan wewenang Bendahara untuk Meiske Lumentut". Vacant state prepends 16/11/2026 08.10 "Mencabut wewenang Bendahara Meiske Lumentut · semua sesi diakhiri" and drops the 16/11 rows |
| Sessions | Bendahara: "Ponsel ini" (Sesi ini · aktif sekarang), "Chrome di laptop" (Terakhir dipakai 14/11/2026 20.15). WebPengaturan: "Browser ini", "Ponsel Android" (Terakhir dipakai 16/11/2026 10.42). Keluar: "Masuk sejak 16/11/2026 08.02". Sambungan: "Diakhiri oleh Meiske L. dari perangkat lain, 16/11/2026 11.40." |
| Masuk (`setelahMasuk`) | "Meiske Lumentut · Wewenang Bendahara aktif"; "Dkn. Olga Tamba · Akses terbatas: Peruntukan Diakonia" |
| Bendahara handover | new appointment "SK-BPMJ-09-2026.pdf"; old SK "SK-BPMJ-04-2026.pdf" (Awal, WebVerifikasi "2 halaman") |
| Pemulihan | "Tercatat di Riwayat aktivitas sebagai pemulihan akun, 16/11/2026 12.05." |

## 3. Where boards disagree

Rule: each screen keeps its own board's figure. Do not "fix" one board to match another. Each row names the boards and, where the canvas lets us tell, why.

| # | Thing | Board → figure | Other board → figure | Reason |
| --- | --- | --- | --- | --- |
| 1 | Saldo buku semua Kas/Bank | Main, WebBeranda, TabBeranda, JabatanKosong, BerandaJabatan, LaporanLintas → Rp38.415.000 | A4F01, F10, WebLaporan → Rp38.465.000 | Different moment: 16/11/2026 (November) vs 31/10/2026 |
| 2 | Bank BNI ··4821 saldo buku | Main, WebBeranda, KasusBaru, AlihPeruntukan, Memuat → Rp24.615.000 (November) | TutupBuku, WebRekonsiliasi → Rp24.615.000 before fee, Rp24.600.000 after; F10 → Rp24.600.000 | October before the fee happens to equal November. Keep both |
| 3 | Kas and SulutGo | November: Kas Rp8.420.000, SulutGo Rp5.380.000 | October end: Kas Rp8.750.000, SulutGo Rp5.115.000 | Different month |
| 4 | Saldo peruntukan Diakonia | A4Terbatas → saldo akhir Oktober Rp3.700.000 | Terbatas, WebTerbatas, AlihPeruntukan → Rp4.200.000 | November; but the November rows on Terbatas (+1.200.000, −500.000) would give Rp4.400.000. Not derivable |
| 5 | Fotokopi warta jemaat | Main, PilihBulan, WebPemeriksa → Draf 14/11/2026 | WebTransaksi → Draf 16/11/2026 (BKU-2026-0147 after Bukukan); Bukti, WebBukti, Dokumen, LihatDokumen → BKU-2026-0147 Dibukukan 16/11/2026 | Different moments of the same draft |
| 6 | BKU-2026-0147 | Main, TabCatat, WebCatat → whatever the Catat flow posts | WebTransaksi, Bukti, Dokumen → Fotokopi warta jemaat | The Catat flow reuses the next number |
| 7 | BKU-2026-0151 | KeuanganUnit → Persembahan Ibadah Kolom Rp320.000, 17/11/2026 20.10; AlurUnit → same, 12/11/2026 | Pemeriksa → Sewa kursi ibadah padang −Rp900.000; WebPemeriksa → 0151/0152/0153 for its rows; Bukti → series "sampai 0151" | Number reused by independent boards |
| 8 | BKU-2026-0150 | Kewajiban → Retret Pemuda settlement 05/11/2026 | Kewajiban's own next number for new entries is also BKU-2026-0150 | Board logic (`nomor: 150`); keep |
| 9 | BKU-2026-0152 | AlihPeruntukan → Alih peruntukan | WebPemeriksa → second posted row | Number reuse |
| 10 | Persembahan 15/11/2026 | Main, WebTransaksi, Bukti → BKU-2026-0146 Rp3.450.000 | Persembahan, WebPersembahan → new posting BKU-2026-0148, parts Rp3.600.000 | Persembahan board demonstrates recording the same service again |
| 11 | BKU-2026-0146 posting | WebTransaksi, Lainnya → "15/11/2026 12.20", by Meiske L. | JabatanKosong → "Dibukukan pada 16/11/2026 11.42", by Yanti Sumual | Vacancy board shows an Operator posting |
| 12 | Uang Muka list | Kewajiban, WebKasus → 3 advances, 2 claims | WebKewajiban → adds Ibu Selvie Kalalo "Konsumsi syukur HUT" Rp300.000 (used Rp375.000) and claim "Kelebihan konsumsi syukur HUT" Rp75.000 | Web shows the overspend case; F02/F14 count 3 October advances including Selvie's |
| 13 | Advance settlements | R03, Keputusan → Rp400.000 and Rp300.000 dated November, October prints Rp0 | Kewajiban → also Rp850.000 settlement of the November advance | Not a conflict; listed so nobody adds them to October |
| 14 | Kolom 7 blocking draft | SelesaikanUnit → "28/10/2026 · −Rp150.000", "terhalang 2 hal" | AlurUnit → "28/10/2026 · Rp185.000", "terhalang 1 hal"; KeuanganUnit → Draf Konsumsi ibadah Kolom −Rp150.000 (November) | Separate boards |
| 15 | October blockers | Main, WebBeranda, BerandaJabatan → "1 hambatan" | WebTutupBuku (`adaHambatan`) → 2: BNI not reconciled and BKU-2026-0122 "Diunggah, belum diverifikasi" | F12 TERBATAS prints 0122 "Terverifikasi" at close; the web blocker is a demo state |
| 16 | Penatua Kolom 2 vacancy | Penugasan → Altje Rompas until 31/10/2026, run by Yanti since 01/11/2026; AlurJabatanKosong → "Kosong sejak 31/10/2026", filled by Altje Rompas from 16/11/2026 | DataAnggota, Peristiwa → death of Yohanis Rompas (14/11/2026) made Penatua Kolom 2 vacant | Two stories for one vacancy |
| 17 | Death of Yohanis Rompas | Peristiwa → Diverifikasi, "14/11/2026 · diajukan keluarga" | AntreanVerifikasi → Diajukan, "Kolom 2 · diajukan keluarga 16/11/2026" | Different moments |
| 18 | New Bendahara Jemaat | Bendahara, WebSerahTerima → Yohanis Tumbelaka, aktif sejak 16/11/2026, SK-BPMJ-09-2026 | JabatanKosong, WebJabatanKosong → Deitje Kawengian, aktif sejak 18/11/2026 | Separate boards |
| 19 | Who closed October | A4F01 → "Disiapkan oleh Meiske Lumentut"; TutupBuku normal → Meiske L. | Vacancy on → "Ditutup oleh Yanti Sumual, Operator" at 16/11/2026 11.05 | A4 pages have no `jabatanKosong` tweak |
| 20 | Kas count of October | F10, F11 → hitung kas Rp8.750.000 = buku, selisih Rp0 | Kejadian → "Kas Oktober 2026: hasil hitung kas lebih Rp85.000 dari Saldo buku." | Kejadian demo |
| 21 | Report format approval | A4F01, Lainnya → 03/10/2026 (riwayat 10.15); FormatLaporan → "Dicatat oleh Meiske L., 03/10/2026 11.40" | WebPengaturan → "sudah dicatat · 01/11/2026"; WebLaporan → "[NAMA] … · 01/11/2026", "Dicatat oleh Meiske L., 02/11/2026 09.10" | Keep each; WebLaporan's "[NAMA]" is drawn as is |
| 22 | Number of Lingkup | Awal → "3 Kas/Bank · 3 peruntukan · 4 Lingkup"; Catat forms → 4 | Lainnya → 5 (adds Komisi Diakonia) | — |
| 23 | 2.2.01.02.00 name | KasusBaru → "Persembahan khusus Wilayah" | WebMataAnggaran → "DANA TRANSIT Penyaluran Sentralisasi Sinode" (Belanja tab) | — |
| 24 | 2.1.01.02.00 | F02 and Persembahan (version 2026.1) use it | MataAnggaran, WebMataAnggaran → marked "Baru" in 2026.2; KasusBaru names it "Sentralisasi Sinode" | Keep each |
| 25 | 1.4.10.03.00 Sumbangan natura | F05 (2026.1) prints it as Rp0 | WebMataAnggaran → "Baru" in 2026.2 | — |
| 26 | Count of new rows in 2026.2 | Both → "2 baris baru · 1 nama berubah" | WebMataAnggaran tags 4 rows "Baru" | Keep the text and the tags |
| 27 | Honor pemusik draft | Main, WebTransaksi → 08/11/2026, Bank BNI, no MA | WebPemeriksa → 15/11/2026, MA 5.07.01.00; Draf → 28 September 2026; Impor → 08/11/2026 Kas Rp650.000 | Separate demos |
| 28 | Ferry Wenas's Kolom | ImporBuku, KonfirmasiKeluarga, AlurKeluarga → Kolom 7 | CariOrang → "Data jemaat · Kolom 2"; AlurJabatanKosong → a Kolom 2 membership request | — |
| 29 | Wenas-Lasut sampul syukur | PersembahanSaya, PersembahanBernama → 01/11/2026, BKU-2026-0132 | CariOrang → "Sampul syukur 08/11/2026" | — |
| 30 | Novita's display name | DataAnggota → "Keluarga + Kolom" | PersembahanSaya, PersembahanBernama → "Tanpa nama"; TampilanNama → depends on state | State-dependent |
| 31 | Novita's membership | DataAnggota, ImporBuku → Aktif, Kolom 7 since 2021 | PermohonanAnggota, AntreanVerifikasi → applying 16/11/2026, verified 17/11/2026 | Journey boards replay joining |
| 32 | Attendance, Ibadah Pagi 15/11 | Warta, WartaEditor, Kehadiran → 231, total 412 | Kehadiran `Koreksi` → 236; total not updated elsewhere | Correction state |
| 33 | Modules | Modul → Data jemaat, Ibadah, Kehadiran "Tidak aktif"; Panitia "Hanya baca" since 01/11/2026 | Member, worship and Panitia boards behave as active | Modul shows the activation story |
| 34 | Panitia Natal money | Panitia → saldo Rp4.350.000 (Aktif), sisa Rp650.000 | AlurPanitia → saldo Rp350.000, sisa Rp350.000; Kewajiban → Panitia Natal advance sisa Rp650.000 | Different stages and boards |
| 35 | Dates after "today" | — | WartaEditor 20–21/11/2026; KonfirmasiKeluarga, PermohonanAnggota, PermintaanDana, KeuanganUnit, CabutIzin, DataGanda 17/11/2026; DokumenGereja 18/11/2026; JabatanKosong 18/11/2026; Panitia 05/01/2027 | States drawn later than 16/11/2026; keep |
| 36 | Draf counts | Main, WebBeranda → "2 draf", November | KotakMasuk → "2 draf belum dibukukan · Keuangan · Oktober 2026" | — |
| 37 | Second checker | Lainnya → off, "Hidup mulai Desember 2026" when switched | Pemeriksa, WebPemeriksa → "Wajib pemeriksa kedua: hidup" | Pemeriksa demonstrates the rule |
| 38 | F12 row count | F12 → "Contoh 5 dari 33 baris" | F02 → 31 rows; PilihBulan → "33 transaksi" | 33 = 31 + 2, which two is not drawn |
| 39 | Kas of Panitia Natal | Panitia → "Kas Panitia Natal yang dikelolanya" | KasUnit, Lainnya → not listed | — |
| 40 | Sekretaris Jemaat status | Penugasan list → Aktif sejak 03/11/2026 | Penugasan `Menunggu verifikasi wewenang` | State |

## 4. Formatting helpers and the vacancy scenario

### 4.1 Helpers (`lib/mock/format.dart`)

Every helper below reproduces a function or a string pattern of the boards. Add one unit test per helper with the examples given.

```dart
const kosong = '—'; // "not known", never Rp0

/// Board `rp(n)`: '−' (U+2212) for negatives, dot thousands, no decimals.
/// rp(-15000) → '−Rp15.000', rp(0) → 'Rp0', rp(38415000) → 'Rp38.415.000'
String rp(int n);

/// Flow boards' `rpT(d)`: digits string → 'Rp1.500.000'; '' → 'Rp0'.
String rpDigit(String digits);

/// Signed with a space, used in deltas: '+ Rp3.150.000' (Persembahan),
/// '+ Rp500.000' / '− Rp500.000' (AlihPeruntukan), '− Rp850.000' (Kewajiban entries).
String rpBeda(int n);

/// Thousand dots for typed amounts: '1250000' → '1.250.000'.
String titik(String digits);

/// Board input filter: strip non-digits, strip leading zeros, cut to [max]
/// (11 on most amount fields; 12 on Main, WebCatat, TabCatat, WebAwal and the
/// statement-balance field of RekonIsi/WebRekonIsi; 10 on `batas` of
/// UbahPengaturan/WebUbahPengaturan). With [simpanNol] a lone '0' survives
/// (Persembahan, Awal: "Isi Rp0"). Phone 13, date 10, code 6 keep their
/// leading zeros (dates also '/'), so those fields do not use it.
/// RupiahInputFormatter (components.md 2.3) calls it, then [titik].
String hanyaAngka(String raw, {int max = 11, bool simpanNol = false});

/// 06/10/2026
String tgl(DateTime d);
/// 6 Oktober 2026 (Januari Februari Maret April Mei Juni Juli Agustus
/// September Oktober November Desember)
String tglPanjang(DateTime d);
/// 11.05 (dot, 24 h)
String jam(DateTime d);
/// 16/11/2026 11.05
String tglJam(DateTime d);
/// Oktober 2026
String bulanTahun(int tahun, int bulan);

/// Flow boards' `tgl(t)`: 'dd/mm/yyyy' → yyyymmdd int, null when not that
/// shape or day/month out of range (no calendar check). Compared with
/// `hari = 20261116` for "harus sebelum hari ini" / "belum boleh di masa depan".
int? bacaTgl(String t);
const hari = 20261116, hariTeks = '16/11/2026';

/// Riwayat line of the flow boards: '16/11/2026 · <teks>', newest first.
List<String> catat(List<String> riwayat, String teks);

/// Masked phone: '081298765432' → '0812 ···· 5432'.
String samarHp(String n);
/// Masked email: 'olvie@contoh.id' → 'o···@contoh.id'; '' → 'Belum diisi'.
String samarEmail(String e);

/// Phone check of AlurMasuk / AkunSaya: ^08\d{8,11}$
bool hpSah(String n);
/// Email check of AkunSaya: ^[^@\s]+@[^@\s]+\.[^@\s]+$
bool emailSah(String e);

/// Count-up used after posting (Main, Kewajiban, TutupBuku, WebRekonsiliasi):
/// steps of 30 ms, eased 1 − (1 − i/n)^3, n = 26 (Main) or 22 (others),
/// Main starts after 750 ms. Instant under reduce motion.
int hitungNaik(int dari, int ke, int i, int n);
```

Kas/Bank labels: "Kas", "Bank BNI ··4821", "Bank SulutGo ··1107"; in F02 transfer rows "Kas ke Bank BNI", "Kas ke Bank SulutGo", "Bank BNI ke Kas". The mask is two U+00B7 middle dots plus the last four digits.

### 4.2 Vacancy scenario (R04, global switch `jabatanKosong`)

| Item | Value |
| --- | --- |
| Revocation | "Wewenang Meiske Lumentut dicabut pada 16/11/2026 08.10 oleh Petugas verifikasi, atas permintaan BPMJ. Semua sesinya sudah diakhiri." (Bendahara); WebPengaturan/WebSerahTerima: "… oleh Petugas verifikasi. Semua data hanya dapat dilihat. Yang perlu bertindak: BPMJ Jemaat Karunia …" |
| Riwayat line | "16/11/2026 08.10" · "Mencabut wewenang Bendahara Meiske Lumentut · semua sesi diakhiri" |
| Operator takes over | 16/11/2026 08.15 |
| Phone strip (finance boards) | "Menjalankan jabatan kosong · Bendahara Jemaat" |
| Web side-nav user | "Yanti Sumual · Operator" / "Menjalankan jabatan kosong Bendahara Jemaat" (normal: "Meiske L. · Bendahara" / "Wewenang Bendahara aktif") |
| Web band | "Anda menjalankan jabatan kosong Bendahara Jemaat sejak 16/11/2026 08.15. Setiap tindakan dicatat sebagai dijalankan oleh Operator Yanti Sumual." |
| `plk` | on: "Yanti Sumual, Operator"; off: "Meiske L." |
| `plk2` | on: "Yanti Sumual, Operator (menjalankan jabatan kosong Bendahara Jemaat)"; off: "Meiske L." |
| Close confirmation | "Ditutup oleh Yanti Sumual, Operator , yang menjalankan jabatan kosong Bendahara Jemaat. Nama dan keadaan ini tercatat pada tutup buku." (the space before the comma is in the board) |
| Second checker | "Menjalankan jabatan kosong tidak menggantikan orang kedua. Yang dapat memeriksa: Pnt. Jefry Wowor." |
| Post filled | JabatanKosong: "Bendahara Jemaat sudah terisi: Deitje Kawengian, wewenang aktif sejak 18/11/2026." |
| Other vacancy | Penatua Kolom 2, run by Yanti Sumual since 01/11/2026 (Penugasan, BerandaJabatan, AntreanVerifikasi, AlurJabatanKosong) |

`tukarJk` (one shared function): walk the screen's display strings; a string that contains "Meiske L." and whose every `dd/mm/yyyy` date is 16/11/2026 (or that has no date) gets each "Meiske L." replaced by "Yanti Sumual, Operator". Apply it only on boards where it is switched on:

- **On** (`if (jk && true)`): AIMataAnggaran, Draf, Dokumen, Koreksi, Main, LihatDokumen, MataAnggaran, RekonIsi, TutupBuku, WebAIMataAnggaran, WebDokumen, WebDraf, WebKoreksi, WebLihatDokumen, WebMataAnggaran, WebRekonIsi, WebRekonsiliasi, WebTutupBuku.
- **Off** (`if (jk && false)`): every other board with the `jabatanKosong` tweak. They still show the strip, band and `plk`/`plk2` names, but do not rewrite other strings.

Example: with the switch on, Main's detail "Terverifikasi (oleh Meiske L.)" becomes "Terverifikasi (oleh Yanti Sumual, Operator)" (no date in the string), while WebTransaksi keeps "Terverifikasi (oleh Meiske L.)".
