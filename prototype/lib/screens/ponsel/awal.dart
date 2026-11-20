import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../motion/kerangka.dart';
import '../../motion/ulang.dart';
import '../../motion/urutan.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/batang_pembagian.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/input_format.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/logo.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

const _kas = 3200000;

/// (key, name) of the three peruntukan rows; colours by index.
const _kunci = [
  ('umum', 'Umum Jemaat'),
  ('diak', 'Diakonia'),
  ('bang', 'Pembangunan'),
];
const _awalBagi = {'umum': '2.000.000', 'diak': '700.000', 'bang': ''};

/// The board's state object (02-awal.md, "Board-level state survives child
/// routes"): wewenang, opn and the three split fields. The fields' raw digits
/// are their text without the thousand dots.
class _Awal extends ChangeNotifier {
  _Awal() {
    for (final c in bagi.values) {
      c.addListener(notifyListeners);
    }
  }

  String wewenang = 'belum';
  bool opn = false;
  final bagi = {
    for (final k in _kunci) k.$1: TextEditingController(text: _awalBagi[k.$1]),
  };
  final fokus = {for (final k in _kunci) k.$1: FocusNode()};
  Timer? _t;

  bool get aktif => wewenang == 'aktif';
  bool get tunggu => wewenang == 'tunggu';
  String mentah(String k) => bagi[k]!.text.replaceAll('.', '');
  int _num(String k) => mentah(k).isEmpty ? 0 : int.parse(mentah(k));
  int get jumlah => _kunci.fold(0, (a, k) => a + _num(k.$1));
  int get sisa => _kas - jumlah;
  bool get adaKosong => _kunci.any((k) => mentah(k.$1).isEmpty);
  bool get pas => sisa == 0 && !adaKosong;

  void ulang() {
    _t?.cancel();
    wewenang = 'belum';
    opn = false;
    for (final k in _kunci) {
      bagi[k.$1]!.text = _awalBagi[k.$1]!;
    }
    notifyListeners();
  }

  void kirim() {
    wewenang = 'tunggu';
    notifyListeners();
    _t?.cancel();
    _t = Timer(const Duration(milliseconds: 2800), () {
      wewenang = 'aktif';
      notifyListeners();
    });
  }

  void isi(String k, int n) => bagi[k]!.text = titik('$n');

  void bukukan() {
    opn = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _t?.cancel();
    for (final c in bagi.values) {
      c.dispose();
    }
    for (final f in fokus.values) {
      f.dispose();
    }
    super.dispose();
  }
}

class _Lingkup extends InheritedNotifier<_Awal> {
  const _Lingkup({required _Awal super.notifier, required super.child});
}

_Awal _awal(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<_Lingkup>()!.notifier!;

class AwalKendali extends StatefulWidget {
  const AwalKendali({super.key, required this.child});
  final Widget child;
  @override
  State<AwalKendali> createState() => _AwalKendaliState();
}

class _AwalKendaliState extends State<AwalKendali> {
  final _k = _Awal();

  @override
  void dispose() {
    _k.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayarPonsel(
    child: _Lingkup(notifier: _k, child: widget.child),
  );
}

class AwalScreen extends StatelessWidget {
  const AwalScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.warna.kertas,
    child: switch (anak) {
      'tunjuk' => const _Tunjuk(),
      'saldo' => const _Saldo(),
      _ => const _Langkah(),
    },
  );
}

// ── shared pieces ──────────────────────────────────────────────────────────

List<Widget> _jarak(double h, List<Widget> anak) => [
  for (var i = 0; i < anak.length; i++) ...[
    if (i > 0) SizedBox(height: h),
    anak[i],
  ],
];

BoxDecoration _kartu(PalakatWarna c, double r) => BoxDecoration(
  color: c.permukaan,
  border: Border.all(color: c.garis),
  borderRadius: BorderRadius.circular(r),
);

Border? _garisAtas(PalakatWarna c, int i) =>
    i == 0 ? null : Border(top: BorderSide(color: c.garis));

/// Bottom action bar: `permukaan`, top 1 `garis`, padding 12 20 22.
Widget _bawah(PalakatWarna c, List<Widget> anak) => Container(
  padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
  decoration: BoxDecoration(
    color: c.permukaan,
    border: Border(top: BorderSide(color: c.garis)),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: _jarak(8, anak),
  ),
);

const _muncul = Duration(milliseconds: 300);

// ── view langkah (/Awal) ───────────────────────────────────────────────────

class _Langkah extends StatelessWidget {
  const _Langkah();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = _awal(context);
    final aktif = k.aktif, tunggu = k.tunggu;
    // (title, subtitle, state, child route)
    final daftar = <(String, String, String, String?)>[
      ('Identitas Jemaat', 'WITA · tahun buku mulai 1 Januari', 'ok', null),
      (
        'Kas/Bank, peruntukan, Lingkup',
        '3 Kas/Bank · 3 peruntukan · 4 Lingkup',
        'ok',
        null,
      ),
      (
        'Mata Anggaran',
        'Versi 2026.1 diterbitkan · berlaku mulai September 2026',
        'ok',
        null,
      ),
      (
        'Penunjukan Bendahara',
        aktif
            ? 'Wewenang Bendahara aktif'
            : tunggu
            ? 'Menunggu verifikasi wewenang · Petugas verifikasi'
            : 'Giliran Anda: kirim surat penunjukan',
        aktif
            ? 'ok'
            : tunggu
            ? 'tunggu'
            : 'kini',
        'tunjuk',
      ),
      (
        'Saldo awal pencatatan',
        k.opn
            ? 'Dibukukan · OPN-2026-0001'
            : aktif
            ? 'Giliran Anda: bagi saldo ke peruntukan'
            : 'Terbuka setelah wewenang Bendahara aktif',
        k.opn
            ? 'ok'
            : aktif
            ? 'kini'
            : 'kunci',
        'saldo',
      ),
      (
        'Persetujuan format laporan',
        'Pimpinan Jemaat yang berwenang · wajib sebelum tutup buku pertama',
        'nanti',
        null,
      ),
    ];
    final selesai = daftar.where((l) => l.$3 == 'ok').length;
    final alasan = aktif
        ? 'Tinggal satu langkah: bukukan saldo awal pencatatan.'
        : tunggu
        ? 'Menunggu Petugas verifikasi memeriksa penunjukan Bendahara.'
        : 'Kirim surat penunjukan Bendahara untuk diverifikasi.';

    return Gerak(
      Kerangka.pudar,
      lama: const Duration(milliseconds: 200),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _jarak(18, [
            const Row(
              children: [
                TandaPalakat(),
                SizedBox(width: 10),
                KataPalakat(ukuran: 17, tinggiBaris: 1.4),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: const Text(
                    'Pengaturan awal Jemaat',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jemaat Karunia · $selesai dari 6 langkah selesai',
                  style: TextStyle(fontSize: 15, color: c.tinta2),
                ),
              ],
            ),
            // `display: flex` <a>: the target spans the column's width.
            const Tautan(
              ke: Layar.awalIsian,
              child: Align(
                alignment: Alignment.centerLeft,
                child: TautanTeks(
                  'Isi identitas, Kas/Bank, peruntukan dan Lingkup',
                  berat: FontWeight.w700,
                  ukuran: 15,
                ),
              ),
            ),
            if (!k.opn)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: ShapeDecoration(
                  shape: GarisBorder.putus(c.putus, radius: 14),
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Belum ada tindakan keuangan yang tersedia.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.tinta,
                        ),
                      ),
                      TextSpan(text: ' $alasan'),
                    ],
                  ),
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
              )
            else
              Gerak(
                Kerangka.muncul,
                key: const ValueKey('siap'),
                lama: _muncul,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.tinta,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _jarak(10, [
                      Text(
                        'Jemaat siap mencatat.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.permukaan,
                        ),
                      ),
                      Text(
                        'Pencatatan dimulai 15 September 2026. Persetujuan '
                        'format laporan masih perlu dicatat sebelum tutup '
                        'buku pertama.',
                        style: TextStyle(fontSize: 14, color: c.diTinta2),
                      ),
                      Tautan(
                        ke: Layar.keuangan,
                        cara: Cara.ganti,
                        radius: 12,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 48),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: c.permukaan,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Mulai mencatat',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: c.tinta,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _kartu(c, 16),
              child: Column(
                children: [
                  for (var i = 0; i < daftar.length; i++)
                    _BarisLangkah(nomor: i + 1, l: daftar[i]),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _BarisLangkah extends StatelessWidget {
  const _BarisLangkah({required this.nomor, required this.l});
  final int nomor;
  final (String, String, String, String?) l;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final (judul, sub, st, ke) = l;
    final bisa = ke != null && (st == 'kini' || st == 'tunggu' || st == 'ok');
    return Tekan(
      onTap: bisa ? () => context.dorongKe(Layar.awal, anak: ke) : null,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(border: _garisAtas(c, nomor - 1)),
        child: Row(
          children: [
            _Bulat(st: st, nomor: nomor, ukuran: 34, teks: 15),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: st == 'kunci' ? c.tinta3 : c.tinta,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 13,
                      color: st == 'kini' ? c.laut : c.tinta3,
                      fontWeight: st == 'kini'
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (bisa) ...[
              const SizedBox(width: 14),
              PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
            ],
          ],
        ),
      ),
    );
  }
}

/// Step circle. `ok` laut "✓", `kini` tinta, `tunggu` dashed tinta,
/// `kunci`/`nanti` dashed putus. The dashed ones are content-box on the
/// board: [ukuran] + 2 × 1.5.
class _Bulat extends StatelessWidget {
  const _Bulat({
    required this.st,
    required this.nomor,
    required this.ukuran,
    required this.teks,
  });
  final String st;
  final int nomor;
  final double ukuran, teks;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final (Color? isi, Color? garis, Color fg) = switch (st) {
      'ok' => (c.laut, null, c.diLaut),
      'kini' => (c.tinta, null, c.permukaan),
      'tunggu' => (null, c.tinta, c.tinta),
      _ => (null, c.putus, c.tinta3),
    };
    final sisi = garis == null ? ukuran : ukuran + 3;
    return Container(
      width: sisi,
      height: sisi,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: isi,
        shape: garis == null
            ? const CircleBorder()
            : GarisBorder.putus(garis, radius: sisi / 2),
      ),
      child: Text(
        st == 'ok' ? '✓' : '$nomor',
        style: TextStyle(
          fontFamily: PalakatText.mono,
          fontWeight: FontWeight.w600,
          fontSize: teks,
          color: fg,
        ),
      ),
    );
  }
}

// ── view tunjuk (/Awal/tunjuk) ─────────────────────────────────────────────

class _Tunjuk extends StatelessWidget {
  const _Tunjuk();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = _awal(context);
    final (judul, teks) = switch (k.wewenang) {
      'tunggu' => (
        'Menunggu verifikasi wewenang',
        'Petugas verifikasi sedang memeriksa surat penunjukan. Sampai '
            'selesai, belum ada tindakan keuangan yang tersedia.',
      ),
      'aktif' => (
        'Wewenang Bendahara aktif',
        'Anda sekarang dapat mencatat, membukukan dan menutup buku untuk '
            'Jemaat Karunia.',
      ),
      _ => (
        'Belum dikirim',
        'Kirim surat penunjukan dari BPMJ untuk diverifikasi.',
      ),
    };
    final Widget ikon = switch (k.wewenang) {
      'tunggu' => const Putar(
        periode: Duration(seconds: 6),
        child: PalakatIkon(Ikon.lingkarTunggu, ukuran: 88),
      ),
      'aktif' => const LingkarSelesai(key: ValueKey('aktif')),
      _ => const PalakatIkon(Ikon.lingkarBelum, ukuran: 88),
    };
    final fakta = [
      ('Yang ditunjuk', 'Meiske Lumentut'),
      ('Yang menunjuk', 'BPMJ Jemaat Karunia'),
      ('Surat penunjukan', 'SK-BPMJ-04-2026.pdf · Terlampir'),
      (
        'Diverifikasi oleh',
        k.aktif ? 'Petugas verifikasi · 15/09/2026' : 'Belum diverifikasi',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaPonsel(
          judul: 'Penunjukan Bendahara',
          kembaliKe: Layar.awal,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _jarak(18, [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Column(
                    children: _jarak(12, [
                      ExcludeSemantics(child: ikon),
                      Semantics(
                        container: true,
                        liveRegion: true,
                        child: Text(
                          judul,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        teks,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: c.tinta2),
                      ),
                    ]),
                  ),
                ),
                _KartuFakta(baris: fakta, padding: 12, nilaiMono: false),
                Text(
                  'Akses teknis ke aplikasi saja tidak memberi wewenang '
                  'Bendahara. Wewenang hanya berasal dari keputusan Jemaat '
                  'yang sudah diverifikasi.',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ]),
            ),
          ),
        ),
        _bawah(c, [
          switch (k.wewenang) {
            'tunggu' => Container(
              constraints: const BoxConstraints(minHeight: 52),
              alignment: Alignment.center,
              child: Text(
                'Menunggu Petugas verifikasi. Tidak ada yang perlu Anda '
                'lakukan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ),
            'aktif' => const Gerak(
              Kerangka.muncul,
              key: ValueKey('lanjut'),
              lama: _muncul,
              child: Tombol(
                'Lanjut ke saldo awal pencatatan',
                onPressed: null,
                ke: Layar.awal,
                cara: Cara.naik,
              ),
            ),
            _ => Tombol('Kirim untuk diverifikasi', onPressed: k.kirim),
          },
        ]),
      ],
    );
  }
}

/// Key–value card: `permukaan`, 1 `garis`, radius 14, padding 4 16; rows
/// [padding] × 0 with a divider from row 2, key 14 `tinta2`.
class _KartuFakta extends StatelessWidget {
  const _KartuFakta({
    required this.baris,
    required this.padding,
    required this.nilaiMono,
  });
  final List<(String, String)> baris;
  final double padding;
  final bool nilaiMono;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: _kartu(c, 14),
      child: Column(
        children: [
          for (var i = 0; i < baris.length; i++)
            Container(
              padding: EdgeInsets.symmetric(vertical: padding),
              decoration: BoxDecoration(border: _garisAtas(c, i)),
              child: _Susut(
                kiri: baris[i].$1,
                kanan: baris[i].$2,
                gayaKiri: TextStyle(fontSize: 14, color: c.tinta2),
                gayaKanan: nilaiMono
                    ? const TextStyle(
                        fontFamily: PalakatText.mono,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      )
                    : const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

/// `display: flex; justify-content: space-between; gap: 16px` with two
/// texts: when both do not fit, each shrinks in proportion to its own
/// max-content width (CSS `flex-shrink: 1`).
class _Susut extends StatelessWidget {
  const _Susut({
    required this.kiri,
    required this.kanan,
    required this.gayaKiri,
    required this.gayaKanan,
  });
  final String kiri, kanan;
  final TextStyle gayaKiri, gayaKanan;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, k) {
      final dasar = DefaultTextStyle.of(context).style;
      double ukur(String t, TextStyle g) => (TextPainter(
        text: TextSpan(text: t, style: dasar.merge(g)),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout()).width.ceilToDouble();
      var a = ukur(kiri, gayaKiri), b = ukur(kanan, gayaKanan);
      final lebih = a + b + 16 - k.maxWidth;
      if (lebih > 0) {
        final ka = lebih * a / (a + b);
        a -= ka;
        b -= lebih - ka;
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: a,
            child: Text(kiri, style: gayaKiri),
          ),
          SizedBox(
            width: b,
            child: Text(kanan, textAlign: TextAlign.right, style: gayaKanan),
          ),
        ],
      );
    },
  );
}

// ── view saldo (/Awal/saldo) ───────────────────────────────────────────────

class _Saldo extends StatefulWidget {
  const _Saldo();
  @override
  State<_Saldo> createState() => _SaldoState();
}

class _SaldoState extends State<_Saldo> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Deep link while authority is not active: the board never allows it.
    if (!_awal(context).aktif) {
      final router = GoRouter.of(context);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => router.go(Layar.awal.jalur),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = _awal(context);
    if (!k.aktif) return const SizedBox.shrink();
    final sisa = k.sisa, pas = k.pas;
    final warnaSisa = pas
        ? c.laut
        : sisa == 0
        ? c.tinta
        : c.bata;
    final warnaBaris = BatangPembagian.warnaBagian(c);

    final Widget isi = !k.opn
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _jarak(18, [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kas · jumlah terverifikasi',
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                  Text(
                    rp(_kas),
                    style: const TextStyle(
                      fontFamily: PalakatText.mono,
                      fontSize: 34,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'Sumber: berita acara hitung kas 14/09/2026 · Terlampir',
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _jarak(10, [
                  const Text(
                    'Bagi ke peruntukan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  BatangPembagian(
                    total: _kas,
                    bagian: [
                      for (var i = 0; i < 3; i++)
                        BagianBatang(
                          int.tryParse(k.mentah(_kunci[i].$1)) ?? 0,
                          warnaBaris[i],
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          pas
                              ? 'Pas dengan Kas'
                              : sisa < 0
                              ? 'Lebih dari Kas'
                              : 'Sisa belum dibagi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: warnaSisa,
                          ),
                        ),
                      ),
                      Text(
                        rp(sisa.abs()),
                        style: TextStyle(
                          fontFamily: PalakatText.mono,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: warnaSisa,
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: _kartu(c, 14),
                child: Column(
                  children: [
                    for (var i = 0; i < 3; i++)
                      _BarisBagi(i: i, warna: warnaBaris[i], k: k),
                  ],
                ),
              ),
              DefaultTextStyle.merge(
                style: TextStyle(fontSize: 14, color: c.tinta2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _jarak(4, const [
                    Text('Bank BNI ··4821 · Rp24.000.000 · sudah dibagi'),
                    Text('Bank SulutGo ··1107 · Rp5.100.000 · sudah dibagi'),
                    Text(
                      'Uang muka dan titipan yang masih berjalan: tidak ada',
                    ),
                  ]),
                ),
              ),
              Text(
                'Saldo awal bukan Pendapatan. Jumlah per peruntukan harus '
                'sama persis dengan tiap Kas/Bank, termasuk yang Rp0.',
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
            ]),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _jarak(18, [
              _KartuOpn(padding: 18, ukuranAngka: 30, jarakHuruf: 0),
              Gerak(
                Kerangka.muncul,
                lama: _muncul,
                tunda: const Duration(milliseconds: 600),
                child: _KartuFakta(
                  padding: 11,
                  nilaiMono: true,
                  baris: [
                    ('Kas', rp(3200000)),
                    ('Bank BNI ··4821', rp(24000000)),
                    ('Bank SulutGo ··1107', rp(5100000)),
                  ],
                ),
              ),
            ]),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaPonsel(
          judul: 'Saldo awal pencatatan',
          anakJudul: 'Per 15 September 2026, tanggal mulai pencatatan',
          kembaliKe: Layar.awal,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: isi,
          ),
        ),
        _bawah(c, [
          if (!pas && !k.opn)
            Text(
              'Tidak dapat dibukukan: '
              '${sisa != 0 ? 'jumlah per peruntukan belum sama dengan Kas.' : 'masih ada peruntukan yang belum diisi.'}',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          if (pas && !k.opn)
            Gerak(
              Kerangka.muncul,
              key: const ValueKey('bukukan'),
              lama: _muncul,
              child: Tombol(
                'Periksa dan bukukan saldo awal',
                onPressed: k.bukukan,
              ),
            ),
          if (k.opn)
            const Tombol(
              'Kembali ke pengaturan awal',
              onPressed: null,
              jenis: JenisTombol.kedua,
              ke: Layar.awal,
              cara: Cara.naik,
            ),
        ]),
      ],
    );
  }
}

class _BarisBagi extends StatelessWidget {
  const _BarisBagi({required this.i, required this.warna, required this.k});
  final int i;
  final Color warna;
  final _Awal k;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final (kunci, nama) = _kunci[i];
    final kosong = k.mentah(kunci).isEmpty;
    final dasar = DefaultTextStyle.of(context).style;
    final gayaPesan = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: c.bata,
    );
    const gayaTombol = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);
    double ukur(String t, TextStyle g) => (TextPainter(
      text: TextSpan(text: t, style: dasar.merge(g)),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout()).width.ceilToDouble();
    Widget kecil(
      String teks,
      double lebar,
      Color? isi,
      GarisBorder? garis,
      Color fg,
      VoidCallback f,
    ) => SizedBox(
      width: lebar,
      child: Tekan(
        onTap: f,
        radius: 10,
        child: RupaTombol(
          label: teks,
          isi: isi,
          garis: garis,
          warnaTeks: fg,
          radius: 10,
          tinggi: 44,
          paddingH: 12,
          ukuranTeks: 14,
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: _garisAtas(c, i)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: warna,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ExcludeSemantics(
                  child: GestureDetector(
                    onTap: k.fokus[kunci]!.requestFocus,
                    child: Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _IsianBaris(
                label: nama,
                controller: k.bagi[kunci]!,
                fokus: k.fokus[kunci]!,
              ),
            ],
          ),
          if (kosong)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LayoutBuilder(
                builder: (context, kotak) {
                  // Both sides are `flex: 0 1 auto`: when they do not fit,
                  // each shrinks by its own width, the buttons included.
                  final adaSisa = k.sisa > 0;
                  var teks = ukur('Belum diisi. Kosong bukan Rp0.', gayaPesan);
                  var nol = ukur('Isi Rp0', gayaTombol) + 27;
                  var sisa = adaSisa ? ukur('Isi sisa', gayaTombol) + 24 : 0.0;
                  final tombol = nol + sisa + (adaSisa ? 8 : 0);
                  final lebih = teks + 8 + tombol - kotak.maxWidth;
                  if (lebih > 0) {
                    final kurangTombol = lebih * tombol / (teks + tombol);
                    teks -= lebih - kurangTombol;
                    final kurangNol = kurangTombol * nol / (nol + sisa);
                    nol -= kurangNol;
                    sisa -= kurangTombol - kurangNol;
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: teks,
                        child: Text(
                          'Belum diisi. Kosong bukan Rp0.',
                          style: gayaPesan,
                        ),
                      ),
                      Row(
                        children: [
                          kecil(
                            'Isi Rp0',
                            nol,
                            c.permukaan,
                            GarisBorder.penuh(c.garisTegas, radius: 10),
                            c.tinta,
                            () => k.isi(kunci, 0),
                          ),
                          if (adaSisa) ...[
                            const SizedBox(width: 8),
                            kecil(
                              'Isi sisa',
                              sisa,
                              c.tinta,
                              null,
                              c.permukaan,
                              () => k.isi(kunci, math.max(0, k.sisa)),
                            ),
                          ],
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// The amount field of a split row (IsianJumlah, phone row variant): 150
/// wide on a 1.5 `tinta` underline, "Rp" 14 `tinta3` on the input's
/// baseline, input mono 17/500 right-aligned, min-height 44 with its text
/// centred, placeholder "—".
class _IsianBaris extends StatefulWidget {
  const _IsianBaris({
    required this.label,
    required this.controller,
    required this.fokus,
  });
  final String label;
  final TextEditingController controller;
  final FocusNode fokus;

  @override
  State<_IsianBaris> createState() => _IsianBarisState();
}

class _IsianBarisState extends State<_IsianBaris> {
  @override
  void initState() {
    super.initState();
    widget.fokus.addListener(_ubah);
  }

  void _ubah() => setState(() {});

  @override
  void dispose() {
    widget.fokus.removeListener(_ubah);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final gaya = DefaultTextStyle.of(context).style.copyWith(
      fontFamily: PalakatText.mono,
      fontSize: 17,
      fontWeight: FontWeight.w500,
      // TextField merges the theme bodyLarge, whose M3 default adds 0.5.
      letterSpacing: 0,
      color: c.tinta,
    );
    // `input{font:inherit}`: line height 1.4, centred in the 44 box.
    final tengah = (44 - 17 * (gaya.height ?? 1.4)) / 2;
    return Container(
      width: 150,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.tinta, width: 1.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          ExcludeSemantics(
            child: Text(
              'Rp',
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontSize: 14,
                color: c.tinta3,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Semantics(
              label: widget.label,
              child: CincinFokus(
                tampil: widget.fokus.hasFocus,
                child: Material(
                  type: MaterialType.transparency,
                  // Flutter keeps cursorWidth + 1 free right of right-aligned
                  // text; shift it so the figure ends where the board's does.
                  child: Transform.translate(
                    offset: const Offset(3, 0),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.fokus,
                      keyboardType: TextInputType.number,
                      inputFormatters: const [
                        RupiahInputFormatter(sisakanNol: true),
                      ],
                      textAlign: TextAlign.right,
                      style: gaya,
                      cursorColor: c.laut,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: tengah),
                        // The field is shifted 3 px right; the placeholder is not caret-inset.
                        hint: Transform.translate(
                          offset: const Offset(-3, 0),
                          child: Text(
                            '—',
                            textAlign: TextAlign.right,
                            style: gaya.copyWith(color: c.tinta3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The booked OPN card (the `tinta` motion): `terpilih` line, sweep, stamp.
/// Shared shape with WebAwal, kept per board (padding and figure differ).
class _KartuOpn extends StatelessWidget {
  const _KartuOpn({
    required this.padding,
    required this.ukuranAngka,
    required this.jarakHuruf,
  });
  final double padding, ukuranAngka, jarakHuruf;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(c.tinta, radius: 16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.5),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _jarak(8, [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const LencanaStatus(
                        'Dibukukan',
                        bentuk: BentukLencana.tinta,
                        kepala: true,
                      ),
                      Flexible(
                        child: Gerak(
                          Kerangka.cap,
                          lama: const Duration(milliseconds: 550),
                          tunda: const Duration(milliseconds: 350),
                          kurva: PalakatMotion.keluar,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: c.laut, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'No. Bukti OPN-2026-0001',
                              style: TextStyle(
                                fontFamily: PalakatText.mono,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: c.laut,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Saldo awal pencatatan · semua Kas/Bank',
                      style: TextStyle(fontSize: 14, color: c.tinta2),
                    ),
                  ),
                  Text(
                    rp(32300000),
                    style: TextStyle(
                      fontFamily: PalakatText.mono,
                      fontSize: ukuranAngka,
                      fontWeight: FontWeight.w500,
                      letterSpacing: jarakHuruf,
                    ),
                  ),
                  Text(
                    'Seri OPN · bukan Pendapatan · menjadi final setelah '
                    'September 2026 ditutup',
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ]),
              ),
            ),
            const SapuTinta(),
          ],
        ),
      ),
    );
  }
}
