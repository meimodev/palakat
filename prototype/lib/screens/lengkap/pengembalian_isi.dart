import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OverflowBoxFit;

import '../../mock/format.dart';
import '../../motion/kerangka.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/input_format.dart';
import '../../widgets/isian_alasan.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol_bersyarat.dart';

/// Shared by Pengembalian and WebPengembalian: the boards' `K` map, their
/// state (`tab`, `jm`, `alasan`, `jadi`) and the blocks both draw.
enum JenisPengembalian {
  donatur(
    tab: 'Kembali kepada donatur',
    no: 'BKU-2026-0121',
    ur: 'Sumbangan donatur',
    jm: 500000,
    jenis: 'Pendapatan 1.4.10.02.00 Sumbangan donatur',
    ak: 'Bank BNI ··4821',
    baru: 'Pengembalian kepada donatur',
    arah: 'keluar dari Bank BNI ··4821',
    atJ: 'Pengembalian kepada donatur mengurangi Pendapatan di bulan uangnya dibayarkan.',
    atT: 'Dicatat sebagai Pendapatan negatif pada Mata Anggaran yang sama dan tertaut ke transaksi asal.',
  ),
  pemasok(
    tab: 'Uang kembali dari pemasok',
    no: 'BKU-2026-0116',
    ur: 'Pemeliharaan atap gedung',
    jm: 5500000,
    jenis: 'Belanja 5.08.02.00 Pemeliharaan gedung',
    ak: 'Bank BNI ··4821',
    baru: 'Uang kembali dari pemasok',
    arah: 'masuk ke Bank BNI ··4821',
    atJ: 'Uang kembali dari pemasok mengurangi Belanja di bulan uangnya diterima.',
    atT: 'Dicatat sebagai Belanja negatif pada Mata Anggaran yang sama dan tertaut ke transaksi asal.',
  );

  const JenisPengembalian({
    required this.tab,
    required this.no,
    required this.ur,
    required this.jm,
    required this.jenis,
    required this.ak,
    required this.baru,
    required this.arah,
    required this.atJ,
    required this.atT,
  });

  final String tab, no, ur, jenis, ak, baru, arah, atJ, atT;
  final int jm;
}

/// The boards' state: `tab`, `jm` (the amount controller), `alasan`, `jadi`.
class KeadaanPengembalian extends ChangeNotifier {
  final jumlah = TextEditingController();
  final alasan = TextEditingController();
  var tab = JenisPengembalian.donatur;
  final jadi = <JenisPengembalian, ({int jm, String alasan})>{};

  int get j => angkaDari(jumlah.text) ?? 0;
  bool get lebih => j > tab.jm;

  /// First unmet condition, for the button's semantics hint; '' when met.
  String get belum => j <= 0 || lebih
      ? 'Jumlah (Rp)'
      : IsianAlasan.terisi(alasan.text)
      ? ''
      : 'Alasan · wajib';

  void ubah(String _) => notifyListeners();

  /// `pick`: runs even on the chosen chip, emptying the form.
  void pilih(JenisPengembalian t) {
    tab = t;
    jumlah.clear();
    alasan.clear();
    notifyListeners();
  }

  /// `simpan`: re-checked from the latest input by [TombolBersyarat].
  void simpan() {
    jadi[tab] = (jm: j, alasan: alasan.text.trim());
    jumlah.clear();
    alasan.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    jumlah.dispose();
    alasan.dispose();
    super.dispose();
  }
}

/// Rule note, line language draf; [tautan] is the screen's "Coba alurnya
/// sampai dibukukan" link, set inline at the end.
class CatatanAturan extends StatelessWidget {
  const CatatanAturan({super.key, required this.c, required this.tautan});
  final JenisPengembalian c;
  final Widget tautan;

  @override
  Widget build(BuildContext context) {
    final w = context.warna;
    final tinggi = 14 * (DefaultTextStyle.of(context).style.height ?? 1.4);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        shape: GarisBorder.putus(w.putus, radius: 14),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: c.atJ,
              style: TextStyle(fontWeight: FontWeight.w700, color: w.tinta),
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: '${c.atT} Bulan yang sudah ditutup tidak dibuka lagi.',
              style: TextStyle(color: w.tinta2),
            ),
            const TextSpan(text: ' '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: TautanSebaris(tinggi: tinggi, child: tautan),
            ),
          ],
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

/// An inline link whose 44 px target overflows its line box, so the line
/// keeps the text's height. The [child] Tautan centres its text
/// (`Center(widthFactor: 1, …)`).
// ponytail: taps land only inside the line box (about 20 px tall); a full
// 44 px hit area needs a render object that hit-tests outside its size.
class TautanSebaris extends StatelessWidget {
  const TautanSebaris({super.key, required this.tinggi, required this.child});
  final double tinggi;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: tinggi,
    child: OverflowBox(
      maxHeight: 44,
      fit: OverflowBoxFit.deferToChild,
      child: child,
    ),
  );
}

/// The original voucher card (terpilih line).
class KartuAsal extends StatelessWidget {
  const KartuAsal({super.key, required this.c});
  final JenisPengembalian c;

  @override
  Widget build(BuildContext context) {
    final w = context.warna;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: w.permukaan,
        shape: GarisBorder.penuh(w.tinta, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Drawn without a line: padding 3 9 on a `tinta` field.
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: w.tinta,
                      borderRadius: BorderRadius.circular(
                        PalakatRadius.lencana,
                      ),
                    ),
                    child: Text(
                      'Dibukukan · transaksi asal',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: w.permukaan,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                c.no,
                style: TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 13,
                  color: w.tinta2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rp(c == JenisPengembalian.donatur ? c.jm : -c.jm),
            style: const TextStyle(
              fontFamily: PalakatText.mono,
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(c.ur, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            '${c.jenis} · ${c.ak}',
            style: TextStyle(fontSize: 13, color: w.tinta3),
          ),
        ],
      ),
    );
  }
}

/// After saving: the 2 px link line, the draft card (enters with `muncul`)
/// and the note. Returned as the column's children after [KartuAsal]
/// (the line's −8 margins replace the 16 gap with 8 on both sides).
List<Widget> blokDraf(
  BuildContext context,
  JenisPengembalian c,
  ({int jm, String alasan}) d,
) {
  final w = context.warna;
  return [
    const SizedBox(height: 8),
    Padding(
      padding: const EdgeInsets.only(left: 28),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 2,
          height: 20,
          child: ColoredBox(color: w.tinta),
        ),
      ),
    ),
    const SizedBox(height: 8),
    // Keyed on "draft shown", not on the kind: no replay between two drafts.
    Gerak(
      Kerangka.muncul,
      key: const ValueKey('draf'),
      lama: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          shape: GarisBorder.putus(w.putus, radius: PalakatRadius.kartuBesar),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: LencanaStatus(
                'Draf · belum masuk saldo',
                bentuk: BentukLencana.draf,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              rp(d.jm),
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: w.tinta2,
              ),
            ),
            const SizedBox(height: 4),
            Text(c.baru, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              'Terkait dengan No. Bukti ${c.no} · ${c.arah}',
              style: TextStyle(fontSize: 13, color: w.tinta3),
            ),
            const SizedBox(height: 4),
            Text(
              'Alasan: ${d.alasan}',
              style: TextStyle(fontSize: 14, color: w.tinta2),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 16),
    Text(
      'Transaksi asal tidak diubah. Draf ini diperiksa dan dibukukan seperti '
      'transaksi lain; setelah dibukukan ia tampil sebagai angka negatif pada '
      'Mata Anggaran yang sama di bulan ini.',
      style: TextStyle(fontSize: 14, color: w.tinta2),
    ),
  ];
}

/// Before saving: amount, refusal line, Alasan, "Simpan sebagai draf".
List<Widget> isianPengembalian(KeadaanPengembalian k) => [
  _IsianJumlah(k),
  if (k.lebih) const _Lebih(),
  IsianAlasan(controller: k.alasan, onChanged: k.ubah),
  TombolBersyarat(
    label: 'Simpan sebagai draf',
    tindakan: 'Simpan sebagai draf',
    alasan: k.belum,
    periksa: () => k.belum,
    sudahMulai: false,
    teksBelumRedup: true,
    paddingH: 20,
    onPressed: k.simpan,
  ),
];

class _Lebih extends StatelessWidget {
  const _Lebih();

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Text(
      'Tidak dapat dilakukan: melebihi jumlah transaksi asal.',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: context.warna.bata,
      ),
    ),
  );
}

/// IsianJumlah standar with the board's two-tone inline label ("· paling
/// banyak …" in `tinta3`), which the shared widget cannot draw.
class _IsianJumlah extends StatefulWidget {
  const _IsianJumlah(this.k);
  final KeadaanPengembalian k;

  @override
  State<_IsianJumlah> createState() => _IsianJumlahState();
}

class _IsianJumlahState extends State<_IsianJumlah> {
  final _fokus = FocusNode();

  @override
  void dispose() {
    _fokus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = widget.k;
    final dasar = DefaultTextStyle.of(context).style;
    final maks = '· paling banyak ${rp(k.tab.jm)}';
    final gayaAngka = dasar.copyWith(
      fontFamily: PalakatText.mono,
      fontFeatures: const [FontFeature.tabularFigures()],
      fontSize: 30,
      fontWeight: FontWeight.w500,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: GestureDetector(
            onTap: _fokus.requestFocus,
            child: Text.rich(
              TextSpan(
                text: 'Jumlah (Rp) ',
                children: [
                  TextSpan(
                    text: maks,
                    style: TextStyle(color: c.tinta3),
                  ),
                ],
              ),
              strutStyle: StrutStyle.fromTextStyle(dasar),
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.tinta, width: 2)),
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
                    fontSize: 20,
                    color: c.tinta3,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Semantics(
                  label: 'Jumlah (Rp) $maks',
                  child: ListenableBuilder(
                    listenable: _fokus,
                    builder: (context, _) => CincinFokus(
                      tampil: _fokus.hasFocus,
                      child: Material(
                        type: MaterialType.transparency,
                        child: TextField(
                          controller: k.jumlah,
                          focusNode: _fokus,
                          onChanged: k.ubah,
                          keyboardType: TextInputType.number,
                          inputFormatters: const [RupiahInputFormatter()],
                          textAlignVertical: TextAlignVertical.center,
                          style: gayaAngka,
                          cursorColor: c.laut,
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            constraints: const BoxConstraints(minHeight: 44),
                            hintText: '0',
                            hintStyle: gayaAngka.copyWith(color: c.tinta3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kind chip. [ponsel]: the compact board style (padding 0 12, 13/600);
/// otherwise the standard ChipSatu size (padding 0 14, 14/600).
class ChipJenis extends StatelessWidget {
  const ChipJenis({
    super.key,
    required this.teks,
    required this.dipilih,
    required this.onTap,
    required this.ponsel,
  });

  final String teks;
  final bool dipilih;
  final VoidCallback onTap;
  final bool ponsel;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      dipilih: dipilih,
      radius: 22,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: EdgeInsets.symmetric(horizontal: ponsel ? 12 : 14),
        decoration: ShapeDecoration(
          color: dipilih ? c.tinta : c.permukaan,
          shape: GarisBorder.penuh(
            dipilih ? c.tinta : c.garisTegas,
            radius: PalakatRadius.chip,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                teks,
                style: TextStyle(
                  fontSize: ponsel ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: dipilih ? c.permukaan : c.tinta,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Both chips, wrapping: phone `margin: 0 6px 6px 0`, web `gap: 8px`.
Widget chipJenis(KeadaanPengembalian k, {required bool ponsel}) => Wrap(
  spacing: ponsel ? 6 : 8,
  runSpacing: ponsel ? 6 : 8,
  children: [
    for (final t in JenisPengembalian.values)
      ChipJenis(
        teks: t.tab,
        dipilih: k.tab == t,
        onTap: () => k.pilih(t),
        ponsel: ponsel,
      ),
  ],
);
