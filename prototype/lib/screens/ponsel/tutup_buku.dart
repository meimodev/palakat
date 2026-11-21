import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../motion/hitung.dart';
import '../../motion/kerangka.dart';
import '../../motion/ulang.dart';
import '../../motion/urutan.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/akhir_bulan.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/repositories_keuangan.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

final _akar = Layar.tutupBuku.jalur;
final _cek = '$_akar/cek';

enum _Fase { konfirmasi, proses, gagal }

/// UI state shared by `/tutup-buku` and its child routes: the statement
/// tick, the close phase and the last refusal. Every figure is read from
/// the month-end read models (README 5.6).
class _Papan extends ChangeNotifier {
  late GoRouter router;

  bool centang = false;
  _Fase fase = _Fase.konfirmasi;
  Refusal? tolak;
  Timer? _t;

  void _ubah(void Function() f) {
    f();
    notifyListeners();
  }

  /// Pops down to [lokasi] when it is in the stack; otherwise pops to
  /// `/tutup-buku` and pushes it (a child URL opened directly).
  void _naik(String lokasi) {
    var t = tumpukanHalaman(router);
    final sasaran = t.contains(lokasi) ? lokasi : _akar;
    if (!t.contains(sasaran)) {
      router.go(lokasi);
      return;
    }
    while (t.length > 1 && t.last != sasaran) {
      router.pop();
      final baru = tumpukanHalaman(router);
      if (baru.length >= t.length) break;
      t = baru;
    }
    if (sasaran != lokasi) router.push(lokasi);
  }

  void keBulan() => _naik(_akar);
  void keCek() => _naik(_cek);

  void keKonfirmasi() {
    _ubah(() {
      centang = false;
      tolak = null;
      fase = _Fase.konfirmasi;
    });
    router.push('$_akar/konfirmasi');
  }

  void keRekon() {
    _ubah(() => tolak = null);
    router.push('$_akar/rekonsiliasi');
  }

  void ubahCentang(bool v) => _ubah(() => centang = v);
  void tampilkan(Refusal? r) => _ubah(() => tolak = r);

  /// "Tutup buku": the command runs at once; the board's progress view
  /// shows before the closed view.
  Future<void> tutupBuku(WidgetRef ref, Period p, String pernyataan) async {
    _ubah(() => fase = _Fase.proses);
    final r = await perintah(
      ref,
      (a, k) => ref
          .read(periodRepositoryProvider)
          .close(
            a,
            p.id,
            pernyataan,
            expectedRevision: p.revision,
            idempotencyKey: k,
          ),
    );
    if (r is Refused<ReportSnapshot>) {
      _ubah(() {
        fase = _Fase.gagal;
        tolak = r.refusal;
        centang = false;
      });
      return;
    }
    _t?.cancel();
    _t = Timer(_lamaProses, _keDitutup); // tiruan: tutup buku sedang diproses
  }

  static const _lamaProses = Duration(milliseconds: 1500);

  void _keDitutup() {
    _naik(_akar);
    router.push('$_akar/ditutup');
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }
}

class _Lingkup extends InheritedNotifier<_Papan> {
  const _Lingkup({required _Papan papan, required super.child})
    : super(notifier: papan);

  static _Papan of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
}

class TutupBukuKendali extends StatefulWidget {
  const TutupBukuKendali({super.key, required this.child});
  final Widget child;
  @override
  State<TutupBukuKendali> createState() => _TutupBukuKendaliState();
}

class _TutupBukuKendaliState extends State<TutupBukuKendali> {
  final _papan = _Papan();

  @override
  void dispose() {
    _papan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _papan.router = GoRouter.of(context);
    return LayarPonsel(
      layarKeuangan: true,
      child: _Lingkup(papan: _papan, child: widget.child),
    );
  }
}

class TutupBukuScreen extends StatelessWidget {
  const TutupBukuScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => switch (anak) {
    'cek' => const _Cek(),
    'rekonsiliasi' => const _Rekon(),
    'konfirmasi' => const _Konfirmasi(),
    'ditutup' => const _Ditutup(),
    _ => const _Bulan(),
  };
}

/// The last closed period, for the closed view.
Period? _terakhirDitutup(List<Period> semua) =>
    (semua.where((p) => p.isClosed).toList()..sort(
          (a, b) =>
              (a.closedAt ?? DateTime(0)).compareTo(b.closedAt ?? DateTime(0)),
        ))
        .lastOrNull;

/// 'Periode laporan 1–31 {bulan}', with the cutover note on the first.
String periodeLaporan(Period p, {required bool pertama}) =>
    'Periode laporan ${rentangPeriode(p)}'
    '${pertama ? ', sejak tanggal mulai pencatatan' : ''}';

/// Opens a blocker's screen: its child route on TutupBuku, else its Layar.
void bukaHambatan(
  BuildContext context,
  ButirHambatan h, {
  VoidCallback? rekon,
}) {
  if (h.ke == Layar.tutupBuku && h.anak == 'rekonsiliasi' && rekon != null) {
    rekon();
    return;
  }
  context.dorongKe(h.ke, param: h.param, anak: h.anak);
}

// ---------------------------------------------------------------- bits

const _mono = TextStyle(
  fontFamily: PalakatText.mono,
  fontWeight: FontWeight.w500,
);

/// A board `<button>` whose size is not one of [UkuranTombol].
Widget _tombol(
  String label, {
  required VoidCallback onTap,
  required Color? isi,
  required Color teks,
  Color? garis,
  double tinggi = 44,
  double radius = 12,
}) => Tekan(
  onTap: onTap,
  radius: radius,
  child: RupaTombol(
    label: label,
    isi: isi,
    garis: garis == null ? null : GarisBorder.penuh(garis, radius: radius),
    warnaTeks: teks,
    radius: radius,
    tinggi: tinggi,
    paddingH: 6,
  ),
);

/// Footer bar: `permukaan`, 1 px `garis` above, padding 12 20 22.
Widget _kaki(BuildContext context, List<Widget> anak, {double jarak = 8}) =>
    Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      decoration: BoxDecoration(
        color: context.warna.permukaan,
        border: Border(top: BorderSide(color: context.warna.garis)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: jarak,
        children: anak,
      ),
    );

Widget _tautan({required Layar ke, required String teks}) => Tautan(
  ke: ke,
  child: Center(widthFactor: 1, heightFactor: 1, child: TautanTeks(teks)),
);

Widget _baris(String kiri, Widget kanan, {double jarak = 0}) => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: jarak,
  children: [
    Flexible(
      child: Text(
        kiri,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    kanan,
  ],
);

/// Month title (18/700) and its badge, space-between.
Widget _judulBulan(String bulan, Widget lencana) => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  spacing: 8,
  children: [
    Flexible(
      child: Text(
        bulan,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    ),
    lencana,
  ],
);

/// A full-height view column (`inset: 0`, flex column) that scrolls only when
/// its content is taller than the screen.
Widget _penuh({required EdgeInsets padding, required Widget child}) =>
    LayoutBuilder(
      builder: (context, k) => SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: k.maxHeight - padding.vertical,
          ),
          child: IntrinsicHeight(child: child),
        ),
      ),
    );

Widget _muncul(Widget child, {String? kunci, int ms = 300, int tunda = 0}) =>
    Gerak(
      Kerangka.muncul,
      key: kunci == null ? null : ValueKey(kunci),
      lama: Duration(milliseconds: ms),
      tunda: Duration(milliseconds: tunda),
      child: child,
    );

// ---------------------------------------------------------------- A. Bulan

class _Bulan extends ConsumerWidget {
  const _Bulan();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final p = _Lingkup.of(context);
    final tb = ref.watch(tutupBukuProvider);
    final hari = ref.watch(hariIniProvider);
    final kas = ref.watch(hitungKasProvider);
    final orang = ref.watch(peopleRepositoryProvider);
    final berikut = tb.periode;
    final semua = tb.bulan.semua;
    final bulan = [
      for (final x in semua.reversed)
        if (x.start <= hari) x,
    ];
    final kasLabel = kas?.terakhir == null
        ? 'Hitung kas · Kas belum dihitung'
        : 'Hitung kas · ${rp(kas!.terakhir!.total)} · '
              '${tgl(kas.terakhir!.countedAt)}';
    Widget kartu(Period x) {
      final nama = namaBulan(x);
      if (x.isClosed) {
        final oleh = x.closedBy == null
            ? null
            : orang.person(x.closedBy!)?.shortName ??
                  orang.person(x.closedBy!)?.name;
        return _KartuTutup(
          periode: x,
          teks:
              '${periodeLaporan(x, pertama: x == semua.first)}'
              '${oleh == null || x.closedAt == null ? '' : ' · ditutup oleh $oleh, ${tglJam(x.closedAt!)}'}',
        );
      }
      final berjalan = x == tb.bulan.berjalan;
      if (berjalan) {
        return _KartuBulan(
          bulan: nama,
          garis: x == berikut
              ? Border.all(color: c.tinta, width: 2)
              : Border.all(color: c.garis),
          anak: [
            Text(
              x == berikut
                  ? 'Berikutnya untuk tutup buku · bulan berjalan'
                  : 'Bulan berjalan · menunggu ${berikut == null ? '' : namaBulan(berikut)} ditutup',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Tautan(
                ke: Layar.hitungKas,
                radius: 12,
                child: RupaTombol(
                  label: kasLabel,
                  isi: null,
                  garis: GarisBorder.penuh(c.tinta, radius: 12),
                  warnaTeks: c.tinta,
                  radius: 12,
                  tinggi: 47,
                  paddingH: 0,
                ),
              ),
            ),
          ],
        );
      }
      final n = x == berikut ? tb.hambatan.length : 0;
      return _KartuBulan(
        bulan: nama,
        garis: Border.all(
          color: x == berikut ? c.tinta : c.garis,
          width: x == berikut ? 2 : 1,
        ),
        anak: [
          Text(
            x == berikut
                ? 'Berikutnya untuk tutup buku · '
                      '${n > 0 ? '$n hambatan' : 'tidak ada hambatan'}'
                : 'Menunggu ${berikut == null ? '' : namaBulan(berikut)} ditutup',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          if (x == berikut)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _tombol(
                'Periksa kesiapan tutup buku',
                onTap: p.keCek,
                isi: c.laut,
                teks: c.diLaut,
                tinggi: 48,
              ),
            ),
        ],
      );
    }

    return ColoredBox(
      color: c.kertas,
      child: Gerak(
        Kerangka.pudar,
        lama: const Duration(milliseconds: 200),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Semantics(
                  header: true,
                  child: const Text(
                    'Bulan',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Bulan ditutup satu per satu, mulai dari yang paling lama.',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
              ),
              for (final x in bulan) kartu(x),
            ],
          ),
        ),
      ),
    );
  }
}

class _KartuBulan extends StatelessWidget {
  const _KartuBulan({
    required this.bulan,
    required this.garis,
    required this.anak,
  });
  final String bulan;
  final BoxBorder garis;
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.warna.permukaan,
      border: garis,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        _judulBulan(bulan, LencanaStatus.uang(StatusUang.belumDitutup)),
        ...anak,
      ],
    ),
  );
}

/// A closed month: the `ditutup` (tinta) card; its report line opens the
/// official F01.
class _KartuTutup extends StatelessWidget {
  const _KartuTutup({required this.periode, required this.teks});
  final Period periode;
  final String teks;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final g = GarisStatus.ditutup.gaya(c, radius: 16);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: g.isi,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: c.permukaan),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 6,
          children: [
            _judulBulan(
              namaBulan(periode),
              const LencanaStatus(
                'Sudah ditutup',
                bentuk: BentukLencana.terbalik,
              ),
            ),
            Text(teks, style: TextStyle(fontSize: 14, color: c.diTinta2)),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Tautan(
                ke: Layar.laporanResmi,
                param: {'periode': periode.id, 'bentuk': 'f01'},
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Laporan resmi · PDF · Excel',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- B. Cek

class _Cek extends ConsumerWidget {
  const _Cek();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final p = _Lingkup.of(context);
    final tb = ref.watch(tutupBukuProvider);
    final nama = tb.periode == null ? '' : namaBulan(tb.periode!);
    final hambatan = tb.hambatan;
    final kosong = hambatan.isEmpty;
    final tahu = [
      if (tb.uangMuka > 0)
        '${tb.uangMuka} uang muka dengan sisa belum dipertanggungjawabkan',
      if (tb.dalamPerjalanan > 0)
        '${tb.dalamPerjalanan} setoran dalam perjalanan (belum tercatat di '
            'rekening koran)',
    ];
    return ColoredBox(
      color: c.kertas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(judul: 'Tutup buku $nama', onKembali: p.keBulan),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: [
                  DeretTautan(
                    anak: [
                      _tautan(ke: Layar.kesiapan, teks: 'Pernyataan kesiapan'),
                      _tautan(ke: Layar.aiBulan, teks: 'Bantuan AI'),
                      _tautan(ke: Layar.kejadian, teks: 'Kejadian'),
                    ],
                  ),
                  if (!kosong)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 10,
                      children: [
                        Row(
                          children: [
                            const Flexible(child: JudulBagian('Hambatan')),
                            const SizedBox(width: 8),
                            Hitungan(hambatan.length, rapat: true),
                          ],
                        ),
                        Text(
                          'Tutup buku belum dapat dilakukan sampai semua hambatan selesai.',
                          style: TextStyle(fontSize: 14, color: c.tinta2),
                        ),
                        for (final h in hambatan)
                          Kartu(
                            status: GarisStatus.hambatan,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 4,
                              children: [
                                Text(
                                  h.judul,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  h.sub,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: c.tinta2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Tombol(
                                    h.tombol,
                                    onPressed: () => bukaHambatan(
                                      context,
                                      h,
                                      rekon: p.keRekon,
                                    ),
                                    jenis: JenisTombol.tinta,
                                    ukuran: UkuranTombol.kecil,
                                    paddingH: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                  else
                    _muncul(
                      kunci: 'tanpa-hambatan',
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: c.lautLembut,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          spacing: 12,
                          children: [
                            const PalakatIkon(Ikon.terpenuhi, ukuran: 26),
                            Expanded(
                              child: Text(
                                tb.sudahBerakhir
                                    ? 'Tidak ada hambatan. $nama siap ditutup.'
                                    : 'Tidak ada hambatan. $nama dapat '
                                          'ditutup setelah bulannya berakhir.',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 4,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: JudulBagian('Syarat wajib'),
                      ),
                      for (final s in tb.syarat) _syaratBaris(c, s),
                    ],
                  ),
                  if (tahu.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 6,
                      children: [
                        const JudulBagian('Untuk diketahui'),
                        Text(
                          'Tidak menghalangi tutup buku.',
                          style: TextStyle(fontSize: 13, color: c.tinta3),
                        ),
                        for (final d in tahu)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Text(
                              d,
                              style: TextStyle(fontSize: 14, color: c.tinta2),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          if (tb.siap)
            _muncul(
              kunci: 'kaki-cek',
              _kaki(context, [
                Tombol(
                  'Lanjut ke konfirmasi tutup buku',
                  onPressed: p.keKonfirmasi,
                  paddingH: 6,
                ),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _syaratBaris(PalakatWarna c, Syarat s) {
    final no = !s.terpenuhi;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          no
              ? const PalakatIkon(
                  Ikon.belumTerpenuhi,
                  ukuran: 20,
                  label: 'Belum terpenuhi',
                )
              : const PalakatIkon(
                  Ikon.terpenuhi,
                  ukuran: 20,
                  label: 'Terpenuhi',
                ),
          Expanded(
            child: Text(
              s.teks,
              style: TextStyle(
                fontSize: 14,
                color: no ? c.bata : c.tinta,
                fontWeight: no ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- C. Rekonsiliasi

class _Rekon extends ConsumerWidget {
  const _Rekon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final p = _Lingkup.of(context);
    final id = ref.watch(akunRekonProvider);
    final r = id == null ? null : ref.watch(rekonAkunProvider(id));
    if (r == null || r.sesi == null) {
      return ColoredBox(
        color: c.kertas,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KepalaPonsel(judul: 'Rekonsiliasi', onKembali: p.keCek),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  Text(
                    'Belum ada rekening koran untuk direkonsiliasi.',
                    style: TextStyle(fontSize: 15, color: c.tinta2),
                  ),
                  _tautan(ke: Layar.rekeningKoran, teks: 'Isi rekening koran'),
                ],
              ),
            ),
          ],
        ),
      );
    }
    final nol = r.selisih == 0;
    final pasti = r.dipastikan;
    final berikut = bulanSesudah(r.periode);
    final (bg, fg, bd) = pasti
        ? (c.laut, c.diLaut, c.laut)
        : (null, c.tinta2, c.tinta3);
    final lencana = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: bd, width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        r.status,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fg),
      ),
    );
    Widget ringkas(String a, String b) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(a, style: TextStyle(fontSize: 14, color: c.tinta2)),
        ),
        Text(b, style: _mono.copyWith(fontSize: 14)),
      ],
    );
    final pasangan = [
      for (final m in r.mutasi)
        if (m.lunas &&
            m.cocok.length == 1 &&
            m.cocok.first.sourceRef == m.baris.description)
          m,
    ];
    return ColoredBox(
      color: c.kertas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Rekonsiliasi',
            anakJudul: '${r.akun.name} · ${namaBulan(r.periode)}',
            onKembali: p.keCek,
            ujung: lencana,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 18,
                children: [
                  DeretTautan(
                    anak: [
                      _tautan(
                        ke: Layar.rekeningKoran,
                        teks: 'Isi rekening koran',
                      ),
                      _tautan(ke: Layar.hitungKas, teks: 'Hitung kas'),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: c.permukaan,
                      border: Border.all(color: c.garis),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 8,
                      children: [
                        ringkas('Saldo buku', rp(r.buku)),
                        ringkas(
                          'Saldo rekening koran',
                          r.amati == null ? kosong : rp(r.amati!),
                        ),
                        if (r.setor > 0)
                          _muncul(
                            kunci: 'ringkas-perjalanan',
                            ringkas(
                              'Setoran dalam perjalanan',
                              rpBeda(r.setor),
                            ),
                          ),
                        if (r.bayar > 0)
                          ringkas(
                            'Pembayaran dalam perjalanan',
                            rpBeda(-r.bayar),
                          ),
                        ringkas(
                          'Saldo pembanding',
                          r.pembanding == null ? kosong : rp(r.pembanding!),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: c.tinta, width: 1.5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Flexible(
                                child: Text(
                                  'Selisih belum dijelaskan',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Hitung(
                                nilai: r.selisih ?? 0,
                                builder: (ctx, n) => AnimatedDefaultTextStyle(
                                  duration: ctx.gerak(
                                    const Duration(milliseconds: 300),
                                  ),
                                  curve: Curves.ease,
                                  style: DefaultTextStyle.of(ctx).style.merge(
                                    _mono.copyWith(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: n == 0 ? c.laut : c.bata,
                                    ),
                                  ),
                                  child: Text(rp(n)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (r.belumCocok.isNotEmpty || r.belumDiKoran.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 10,
                      children: [
                        const JudulBagian('Belum cocok'),
                        for (final t in r.belumDiKoran)
                          _BelumCocok(
                            jenis: 'Transaksi · belum ada di rekening koran',
                            judul: t.description,
                            jumlah: rp(diAkun(t, r.akun.id)),
                            rinci: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: t.voucher,
                                    style: _mono.copyWith(
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  TextSpan(text: ' · ${t.effectiveDate}'),
                                ],
                              ),
                            ),
                            tombol: 'Tandai dalam perjalanan',
                            aksi: () async => p.tampilkan(
                              await AksiRekon.dalamPerjalanan(
                                ref,
                                r,
                                t,
                                berikut,
                              ),
                            ),
                            catatan: 'Dibawa ke bulan berikutnya',
                          ),
                        for (final m in r.belumCocok)
                          _kartuMutasi(context, ref, p, r, m),
                      ],
                    ),
                  if (r.dalamPerjalanan.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 10,
                      children: [
                        const JudulBagian('Dalam perjalanan'),
                        for (final t in r.dalamPerjalanan)
                          _muncul(
                            kunci: 'kartu-perjalanan-${t.id}',
                            Kartu(
                              status: GarisStatus.draf,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                spacing: 12,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          diAkun(t, r.akun.id) > 0
                                              ? 'Setoran dalam perjalanan'
                                              : 'Pembayaran dalam perjalanan',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${rp(diAkun(t, r.akun.id).abs())} · '
                                          'dibawa ke $berikut',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: c.tinta3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Tombol(
                                    'Lepaskan',
                                    onPressed: () async => p.tampilkan(
                                      await AksiRekon.dalamPerjalanan(
                                        ref,
                                        r,
                                        t,
                                        berikut,
                                      ),
                                    ),
                                    jenis: JenisTombol.teks,
                                    lebarPenuh: false,
                                    paddingH: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 10,
                    children: [
                      Semantics(
                        header: true,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'Cocok '),
                              TextSpan(
                                text: '· ${r.cocok} mutasi bank',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: c.tinta3,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      for (final m in pasangan)
                        _PasanganCocok(akun: r.akun.id, mutasi: m),
                      Text(
                        '${r.cocok - pasangan.length} mutasi bank lain sudah '
                        'cocok dengan transaksinya.',
                        style: TextStyle(fontSize: 14, color: c.tinta2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _kaki(context, [
            if (p.tolak != null)
              Penolakan(
                tindakan: p.tolak!.action,
                sebab: p.tolak!.because,
                jalan: const [],
                ukuranTeks: 14,
              ),
            if (!pasti && r.alasanBelum != null)
              Text(
                nol
                    ? r.alasanBelum!
                    : 'Selisih belum dijelaskan harus Rp0 sebelum '
                          'rekonsiliasi dapat dipastikan.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            if (!pasti && r.alasanDiperiksa != null)
              Text(
                r.alasanDiperiksa!,
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            if (!pasti && r.alasanBelum == null)
              _muncul(
                kunci: 'pastikan',
                Tombol(
                  r.tombolPastikan,
                  onPressed: () async =>
                      p.tampilkan(await AksiRekon.pastikan(ref, r)),
                  paddingH: 6,
                ),
              ),
            if (pasti)
              Tombol(
                'Kembali ke kesiapan tutup buku',
                onPressed: p.keCek,
                jenis: JenisTombol.kedua,
                paddingH: 6,
              ),
          ]),
        ],
      ),
    );
  }

  Widget _kartuMutasi(
    BuildContext context,
    WidgetRef ref,
    _Papan p,
    RekonAkun r,
    BarisMutasi m,
  ) {
    final draf = m.cocok.where((t) => !t.isPosted).firstOrNull;
    final rinci =
        '${m.baris.date} · sisa belum dicocokkan: ${rp(m.sisa.abs())}';
    if (draf != null) {
      return _BelumCocok(
        jenis:
            'Mutasi bank · transaksinya masih ${draf.status == TransactionStatus.reviewed ? 'Sudah diperiksa' : 'Draf'}',
        judul: m.baris.description,
        jumlah: rp(m.baris.amount),
        rinci: Text(rinci),
        tombol: 'Periksa dan bukukan',
        aksi: () => context.dorongKe(Layar.draf, param: {'id': draf.id}),
        catatan: '${draf.description} · cocok setelah dibukukan',
      );
    }
    if (m.saran.isNotEmpty) {
      return _BelumCocok(
        jenis: 'Mutasi bank · ada transaksi yang cocok',
        judul: m.baris.description,
        jumlah: rp(m.baris.amount),
        rinci: Text(rinci),
        tombol: 'Cocokkan',
        aksi: () async =>
            p.tampilkan(await AksiRekon.cocokkan(ref, r, m, m.saran)),
        catatan: m.saran
            .map((t) => '${t.voucher} · ${rp(diAkun(t, r.akun.id))}')
            .join(' + '),
      );
    }
    final d = drafDariMutasi(
      m.baris,
      r.akun.id,
      ref.read(fundRepositoryProvider).funds(),
    );
    return _BelumCocok(
      jenis: 'Mutasi bank · belum ada transaksinya',
      judul: m.baris.description,
      jumlah: rp(m.baris.amount),
      rinci: Text(rinci),
      tombol: 'Buat transaksi dari mutasi ini',
      aksi: () async => p.tampilkan(await AksiRekon.buatTransaksi(ref, r, m)),
      catatan: d.allocations.first.masterCode == null
          ? d.description
          : 'Belanja ${d.allocations.first.masterCode} ${d.description}',
    );
  }
}

class _BelumCocok extends StatelessWidget {
  const _BelumCocok({
    required this.jenis,
    required this.judul,
    required this.jumlah,
    required this.rinci,
    required this.tombol,
    required this.aksi,
    required this.catatan,
  });
  final String jenis, judul, jumlah, tombol, catatan;
  final Widget rinci;
  final VoidCallback aksi;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final kecil = TextStyle(fontSize: 13, color: c.tinta3);
    return Kartu(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          Text(jenis, style: kecil),
          _baris(judul, Text(jumlah, style: _mono), jarak: 8),
          DefaultTextStyle.merge(style: kecil, child: rinci),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Tombol(
              tombol,
              onPressed: aksi,
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.kecil,
              paddingH: 6,
            ),
          ),
          Text(catatan, style: kecil, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// A line matched to the transaction made from it (`kait`).
class _PasanganCocok extends StatelessWidget {
  const _PasanganCocok({required this.akun, required this.mutasi});
  final String akun;
  final BarisMutasi mutasi;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final t = mutasi.cocok.first;
    final jumlah = rp(mutasi.baris.amount);
    Widget kartu(Widget atas, String judul) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.laut, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 13, color: c.tinta3),
            child: atas,
          ),
          _baris(judul, Text(jumlah, style: _mono)),
        ],
      ),
    );
    const masuk = Duration(milliseconds: 400);
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 6,
          children: [
            Gerak(
              Kerangka.dariKiri(40),
              lama: masuk,
              kurva: PalakatMotion.keluar,
              child: kartu(const Text('Mutasi bank'), mutasi.baris.description),
            ),
            Gerak(
              Kerangka.dariKanan(40),
              lama: masuk,
              kurva: PalakatMotion.keluar,
              child: kartu(
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Transaksi · Dibukukan · '),
                      TextSpan(
                        text: t.voucher,
                        style: _mono.copyWith(fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                t.description,
              ),
            ),
          ],
        ),
        Positioned.fill(
          child: Center(
            child: Gerak(
              Kerangka.kait,
              lama: masuk,
              tunda: const Duration(milliseconds: 350),
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.laut,
                  shape: BoxShape.circle,
                ),
                child: PalakatIkon(Ikon.kait, ukuran: 16, warna: c.diLaut),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- D. Konfirmasi (+ E, F)

class _Konfirmasi extends ConsumerWidget {
  const _Konfirmasi();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final p = _Lingkup.of(context);
    final tb = ref.watch(tutupBukuProvider);
    final Widget isi = switch (p.fase) {
      _Fase.proses => const _Proses(key: ValueKey('proses')),
      _Fase.gagal => _Gagal(key: const ValueKey('gagal'), p: p),
      _Fase.konfirmasi => _isiKonfirmasi(context, ref, c, p, tb),
    };
    return PopScope(
      canPop: p.fase != _Fase.proses,
      child: ColoredBox(color: c.permukaan, child: isi),
    );
  }

  Widget _isiKonfirmasi(
    BuildContext context,
    WidgetRef ref,
    PalakatWarna c,
    _Papan p,
    TutupBuku tb,
  ) {
    final bulan = tb.periode;
    if (bulan == null) return const SizedBox.shrink();
    final nama = namaBulan(bulan);
    final jk = penutupJabatanKosong(ref);
    final tahu = untukDiketahuiTutup(tb);
    final pendamping = TextStyle(fontSize: 14, color: c.tinta2);
    final tebal = TextStyle(fontWeight: FontWeight.w700, color: c.tinta);
    final putih = TextStyle(fontSize: 14, color: c.diTinta);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 18,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const SizedBox(height: 6),
                    Text(
                      'Mohon baca ringkasan di bawah ini sebelum menutup buku.',
                      style: TextStyle(fontSize: 15, color: c.tinta2),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        'Semua syarat wajib sudah terpenuhi:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    for (final s in tb.syarat)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 1),
                              child: PalakatIkon(Ikon.terpenuhi, ukuran: 18),
                            ),
                            Expanded(
                              child: Text(
                                s.teks,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (tahu.isNotEmpty)
                  DefaultTextStyle.merge(
                    style: pendamping,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Untuk diketahui (tidak menghalangi tutup buku). Tetap ditampilkan di laporan, dan yang masih tersisa dibawa ke bulan berikutnya:',
                            style: tebal,
                          ),
                        ),
                        Text(tahu),
                      ],
                    ),
                  ),
                _Cakupan(rentang: rentangPeriode(bulan)),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: c.tinta,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 10,
                    children: [
                      Text(
                        'Tutup buku bersifat permanen.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: c.permukaan,
                        ),
                      ),
                      for (final t in [
                        'Buku bulan $nama menjadi final untuk semua pengguna, siapa pun.',
                        'Transaksi $nama tidak dapat diubah, dibalik, atau dikoreksi, bahkan dari bulan-bulan sesudahnya.',
                        'Laporan resmi $nama dibekukan dan tidak akan berubah.',
                        'Kesalahan atau transaksi terlewat yang ditemukan di kemudian hari hanya dapat dicatat sebagai kejadian setelah tutup buku. Kejadian itu tidak mengubah angka apa pun, tidak menghapus selisih, dan tidak menghilangkan hambatan tutup buku.',
                        'Kesalahan seperti itu dapat menghalangi rekonsiliasi atau tutup buku bulan-bulan sesudahnya. Bulan yang tidak dapat ditutup juga menahan tutup buku semua bulan setelahnya, dan aplikasi ini tidak menyediakan cara untuk memperbaikinya.',
                      ])
                        Text(t, style: putih),
                    ],
                  ),
                ),
                DefaultTextStyle.merge(
                  style: pendamping,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 6,
                    children: [
                      Text('Yang masih dapat Anda lakukan:', style: tebal),
                      const Text(
                        'Mempertanggungjawabkan uang muka dan menyalurkan titipan yang masih tersisa, sebagai transaksi baru yang bertanggal di bulan sesudahnya.',
                      ),
                      const Text(
                        'Mencocokkan setoran dalam perjalanan dengan rekening koran bulan sesudahnya.',
                      ),
                      Text(
                        'Melampirkan dokumen pendukung yang datang terlambat. Dokumen itu tetap disimpan, tetapi laporan resmi $nama tidak berubah.',
                      ),
                    ],
                  ),
                ),
                if (jk != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: c.permukaan,
                      border: Border.all(color: c.tinta, width: 1.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Ditutup oleh '),
                          TextSpan(
                            text: jk,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(
                            text: ', yang menjalankan jabatan kosong Bendahara Jemaat. Nama dan keadaan ini tercatat pada tutup buku.',
                          ),
                        ],
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                _Pernyataan(
                  teks: pernyataanTutup(bulan),
                  nilai: p.centang,
                  onUbah: p.ubahCentang,
                ),
              ],
            ),
          ),
        ),
        _kaki(context, jarak: 6, [
          TombolTahan(
            'Tutup buku $nama',
            siap: p.centang,
            onSelesai: () => p.tutupBuku(ref, bulan, pernyataanTutup(bulan)),
            petunjuk: p.centang
                ? 'Tekan dan tahan tombol sampai penuh'
                : 'Centang pernyataan di atas untuk melanjutkan',
          ),
          Tombol(
            'Kembali',
            onPressed: p.keCek,
            jenis: JenisTombol.teks,
            warnaTeks: c.tinta,
          ),
        ]),
      ],
    );
  }
}

/// The scope line with its inline link "Lihat laporan sementara". The link
/// keeps its drawn inline size; a 44 px high [Tautan] is laid over it
/// (rules-checklist X03, as for PetaLayar's small links).
class _Cakupan extends StatelessWidget {
  const _Cakupan({required this.rentang});
  final String rentang;

  static const _tautan = 'Lihat laporan sementara';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final gaya = DefaultTextStyle.of(context).style
        .merge(const TextStyle(fontSize: 14));
    const a = 'Laporan resmi mencakup ';
    final b = rentang;
    // U+2060: Chrome keeps "kas/bank." together; ICU would break after "/".
    const d =
        ' untuk seluruh Jemaat: semua peruntukan dan semua kas/\u2060bank. ';
    final awal = a.length + b.length + d.length;
    final span = TextSpan(
      style: gaya,
      children: [
        const TextSpan(text: a),
        TextSpan(
          text: b,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const TextSpan(text: d),
        TextSpan(
          text: _tautan,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: c.laut,
            decoration: TextDecoration.underline,
            decorationColor: c.laut,
          ),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, k) {
        final tp = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: k.maxWidth);
        final kotak = tp
            .getBoxesForSelection(
              TextSelection(
                baseOffset: awal,
                extentOffset: awal + _tautan.length,
              ),
            )
            .map((b) => b.toRect())
            .reduce((a, b) => a.expandToInclude(b));
        tp.dispose();
        // 1 px rule + 12 px padding above the text.
        final atas = 13 + kotak.center.dy - 22;
        return Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(color: c.garis),
                ),
              ),
              child: Text.rich(span),
            ),
            Positioned(
              left: kotak.left,
              top: atas,
              width: kotak.width,
              height: 44,
              child: Tautan(
                ke: Layar.laporan,
                label: _tautan,
                child: const SizedBox.expand(),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The statement box: the whole bordered box toggles the checkbox.
class _Pernyataan extends StatelessWidget {
  const _Pernyataan({
    required this.teks,
    required this.nilai,
    required this.onUbah,
  });
  final String teks;
  final bool nilai;
  final ValueChanged<bool> onUbah;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: () => onUbah(!nilai),
      tercentang: nilai,
      radius: 14,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: c.tinta, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            SizedBox.square(
              dimension: 24,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: nilai ? c.laut : c.permukaan,
                  border: nilai
                      ? null
                      : Border.all(color: c.garisTegas, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: nilai
                    ? Center(
                        child: PalakatIkon(
                          Ikon.centang,
                          ukuran: 16,
                          warna: c.diLaut,
                        ),
                      )
                    : null,
              ),
            ),
            Expanded(
              child: Text(
                teks,
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
  }
}

class _Proses extends StatelessWidget {
  const _Proses({super.key});

  @override
  Widget build(BuildContext context) => Gerak(
    Kerangka.pudar,
    lama: const Duration(milliseconds: 200),
    child: SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 18,
        children: [
          const Putar(child: PalakatIkon(Ikon.cincinProses, ukuran: 56)),
          Semantics(
            liveRegion: true,
            child: const Text(
              'Sedang menutup buku…',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Gagal extends StatelessWidget {
  const _Gagal({super.key, required this.p});
  final _Papan p;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Gerak(
      Kerangka.pudar,
      lama: const Duration(milliseconds: 200),
      child: _penuh(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            Semantics(
              header: true,
              child: const Text(
                'Tutup buku tidak terjadi: ada perubahan sejak ringkasan ini ditampilkan.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
            if (p.tolak != null)
              Penolakan(
                tindakan: p.tolak!.action,
                sebab: p.tolak!.because,
                jalan: const [],
              ),
            Text(
              'Bulan ini tetap belum ditutup. Mohon lihat hambatan yang baru muncul.',
              style: TextStyle(fontSize: 15, color: c.tinta2),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Tombol(
                'Lihat hambatan',
                onPressed: p.keCek,
                jenis: JenisTombol.tinta,
                paddingH: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- G. Ditutup

class _Ditutup extends ConsumerWidget {
  const _Ditutup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final p = _Lingkup.of(context);
    final per = _terakhirDitutup(ref.watch(bulanBukuProvider).semua);
    if (per == null) return const SizedBox.shrink();
    final nama = namaBulan(per);
    final oleh = ref.watch(peopleRepositoryProvider).person(per.closedBy ?? '');
    final kecil = TextStyle(fontSize: 13, color: c.diTinta2);
    Widget unduh(String label, String bentuk) => _muncul(
      kunci: bentuk,
      Tombol(
        label,
        onPressed: null,
        ke: Layar.laporanResmi,
        param: {'periode': per.id, 'bentuk': bentuk},
        ukuran: UkuranTombol.kecil,
        paddingH: 14,
        lebarPenuh: false,
      ),
    );
    return Gerak(
      Kerangka.gelap((w) => w.kertas),
      lama: const Duration(milliseconds: 700),
      kurva: Curves.easeOut,
      child: SizedBox.expand(
        child: DefaultTextStyle.merge(
          style: TextStyle(color: c.permukaan),
          child: _penuh(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 18,
              children: [
                const Center(child: SegelGembok()),
                _muncul(
                  ms: 400,
                  tunda: 1400,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Buku bulan $nama sudah ditutup.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ),
                      Text(
                        'Angka laporan resmi sudah dibekukan · ${per.snapshotId}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: c.diTinta2),
                      ),
                      Text(
                        'Dikonfirmasi oleh ${oleh?.shortName ?? oleh?.name} · '
                        '${per.closedAt == null ? '' : tglJam(per.closedAt!)}',
                        textAlign: TextAlign.center,
                        style: kecil,
                      ),
                    ],
                  ),
                ),
                _muncul(
                  ms: 400,
                  tunda: 1700,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: c.permukaan,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(color: c.tinta),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _BarisFile(
                            judul: 'Laporan resmi · PDF',
                            status: 'Siap diunduh',
                            aksi: unduh('Unduh PDF', 'f01'),
                          ),
                          _BarisFile(
                            judul: 'Laporan resmi · Excel',
                            garisAtas: true,
                            status: 'Siap diunduh',
                            aksi: unduh('Unduh Excel', 'excel'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                _muncul(
                  ms: 400,
                  tunda: 1900,
                  _tombol(
                    'Kembali ke Bulan',
                    onTap: p.keBulan,
                    isi: null,
                    teks: c.permukaan,
                    garis: c.permukaan,
                    tinggi: 52,
                    radius: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarisFile extends StatelessWidget {
  const _BarisFile({
    required this.judul,
    required this.status,
    this.aksi,
    this.garisAtas = false,
  });
  final String judul, status;
  final Widget? aksi;
  final bool garisAtas;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    // The board's min height 60 is content-box: the 1 px rule adds to it.
    return Container(
      constraints: BoxConstraints(minHeight: garisAtas ? 61 : 60),
      padding: EdgeInsets.only(top: garisAtas ? 1 : 0),
      decoration: garisAtas
          ? BoxDecoration(
              border: Border(top: BorderSide(color: c.garis)),
            )
          : null,
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(status, style: TextStyle(fontSize: 13, color: c.tinta2)),
              ],
            ),
          ),
          ?aksi,
        ],
      ),
    );
  }
}
