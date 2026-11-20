import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../motion/kerangka.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/keuangan/transaksi.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lembar_bawah.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tekan.dart';

// ── State, shared with WebPilihBulan (same logic class) ──

/// One month of the sheet: period id, name, status, caption, closed.
typedef BulanPilihan = ({
  String id,
  String n,
  String st,
  String cat,
  bool tutup,
});

/// The board's state `{ bulan, buka }` over the periods of the books; each
/// screen owns one and calls [baca] at the top of its build.
class KeadaanPilihBulan {
  /// The month shown ('yyyy-mm'); the running month until one is picked.
  String? bulanId;
  bool buka = false;
  List<BulanPilihan> semua = const [];
  List<BarisTransaksi> baris = const [];

  /// Every period newest first, with its rows ([DP29]: counts computed).
  void baca(WidgetRef ref) {
    final buku = ref.watch(bulanBukuProvider);
    semua = [
      for (final r in ref.watch(daftarBulanProvider))
        _bulan(r, r.dibukukan + r.draf, buku),
    ];
    bulanId ??= buku.berjalan?.id ?? semua.firstOrNull?.id;
    baris = bulanId == null
        ? const []
        : ref.watch(
            daftarTransaksiProvider((
              periodId: bulanId,
              saring: SaringTransaksi.semua,
              accountId: null,
              fundId: null,
            )),
          );
  }

  static BulanPilihan _bulan(RingkasanBulan r, int n, BulanBuku buku) {
    final p = r.periode;
    final nama = namaBulan(p);
    return (
      id: p.id,
      n: nama,
      st: p.isClosed ? 'Sudah ditutup' : 'Belum ditutup',
      cat: p.isClosed
          ? 'Periode laporan ${p.start.hari}–${p.end.hari} $nama · $n transaksi'
          : n == 0
          ? 'Belum ada transaksi'
          : p.id == buku.berjalan?.id
          ? 'Bulan berjalan · $n transaksi'
          : p.id == buku.berikutDitutup?.id
          ? 'Berikutnya untuk tutup buku · $n transaksi'
          : '$n transaksi',
      tutup: p.isClosed,
    );
  }

  BulanPilihan get kini => semua.firstWhere(
    (b) => b.id == bulanId,
    orElse: () => (id: '', n: '', st: '', cat: '', tutup: false),
  );
  String get bulan => kini.n;

  void toggle() => buka = !buka;
  void pilih(String id) {
    bulanId = id;
    buka = false;
  }
}

// ── Shared parts ──

/// CSS half-leading: mixed sans/mono lines and glyph placement match the
/// board. ponytail: belongs in the theme for every screen (sharedNeeds).
const perilakuBarisCss = TextHeightBehavior(
  leadingDistribution: TextLeadingDistribution.even,
);

/// The month pill: "‹bulan› · ‹status› ▾", `aria-expanded`.
class TombolBulan extends StatelessWidget {
  const TombolBulan({super.key, required this.k, required this.onTap});
  final KeadaanPilihBulan k;
  final VoidCallback onTap;

  /// The label up to the '▾', which [_Segitiga] draws (no bundled font has
  /// U+25BE, so as text it falls back to a missing-glyph box).
  static String teks(KeadaanPilihBulan k) => '${k.bulan} · ${k.kini.st} ';

  /// Advance of the drawn '▾' (Chrome's fallback glyph on the board).
  static const lebarSegitiga = 7.0;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Semantics(
      expanded: k.buka,
      child: Tekan(
        onTap: onTap,
        radius: 999,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: ShapeDecoration(
            color: c.permukaan,
            shape: GarisBorder.penuh(c.tinta, radius: 999),
          ),
          child: Align(
            widthFactor: 1,
            child: Text.rich(
              TextSpan(
                text: teks(k),
                children: const [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: _Segitiga(),
                  ),
                ],
              ),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

/// The board's '▾': a 6 × 5 down-triangle 1 px above the baseline, in the
/// text colour.
class _Segitiga extends StatelessWidget {
  const _Segitiga();

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(TombolBulan.lebarSegitiga, 6),
    painter: _SegitigaPainter(DefaultTextStyle.of(context).style.color!),
  );
}

class _SegitigaPainter extends CustomPainter {
  _SegitigaPainter(this.warna);
  final Color warna;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
    Path()
      ..moveTo(0.5, 0)
      ..lineTo(6.5, 0)
      ..lineTo(3.5, 5)
      ..close(),
    Paint()..color = warna,
  );

  @override
  bool shouldRepaint(_SegitigaPainter old) => old.warna != warna;
}

/// The list column: closed banner, rows plus caption, or the empty box.
class DaftarBulan extends StatelessWidget {
  const DaftarBulan({super.key, required this.k, required this.jarak});
  final KeadaanPilihBulan k;

  /// Column gap: 16 phone, 14 web.
  final double jarak;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final baris = k.baris;
    final anak = <Widget>[
      if (k.kini.tutup)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: c.tinta,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${k.bulan} sudah ditutup.',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(
                  text:
                      ' Hanya dapat dilihat. Dokumen susulan dan kejadian '
                      'dicatat dari tiap transaksi.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 14, color: c.permukaan),
          ),
        ),
      if (baris.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, r) in baris.indexed)
              Padding(
                padding: EdgeInsets.only(top: i > 0 ? 10 : 0),
                child: _KartuBaris(r),
              ),
          ],
        )
      else
        Kartu(
          status: GarisStatus.draf,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Belum ada transaksi di ${k.bulan}.',
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.tinta),
                ),
                const TextSpan(
                  text:
                      ' Bulan tanpa transaksi belum selesai: tiap Kas/Bank '
                      'tetap perlu hitung kas atau rekening koran, lalu '
                      'tutup buku.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < anak.length; i++) ...[
          if (i > 0) SizedBox(height: jarak),
          anak[i],
        ],
      ],
    );
  }
}

class _KartuBaris extends StatelessWidget {
  const _KartuBaris(this.r);
  final BarisTransaksi r;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final st = StatusUang.values.firstWhere(
      (s) => s.label == r.status,
      orElse: () => StatusUang.dibukukan,
    );
    final draf = !r.transaksi.isPosted;
    return Kartu(
      status: draf ? GarisStatus.draf : GarisStatus.dibukukan,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              LencanaStatus.uang(st),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  rp(r.jumlah),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: PalakatText.mono,
                    fontWeight: FontWeight.w500,
                    color: draf ? c.tinta3 : c.tinta,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            r.transaksi.description,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: r.nomor,
                  style: const TextStyle(fontFamily: PalakatText.mono),
                ),
                TextSpan(text: ' · ${r.tanggal}'),
              ],
            ),
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ],
      ),
    );
  }
}

/// The four month options of the sheet (phone) or side panel (web).
class PilihanBulan extends StatelessWidget {
  const PilihanBulan({super.key, required this.k, required this.onPilih});
  final KeadaanPilihBulan k;
  final ValueChanged<String> onPilih;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final b in k.semua)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _Pilihan(
              b: b,
              on: b.id == k.bulanId,
              onTap: () => onPilih(b.id),
              c: c,
            ),
          ),
      ],
    );
  }
}

class _Pilihan extends StatelessWidget {
  const _Pilihan({
    required this.b,
    required this.on,
    required this.onTap,
    required this.c,
  });
  final BulanPilihan b;
  final bool on;
  final VoidCallback onTap;
  final PalakatWarna c;

  @override
  Widget build(BuildContext context) {
    final t = b.tutup;
    return Tekan(
      onTap: onTap,
      dipilih: on,
      radius: 14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: ShapeDecoration(
          color: t ? c.tinta : (on ? c.lautLembut : c.permukaan),
          shape: GarisBorder.penuh(
            on ? c.laut : (t ? c.tinta : c.garis),
            tebal: on || t ? 2 : 1,
            radius: 14,
          ),
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: t ? c.permukaan : c.tinta),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      b.n,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Board badge: open months transparent with a `tinta3`
                  // line, the closed month a `permukaan` block.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: ShapeDecoration(
                      color: t ? c.permukaan : null,
                      shape: GarisBorder.penuh(
                        t ? c.permukaan : c.tinta3,
                        radius: 6,
                      ),
                    ),
                    child: Text(
                      b.st,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: t ? c.tinta : c.tinta2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                b.cat,
                style: TextStyle(
                  fontSize: 13,
                  color: t ? c.diTinta2 : c.tinta3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Screen ──

class PilihBulanScreen extends ConsumerStatefulWidget {
  const PilihBulanScreen({super.key});

  @override
  ConsumerState<PilihBulanScreen> createState() => _PilihBulanScreenState();
}

class _PilihBulanScreenState extends ConsumerState<PilihBulanScreen> {
  final k = KeadaanPilihBulan();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    k.baca(ref);
    return Material(
      type: MaterialType.transparency,
      child: DefaultTextHeightBehavior(
        textHeightBehavior: perilakuBarisCss,
        child: LayarPonsel(
          layarKeuangan: true,
          overlay: [
            if (k.buka)
              Positioned.fill(
                child: LembarBawah(
                  judul: 'Pilih bulan',
                  anakJudul: 'Semua bulan sejak tanggal mulai pencatatan.',
                  pegangan: false,
                  latar: c.kertas,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  jarak: 0,
                  labelTirai: 'Kembali ke daftar',
                  masuk: Kerangka.muncul,
                  onTutup: () => setState(() => k.buka = false),
                  isi: [
                    PilihanBulan(
                      k: k,
                      onPilih: (n) => setState(() => k.pilih(n)),
                    ),
                  ],
                ),
              ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: const Text(
                        'Transaksi',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TombolBulan(k: k, onTap: () => setState(k.toggle)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: DaftarBulan(k: k, jarak: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
