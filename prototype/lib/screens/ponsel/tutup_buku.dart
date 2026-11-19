import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../mock/format.dart';
import '../../mock/mock.dart' show plk2;
import '../../motion/hitung.dart';
import '../../motion/kerangka.dart';
import '../../motion/ulang.dart';
import '../../motion/urutan.dart';
import '../../shell/kendali.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

const _stem = 'TutupBuku';
const _akar = '/TutupBuku';
const _cek = '/TutupBuku/cek';

const _syarat = [
  'bulan sebelumnya sudah ditutup',
  'semua 3 kas/bank sudah direkonsiliasi',
  'Mata Anggaran sudah dipilih untuk semua transaksi',
  'persetujuan yang wajib sudah dicatat',
  'dokumen pendukung wajib sudah terverifikasi atau dikecualikan',
  'tidak ada transaksi Draf atau Sudah diperiksa',
  'tidak ada baris impor yang tertunda',
  'persetujuan format laporan sudah dicatat',
];

typedef _Hambatan = ({String j, String s, String tombol, VoidCallback aksi});

enum _Fase { konfirmasi, proses, gagal }

enum _File { siap0, siap, gagal }

/// The board's state object, shared by `/TutupBuku` and its child routes.
class _Papan extends ChangeNotifier {
  late GoRouter router;

  bool perjalanan = false, biaya = false, pasti = false, centang = false;
  bool tutup = false, sudahGagal = false, drafBaru = false;
  _File pdf = _File.siap0, xls = _File.siap0;
  _Fase fase = _Fase.konfirmasi;
  Timer? _t2, _t4, _t5;

  void _ubah(void Function() f) {
    f();
    notifyListeners();
  }

  int get selisih =>
      (24615000 - (biaya ? 15000 : 0)) - (24100000 + (perjalanan ? 500000 : 0));

  List<_Hambatan> get hambatan => [
    if (!pasti)
      (
        j: 'Bank BNI ··4821 belum direkonsiliasi',
        s: selisih == 0
            ? 'Selisih sudah Rp0, rekonsiliasi belum dipastikan'
            : 'Selisih belum dijelaskan ${rp(selisih)}',
        tombol: 'Buka rekonsiliasi',
        aksi: () => router.push('$_akar/rekonsiliasi'),
      ),
    if (drafBaru)
      (
        j: '1 transaksi Draf bertanggal Oktober 2026',
        s: 'Fotokopi liturgi · Rp85.000 · bukukan, pindah tanggal atau batalkan',
        tombol: 'Buka draf',
        aksi: () => _ubah(() => drafBaru = false),
      ),
  ];

  /// Pops down to [lokasi] when it is in the stack; otherwise pops to
  /// `/TutupBuku` and pushes it (a child URL opened directly).
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
      fase = _Fase.konfirmasi;
    });
    router.push('$_akar/konfirmasi');
  }

  void rekon({bool? perjalanan, bool? biaya}) => _ubah(() {
    pasti = false;
    this.perjalanan = perjalanan ?? this.perjalanan;
    this.biaya = biaya ?? this.biaya;
  });

  void pastikan() => _ubah(() => pasti = true);
  void ubahCentang(bool v) => _ubah(() => centang = v);

  void tutupBuku(bool gagalTweak) {
    final gagal = gagalTweak && !sudahGagal;
    _ubah(() => fase = _Fase.proses);
    _t2?.cancel();
    _t2 = Timer(const Duration(milliseconds: 1500), () {
      if (gagal) {
        _ubah(() {
          fase = _Fase.gagal;
          sudahGagal = true;
          drafBaru = true;
          centang = false;
        });
        return;
      }
      _ubah(() {
        tutup = true;
        pdf = xls = _File.siap0;
      });
      _naik(_akar);
      router.push('$_akar/ditutup');
      _t4?.cancel();
      _t4 = Timer(const Duration(milliseconds: 3600), _fileSelesai);
    });
  }

  void _fileSelesai() => _ubah(() {
    pdf = _File.siap;
    xls = _File.gagal;
  });

  /// `/TutupBuku/ditutup` opened directly (01-main.md, Internal views).
  void masukDitutup() {
    if (!tutup) _ubah(() => tutup = true);
    if (pdf == _File.siap0 && !(_t4?.isActive ?? false)) {
      _t4 = Timer(const Duration(milliseconds: 3600), _fileSelesai);
    }
  }

  void xlsCoba() {
    _ubah(() => xls = _File.siap0);
    _t5?.cancel();
    _t5 = Timer(
      const Duration(milliseconds: 1800),
      () => _ubah(() => xls = _File.siap),
    );
  }

  void _batalWaktu() {
    _t2?.cancel();
    _t4?.cancel();
    _t5?.cancel();
  }

  void ulang() {
    _batalWaktu();
    _ubah(() {
      perjalanan = biaya = pasti = centang = false;
      tutup = sudahGagal = drafBaru = false;
      pdf = xls = _File.siap0;
      fase = _Fase.konfirmasi;
    });
  }

  @override
  void dispose() {
    _batalWaktu();
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
  int _generasi = 0;

  @override
  void initState() {
    super.initState();
    ulangPapan[_stem] = _ulang;
  }

  void _ulang() {
    _papan.ulang();
    setState(() => _generasi++);
  }

  @override
  void dispose() {
    if (ulangPapan[_stem] == _ulang) ulangPapan.remove(_stem);
    _papan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _papan.router = GoRouter.of(context);
    return LayarPonsel(
      jabatanKosong: true,
      child: _Lingkup(
        papan: _papan,
        child: GenerasiPapan(generasi: _generasi, child: widget.child),
      ),
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

Widget _tautan({required String ke, required String teks}) => Tautan(
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

class _Bulan extends StatefulWidget {
  const _Bulan();
  @override
  State<_Bulan> createState() => _BulanState();
}

class _BulanState extends State<_Bulan> {
  /// The closed October card has played `cap` (it plays once, when Bulan is
  /// seen again after the close).
  bool _capDiputar = false;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = _Lingkup.of(context);
    final jk = context.prototipe.jabatanKosong;
    final terlihat = ModalRoute.of(context)?.isCurrent ?? true;
    final nHambatan = p.hambatan.length;
    final kartuTutup = p.tutup && (terlihat || _capDiputar);
    if (kartuTutup) _capDiputar = true;
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
              _KartuBulan(
                bulan: 'November 2026',
                garis: Border.all(color: c.garis),
                anak: [
                  Text(
                    p.tutup
                        ? 'Berikutnya untuk tutup buku · bulan berjalan'
                        : 'Bulan berjalan · menunggu Oktober ditutup',
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Tombol(
                      'Hitung kas · Kas belum dihitung',
                      onPressed: null,
                      ke: 'HitungKas',
                      jenis: JenisTombol.kedua,
                      ukuran: UkuranTombol.kecil,
                      paddingH: 0,
                    ),
                  ),
                ],
              ),
              if (kartuTutup)
                Gerak(
                  Kerangka.capSegel,
                  key: const ValueKey('oktober-tutup'),
                  lama: const Duration(milliseconds: 500),
                  kurva: PalakatMotion.keluar,
                  child: _KartuTutup(
                    bulan: 'Oktober 2026',
                    teks:
                        'Periode laporan 1–31 Oktober 2026 · ditutup oleh ${plk2(jk)}, 16/11/2026 11.05',
                  ),
                )
              else if (!p.tutup)
                _KartuBulan(
                  bulan: 'Oktober 2026',
                  garis: Border.all(color: c.tinta, width: 2),
                  anak: [
                    Text(
                      'Berikutnya untuk tutup buku · '
                      '${nHambatan > 0 ? '$nHambatan hambatan' : 'tidak ada hambatan'}',
                      style: TextStyle(fontSize: 14, color: c.tinta2),
                    ),
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
                ),
              const _KartuTutup(
                bulan: 'September 2026',
                teks: 'Periode laporan 15–30 September 2026, sejak tanggal mulai pencatatan',
              ),
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

/// A closed month: the `ditutup` (tinta) card.
class _KartuTutup extends StatelessWidget {
  const _KartuTutup({required this.bulan, required this.teks});
  final String bulan, teks;

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
              bulan,
              const LencanaStatus(
                'Sudah ditutup',
                bentuk: BentukLencana.terbalik,
              ),
            ),
            Text(teks, style: TextStyle(fontSize: 14, color: c.diTinta2)),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Laporan resmi · PDF · Excel',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- B. Cek

class _Cek extends StatelessWidget {
  const _Cek();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = _Lingkup.of(context);
    final hambatan = p.hambatan;
    final kosong = hambatan.isEmpty;
    return ColoredBox(
      color: c.kertas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(judul: 'Tutup buku Oktober 2026', onKembali: p.keBulan),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: [
                  DeretTautan(
                    anak: [
                      _tautan(ke: 'Kesiapan', teks: 'Pernyataan kesiapan'),
                      _tautan(ke: 'AIBulan', teks: 'Bantuan AI'),
                      _tautan(ke: 'Kejadian', teks: 'Kejadian'),
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
                                  h.j,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  h.s,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: c.tinta2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Tombol(
                                    h.tombol,
                                    onPressed: h.aksi,
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
                        child: const Row(
                          spacing: 12,
                          children: [
                            PalakatIkon(Ikon.terpenuhi, ukuran: 26),
                            Expanded(
                              child: Text(
                                'Tidak ada hambatan. Oktober 2026 siap ditutup.',
                                style: TextStyle(
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
                      for (final (i, t) in _syarat.indexed)
                        _syaratBaris(c, p, i, t),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 6,
                    children: [
                      const JudulBagian('Untuk diketahui'),
                      Text(
                        'Tidak menghalangi tutup buku.',
                        style: TextStyle(fontSize: 13, color: c.tinta3),
                      ),
                      for (final d in [
                        '2 uang muka dengan sisa belum dipertanggungjawabkan',
                        if (p.perjalanan) '1 setoran dalam perjalanan (belum tercatat di rekening koran)',
                      ])
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
          if (kosong)
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

  Widget _syaratBaris(PalakatWarna c, _Papan p, int i, String t) {
    final no = (i == 1 && !p.pasti) || (i == 5 && p.drafBaru);
    final teks = i == 1 && !p.pasti
        ? '2 dari 3 kas/bank sudah direkonsiliasi'
        : i == 5 && p.drafBaru
        ? 'masih ada 1 transaksi Draf'
        : t;
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
              teks,
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

class _Rekon extends StatelessWidget {
  const _Rekon();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = _Lingkup.of(context);
    final nol = p.selisih == 0;
    final (bg, fg, bd) = p.pasti
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
        p.pasti ? 'Sudah dipastikan' : 'Sedang dikerjakan',
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
    return ColoredBox(
      color: c.kertas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Rekonsiliasi',
            anakJudul: 'Bank BNI ··4821 · Oktober 2026',
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
                      _tautan(ke: 'RekonIsi', teks: 'Isi rekening koran'),
                      _tautan(ke: 'HitungKas', teks: 'Hitung kas'),
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
                        ringkas(
                          'Saldo buku',
                          rp(24615000 - (p.biaya ? 15000 : 0)),
                        ),
                        ringkas('Saldo rekening koran', 'Rp24.100.000'),
                        if (p.perjalanan)
                          _muncul(
                            kunci: 'ringkas-perjalanan',
                            ringkas('Setoran dalam perjalanan', '+ Rp500.000'),
                          ),
                        ringkas(
                          'Saldo pembanding',
                          rp(24100000 + (p.perjalanan ? 500000 : 0)),
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
                                nilai: p.selisih,
                                builder: (ctx, n) => AnimatedDefaultTextStyle(
                                  duration: ctx.gerak(
                                    const Duration(milliseconds: 300),
                                  ),
                                  curve: Curves.ease,
                                  style: _mono.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: n == 0 ? c.laut : c.bata,
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
                  if (!p.perjalanan || !p.biaya)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 10,
                      children: [
                        const JudulBagian('Belum cocok'),
                        if (!p.perjalanan)
                          _BelumCocok(
                            jenis: 'Transaksi · belum ada di rekening koran',
                            judul: 'Setoran ke bank',
                            jumlah: 'Rp500.000',
                            rinci: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'BKU-2026-0131',
                                    style: _mono.copyWith(
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const TextSpan(text: ' · 31/10/2026'),
                                ],
                              ),
                            ),
                            tombol: 'Tandai dalam perjalanan',
                            aksi: () => p.rekon(perjalanan: true),
                            catatan: 'Dibawa ke bulan berikutnya',
                          ),
                        if (!p.biaya)
                          _BelumCocok(
                            jenis: 'Mutasi bank · belum ada transaksinya',
                            judul: 'BIAYA ADM',
                            jumlah: '−Rp15.000',
                            rinci: const Text(
                              '31/10/2026 · sisa belum dicocokkan: Rp15.000',
                            ),
                            tombol: 'Buat transaksi dari mutasi ini',
                            aksi: () => p.rekon(biaya: true),
                            catatan:
                                'Belanja 5.03.03.00 Biaya administrasi bank',
                          ),
                      ],
                    ),
                  if (p.perjalanan)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 10,
                      children: [
                        const JudulBagian('Dalam perjalanan'),
                        _muncul(
                          kunci: 'kartu-perjalanan',
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
                                      const Text(
                                        'Setoran dalam perjalanan',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Rp500.000 · dibawa ke November 2026',
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
                                  onPressed: () => p.rekon(perjalanan: false),
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
                                text: '· ${p.biaya ? 13 : 12} mutasi bank',
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
                      if (p.biaya) const _PasanganCocok(),
                      Text(
                        '12 mutasi bank lain sudah cocok dengan transaksinya.',
                        style: TextStyle(fontSize: 14, color: c.tinta2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _kaki(context, [
            if (!nol)
              Text(
                'Selisih belum dijelaskan harus Rp0 sebelum rekonsiliasi dapat dipastikan.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            if (nol && !p.pasti)
              _muncul(
                kunci: 'pastikan',
                Tombol(
                  'Pastikan rekonsiliasi',
                  onPressed: p.pastikan,
                  paddingH: 6,
                ),
              ),
            if (p.pasti)
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

/// The matched pair after "Buat transaksi dari mutasi ini" (`kait`).
class _PasanganCocok extends StatelessWidget {
  const _PasanganCocok();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
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
          _baris(judul, const Text('−Rp15.000', style: _mono)),
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
              child: kartu(const Text('Mutasi bank'), 'BIAYA ADM'),
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
                        text: 'BKU-2026-0133',
                        style: _mono.copyWith(fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                'Biaya administrasi bank',
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

class _Konfirmasi extends StatelessWidget {
  const _Konfirmasi();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = _Lingkup.of(context);
    final jk = context.prototipe.jabatanKosong;
    final Widget isi = switch (p.fase) {
      _Fase.proses => const _Proses(key: ValueKey('proses')),
      _Fase.gagal => _Gagal(key: const ValueKey('gagal'), p: p),
      _Fase.konfirmasi => _isiKonfirmasi(context, c, p, jk),
    };
    return PopScope(
      canPop: p.fase != _Fase.proses,
      child: ColoredBox(color: c.permukaan, child: isi),
    );
  }

  Widget _isiKonfirmasi(
    BuildContext context,
    PalakatWarna c,
    _Papan p,
    bool jk,
  ) {
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
                      child: const Text(
                        'Tutup buku bulan Oktober 2026?',
                        style: TextStyle(
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
                    for (final t in _syarat)
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
                                t,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
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
                      const Text(
                        '2 uang muka dengan sisa belum dipertanggungjawabkan; 1 setoran dalam perjalanan (belum tercatat di rekening koran)',
                      ),
                    ],
                  ),
                ),
                const _Cakupan(),
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
                      for (final t in const [
                        'Buku bulan Oktober 2026 menjadi final untuk semua pengguna, siapa pun.',
                        'Transaksi Oktober 2026 tidak dapat diubah, dibalik, atau dikoreksi, bahkan dari bulan-bulan sesudahnya.',
                        'Laporan resmi Oktober 2026 dibekukan dan tidak akan berubah.',
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
                      const Text(
                        'Melampirkan dokumen pendukung yang datang terlambat. Dokumen itu tetap disimpan, tetapi laporan resmi Oktober 2026 tidak berubah.',
                      ),
                    ],
                  ),
                ),
                if (jk)
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
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'Ditutup oleh '),
                          TextSpan(
                            text: 'Yanti Sumual, Operator',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: ', yang menjalankan jabatan kosong Bendahara Jemaat. Nama dan keadaan ini tercatat pada tutup buku.',
                          ),
                        ],
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                _Pernyataan(nilai: p.centang, onUbah: p.ubahCentang),
              ],
            ),
          ),
        ),
        _kaki(context, jarak: 6, [
          TombolTahan(
            'Tutup buku Oktober 2026',
            siap: p.centang,
            onSelesai: () => p.tutupBuku(
              PrototypeState.maybeOf(
                    context,
                    dengar: false,
                  )?.tweak(_stem, 'gagalDiCekTerakhir') ==
                  true,
            ),
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
  const _Cakupan();

  static const _tautan = 'Lihat laporan sementara';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final gaya = DefaultTextStyle.of(context).style
        .merge(const TextStyle(fontSize: 14));
    const a = 'Laporan resmi mencakup ', b = '1–31 Oktober 2026';
    // U+2060: Chrome keeps "kas/bank." together; ICU would break after "/".
    const d =
        ' untuk seluruh Jemaat: semua peruntukan dan semua kas/\u2060bank. ';
    const awal = a.length + b.length + d.length;
    final span = TextSpan(
      style: gaya,
      children: [
        const TextSpan(text: a),
        const TextSpan(
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
              const TextSelection(
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
                ke: 'Laporan',
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
  const _Pernyataan({required this.nilai, required this.onUbah});
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
                          tebal: 3,
                        ),
                      )
                    : null,
              ),
            ),
            const Expanded(
              child: Text(
                'Saya sudah membaca ringkasan dan laporan sementara. Saya mengerti bahwa tutup buku ini bersifat permanen dan transaksi Oktober 2026 tidak dapat dikoreksi lagi.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
            const Align(
              alignment: Alignment.centerLeft,
              child: LencanaStatus(
                'Oktober 2026 · Belum ditutup',
                bentuk: BentukLencana.garis,
              ),
            ),
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
            Text(
              'Bulan Oktober 2026 tetap belum ditutup. Mohon lihat hambatan yang baru muncul.',
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

class _Ditutup extends StatefulWidget {
  const _Ditutup();
  @override
  State<_Ditutup> createState() => _DitutupState();
}

class _DitutupState extends State<_Ditutup> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .getInheritedWidgetOfExactType<_Lingkup>()
          ?.notifier
          ?.masukDitutup();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = _Lingkup.of(context);
    final jk = context.prototipe.jabatanKosong;
    final kecil = TextStyle(fontSize: 13, color: c.diTinta2);
    Widget unduh(String label, {required String ke}) => _muncul(
      kunci: ke,
      Tombol(
        label,
        onPressed: null,
        ke: ke,
        ukuran: UkuranTombol.kecil,
        paddingH: 14,
        lebarPenuh: false,
      ),
    );
    final xlsGagal = p.xls == _File.gagal;
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
                        child: const Text(
                          'Buku bulan Oktober 2026 sudah ditutup.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ),
                      Text(
                        'Angka laporan resmi sudah dibekukan; file laporannya sedang disiapkan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: c.diTinta2),
                      ),
                      Text(
                        'Dikonfirmasi oleh ${plk2(jk)} · 16/11/2026 11.05',
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
                            status: p.pdf == _File.siap
                                ? 'Siap diunduh'
                                : 'Sedang disiapkan',
                            aksi: p.pdf == _File.siap
                                ? unduh('Unduh PDF', ke: 'A4F01')
                                : null,
                          ),
                          _BarisFile(
                            judul: 'Laporan resmi · Excel',
                            garisAtas: true,
                            status: xlsGagal
                                ? 'File gagal dibuat'
                                : p.xls == _File.siap
                                ? 'Siap diunduh'
                                : 'Sedang disiapkan',
                            gagal: xlsGagal,
                            aksi: xlsGagal
                                ? Tombol(
                                    'Coba lagi',
                                    onPressed: p.xlsCoba,
                                    jenis: JenisTombol.garisBata,
                                    ukuran: UkuranTombol.kecil,
                                    paddingH: 14,
                                    lebarPenuh: false,
                                  )
                                : p.xls == _File.siap
                                ? unduh('Unduh Excel', ke: 'WebExcel')
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _muncul(
                  ms: 400,
                  tunda: 1900,
                  Text(
                    'File yang gagal dibuat cukup dibuat lagi dari angka yang sama. Tutup buku tetap berlaku.',
                    textAlign: TextAlign.center,
                    style: kecil,
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
    this.gagal = false,
    this.garisAtas = false,
  });
  final String judul, status;
  final Widget? aksi;
  final bool gagal, garisAtas;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
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
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    color: gagal ? c.bata : c.tinta2,
                    fontWeight: gagal ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          ?aksi,
        ],
      ),
    );
  }
}
