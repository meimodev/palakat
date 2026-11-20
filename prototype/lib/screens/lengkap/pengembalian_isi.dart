import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../motion/kerangka.dart';
import '../../providers/keuangan/pengembalian.dart';
import '../../providers/repositories_keuangan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart' show BarisTombol, KepalaKartu;
import '../../widgets/garis.dart';
import '../../widgets/input_format.dart';
import '../../widgets/isian_alasan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// Shared by Pengembalian and WebPengembalian (the former Alur screens merged
/// in, RD04): pick the original, enter the refund, see it Draf or Dibukukan.
enum JenisPengembalian {
  donatur(
    tab: 'Kembali kepada donatur',
    tombol: 'Kembalikan kepada donatur',
    baru: 'Pengembalian kepada donatur',
    atJ: 'Pengembalian kepada donatur mengurangi Pendapatan di bulan uangnya dibayarkan.',
    atT: 'Dicatat sebagai Pendapatan negatif pada Mata Anggaran yang sama dan tertaut ke transaksi asal.',
  ),
  pemasok(
    tab: 'Uang kembali dari pemasok',
    tombol: 'Catat uang kembali dari pemasok',
    baru: 'Uang kembali dari pemasok',
    atJ: 'Uang kembali dari pemasok mengurangi Belanja di bulan uangnya diterima.',
    atT: 'Dicatat sebagai Belanja negatif pada Mata Anggaran yang sama dan tertaut ke transaksi asal.',
  );

  const JenisPengembalian({
    required this.tab,
    required this.tombol,
    required this.baru,
    required this.atJ,
    required this.atT,
  });

  final String tab, tombol, baru, atJ, atT;

  static JenisPengembalian dari(AsalPengembalian a) =>
      a.pemasok ? pemasok : donatur;
}

/// The screens' UI state: the kind chip, the chosen original, the saved
/// refund, the last refusal and the two fields. Records live in
/// TransactionRepository.
class KeadaanPengembalian extends ChangeNotifier {
  final jumlah = TextEditingController();
  final alasan = TextEditingController();
  var tab = JenisPengembalian.pemasok;
  String? asalId, hasilId;
  Refusal? pesan;

  int get j => angkaDari(jumlah.text) ?? 0;
  bool lebih(AsalPengembalian a) => j > a.boleh;

  /// First unmet condition, for the button's semantics hint; '' when met.
  String belum(AsalPengembalian a) => j <= 0 || lebih(a)
      ? 'Jumlah (Rp)'
      : IsianAlasan.terisi(alasan.text)
      ? ''
      : 'Alasan · wajib';

  void ubah([String _ = '']) => notifyListeners();

  void _kosong() {
    jumlah.clear();
    alasan.clear();
    hasilId = null;
    pesan = null;
  }

  /// A kind chip: back to the list of that kind.
  void pilih(JenisPengembalian t) {
    tab = t;
    asalId = null;
    _kosong();
    notifyListeners();
  }

  /// "Catat uang kembali …" on an original.
  void mulai(AsalPengembalian a) {
    asalId = a.id;
    tab = JenisPengembalian.dari(a);
    _kosong();
    notifyListeners();
  }

  /// "Kembali" and "Selesai".
  void selesai() {
    asalId = null;
    _kosong();
    notifyListeners();
  }

  /// "Simpan sebagai draf" ([bukukan] false) or "Periksa dan bukukan".
  Future<void> simpan(
    WidgetRef ref,
    AsalPengembalian a, {
    required bool bukukan,
  }) async {
    if (belum(a).isNotEmpty) return;
    final r = await catatPengembalian(
      ref,
      a,
      jumlah: j,
      alasan: alasan.text.trim(),
      bukukan: bukukan,
    );
    hasilId = r.id ?? hasilId;
    pesan = r.pesan;
    notifyListeners();
  }

  /// "Periksa dan bukukan" on the saved draft.
  Future<void> bukukan(WidgetRef ref) async {
    final id = hasilId;
    if (id == null) return;
    pesan = await bukukanPengembalian(ref, id);
    notifyListeners();
  }

  @override
  void dispose() {
    jumlah.dispose();
    alasan.dispose();
    super.dispose();
  }
}

/// The rule note of [c], line language draf.
class CatatanAturan extends StatelessWidget {
  const CatatanAturan({super.key, required this.c});
  final JenisPengembalian c;

  @override
  Widget build(BuildContext context) {
    final w = context.warna;
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
  const KartuAsal({super.key, required this.a});
  final AsalPengembalian a;

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
                a.no,
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
            rp(a.pemasok ? -a.t.total : a.t.total),
            style: const TextStyle(
              fontFamily: PalakatText.mono,
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            a.t.description,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '${a.ma} · ${a.kasBank} · ${tgl(a.t.effectiveDate.awal)}',
            style: TextStyle(fontSize: 13, color: w.tinta3),
          ),
          if (!a.bulanSama) ...[
            const SizedBox(height: 4),
            Text(
              '${a.bulan}, tetapi pengembalian dicatat di bulan uangnya '
              '${a.pemasok ? 'diterima' : 'dibayarkan'}.',
              style: TextStyle(fontSize: 13, color: w.tinta3),
            ),
          ],
        ],
      ),
    );
  }
}

/// The pick list: each original of kind [k.tab] with its button.
List<Widget> daftarAsal(
  BuildContext context,
  KeadaanPengembalian k,
  List<AsalPengembalian> semua,
) {
  final w = context.warna;
  final daftar = [
    for (final a in semua)
      if (JenisPengembalian.dari(a) == k.tab) a,
  ];
  return [
    Text(
      'Pilih transaksi asalnya. Transaksi asal tidak diubah.',
      style: TextStyle(fontSize: 14, color: w.tinta2),
    ),
    if (daftar.isEmpty)
      Text(
        'Tidak ada transaksi di bulan yang belum ditutup.',
        style: TextStyle(fontSize: 14, color: w.tinta3),
      ),
    for (final a in daftar)
      Kartu(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 6,
          children: [
            KepalaKartu(
              judul: a.t.description,
              ujung: LencanaStatus.uang(StatusUang.dibukukan),
            ),
            Text(
              '${a.no} · ${tgl(a.t.effectiveDate.awal)} · ${rp(a.t.total)} · '
              '${a.ma}',
              style: TextStyle(fontSize: 13, color: w.tinta3),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Tombol(
                k.tab.tombol,
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
                lebarPenuh: false,
                onPressed: () => k.mulai(a),
              ),
            ),
          ],
        ),
      ),
  ];
}

/// After saving: the 2 px link line, the refund card (enters with `muncul`)
/// and, while it is a draft, "Periksa dan bukukan"; once booked, what it
/// changed.
List<Widget> blokDraf(
  BuildContext context,
  WidgetRef ref,
  KeadaanPengembalian k,
  AsalPengembalian a,
) {
  final w = context.warna;
  final t = ref.watch(transactionRepositoryProvider).get(k.hasilId ?? '');
  if (t == null) return const [];
  final c = JenisPengembalian.dari(a);
  final alasan = ref.watch(alasanPengembalianProvider(t.id));
  final p = ref.watch(pengaruhPengembalianProvider);
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
    // Keyed on "refund shown", not on the kind: no replay between two.
    Gerak(
      Kerangka.muncul,
      key: const ValueKey('draf'),
      lama: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          shape: t.isPosted
              ? GarisBorder.penuh(w.tinta, radius: PalakatRadius.kartuBesar)
              : GarisBorder.putus(w.putus, radius: PalakatRadius.kartuBesar),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: t.isPosted
                  ? LencanaStatus.uang(StatusUang.dibukukan)
                  : const LencanaStatus(
                      'Draf · belum masuk saldo',
                      bentuk: BentukLencana.draf,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              rp(a.pemasok ? t.total : -t.total),
              style: TextStyle(
                fontFamily: PalakatText.mono,
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: t.isPosted ? w.tinta : w.tinta2,
              ),
            ),
            const SizedBox(height: 4),
            Text(c.baru, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              [
                if (t.voucher != null) t.voucher!,
                'Terkait dengan No. Bukti ${a.no}',
                '${a.pemasok ? 'masuk ke' : 'keluar dari'} ${a.kasBank}',
                tgl(t.effectiveDate.awal),
              ].join(' · '),
              style: TextStyle(fontSize: 13, color: w.tinta3),
            ),
            if (alasan.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Alasan: $alasan',
                style: TextStyle(fontSize: 14, color: w.tinta2),
              ),
            ],
          ],
        ),
      ),
    ),
    const SizedBox(height: 16),
    if (k.pesan case final r?) ...[
      Penolakan(
        tindakan: r.action,
        sebab:
            r.because +
            (r.whoCanAct == null
                ? ''
                : ' Yang perlu bertindak: ${r.whoCanAct}.'),
        jalan: const [],
        ukuranTeks: 14,
      ),
      const SizedBox(height: 16),
    ],
    if (t.isPosted)
      Kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 6,
          children: [
            const Text(
              'Pengaruhnya',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            _Kv(
              '${a.pemasok ? 'Belanja' : 'Pendapatan'} ${p.bulan}',
              rp(a.pemasok ? p.belanja : p.pendapatan),
            ),
            _Kv('Saldo buku semua Kas/Bank', rp(p.saldo)),
          ],
        ),
      )
    else
      Text(
        'Transaksi asal tidak diubah. Draf ini diperiksa dan dibukukan seperti '
        'transaksi lain; setelah dibukukan ia tampil sebagai angka negatif '
        'pada Mata Anggaran yang sama di bulan ini.',
        style: TextStyle(fontSize: 14, color: w.tinta2),
      ),
    const SizedBox(height: 16),
    BarisTombol(
      anak: [
        if (t.isDraft)
          Tombol(
            'Periksa dan bukukan',
            jenis: JenisTombol.tinta,
            onPressed: () => k.bukukan(ref),
          ),
        Tombol(
          'Selesai',
          jenis: JenisTombol.kedua,
          ukuran: UkuranTombol.sedang,
          onPressed: k.selesai,
        ),
      ],
    ),
  ];
}

class _Kv extends StatelessWidget {
  const _Kv(this.k, this.v);
  final String k, v;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: Text(
          k,
          style: TextStyle(fontSize: 14, color: context.warna.tinta2),
        ),
      ),
      const SizedBox(width: 16),
      Text(
        v,
        style: const TextStyle(
          fontFamily: PalakatText.mono,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

/// Before saving: amount, refusal line, Alasan, "Periksa dan bukukan",
/// "Simpan sebagai draf", "Kembali".
List<Widget> isianPengembalian(
  WidgetRef ref,
  KeadaanPengembalian k,
  AsalPengembalian a,
) => [
  _IsianJumlah(k, a),
  if (k.lebih(a)) const _Lebih(),
  _Turun(k),
  if (k.pesan case final r?)
    Penolakan(
      tindakan: r.action,
      sebab: r.because,
      jalan: const [],
      ukuranTeks: 14,
    ),
  BarisTombol(
    anak: [
      TombolBersyarat(
        label: 'Periksa dan bukukan',
        tindakan: 'Periksa dan bukukan',
        alasan: k.belum(a),
        periksa: () => k.belum(a),
        sudahMulai: false,
        teksBelumRedup: true,
        paddingH: 20,
        onPressed: () => k.simpan(ref, a, bukukan: true),
      ),
      Semantics(
        hint: k.belum(a).isEmpty ? null : k.belum(a),
        child: Tombol(
          'Simpan sebagai draf',
          jenis: JenisTombol.kedua,
          ukuran: UkuranTombol.sedang,
          onPressed: () => k.simpan(ref, a, bukukan: false),
        ),
      ),
    ],
  ),
  BarisTombol(
    anak: [
      Tombol(
        'Kembali',
        jenis: JenisTombol.teks,
        ukuran: UkuranTombol.kecil,
        onPressed: k.selesai,
      ),
    ],
  ),
];

/// IsianAlasan plus the space the board's inline-block textarea leaves under
/// its baseline: the root line's half-leading and descent (Plus Jakarta Sans
/// descent 0.222 em, content 1.26 em), about 4.7 px.
class _Turun extends StatelessWidget {
  const _Turun(this.k);
  final KeadaanPengembalian k;

  @override
  Widget build(BuildContext context) {
    final g = DefaultTextStyle.of(context).style;
    final fs = g.fontSize ?? 16;
    final tema = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: fs * ((g.height ?? 1.4) - 1.26) / 2 + fs * 0.222,
      ),
      // The TextField merges the theme's bodyLarge, whose letter spacing
      // (0.5, from Material's typography) the board's textarea does not have.
      child: Theme(
        data: tema.copyWith(
          textTheme: tema.textTheme.copyWith(
            bodyLarge: tema.textTheme.bodyLarge?.copyWith(letterSpacing: 0),
          ),
        ),
        child: IsianAlasan(controller: k.alasan, onChanged: k.ubah),
      ),
    );
  }
}

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
  const _IsianJumlah(this.k, this.a);
  final KeadaanPengembalian k;
  final AsalPengembalian a;

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
    final maks = '· paling banyak ${palingBanyak(widget.a)}';
    final gayaAngka = dasar.copyWith(
      fontFamily: PalakatText.mono,
      fontFeatures: const [FontFeature.tabularFigures()],
      fontSize: 30,
      letterSpacing: 0, // the TextField would merge bodyLarge's 0.5
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
    for (final t in JenisPengembalian.values.reversed)
      ChipJenis(
        teks: t.tab,
        dipilih: k.tab == t,
        onTap: () => k.pilih(t),
        ponsel: ponsel,
      ),
  ],
);
