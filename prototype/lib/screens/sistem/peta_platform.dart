import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../shell/halaman_lembar.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';

/// Peta layar · Putaran 2–5 (sheet 1280 × 2100, spec 13 PetaPlatform).
///
/// The links are drawn at their text size (the board's dense rows) and get
/// their 44 × 44 hit areas from a transparent layer of [Tautan]s laid over
/// the sheet after layout; where two areas overlap, the nearer link wins.
class PetaPlatformScreen extends StatefulWidget {
  const PetaPlatformScreen({super.key});

  @override
  State<PetaPlatformScreen> createState() => _PetaPlatformScreenState();
}

typedef _Tautan = ({String teks, String ke});
typedef _Entri = ({String nama, List<_Tautan> tautan, String keadaan});

/// Every link in drawing order: the 84 column links, then the card's four.
/// [label] names the entry too, since the hit layer reads apart from it.
final List<({String teks, String ke, String label})> _semua = [
  for (final k in _kolom)
    for (final e in k.entri)
      for (final t in e.tautan)
        (teks: t.teks, ke: t.ke, label: '${e.nama} · ${t.teks}'),
  for (final t in _bawah) (teks: t.teks, ke: t.ke, label: t.teks),
];
final int _jumlahKolom = _semua.length - _bawah.length;

/// The plain 15 px `tinta` separator between the card's links.
const _pemisah = ' · ';

class _PetaPlatformScreenState extends State<PetaPlatformScreen> {
  final _kunciLapis = GlobalKey();
  final _kunci = [for (var i = 0; i < _jumlahKolom; i++) GlobalKey()];
  final _kunciBaris = GlobalKey();
  final _sorot = ValueNotifier<int?>(null);

  /// Hit areas with the index of the link they open (a wrapped link has one
  /// per line).
  List<({Rect r, int i})> _kotak = const [];

  @override
  void dispose() {
    _sorot.dispose();
    super.dispose();
  }

  // Measures every link text and lays the hit areas over them.
  void _ukur(Duration _) {
    if (!mounted) return;
    final lapis = _kunciLapis.currentContext?.findRenderObject() as RenderBox?;
    if (lapis == null || !lapis.hasSize) return;
    final teks = <Rect>[];
    final milik = <int>[];
    for (final (i, k) in _kunci.indexed) {
      final b = k.currentContext?.findRenderObject() as RenderBox?;
      if (b == null || !b.hasSize) return;
      teks.add(b.localToGlobal(Offset.zero, ancestor: lapis) & b.size);
      milik.add(i);
    }
    // The card's links wrap inside one paragraph, as inline links do.
    final p = _kunciBaris.currentContext?.findRenderObject();
    if (p is! RenderParagraph || !p.hasSize) return;
    final ke = p.getTransformTo(lapis);
    var awal = 0;
    for (final (j, t) in _bawah.indexed) {
      if (j > 0) awal += _pemisah.length;
      final pilih = TextSelection(
        baseOffset: awal,
        extentOffset: awal + t.teks.length,
      );
      for (final b in p.getBoxesForSelection(pilih)) {
        teks.add(MatrixUtils.transformRect(ke, b.toRect()));
        milik.add(_jumlahKolom + j);
      }
      awal += t.teks.length;
    }
    final luas = luasSentuh(teks, Offset.zero & lapis.size);
    final baru = [for (final (n, r) in luas.indexed) (r: r, i: milik[n])];
    if (!listEquals(baru, _kotak)) setState(() => _kotak = baru);
  }

  Widget _teks(int i) => _TeksTautan(
    key: _kunci[i],
    teks: _semua[i].teks,
    indeks: i,
    sorot: _sorot,
  );

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(_ukur);
    final c = context.warna;
    var n = 0;
    final kolom = [
      for (final k in _kolom)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                k.judul,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final e in k.entri)
              _BlokEntri(
                entri: e,
                tautan: [for (final _ in e.tautan) _teks(n++)],
              ),
          ],
        ),
    ];
    Widget paragraf(String label, String isi) => Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: isi,
            style: TextStyle(color: c.tinta2),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 14),
    );
    final kiri = Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          const Text(
            'Yang berubah di Putaran 1 (keuangan)',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          for (final p in _berubah) paragraf(p.$1, p.$2),
          ExcludeSemantics(
            child: ValueListenableBuilder<int?>(
              valueListenable: _sorot,
              builder: (context, s, _) => Text.rich(
                key: _kunciBaris,
                TextSpan(
                  children: [
                    for (final (j, t) in _bawah.indexed) ...[
                      if (j > 0) const TextSpan(text: _pemisah),
                      TextSpan(
                        text: t.teks,
                        style: _gayaTautan(
                          s == _jumlahKolom + j ? c.lautTua : c.laut,
                          14,
                          FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    final kanan = Kartu(
      status: GarisStatus.draf,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          const Text(
            'Diputuskan 18/11/2026',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          Text.rich(
            TextSpan(
              children: [
                for (final (i, s) in _diputuskan.indexed)
                  TextSpan(
                    text: s,
                    style: i.isOdd
                        ? null
                        : const TextStyle(fontWeight: FontWeight.w700),
                  ),
              ],
            ),
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
        ],
      ),
    );
    return HalamanLembar(
      ukuran: const Size(1280, 2100),
      jarak: 28,
      isi: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Peta layar · Putaran 2–5',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Brief versi 2, 18/11/2026. 56 layar: semuanya untuk ponsel, '
              'dan 30 di antaranya juga untuk laptop (Bendahara, Sekretaris '
              'Jemaat, Operator). Setiap layar hanya ada selama modulnya aktif.',
              style: TextStyle(color: c.tinta2),
            ),
          ],
        ),
        Stack(
          key: _kunciLapis,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 28,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 28,
                  children: [for (final k in kolom) Expanded(child: k)],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 28,
                  children: [
                    Expanded(flex: 14, child: kiri),
                    Expanded(flex: 10, child: kanan),
                  ],
                ),
              ],
            ),
            for (final (n, (:r, :i)) in _kotak.indexed)
              Positioned.fromRect(
                rect: r,
                child: MouseRegion(
                  onEnter: (_) => _sorot.value = i,
                  onExit: (_) {
                    if (_sorot.value == i) _sorot.value = null;
                  },
                  child: _satuTarget(
                    n == 0 || _kotak[n - 1].i != i,
                    Tautan(
                      ke: _semua[i].ke,
                      label: _semua[i].label,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// A wrapped link's second line opens the same board but is one stop for
/// keyboard and screen reader only on its first line.
Widget _satuTarget(bool pertama, Widget child) =>
    pertama ? child : ExcludeSemantics(child: ExcludeFocus(child: child));

TextStyle _gayaTautan(Color w, double ukuran, [FontWeight? berat]) => TextStyle(
  fontSize: ukuran,
  fontWeight: berat,
  color: w,
  decoration: TextDecoration.underline,
  decorationColor: w,
);

/// One map entry: top rule, name and links on a baseline, then the states.
class _BlokEntri extends StatelessWidget {
  const _BlokEntri({required this.entri, required this.tautan});

  final _Entri entri;
  final List<Widget> tautan;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 9, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 2,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              spacing: 12,
              children: [
                Expanded(
                  child: Text(
                    entri.nama,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                DefaultTextStyle.merge(
                  style: const TextStyle(fontSize: 13),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      for (var i = 0; i < tautan.length; i++) ...[
                        if (i > 0) const Text(' · '),
                        tautan[i],
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Text(
              entri.keadaan,
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ],
        ),
      ),
    );
  }
}

/// The drawn link: `laut`, underlined, `lautTua` while its hit area is
/// hovered. Its press target is the matching [Tautan] in the hit layer.
class _TeksTautan extends StatelessWidget {
  const _TeksTautan({
    super.key,
    required this.teks,
    required this.indeks,
    required this.sorot,
  });

  final String teks;
  final int indeks;
  final ValueNotifier<int?> sorot;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return ExcludeSemantics(
      child: ValueListenableBuilder<int?>(
        valueListenable: sorot,
        builder: (context, s, _) => Text(
          teks,
          style: _gayaTautan(s == indeks ? c.lautTua : c.laut, 13),
        ),
      ),
    );
  }
}

/// Hit areas for links drawn at [teks]: each at least 44 × 44 around its
/// text, kept inside [batas]; where two overlap they split at the midpoint
/// between the texts, so the nearer link wins, and each regrows to 44 on
/// its far side.
@visibleForTesting
List<Rect> luasSentuh(List<Rect> teks, Rect batas) {
  double geser(double a, double z, double min, double max) =>
      a < min ? min - a : (z > max ? max - z : 0);
  final k = [
    for (final t in teks)
      Rect.fromCenter(
        center: t.center,
        width: math.max(44, t.width),
        height: math.max(44, t.height),
      ),
  ];
  for (var i = 0; i < k.length; i++) {
    final b = k[i];
    k[i] = b.shift(
      Offset(
        geser(b.left, b.right, batas.left, batas.right),
        geser(b.top, b.bottom, batas.top, batas.bottom),
      ),
    );
  }
  // Second pass without regrowth: cuts what a regrown side reached into.
  for (final tumbuh in [44.0, 0.0]) {
    for (var i = 0; i < k.length; i++) {
      for (var j = i + 1; j < k.length; j++) {
        if (!k[i].overlaps(k[j])) continue;
        final (a, b) = (teks[i], teks[j]);
        final gx = math.max(b.left - a.right, a.left - b.right);
        final gy = math.max(b.top - a.bottom, a.top - b.bottom);
        if (gx >= gy) {
          final (p, q) = a.left <= b.left ? (i, j) : (j, i);
          final m = (teks[p].right + teks[q].left) / 2;
          // Cut at the midpoint, then grow the far side back to 44.
          final kp = math.min(k[p].right, m);
          final kq = math.max(k[q].left, m);
          k[p] = Rect.fromLTRB(
            math.min(k[p].left, kp - tumbuh),
            k[p].top,
            kp,
            k[p].bottom,
          );
          k[q] = Rect.fromLTRB(
            kq,
            k[q].top,
            math.max(k[q].right, kq + tumbuh),
            k[q].bottom,
          );
        } else {
          final (p, q) = a.top <= b.top ? (i, j) : (j, i);
          final m = (teks[p].bottom + teks[q].top) / 2;
          final kp = math.min(k[p].bottom, m);
          final kq = math.max(k[q].top, m);
          k[p] = Rect.fromLTRB(
            k[p].left,
            math.min(k[p].top, kp - tumbuh),
            k[p].right,
            kp,
          );
          k[q] = Rect.fromLTRB(
            k[q].left,
            kq,
            k[q].right,
            math.max(k[q].bottom, kq + tumbuh),
          );
        }
      }
    }
  }
  // ponytail: a link cut at the layer's edge (column 4's "Web") stays under
  // 44 wide; the layer cannot reach into the sheet padding without a shared
  // inline hit-slop option on Tautan.
  return [for (final r in k) r.intersect(batas)];
}

const _berubah = [
  (
    'Lingkup.',
    'Komisi menjadi jenis Lingkup kelima (DL17): contoh di Pengaturan dan '
        'Pengaturan awal.',
  ),
  (
    'Pernyataan kesiapan.',
    'Pindah ke Putaran 5; “penyiap” diganti bendahara unit (DL26). Bukan '
        'bagian pemeriksaan tutup buku V1.',
  ),
  (
    'Jabatan kosong.',
    'Operator dapat menjalankan jabatan kosong, termasuk Bendahara Jemaat '
        '(DL12): pita di setiap layar dan nama Operator di konfirmasi tutup '
        'buku.',
  ),
  (
    'Pemberitahuan.',
    'V1 tetap tanpa pemberitahuan dorong. Kotak Pemberitahuan untuk semua '
        'modul ada di Putaran 2; dorong lewat Firebase Cloud Messaging di '
        'Putaran 5 (DL20).',
  ),
  (
    'Yang tidak berubah.',
    'Layar keuangan V1, siklus bulanan, Paket Laporan, Bantuan AI dan '
        'kata-kata konfirmasi tutup buku.',
  ),
];

const List<_Tautan> _bawah = [
  (teks: 'Lihat keadaan jabatan kosong', ke: 'JabatanKosong'),
  (teks: 'Pernyataan kesiapan', ke: 'Kesiapan'),
  (teks: 'Alur · Pengembalian', ke: 'AlurPengembalian'),
  (teks: 'A4 · Warta Jemaat', ke: 'A4Warta'),
];

/// Bold and plain runs in turn, starting bold.
const _diputuskan = [
  '25',
  ' Satu aplikasi untuk pelayan dan anggota. ',
  '26',
  ' Tata letak laptop hanya untuk Bendahara, Sekretaris Jemaat dan Operator; '
      'layar jabatan lain ponsel saja. ',
  '27',
  ' Warta Jemaat: templat A4 tetap sebagai PDF, juga dibaca di aplikasi. ',
  '28',
  ' Naskah izin data pribadi: naskah bawaan, belum ditinjau penasihat hukum. ',
  '29',
  ' Kategori BIPRA mengikuti ketentuan GMIM dan tidak diubah gereja: Anak '
      'sampai sebelum 12 tahun; Remaja 12 tahun sampai 17 tahun 364 hari; '
      'Pemuda 18 tahun ke atas dan belum pernah menikah; Bapa dan Ibu sudah '
      'menikah. ',
  '30',
  ' Label “Pelayan dan pengurus”. ',
  '31',
  ' Beranda gabungan; jabatan dipilih aplikasi per tindakan, dan ditanyakan '
      'bila dua jabatan berwenang. ',
  '32',
  ' Anggota hanya melihat persembahan bernama miliknya sendiri. ',
  'Ketua Jemaat',
  ' adalah Pendeta. ',
  'Masuk',
  ': semua jabatan, termasuk Bendahara Jemaat, memakai kode ke nomor ponsel '
      '(WhatsApp atau SMS); email hanya cadangan untuk pemulihan akun. ',
  'Pengembalian kepada donatur',
  ' mengurangi Pendapatan di bulan uangnya dibayarkan. ',
  'Menghubungkan akun',
  ': anggota mengisi nama dan tanggal lahir, Penatua Kolom memverifikasi. ',
  'Layar kunci',
  ': pemberitahuan dorong hanya menyebut modul dan jenis pekerjaan, tanpa '
      'nama dan tanpa jumlah uang. ',
  'Persetujuan di aplikasi',
  ': pemberi persetujuan ditetapkan menurut jabatan, sekali per gereja, tanpa '
      'batas jumlah.',
];

const List<({String judul, List<_Entri> entri})> _kolom = [
  (
    judul: 'Putaran 2 · Kerangka platform',
    entri: [
      (
        nama: 'Beranda',
        tautan: [
          (teks: 'Ponsel', ke: 'BerandaJabatan'),
          (teks: 'Web', ke: 'WebBerandaJabatan'),
        ],
        keadaan: 'Beberapa jabatan · Bendahara Jemaat · Sekretaris Jemaat · Operator · Anggota jemaat · Jabatan dipilih otomatis · Dua jabatan dapat bertindak',
      ),
      (
        nama: 'Modul',
        tautan: [(teks: 'Ponsel', ke: 'Modul')],
        keadaan: 'Daftar modul · Mengaktifkan Data jemaat · Menonaktifkan Warta Jemaat · Dilihat jabatan lain',
      ),
      (
        nama: 'Penugasan jabatan',
        tautan: [
          (teks: 'Ponsel', ke: 'Penugasan'),
          (teks: 'Web', ke: 'WebPenugasan'),
        ],
        keadaan: 'Daftar jabatan · Catat penugasan · Menugaskan diri sendiri · Menunggu verifikasi wewenang',
      ),
      (
        nama: 'Menjalankan jabatan kosong',
        tautan: [
          (teks: 'Ponsel', ke: 'JabatanKosong'),
          (teks: 'Web', ke: 'WebJabatanKosong'),
        ],
        keadaan: 'Pita di setiap layar · Konfirmasi tutup buku · Tercatat di Riwayat · Wajib pemeriksa kedua · Jabatan sudah terisi',
      ),
      (
        nama: 'Pelimpahan tugas',
        tautan: [(teks: 'Ponsel', ke: 'Pelimpahan')],
        keadaan: 'Daftar pelimpahan · Buat pelimpahan · Berakhir sendiri',
      ),
      (
        nama: 'Pemberitahuan',
        tautan: [
          (teks: 'Ponsel', ke: 'KotakMasuk'),
          (teks: 'Web', ke: 'WebKotakMasuk'),
        ],
        keadaan:
            'Ada pemberitahuan · Semua sudah selesai · Hanya modul Keuangan',
      ),
      (
        nama: 'Cari orang',
        tautan: [
          (teks: 'Ponsel', ke: 'CariOrang'),
          (teks: 'Web', ke: 'WebCariOrang'),
        ],
        keadaan: 'Dilihat Operator · Dilihat Penatua Kolom 7 · Tidak ada hasil',
      ),
      (
        nama: 'Alur · Penugasan jabatan',
        tautan: [(teks: 'Ponsel', ke: 'AlurPenugasan')],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Menjalankan jabatan kosong',
        tautan: [
          (teks: 'Ponsel', ke: 'AlurJabatanKosong'),
          (teks: 'Web', ke: 'WebAlurJabatanKosong'),
        ],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Pelimpahan tugas',
        tautan: [(teks: 'Ponsel', ke: 'AlurPelimpahan')],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Beranda gabungan',
        tautan: [(teks: 'Ponsel', ke: 'AlurBeranda')],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Modul',
        tautan: [(teks: 'Ponsel', ke: 'AlurModul')],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Masuk dan menghubungkan akun',
        tautan: [
          (teks: 'Ponsel', ke: 'AlurMasuk'),
          (teks: 'Web', ke: 'WebAlurMasuk'),
        ],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Akun saya',
        tautan: [
          (teks: 'Ponsel', ke: 'AkunSaya'),
          (teks: 'Web', ke: 'WebAkunSaya'),
        ],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Memulihkan akun anggota',
        tautan: [
          (teks: 'Ponsel', ke: 'AlurPulihkan'),
          (teks: 'Web', ke: 'WebAlurPulihkan'),
        ],
        keadaan: 'Alur',
      ),
      (
        nama: 'Keadaan umum',
        tautan: [
          (teks: 'Ponsel', ke: 'KeadaanUmum'),
          (teks: 'Web', ke: 'WebKeadaanUmum'),
        ],
        keadaan: 'Memuat · Gagal memuat · Tanpa sambungan · Tidak berwenang · Modul tidak aktif · Sesi berakhir',
      ),
    ],
  ),
  (
    judul: 'Putaran 3 · Sekretariat',
    entri: [
      (
        nama: 'Dokumen gereja',
        tautan: [
          (teks: 'Ponsel', ke: 'DokumenGereja'),
          (teks: 'Web', ke: 'WebDokumenGereja'),
        ],
        keadaan: 'Daftar dokumen · Dokumen dengan revisi · Belum ada dokumen · Dilihat anggota jemaat',
      ),
      (
        nama: 'Terbitkan dokumen',
        tautan: [
          (teks: 'Ponsel', ke: 'TerbitDokumen'),
          (teks: 'Web', ke: 'WebTerbitDokumen'),
        ],
        keadaan: 'Mengisi · Sedang diunggah · Gagal diunggah · Diterbitkan · Ralat sebagai revisi',
      ),
      (
        nama: 'Permohonan surat',
        tautan: [
          (teks: 'Ponsel', ke: 'PermohonanSurat'),
          (teks: 'Web', ke: 'WebPermohonanSurat'),
        ],
        keadaan: 'Diajukan · Menerbitkan surat · Data jemaat tidak aktif · Diterbitkan · Tidak diterbitkan',
      ),
      (
        nama: 'Pengumuman',
        tautan: [
          (teks: 'Ponsel', ke: 'Pengumuman'),
          (teks: 'Web', ke: 'WebPengumuman'),
        ],
        keadaan: 'Daftar · Draf · Diterbitkan · Diarsipkan sendiri · Ralat sebagai revisi',
      ),
      (
        nama: 'Warta Jemaat · edisi 22/11/2026',
        tautan: [
          (teks: 'Ponsel', ke: 'WartaEditor'),
          (teks: 'Web', ke: 'WebWartaEditor'),
        ],
        keadaan: 'Draf · Sudah diperiksa · Disetujui · Diterbitkan · Hanya Pengumuman yang aktif',
      ),
      (
        nama: 'Tampilkan nama (pengecualian)',
        tautan: [
          (teks: 'Ponsel', ke: 'BukaNama'),
          (teks: 'Web', ke: 'WebBukaNama'),
        ],
        keadaan: 'Mengisi alasan · Alasan belum diisi · Tercatat · Bukan Sekretaris Jemaat',
      ),
      (
        nama: 'Warta Jemaat',
        tautan: [
          (teks: 'Ponsel', ke: 'WartaArsip'),
          (teks: 'Web', ke: 'WebWartaArsip'),
        ],
        keadaan: 'Arsip edisi · Edisi dengan ralat · Dibaca anggota jemaat · Belum ada edisi',
      ),
      (
        nama: 'Alur · Menerbitkan dokumen',
        tautan: [
          (teks: 'Ponsel', ke: 'AlurDokumen'),
          (teks: 'Web', ke: 'WebAlurDokumen'),
        ],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Permohonan surat',
        tautan: [
          (teks: 'Ponsel', ke: 'AlurSurat'),
          (teks: 'Web', ke: 'WebAlurSurat'),
        ],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Warta mingguan',
        tautan: [
          (teks: 'Ponsel', ke: 'AlurWarta'),
          (teks: 'Web', ke: 'WebAlurWarta'),
        ],
        keadaan: 'Alur',
      ),
    ],
  ),
  (
    judul: 'Putaran 4 · Data jemaat',
    entri: [
      (
        nama: 'Permohonan menjadi anggota',
        tautan: [(teks: 'Ponsel', ke: 'PermohonanAnggota')],
        keadaan: 'Mengisi · Izin belum diberikan · Untuk anak · Diajukan · Dikembalikan · Diverifikasi · Tidak diterima',
      ),
      (
        nama: 'Impor buku anggota',
        tautan: [
          (teks: 'Ponsel', ke: 'ImporBuku'),
          (teks: 'Web', ke: 'WebImporBuku'),
        ],
        keadaan: 'Ditampung · Lolos pengecekan · Sudah diimpor',
      ),
      (
        nama: 'Konfirmasi keluarga',
        tautan: [(teks: 'Ponsel', ke: 'KonfirmasiKeluarga')],
        keadaan: 'Belum dikonfirmasi · Dikonfirmasi di aplikasi · Formulir kertas diunggah · Aktif',
      ),
      (
        nama: 'Verifikasi data',
        tautan: [(teks: 'Ponsel', ke: 'AntreanVerifikasi')],
        keadaan: 'Antrean · Kembalikan dengan alasan · Milik keluarga sendiri · Jabatan kosong · Tidak ada yang menunggu',
      ),
      (
        nama: 'Data anggota dan keluarga',
        tautan: [
          (teks: 'Ponsel', ke: 'DataAnggota'),
          (teks: 'Web', ke: 'WebDataAnggota'),
        ],
        keadaan: 'Dilihat Penatua Kolom 7 · Dilihat Sekretaris Jemaat · Belum dikonfirmasi · Meninggal dunia · Penatua Kolom lain',
      ),
      (
        nama: 'Peristiwa',
        tautan: [(teks: 'Ponsel', ke: 'Peristiwa')],
        keadaan: 'Mengajukan · Diajukan · Diverifikasi · Dikembalikan · Kematian · Pindah Kolom',
      ),
      (
        nama: 'Tampilan nama saya di publikasi',
        tautan: [(teks: 'Ponsel', ke: 'TampilanNama')],
        keadaan: 'Pilihan pribadi · Mengikuti bawaan keluarga · Masih mudah dikenali',
      ),
      (
        nama: 'Cabut izin dan hapus data saya',
        tautan: [(teks: 'Ponsel', ke: 'CabutIzin')],
        keadaan:
            'Penjelasan · Konfirmasi · Permintaan lewat kertas · Sudah dihapus',
      ),
      (
        nama: 'Kemungkinan data ganda',
        tautan: [
          (teks: 'Ponsel', ke: 'DataGanda'),
          (teks: 'Web', ke: 'WebDataGanda'),
        ],
        keadaan: 'Bandingkan · Gabungkan · Bukan orang yang sama',
      ),
      (
        nama: 'Persembahan saya',
        tautan: [(teks: 'Ponsel', ke: 'PersembahanSaya')],
        keadaan: 'Ada persembahan bernama · Rincian · Belum ada · Bukan persembahan saya',
      ),
      (
        nama: 'Alur · Menjadi anggota',
        tautan: [(teks: 'Ponsel', ke: 'AlurAnggota')],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Peristiwa',
        tautan: [(teks: 'Ponsel', ke: 'AlurPeristiwa')],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Buku anggota',
        tautan: [
          (teks: 'Ponsel', ke: 'AlurKeluarga'),
          (teks: 'Web', ke: 'WebAlurKeluarga'),
        ],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Data saya',
        tautan: [(teks: 'Ponsel', ke: 'AlurNama')],
        keadaan: 'Alur',
      ),
    ],
  ),
  (
    judul: 'Putaran 5 · Kolaborasi',
    entri: [
      (
        nama: 'Keuangan Kolom 7',
        tautan: [(teks: 'Ponsel', ke: 'KeuanganUnit')],
        keadaan: 'Beranda unit · Dibukukan · Kas/Bank dikelola Bendahara Jemaat · Peruntukan lain · Pernyataan kesiapan · Tutup buku bukan wewenang unit',
      ),
      (
        nama: 'Hambatan dari unit',
        tautan: [
          (teks: 'Ponsel', ke: 'SelesaikanUnit'),
          (teks: 'Web', ke: 'WebSelesaikanUnit'),
        ],
        keadaan: 'Hambatan · Mengisi alasan · Alasan belum diisi · Diselesaikan · Ada selisih',
      ),
      (
        nama: 'Permintaan dana',
        tautan: [(teks: 'Ponsel', ke: 'PermintaanDana')],
        keadaan: 'Menunggu persetujuan · Disetujui · Tidak disetujui · Kembali menunggu · Menyetujui permintaan sendiri · Di bawah batas · Persetujuan di luar aplikasi',
      ),
      (
        nama: 'Panitia Natal 2026',
        tautan: [(teks: 'Ponsel', ke: 'Panitia')],
        keadaan: 'Perencanaan · Aktif · Penutupan keuangan · Sisa uang · Ditutup · Diarsipkan',
      ),
      (
        nama: 'Ibadah dan kegiatan',
        tautan: [(teks: 'Ponsel', ke: 'Ibadah')],
        keadaan: 'Draf · Dijadwalkan · Sedang berlangsung · Selesai · Ditutup · Ibadah seluruh Jemaat',
      ),
      (
        nama: 'Jumlah kehadiran',
        tautan: [(teks: 'Ponsel', ke: 'Kehadiran')],
        keadaan: 'Sedang dihitung · Sudah diperiksa · Ditetapkan · Koreksi · Petugas penghitung',
      ),
      (
        nama: 'Laporan',
        tautan: [
          (teks: 'Ponsel', ke: 'LaporanLintas'),
          (teks: 'Web', ke: 'WebLaporanLintas'),
        ],
        keadaan:
            'Seluruh Jemaat · Kolom 7 · Panitia Natal 2026 · Modul tidak aktif',
      ),
      (
        nama: 'Persembahan bernama',
        tautan: [
          (teks: 'Ponsel', ke: 'PersembahanBernama'),
          (teks: 'Web', ke: 'WebPersembahanBernama'),
        ],
        keadaan: 'Tanpa nama · Pilih pemberi · Tercatat atas nama anggota · Belum dikonfirmasi · Dilihat jabatan lain',
      ),
      (
        nama: 'Alur · Keuangan unit',
        tautan: [
          (teks: 'Ponsel', ke: 'AlurUnit'),
          (teks: 'Web', ke: 'WebAlurUnit'),
        ],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Permintaan dana',
        tautan: [(teks: 'Ponsel', ke: 'AlurDana')],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Ibadah dan kehadiran',
        tautan: [(teks: 'Ponsel', ke: 'AlurIbadah')],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Panitia',
        tautan: [(teks: 'Ponsel', ke: 'AlurPanitia')],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Pemberi persetujuan',
        tautan: [(teks: 'Ponsel', ke: 'PemberiPersetujuan')],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Kas/Bank unit',
        tautan: [
          (teks: 'Ponsel', ke: 'KasUnit'),
          (teks: 'Web', ke: 'WebKasUnit'),
        ],
        keadaan: 'Alur',
      ),
      (
        nama: 'Alur · Membentuk Panitia',
        tautan: [(teks: 'Ponsel', ke: 'AlurPanitiaBaru')],
        keadaan: 'Alur',
      ),
    ],
  ),
];
