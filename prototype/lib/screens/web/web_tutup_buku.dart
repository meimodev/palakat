import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/akhir_bulan.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/repositories_keuangan.dart';
import '../../motion/kerangka.dart';
import '../../motion/ulang.dart';
import '../../motion/urutan.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

enum _Tahap { konfirmasi, proses, sudah }

/// Web · Tutup buku (spec 01-main.md, WebTutupBuku): the laptop month close
/// on the month-end read models (README 5.6): the months, the computed
/// blockers of the next month to close, and its confirmation.
class WebTutupBukuScreen extends ConsumerStatefulWidget {
  const WebTutupBukuScreen({super.key});

  @override
  ConsumerState<WebTutupBukuScreen> createState() => _WebTutupBukuScreenState();
}

class _WebTutupBukuScreenState extends ConsumerState<WebTutupBukuScreen> {
  var _tahap = _Tahap.konfirmasi;
  var _centang = false;
  Refusal? _tolak;

  /// The month closed in this visit.
  String? _ditutupId;
  Timer? _t;

  static const _lamaProses = Duration(milliseconds: 1500);

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  Future<void> _tutupBuku(Period p) async {
    setState(() {
      _tahap = _Tahap.proses;
      _tolak = null;
    });
    final r = await perintah(
      ref,
      (a, k) => ref
          .read(periodRepositoryProvider)
          .close(
            a,
            p.id,
            pernyataanTutup(p),
            expectedRevision: p.revision,
            idempotencyKey: k,
          ),
    );
    if (!mounted) return;
    if (r is! Ok<ReportSnapshot>) {
      setState(() {
        _tahap = _Tahap.konfirmasi;
        _centang = false;
        _tolak = r?.refusal;
      });
      return;
    }
    _t?.cancel();
    _menunggu = p.id;
    _t = Timer(_lamaProses, _selesai); // tiruan: tutup buku sedang diproses
  }

  String? _menunggu;

  void _selesai() {
    if (!mounted) return;
    setState(() {
      _tahap = _Tahap.sudah;
      _ditutupId = _menunggu;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final tb = ref.watch(tutupBukuProvider);
    final hari = ref.watch(hariIniProvider);
    final semua = tb.bulan.semua;
    final ditutup = semua.where((p) => p.id == _ditutupId).firstOrNull;
    final tutup = _tahap == _Tahap.sudah && ditutup != null;
    final hamb = tb.hambatan.isNotEmpty;

    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        layarKeuangan: true,
        jarak: 22,
        nav: NavSamping(item: navKeuangan, aktif: 4),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: const Text(
                  'Bulan dan tutup buku',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                'Bulan ditutup satu per satu, mulai dari yang paling lama. '
                'Bulan tanpa transaksi tetap harus ditutup.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
          DeretTautan(
            web: true,
            anak: [
              Tautan(
                ke: Layar.kesiapan,
                child: _tengah(const TautanTeks('Pernyataan kesiapan')),
              ),
              Tautan(
                ke: Layar.aiBulan,
                child: _tengah(const TautanTeks('Bantuan AI')),
              ),
              Tautan(
                ke: Layar.kejadian,
                child: _tengah(const TautanTeks('Kejadian setelah tutup buku')),
              ),
            ],
          ),
          _KisiSama(
            minLebar: 240,
            anak: [
              for (final p in semua)
                if (p.start <= hari) _kartuBulan(c, tb, p, semua.first == p),
            ],
          ),
          if (_tolak != null)
            Penolakan(
              tindakan: _tolak!.action,
              sebab: _tolak!.because,
              jalan: const [],
            ),
          if (hamb && !tutup) _hambatan(c, tb),
          if (!hamb && tb.siap && _tahap == _Tahap.konfirmasi)
            _konfirmasi(c, tb),
          if (!hamb && !tb.siap && !tutup && tb.periode != null)
            Text(
              'Tidak ada hambatan. ${namaBulan(tb.periode!)} dapat ditutup '
              'setelah bulannya berakhir.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          if (_tahap == _Tahap.proses) _proses(c),
          if (tutup) _ditutup(c, ditutup),
        ],
      ),
    );
  }

  static Widget _tengah(Widget w) =>
      Align(widthFactor: 1, heightFactor: 1, child: w);

  // ---- Month cards ----

  /// The card's top row: month and badge, `space-between`, gap 8. When both
  /// do not fit, each shrinks by its share of the overflow (CSS flex-shrink 1)
  /// and its text wraps, as on the board at 860 px.
  Widget _judulBulan(
    String bulan,
    String lencana, {
    required Color teks,
    Color? isi,
    Color? garis,
    bool kepala = false,
    required double tepi,
  }) {
    const gayaBulan = TextStyle(fontSize: 17, fontWeight: FontWeight.w700);
    final gayaLencana = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: teks,
    );
    final pad = kepala
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 9, vertical: 3);
    final skala = MediaQuery.textScalerOf(context);
    double lebar(String t, TextStyle g) => (TextPainter(
      text: TextSpan(text: t, style: PalakatText.isiWeb.merge(g)),
      textDirection: TextDirection.ltr,
      textScaler: skala,
    )..layout()).width.ceilToDouble();

    final lencanaW = Container(
      padding: pad,
      decoration: ShapeDecoration(
        color: isi,
        shape: garis == null
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))
            : GarisBorder.penuh(garis, radius: 6),
      ),
      child: Text(lencana, style: gayaLencana),
    );
    // No LayoutBuilder: the card sits in an IntrinsicHeight.
    return Builder(
      builder: (context) {
        final wT = lebar(bulan, gayaBulan);
        final wB =
            lebar(lencana, gayaLencana) +
            pad.horizontal +
            (garis == null ? 0 : 3);
        final lebih = wT + wB + 8 - (_LebarSel.of(context) - tepi);
        final tT = lebih > 0 ? wT - lebih * wT / (wT + wB) : wT;
        final tB = lebih > 0 ? wB - lebih * wB / (wT + wB) : wB;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: tT,
              child: Text(bulan, style: gayaBulan),
            ),
            const SizedBox(width: 8),
            SizedBox(width: tB, child: lencanaW),
          ],
        );
      },
    );
  }

  Widget _kartuBulan(PalakatWarna c, TutupBuku tb, Period p, bool pertama) {
    final nama = namaBulan(p);
    if (p.isClosed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.tinta,
          borderRadius: BorderRadius.circular(16),
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: c.permukaan),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _judulBulan(
                nama,
                'Sudah ditutup',
                teks: c.tinta,
                isi: c.permukaan,
                kepala: true,
                tepi: 32,
              ),
              const SizedBox(height: 4),
              Text(
                'Periode laporan ${rentangPeriode(p)}',
                style: TextStyle(fontSize: 13, color: c.diTinta2),
              ),
              const SizedBox(height: 8),
              Tautan(
                ke: Layar.laporanResmi,
                param: {'periode': p.id, 'bentuk': 'f01'},
                child: Align(
                  alignment: Alignment.centerLeft,
                  heightFactor: 1,
                  child: TautanTeks(
                    'Lihat laporan resmi',
                    berat: FontWeight.w700,
                    ukuran: 14,
                    warna: c.permukaan,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final berikut = tb.periode;
    final dulu = berikut == null ? '' : namaBulan(berikut);
    final n = tb.hambatan.length;
    final teks = p == tb.bulan.berjalan
        ? (p == berikut
              ? 'Berikutnya untuk tutup buku · bulan berjalan'
              : 'Bulan berjalan · menunggu $dulu ditutup')
        : p == berikut
        ? 'Berikutnya untuk tutup buku · '
              '${n > 0 ? '$n hambatan' : 'tidak ada hambatan'}'
        : 'Menunggu $dulu ditutup';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: p == berikut
            ? Border.all(color: c.tinta, width: 2)
            : Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _judulBulan(
            nama,
            'Belum ditutup',
            teks: c.tinta2,
            garis: c.tinta3,
            tepi: p == berikut ? 36 : 34,
          ),
          const SizedBox(height: 4),
          Text(teks, style: TextStyle(fontSize: 13, color: c.tinta2)),
        ],
      ),
    );
  }

  // ---- Hambatan ----

  Widget _kartuHambatan(
    PalakatWarna c, {
    required String judul,
    required InlineSpan teks,
    required Widget tombol,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: c.permukaan,
      border: Border.all(color: c.bata, width: 1.5),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(judul, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text.rich(teks, style: TextStyle(fontSize: 14, color: c.tinta2)),
        const SizedBox(height: 12),
        tombol,
      ],
    ),
  );

  Widget _hambatan(PalakatWarna c, TutupBuku tb) {
    final tahu = untukDiketahuiTutup(tb);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Flexible(
              child: Semantics(
                header: true,
                child: Text(
                  'Hambatan tutup buku ${namaBulan(tb.periode!)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              constraints: const BoxConstraints(minWidth: 22),
              height: 22,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.bata,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${tb.hambatan.length}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: c.diBata,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _KisiSama(
          minLebar: 320,
          anak: [
            for (final h in tb.hambatan)
              _kartuHambatan(
                c,
                judul: h.judul,
                teks: TextSpan(text: h.sub),
                tombol: Tombol(
                  h.tombol,
                  onPressed: null,
                  ke: h.ke,
                  param: h.param,
                  anak: h.anak,
                  jenis: JenisTombol.tinta,
                  ukuran: UkuranTombol.kecil,
                  lebarPenuh: false,
                ),
              ),
          ],
        ),
        if (tahu.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Untuk diketahui (tidak menghalangi tutup buku): $tahu.',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
        ],
      ],
    );
  }

  // ---- Konfirmasi ----

  static Widget _jarak(double h, List<Widget> anak) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < anak.length; i++) ...[
        if (i > 0) SizedBox(height: h),
        anak[i],
      ],
    ],
  );

  Widget _konfirmasi(PalakatWarna c, TutupBuku tb) {
    final p = tb.periode!;
    final nama = namaBulan(p);
    final jk = penutupJabatanKosong(ref);
    final tahu = untukDiketahuiTutup(tb);
    final kiri = _jarak(16, [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Tutup buku bulan $nama?',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mohon baca ringkasan di bawah ini sebelum menutup buku.',
            style: TextStyle(color: c.tinta2),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Semua syarat wajib sudah terpenuhi:',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          for (final s in tb.syarat)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: PalakatIkon(Ikon.terpenuhi, ukuran: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(s.teks, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
        ],
      ),
      if (tahu.isNotEmpty)
        DefaultTextStyle.merge(
          style: TextStyle(fontSize: 14, color: c.tinta2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Untuk diketahui (tidak menghalangi tutup buku). Tetap '
                'ditampilkan di laporan, dan yang masih tersisa dibawa ke '
                'bulan berikutnya:',
                style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
              ),
              const SizedBox(height: 4),
              Text(tahu),
            ],
          ),
        ),
      Container(
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.garis)),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Laporan resmi mencakup '),
              TextSpan(
                text: rentangPeriode(p),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(
                text:
                    ' untuk seluruh Jemaat: semua peruntukan dan semua '
                    'kas/bank. ',
              ),
              // One span per word: the board's inline <a> wraps between its
              // words at 860 px. Each keeps a 44 px target without growing
              // the line; screen readers hear one link.
              for (final (i, kata) in const [
                'Lihat ',
                'laporan ',
                'sementara',
              ].indexed)
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: ExcludeSemantics(
                    excluding: i > 0,
                    child: MarginNegatif(
                      atas: (44 - 14 * 1.45) / 2,
                      bawah: (44 - 14 * 1.45) / 2,
                      child: Tautan(
                        ke: Layar.laporan,
                        // The words together are the target; a 44 px minimum
                        // per word would widen the gaps between them.
                        minLebar: 0,
                        child: Semantics(
                          label: 'Lihat laporan sementara',
                          excludeSemantics: true,
                          child: _tengah(
                            TautanTeks(kata, berat: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ),
      DefaultTextStyle.merge(
        style: TextStyle(fontSize: 14, color: c.tinta2),
        child: _jarak(6, [
          Text(
            'Yang masih dapat Anda lakukan:',
            style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
          ),
          const Text(
            'Mempertanggungjawabkan uang muka dan menyalurkan titipan yang '
            'masih tersisa, sebagai transaksi baru yang bertanggal di bulan '
            'sesudahnya.',
          ),
          const Text(
            'Mencocokkan setoran dalam perjalanan dengan rekening koran bulan '
            'sesudahnya.',
          ),
          Text(
            'Melampirkan dokumen pendukung yang datang terlambat. Dokumen itu '
            'tetap disimpan, tetapi laporan resmi $nama tidak berubah.',
          ),
        ]),
      ),
    ]);

    final permanen = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.tinta,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: 14, color: c.diTinta),
        child: _jarak(10, [
          Text(
            'Tutup buku bersifat permanen.',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: c.permukaan,
            ),
          ),
          Text(
            'Buku bulan $nama menjadi final untuk semua pengguna, '
            'siapa pun.',
          ),
          Text(
            'Transaksi $nama tidak dapat diubah, dibalik, atau '
            'dikoreksi, bahkan dari bulan-bulan sesudahnya.',
          ),
          Text('Laporan resmi $nama dibekukan dan tidak akan berubah.'),
          const Text(
            'Kesalahan atau transaksi terlewat yang ditemukan di kemudian '
            'hari hanya dapat dicatat sebagai kejadian setelah tutup buku. '
            'Kejadian itu tidak mengubah angka apa pun, tidak menghapus '
            'selisih, dan tidak menghilangkan hambatan tutup buku.',
          ),
          const Text(
            'Kesalahan seperti itu dapat menghalangi rekonsiliasi atau tutup '
            'buku bulan-bulan sesudahnya. Bulan yang tidak dapat ditutup juga '
            'menahan tutup buku semua bulan setelahnya, dan aplikasi ini '
            'tidak menyediakan cara untuk memperbaikinya.',
          ),
        ]),
      ),
    );

    final garisTinta = BoxDecoration(
      color: c.permukaan,
      border: Border.all(color: c.tinta, width: 1.5),
      borderRadius: BorderRadius.circular(14),
    );

    final kotakCentang = Tekan(
      onTap: () => setState(() => _centang = !_centang),
      tercentang: _centang,
      radius: 14,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: garisTinta,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox.square(
              dimension: 24,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: _centang ? c.laut : c.permukaan,
                  shape: _centang
                      ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        )
                      : GarisBorder.penuh(c.garisTegas, radius: 4),
                ),
                child: _centang
                    ? Center(
                        child: PalakatIkon(
                          Ikon.centang,
                          ukuran: 16,
                          warna: c.diLaut,
                          tebal: 3,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                pernyataanTutup(p),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    const kembaliGaya = TextStyle(fontWeight: FontWeight.w700);
    final lebarKembali =
        (TextPainter(
          text: TextSpan(
            text: 'Kembali',
            style: PalakatText.isiWeb.merge(kembaliGaya),
          ),
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout()).width.ceilToDouble() +
        40;

    final kanan = _jarak(14, [
      permanen,
      if (jk != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: garisTinta,
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Ditutup oleh '),
                TextSpan(
                  text: jk,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(
                  text:
                      ', yang menjalankan jabatan kosong Bendahara Jemaat. '
                      'Nama dan keadaan ini tercatat pada tutup buku.',
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      kotakCentang,
      BarisLentur(
        jarak: 10,
        rata: CrossAxisAlignment.center,
        anak: [
          Lentur(
            dasar: 240,
            child: TombolTahan(
              'Tutup buku $nama',
              siap: _centang,
              onSelesai: () => _tutupBuku(p),
              tinggi: 54,
            ),
          ),
          Lentur(
            dasar: lebarKembali,
            tumbuh: 0,
            child: Tautan(
              ke: Layar.keuangan,
              cara: Cara.ganti,
              child: Container(
                constraints: const BoxConstraints(minHeight: 54),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kembali',
                  softWrap: false,
                  style: kembaliGaya.copyWith(color: c.tinta),
                ),
              ),
            ),
          ),
        ],
      ),
      Text(
        _centang
            ? 'Tekan dan tahan tombol sampai penuh.'
            : 'Centang pernyataan di atas untuk melanjutkan.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
    ]);

    return Container(
      padding: EdgeInsets.all(context.jepit(18, 2.4, 32)),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(18),
      ),
      child: KisiOtomatis(minLebar: 380, jarak: 28, anak: [kiri, kanan]),
    );
  }

  // ---- Proses ----

  Widget _proses(PalakatWarna c) => Container(
    constraints: const BoxConstraints(minHeight: 320),
    decoration: BoxDecoration(
      color: c.permukaan,
      border: Border.all(color: c.garis),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Putar(child: PalakatIkon(Ikon.cincinProses, ukuran: 52)),
        const SizedBox(height: 16),
        Semantics(
          liveRegion: true,
          child: const Text(
            'Sedang menutup buku…',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  // ---- Ditutup ----

  Widget _barisBerkas(
    PalakatWarna c, {
    required String judul,
    required String teks,
    Widget? aksi,
    bool garisAtas = false,
  }) => Container(
    constraints: const BoxConstraints(minHeight: 60),
    decoration: garisAtas
        ? BoxDecoration(
            border: Border(top: BorderSide(color: c.garis)),
          )
        : null,
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(judul, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(teks, style: TextStyle(fontSize: 13, color: c.tinta2)),
            ],
          ),
        ),
        if (aksi != null) ...[const SizedBox(width: 12), aksi],
      ],
    ),
  );

  Widget _ditutup(PalakatWarna c, Period p) {
    final nama = namaBulan(p);
    final oleh = ref.watch(peopleRepositoryProvider).person(p.closedBy ?? '');
    Widget unduh(String label, String bentuk) => Tombol(
      label,
      onPressed: null,
      ke: Layar.laporanResmi,
      param: {'periode': p.id, 'bentuk': bentuk},
      ukuran: UkuranTombol.kecil,
      paddingH: 14,
      lebarPenuh: false,
    );

    final teks = Gerak(
      Kerangka.muncul,
      lama: const Duration(milliseconds: 400),
      tunda: const Duration(milliseconds: 1400),
      child: _jarak(6, [
        Semantics(
          header: true,
          child: Text(
            'Buku bulan $nama sudah ditutup.',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
        Text(
          'Angka laporan resmi sudah dibekukan · ${p.snapshotId}',
          style: TextStyle(color: c.diTinta2),
        ),
        Text(
          'Dikonfirmasi oleh ${oleh?.shortName ?? oleh?.name} · '
          '${p.closedAt == null ? '' : tglJam(p.closedAt!)}',
          style: TextStyle(fontSize: 13, color: c.diTinta2),
        ),
      ]),
    );

    final berkas = Gerak(
      Kerangka.muncul,
      lama: const Duration(milliseconds: 400),
      tunda: const Duration(milliseconds: 1700),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: c.permukaan,
          borderRadius: BorderRadius.circular(14),
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: c.tinta),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _barisBerkas(
                c,
                judul: 'Laporan resmi · PDF',
                teks: 'Siap diunduh',
                aksi: unduh('Unduh PDF', 'f01'),
              ),
              _barisBerkas(
                c,
                judul: 'Laporan resmi · Excel',
                teks: 'Siap diunduh',
                garisAtas: true,
                aksi: unduh('Unduh Excel', 'excel'),
              ),
            ],
          ),
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Gerak(
        Kerangka.gelap((w) => w.permukaan),
        lama: const Duration(milliseconds: 700),
        kurva: Curves.easeOut,
        child: Padding(
          padding: EdgeInsets.all(context.jepit(20, 3, 40)),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: c.permukaan),
            child: BarisLentur(
              jarak: 28,
              rata: CrossAxisAlignment.center,
              anak: [
                const Lentur(dasar: 104, tumbuh: 0, child: SegelGembok()),
                Lentur(dasar: 320, child: teks),
                // flex-basis 320 is the content box; padding 0 16 adds 32.
                Lentur(dasar: 352, child: berkas),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// CSS grid `repeat(auto-fit, minmax(min(X, 100%), 1fr))`, gap 14, with the
/// grid's default `align-items: stretch` (cards in a row share one height).
class _KisiSama extends StatelessWidget {
  const _KisiSama({required this.minLebar, required this.anak});
  final double minLebar;
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, k) {
      const jarak = 14.0;
      final n = KisiOtomatis.kolom(k.maxWidth, minLebar, jarak, anak.length);
      final lebar = (k.maxWidth - jarak * (n - 1)) / n;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < anak.length; i += n) ...[
            if (i > 0) const SizedBox(height: jarak),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = i; j < i + n && j < anak.length; j++) ...[
                    if (j > i) const SizedBox(width: jarak),
                    SizedBox(
                      width: lebar,
                      child: _LebarSel(lebar, child: anak[j]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    },
  );
}

/// The width of a [_KisiSama] cell, for the month title row.
class _LebarSel extends InheritedWidget {
  const _LebarSel(this.lebar, {required super.child});
  final double lebar;

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_LebarSel>()!.lebar;

  @override
  bool updateShouldNotify(_LebarSel old) => old.lebar != lebar;
}
