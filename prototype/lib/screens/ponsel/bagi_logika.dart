import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/batang_pembagian.dart';
import '../../widgets/input_format.dart';
import '../../widgets/tekan.dart';

/// Bagi and WebBagi: one Toko Sinar payment split across Mata Anggaran rows.
/// The two boards' logic classes are identical, so both screens mix this in.
const int jumlahBagi = 1250000;

/// Belanja Mata Anggaran in board order (`MA`).
const Map<String, String> maBagi = {
  '5.01.02.00': 'Listrik, air dan telepon',
  '5.02.01.00': 'Alat tulis dan fotokopi',
  '5.03.03.00': 'Biaya administrasi bank',
  '5.04.01.00': 'Konsumsi rapat',
  '5.05.02.00': 'Sewa peralatan',
};

/// CSS spreads a line's extra height evenly above and below the glyphs;
/// Flutter's default puts it in proportion to ascent and descent.
const cssLeading = TextHeightBehavior(
  leadingDistribution: TextLeadingDistribution.even,
);

class BarisBagi {
  BarisBagi(this.k, this.v);

  /// No. MA.
  final String k;

  /// Raw digits ('' = not filled).
  String v;
  String get nama => maBagi[k]!;
  int get angka => v.isEmpty ? 0 : int.parse(v);
}

mixin LogikaBagi<T extends StatefulWidget> on State<T> {
  final List<BarisBagi> baris = [
    BarisBagi('5.01.02.00', '1000000'),
    BarisBagi('5.02.01.00', '200000'),
  ];
  bool pilih = false;
  bool _dipakai = false;

  // One field per No. MA; kept until dispose so a removed row's field never
  // sees a disposed controller.
  final Map<String, TextEditingController> _isian = {};

  TextEditingController isian(BarisBagi b) =>
      _isian.putIfAbsent(b.k, () => TextEditingController(text: titik(b.v)));

  int get total => baris.fold(0, (a, b) => a + b.angka);
  int get sisa => jumlahBagi - total;
  bool get kosong => baris.any((b) => b.v.isEmpty);
  bool get pas => sisa == 0 && !kosong && baris.length >= 2;
  bool get dipakai => _dipakai && pas;

  String get labelSisa => sisa == 0
      ? 'Total baris sama dengan Jumlah'
      : sisa < 0
      ? 'Total baris lebih dari Jumlah'
      : 'Sisa belum dibagi';

  String get alasan => baris.length < 2
      ? 'Pembagian memerlukan paling sedikit dua baris.'
      : kosong
      ? 'Masih ada baris yang belum diisi.'
      : 'Total baris harus sama dengan Jumlah.';

  String get status =>
      'Mata Anggaran sudah dipilih · dibagi ke ${baris.length} baris';

  /// Mata Anggaran not yet in the rows, in source order.
  List<String> get pilihan => [
    for (final k in maBagi.keys)
      if (!baris.any((b) => b.k == k)) k,
  ];

  bool bisaSisa(BarisBagi b) => b.v.isEmpty && sisa > 0;

  Color warnaBaris(BuildContext context, int i) {
    final w = BatangPembagian.warnaBagian(context.warna);
    return w[i % w.length];
  }

  List<BagianBatang> bagian(BuildContext context) => [
    for (var i = 0; i < baris.length; i++)
      BagianBatang(baris[i].angka, warnaBaris(context, i)),
  ];

  /// The field's text is already filtered by RupiahInputFormatter(sisakanNol).
  void ubah(BarisBagi b, String teks) => setState(() {
    b.v = hanyaAngka(teks, simpanNol: true);
    _dipakai = false;
  });

  void isiSisa(BarisBagi b) => setState(() {
    b.v = '$sisa';
    isian(b).text = titik(b.v);
    _dipakai = false;
  });

  void lepas(BarisBagi b) => setState(() {
    baris.remove(b);
    _dipakai = false;
  });

  void tambah(String k) => setState(() {
    final b = BarisBagi(k, '');
    isian(b).text = '';
    baris.add(b);
    pilih = false;
    _dipakai = false;
  });

  void bukaPilih() => setState(() => pilih = true);
  void tutupPilih() => setState(() => pilih = false);

  /// TombolBersyarat: re-checks on press.
  void pakai() {
    if (pas) setState(() => _dipakai = true);
  }

  @override
  void dispose() {
    for (final c in _isian.values) {
      c.dispose();
    }
    super.dispose();
  }
}

/// "Isi sisa": min height 44, padding 0 12, radius 10, `tinta`, 700 14.
class IsiSisaBagi extends StatelessWidget {
  const IsiSisaBagi({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      radius: 10,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.tinta,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Isi sisa',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: c.permukaan,
          ),
        ),
      ),
    );
  }
}

/// The row amount field of Bagi and WebBagi: "Rp" 14 `tinta3`, gap 4, the
/// mono 17/500 figure right-aligned and centred in a 44 high input, on a 1.5
/// `tinta` underline, [lebar] 160 (phone) or 170 (web).
/// IsianJumlah(baris) is this form, but its text sits at the top of the 44 px
/// box (a collapsed InputDecorator ignores its min height), and its width is
/// fixed at 160.
class IsianBarisBagi extends StatefulWidget {
  const IsianBarisBagi({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.lebar = 160,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final double lebar;

  @override
  State<IsianBarisBagi> createState() => _IsianBarisBagiState();
}

class _IsianBarisBagiState extends State<IsianBarisBagi> {
  final _fokus = FocusNode();

  @override
  void initState() {
    super.initState();
    _fokus.addListener(_ubah);
  }

  void _ubah() => setState(() {});

  @override
  void dispose() {
    _fokus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final gaya = DefaultTextStyle.of(context).style.copyWith(
      fontFamily: PalakatText.mono,
      fontFeatures: const [FontFeature.tabularFigures()],
      fontSize: 17,
      fontWeight: FontWeight.w500,
    );
    return Container(
      width: widget.lebar,
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
                tampil: _fokus.hasFocus,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      // The placeholder: Chrome sets it flush right, without
                      // the caret room the figure gets.
                      if (widget.controller.text.isEmpty)
                        ExcludeSemantics(
                          child: Text(
                            '—',
                            style: gaya.copyWith(color: c.tinta3),
                          ),
                        ),
                      // Flutter keeps room for the caret after right-aligned
                      // text; Chrome draws the figure 4 px further right.
                      Transform.translate(
                        offset: const Offset(4, 0),
                        child: Material(
                          type: MaterialType.transparency,
                          child: TextField(
                            controller: widget.controller,
                            focusNode: _fokus,
                            onChanged: widget.onChanged,
                            keyboardType: TextInputType.number,
                            inputFormatters: const [
                              RupiahInputFormatter(sisakanNol: true),
                            ],
                            textAlign: TextAlign.right,
                            style: gaya,
                            cursorColor: c.tinta,
                            decoration: const InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
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
