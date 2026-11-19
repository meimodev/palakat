import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../motion/kerangka.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tekan.dart';

/// The date picker shared by Tanggal and WebTanggal (spec 11): the board's
/// state `{ bln: 10, hari: 14, dok: 'sama', dokTeks: '' }` and the parts both
/// layouts arrange. `bln` is the JS month index (8 September … 11 Desember),
/// year 2026.
mixin TanggalLogika<T extends StatefulWidget> on State<T> {
  static const _nb = {
    8: 'September',
    9: 'Oktober',
    10: 'November',
    11: 'Desember',
  };

  int bln = 10;
  int? hari = 14;
  String dok = 'sama';
  final dokTeks = TextEditingController();
  bool _layangKejadian = false;
  late final _ketukKejadian = TapGestureRecognizer();

  bool get tutup => bln == 8;
  bool get nanti => bln == 11;
  bool boleh(int d) => !tutup && !nanti && !(bln == 10 && d > 16);
  int? get sel => hari != null && boleh(hari!) ? hari : null;
  String get tglTeks => sel != null ? '$sel ${_nb[bln]} 2026' : 'Belum dipilih';

  @override
  void dispose() {
    dokTeks.dispose();
    _ketukKejadian.dispose();
    super.dispose();
  }

  void _prev() => setState(() {
    bln--;
    hari = null;
  });
  void _next() => setState(() {
    bln++;
    hari = null;
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
        panah('‹', 'Bulan sebelumnya', bln > 8 ? _prev : null),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              Text(
                '${_nb[bln]} 2026',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // The badge is an inline span: the 16 / 1.4 line box sets the
              // height, its padding and line spill over; its 13 px text sits
              // on the line's baseline, a little below centre.
              SizedBox(
                height: 22.4,
                child: OverflowBox(
                  maxHeight: double.infinity,
                  child: Container(
                    transform: Matrix4.translationValues(0, 2, 0),
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
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: tutup ? c.permukaan : c.tinta,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        panah('›', 'Bulan berikutnya', bln < 11 ? _next : null),
      ],
    );
  }

  /// Weekday row and the day grid (7 equal columns, gap 4).
  Widget kisiHari(BuildContext context) {
    final c = context.warna;
    final n = DateTime(2026, bln + 2, 0).day;
    final off = DateTime(2026, bln + 1, 1).weekday - 1;
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
      final ok = boleh(d), on = d == sel, kini = bln == 10 && d == 16;
      return Tekan(
        onTap: ok ? () => setState(() => hari = d) : null,
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
    if (tutup) {
      final warna = _layangKejadian ? c.lautTua : c.laut;
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Tidak dapat dipilih: September 2026 sudah ditutup.',
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
        'Tidak dapat dipilih: tanggal setelah hari ini, 16 November 2026.',
        style: TextStyle(fontSize: 14, color: c.tinta2),
      );
    }
    if (bln == 10) {
      return Text(
        'Hari ini 16 November 2026. Tanggal sesudahnya belum dapat dipilih.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      );
    }
    if (sel == null) return null;
    return Gerak(
      Kerangka.muncul,
      lama: const Duration(milliseconds: 300),
      child: const Kartu(
        status: GarisStatus.terpilih,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Masuk laporan Oktober 2026',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text:
                    ', bulan berikutnya untuk tutup buku. Rekonsiliasi '
                    'Oktober yang sudah dipastikan menjadi “Perlu dipastikan '
                    'lagi”.',
              ),
            ],
          ),
          style: TextStyle(fontSize: 14),
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
            sel != null
                ? 'masuk laporan ${_nb[bln]} 2026'
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
          baris('Dicatat pada', 'otomatis', '16/11/2026 11.40', mono),
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
