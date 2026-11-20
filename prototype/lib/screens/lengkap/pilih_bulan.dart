import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../motion/kerangka.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lembar_bawah.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tekan.dart';

// ── Board data and state, shared with WebPilihBulan (same logic class) ──

/// The board's `B`: month, status, caption, closed.
typedef BulanPilihan = ({String n, String st, String cat, bool tutup});

/// The board's `D` rows: status, No. Bukti ('' for a draft), date, uraian, amount.
typedef BarisBulan = ({StatusUang st, String no, String tgl, String ur, int n});

const List<BulanPilihan> semuaBulanPilihan = [
  (
    n: 'Desember 2026',
    st: 'Belum ditutup',
    cat: 'Belum ada transaksi',
    tutup: false,
  ),
  (
    n: 'November 2026',
    st: 'Belum ditutup',
    cat: 'Bulan berjalan · 12 transaksi',
    tutup: false,
  ),
  (
    n: 'Oktober 2026',
    st: 'Belum ditutup',
    cat: 'Berikutnya untuk tutup buku · 33 transaksi',
    tutup: false,
  ),
  (
    n: 'September 2026',
    st: 'Sudah ditutup',
    cat: 'Periode laporan 15–30 September 2026 · 21 transaksi',
    tutup: true,
  ),
];

const Map<String, List<BarisBulan>> barisPerBulan = {
  'November 2026': [
    (
      st: StatusUang.dibukukan,
      no: 'BKU-2026-0146',
      tgl: '15/11/2026',
      ur: 'Persembahan Ibadah Minggu',
      n: 3450000,
    ),
    (
      st: StatusUang.draf,
      no: '',
      tgl: '14/11/2026',
      ur: 'Fotokopi warta jemaat',
      n: -150000,
    ),
    (
      st: StatusUang.dibukukan,
      no: 'BKU-2026-0143',
      tgl: '11/11/2026',
      ur: 'Sewa sound system',
      n: -600000,
    ),
  ],
  'Oktober 2026': [
    (
      st: StatusUang.dibukukan,
      no: 'BKU-2026-0133',
      tgl: '31/10/2026',
      ur: 'Biaya administrasi bank',
      n: -15000,
    ),
    // +Rp2.000.000 here, −Rp2.000.000 on RekonIsi: each board keeps its own.
    (
      st: StatusUang.dibukukan,
      no: 'BKU-2026-0127',
      tgl: '30/10/2026',
      ur: 'Pindah antar Kas/Bank: Bank BNI ke Kas',
      n: 2000000,
    ),
    (
      st: StatusUang.dibalik,
      no: 'BKU-2026-0105',
      tgl: '09/10/2026',
      ur: 'Konsumsi rapat majelis',
      n: -750000,
    ),
  ],
  'September 2026': [
    (
      st: StatusUang.dibukukan,
      no: 'BKU-2026-0031',
      tgl: '22/09/2026',
      ur: 'Alat tulis Toko Sinar',
      n: -85000,
    ),
    (
      st: StatusUang.dibukukan,
      no: 'BKU-2026-0019',
      tgl: '18/09/2026',
      ur: 'Persembahan Ibadah Minggu',
      n: 2900000,
    ),
    (
      st: StatusUang.dibukukan,
      no: 'OPN-2026-0001',
      tgl: '15/09/2026',
      ur: 'Saldo awal pencatatan',
      n: 32300000,
    ),
  ],
  'Desember 2026': [],
};

/// The board's state `{ bulan, buka }` and derived values. Each screen owns one.
class KeadaanPilihBulan {
  String bulan = 'November 2026';
  bool buka = false;

  BulanPilihan get kini => semuaBulanPilihan.firstWhere((b) => b.n == bulan);
  List<BarisBulan> get baris => barisPerBulan[bulan]!;

  void toggle() => buka = !buka;
  void pilih(String n) {
    bulan = n;
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
            for (final r in baris)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _KartuBaris(r),
              ),
            Text(
              'Contoh 3 baris.',
              style: TextStyle(fontSize: 13, color: c.tinta3),
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
  final BarisBulan r;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final draf = r.st == StatusUang.draf;
    return Kartu(
      status: draf ? GarisStatus.draf : GarisStatus.dibukukan,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              LencanaStatus.uang(r.st),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  rp(r.n),
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
          Text(r.ur, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: r.no.isEmpty ? 'Belum ada No. Bukti' : r.no,
                  style: const TextStyle(fontFamily: PalakatText.mono),
                ),
                TextSpan(text: ' · ${r.tgl}'),
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
        for (final b in semuaBulanPilihan)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _Pilihan(
              b: b,
              on: b.n == k.bulan,
              onTap: () => onPilih(b.n),
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

class PilihBulanScreen extends StatefulWidget {
  const PilihBulanScreen({super.key});

  @override
  State<PilihBulanScreen> createState() => _PilihBulanScreenState();
}

class _PilihBulanScreenState extends State<PilihBulanScreen> {
  final k = KeadaanPilihBulan();

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Material(
      type: MaterialType.transparency,
      child: DefaultTextHeightBehavior(
        textHeightBehavior: perilakuBarisCss,
        child: LayarPonsel(
          jabatanKosong: true,
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
