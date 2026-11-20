import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/finance/finance.dart';
import '../../motion/kerangka.dart';
import '../../providers/actor.dart';
import '../../providers/clock.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/keuangan/isian.dart';
import '../../providers/repositories_keuangan.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tekan.dart';

/// The date picker shared by Tanggal and WebTanggal (spec 11): the months of
/// the books (cutover to M+1) from the periods, today from the clock. A day
/// can be picked in an open month, from the period's start up to today.
mixin TanggalLogika<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// The month shown ('yyyy-mm') and the day picked.
  late String _bulanId;
  Tanggal? _pilih;
  String dok = 'sama';
  final dokTeks = TextEditingController();
  bool _layangKejadian = false;
  late final _ketukKejadian = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    final Tanggal awal =
        ref.read(isianCatatProvider)?.tanggal ?? ref.read(hariIniProvider);
    final b = ref.read(bulanBukuProvider);
    _pilih = awal;
    _bulanId =
        (b.semua.where((p) => p.contains(awal)).firstOrNull ?? b.berjalan)
            ?.id ??
        '';
  }

  List<Period> get _semua => ref.watch(bulanBukuProvider).semua;
  Tanggal get _hariIni => ref.watch(hariIniProvider);

  /// The month shown: the picked one, else the period holding today.
  Period? get _p =>
      _semua.where((p) => p.id == _bulanId).firstOrNull ??
      ref.watch(bulanBukuProvider).berjalan;
  int get _i => _semua.indexWhere((p) => p.id == _p?.id);

  bool get tutup => _p?.isClosed ?? false;
  bool get nanti => _p != null && _p!.start > _hariIni;
  bool boleh(Tanggal d) {
    final p = _p;
    return p != null && !p.isClosed && p.contains(d) && d <= _hariIni;
  }

  Tanggal? get sel => _pilih != null && boleh(_pilih!) ? _pilih : null;
  String get tglTeks => sel != null ? tglPanjang(sel!.awal) : 'Belum dipilih';

  /// "Pakai {tanggal}": hands the date to the form, then back to it.
  void pakai(Layar ke) {
    final t = sel;
    if (t == null) return;
    ref.read(isianCatatProvider.notifier).pakaiTanggal(t);
    context.naikKe(ke);
  }

  @override
  void dispose() {
    dokTeks.dispose();
    _ketukKejadian.dispose();
    super.dispose();
  }

  void _geser(int arah) => setState(() {
    final semua = ref.read(bulanBukuProvider).semua;
    _bulanId = semua[semua.indexWhere((p) => p.id == _bulanId) + arah].id;
    _pilih = null;
    _layangKejadian = false; // the link goes away under the pointer
  });

  /// "‹", month name over the status badge, "›".
  Widget bilahBulan(BuildContext context) {
    final c = context.warna;
    Widget panah(String t, String label, VoidCallback? onTap) => Tekan(
      onTap: onTap,
      label: label,
      radius: 12,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: c.permukaan,
          shape: GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 12),
        ),
        child: Text(t, style: const TextStyle(fontSize: 20)),
      ),
    );
    return Row(
      children: [
        panah('‹', 'Bulan sebelumnya', _i > 0 ? () => _geser(-1) : null),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              Text(
                _p == null ? '' : namaBulan(_p!),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // The badge is an inline span in the page's line (16 / 1.4 on
              // the phone, 15 / 1.45 on the web): the line box sets the
              // height, its padding and line spill over. Its box is the 13 px
              // font's content area (1.26 em) plus padding and line, sitting
              // on the line's baseline (CSS half-leading with the font's
              // 1.038 / 0.222 em ascent and descent).
              Builder(
                builder: (context) {
                  final g = DefaultTextStyle.of(context).style;
                  final f = g.fontSize ?? 16, lh = f * (g.height ?? 1.4);
                  final dasar = (lh - 1.26 * f) / 2 + 1.038 * f;
                  return SizedBox(
                    height: lh,
                    child: OverflowBox(
                      maxHeight: double.infinity,
                      child: Container(
                        transform: Matrix4.translationValues(
                          0,
                          dasar - 5.304 - lh / 2,
                          0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: ShapeDecoration(
                          color: tutup ? c.tinta : c.permukaan,
                          shape: GarisBorder.penuh(c.tinta, radius: 6),
                        ),
                        child: Text(
                          tutup ? 'Sudah ditutup' : 'Belum ditutup',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.26,
                            leadingDistribution: TextLeadingDistribution.even,
                            fontWeight: FontWeight.w700,
                            color: tutup ? c.permukaan : c.tinta,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        panah(
          '›',
          'Bulan berikutnya',
          _i >= 0 && _i < _semua.length - 1 ? () => _geser(1) : null,
        ),
      ],
    );
  }

  /// Weekday row and the day grid (7 equal columns, gap 4).
  Widget kisiHari(BuildContext context) {
    final c = context.warna;
    final p = _p;
    if (p == null) return const SizedBox.shrink();
    final n = DateTime.utc(p.year, p.month + 1, 0).day;
    final off = DateTime.utc(p.year, p.month, 1).weekday - 1;
    final kotak = <int?>[
      for (var i = 0; i < off; i++) null,
      for (var d = 1; d <= n; d++) d,
    ];
    while (kotak.length % 7 != 0) {
      kotak.add(null);
    }
    Widget baris(List<Widget> isi) => Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(child: isi[i]),
        ],
      ],
    );
    Widget hariSel(int d) {
      final t = Tanggal(p.year, p.month, d);
      final ok = boleh(t), on = t == sel, kini = t == _hariIni;
      return Tekan(
        onTap: ok ? () => setState(() => _pilih = t) : null,
        dipilih: on,
        radius: 12,
        minLebar: 0,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: on ? c.tinta : (ok ? c.permukaan : null),
            shape: on || kini
                ? GarisBorder.penuh(c.tinta, radius: 12)
                : ok
                ? GarisBorder.penuh(c.garis, tebal: 1, radius: 12)
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
          ),
          child: Text(
            '$d',
            style: TextStyle(
              color: on ? c.permukaan : (ok ? c.tinta : c.tinta3),
              fontWeight: on || kini ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: baris([
            for (final h in const [
              'Sen',
              'Sel',
              'Rab',
              'Kam',
              'Jum',
              'Sab',
              'Min',
            ])
              Text(
                h,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
          ]),
        ),
        for (var r = 0; r < kotak.length; r += 7) ...[
          if (r > 0) const SizedBox(height: 4),
          baris([
            for (final d in kotak.sublist(r, r + 7))
              d == null ? const SizedBox(height: 44) : hariSel(d),
          ]),
        ],
      ],
    );
  }

  /// The one message under the grid for the month shown, or null.
  /// [keKejadian] opens "Kejadian setelah tutup buku".
  Widget? pesan(BuildContext context, VoidCallback keKejadian) {
    final c = context.warna;
    final p = _p;
    if (p == null) return null;
    final hariIni = tglPanjang(_hariIni.awal);
    if (tutup) {
      final warna = _layangKejadian ? c.lautTua : c.laut;
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Tidak dapat dipilih: ${namaBulan(p)} sudah ditutup.',
              style: TextStyle(fontWeight: FontWeight.w700, color: c.bata),
            ),
            const TextSpan(
              text:
                  ' Yang masih dapat Anda lakukan: pilih tanggal di bulan '
                  'yang belum ditutup, atau catat sebagai ',
            ),
            // ponytail: a span link wraps like the board's <a> but takes no
            // keyboard focus; a WidgetSpan Tautan would not wrap.
            TextSpan(
              text: 'Kejadian setelah tutup buku',
              recognizer: _ketukKejadian..onTap = keKejadian,
              mouseCursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _layangKejadian = true),
              onExit: (_) => setState(() => _layangKejadian = false),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: warna,
                decoration: TextDecoration.underline,
                decorationColor: warna,
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
        style: const TextStyle(fontSize: 15),
      );
    }
    if (nanti) {
      return Text(
        'Tidak dapat dipilih: tanggal setelah hari ini, $hariIni.',
        style: TextStyle(fontSize: 14, color: c.tinta2),
      );
    }
    if (p.contains(_hariIni)) {
      return Text(
        'Hari ini $hariIni. Tanggal sesudahnya belum dapat dipilih.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      );
    }
    if (sel == null) return null;
    // A confirmed reconciliation of the month turns stale (DM 5.4).
    final rekon = ref.watch(reconciliationRepositoryProvider);
    final dipastikan = ref
        .watch(accountRepositoryProvider)
        .accounts()
        .any((a) => rekon.session(a.id, p.id)?.status == ReconStatus.confirmed);
    return Gerak(
      Kerangka.muncul,
      lama: const Duration(milliseconds: 300),
      child: Kartu(
        status: GarisStatus.terpilih,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Masuk laporan ${namaBulan(p)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: [
                  if (p.id == ref.watch(bulanBukuProvider).berikutDitutup?.id)
                    ', bulan berikutnya untuk tutup buku.'
                  else
                    '.',
                  if (dipastikan)
                    ' Rekonsiliasi ${namaBulan(p).split(' ').first} yang '
                        'sudah dipastikan menjadi “Perlu dipastikan lagi”.',
                ].join(),
              ),
            ],
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  /// Tanggal transaksi, Tanggal dokumen, Dicatat pada, Dibukukan pada.
  Widget kartuRincian(BuildContext context) => Builder(builder: _kartuRincian);

  // Built under the page's DefaultTextStyle, which [baris] measures with.
  Widget _kartuRincian(BuildContext context) {
    final c = context.warna;
    final sub = TextStyle(fontSize: 13, color: c.tinta3);
    const judul = TextStyle(fontWeight: FontWeight.w600);
    const mono = TextStyle(fontFamily: PalakatText.mono, fontSize: 14);
    Widget kepala(String a, String b) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(a, style: judul),
        Text(b, style: sub),
      ],
    );
    final dasar = DefaultTextStyle.of(context).style;
    final skala = MediaQuery.textScalerOf(context);
    double lebar(String t, TextStyle g) {
      final p = TextPainter(
        text: TextSpan(text: t, style: dasar.merge(g)),
        textDirection: TextDirection.ltr,
        textScaler: skala,
      )..layout();
      final w = p.width;
      p.dispose();
      return w;
    }

    // CSS `justify-content: space-between` with both items shrinkable: an
    // item keeps its natural width, or, when the row is too narrow, a share
    // proportional to it (flex-shrink 1 × flex-basis auto).
    Widget baris(
      String a,
      String b,
      String nilai,
      TextStyle gaya, {
      bool garis = true,
    }) {
      final kiri = math.max(lebar(a, judul), lebar(b, sub));
      final kanan = lebar(nilai, gaya);
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: garis
            ? BoxDecoration(
                border: Border(top: BorderSide(color: c.garis)),
              )
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(flex: kiri.ceil(), child: kepala(a, b)),
            const SizedBox(width: 16),
            Flexible(
              flex: kanan.ceil(),
              child: Text(nilai, textAlign: TextAlign.right, style: gaya),
            ),
          ],
        ),
      );
    }

    return Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          baris(
            'Tanggal transaksi',
            sel != null && _p != null
                ? 'masuk laporan ${namaBulan(_p!)}'
                : 'menentukan bulan laporan',
            tglTeks,
            const TextStyle(fontWeight: FontWeight.w700),
            garis: false,
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.garis)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kepala(
                  'Tanggal dokumen',
                  'Tanggal pada nota. Tidak memengaruhi bulan laporan.',
                ),
                const SizedBox(height: 8),
                ChipPilihan<String>(
                  pilihan: const [
                    (nilai: 'sama', teks: 'Sama dengan tanggal transaksi'),
                    (nilai: 'beda', teks: 'Berbeda'),
                  ],
                  terpilih: dok,
                  onPilih: (v) => setState(() => dok = v),
                ),
                if (dok == 'beda') ...[
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: IsianTeks(
                      controller: dokTeks,
                      labelSemantik: 'Tanggal dokumen',
                      petunjuk: 'hh/bb/tttt',
                      keyboardType: TextInputType.number,
                      formatters: const [_SaringTanggal()],
                      gaya: const TextStyle(fontFamily: PalakatText.mono),
                    ),
                  ),
                ],
              ],
            ),
          ),
          baris(
            'Dicatat pada',
            'otomatis',
            tglJam(ref.watch(clockProvider).now()),
            mono,
          ),
          baris('Dibukukan pada', 'otomatis, saat Bukukan', '—', mono),
        ],
      ),
    );
  }
}

/// `onDok`: keep digits and "/", then the first 10 characters. No slashes
/// are added and the date is not checked.
class _SaringTanggal extends TextInputFormatter {
  const _SaringTanggal();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue lama,
    TextEditingValue baru,
  ) {
    final buang = RegExp(r'[^\d/]');
    var teks = baru.text.replaceAll(buang, '');
    if (teks.length > 10) teks = teks.substring(0, 10);
    final ujung = baru.selection.end.clamp(0, baru.text.length);
    final kursor = baru.text
        .substring(0, ujung)
        .replaceAll(buang, '')
        .length
        .clamp(0, teks.length);
    return TextEditingValue(
      text: teks,
      selection: TextSelection.collapsed(offset: kursor),
    );
  }
}
