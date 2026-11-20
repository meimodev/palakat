import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../providers/keuangan/dokumen.dart';
import '../../providers/keuangan/koreksi.dart';
import '../../widgets/kartu_persetujuan.dart';
import '../../widgets/penolakan.dart';
import '../../providers/keuangan/persetujuan.dart';
import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/isian_alasan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';

const _mode = [
  (
    id: 'koreksi',
    n: 'Pembalikan dan transaksi koreksi',
    s: 'Keduanya dibukukan bersama, atau tidak sama sekali',
  ),
  (id: 'balik', n: 'Pembalikan saja', s: 'Transaksi ini seharusnya tidak ada'),
];

/// An inline `<textarea>` sits on its div's text baseline: the line box adds
/// this much below it on the board.
const double _celahArea = 5;
const _mono = TextStyle(
  fontFamily: PalakatText.mono,
  fontFeatures: [FontFeature.tabularFigures()],
);

/// The board's UI state (`state = {…}` of the logic class); the records
/// come from [koreksiProvider].
class _Papan extends ChangeNotifier {
  String alasan = '', mode = 'koreksi', kejadian = '';

  /// The chosen Mata Anggaran code; null: the first other than the original's.
  String? ma;

  /// The last refusal of a command, shown on detail.
  Refusal? pesan;

  bool get kor => mode == 'koreksi';
  void ubah(VoidCallback f) {
    f();
    notifyListeners();
  }
}

class _Lingkup extends InheritedNotifier<_Papan> {
  const _Lingkup({required _Papan papan, required super.child})
    : super(notifier: papan);
}

_Papan _papan(BuildContext c) =>
    c.dependOnInheritedWidgetOfExactType<_Lingkup>()!.notifier!;

/// The transaction of the route's `:id` (watched).
DataKoreksi? _data(BuildContext c, WidgetRef ref) =>
    ref.watch(koreksiProvider(GoRouterState.of(c).pathParameters['id'] ?? ''));

/// [p]'s Mata Anggaran code for the correction.
String? _maDipilih(_Papan p, DataKoreksi d) =>
    p.ma ??
    (d.pilihanMa.length > 1 ? d.pilihanMa[1].$1 : d.pilihanMa.firstOrNull?.$1);

Widget _penolakan(Refusal r) => Penolakan(
  tindakan: r.action,
  sebab:
      r.because +
      (r.whoCanAct == null ? '' : ' Yang perlu bertindak: ${r.whoCanAct}.'),
  jalan: const [],
);

/// Owns the board state and LayarPonsel (strip) (navigation.md 2.1); the
/// child routes are views only.
class KoreksiKendali extends StatefulWidget {
  const KoreksiKendali({super.key, required this.child});
  final Widget child;
  @override
  State<KoreksiKendali> createState() => _KoreksiKendaliState();
}

class _KoreksiKendaliState extends State<KoreksiKendali> {
  final _p = _Papan();

  @override
  void dispose() {
    _p.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: _Lingkup(
      papan: _p,
      child: ListenableBuilder(
        listenable: _p,
        builder: (context, _) =>
            LayarPonsel(layarKeuangan: true, child: widget.child),
      ),
    ),
  );
}

class KoreksiScreen extends ConsumerStatefulWidget {
  const KoreksiScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;
  @override
  ConsumerState<KoreksiScreen> createState() => _KoreksiScreenState();
}

class _KoreksiScreenState extends ConsumerState<KoreksiScreen> {
  @override
  void initState() {
    super.initState();
    // Deep links to a view the board cannot reach now go back to detail.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final d = ref.read(
        koreksiProvider(GoRouterState.of(context).pathParameters['id'] ?? ''),
      );
      final sah = switch (widget.anak) {
        _ when d == null => widget.anak == null,
        'hasil' => d.dibalik,
        'kejadian' => d.tutup,
        'pembalikan' => !d.tutup && !d.dibalik && !d.menunggu,
        _ => true,
      };
      if (!sah) {
        context.naikKe(
          Layar.koreksi,
          param: GoRouterState.of(context).pathParameters,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => switch (widget.anak) {
    'pembalikan' => const _Pembalikan(),
    'hasil' => const _Hasil(),
    'kejadian' => const _Kejadian(),
    _ => const _Detail(),
  };
}

// ── shared bits ───────────────────────────────────────────────────────────

void _keDetail(BuildContext c) =>
    c.naikKe(Layar.koreksi, param: GoRouterState.of(c).pathParameters);

/// Key–value card: `permukaan`, 1 `garis`, radius 14, padding 4 16; rows 11 0.
class _Rincian extends StatelessWidget {
  const _Rincian(this.baris);

  /// (key, value, value in mono).
  final List<(String, String, bool)> baris;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style;
    final gayaK = dasar.merge(TextStyle(fontSize: 14, color: c.tinta2));
    final gayaV = dasar.merge(
      const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
    int lebar(String t, TextStyle g) => _flex(context, t, g);

    return Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (k, v, mono)) in baris.indexed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: i == 0
                  ? null
                  : BoxDecoration(
                      border: Border(top: BorderSide(color: c.garis)),
                    ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: lebar(k, gayaK),
                    child: Text(k, style: gayaK),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    flex: lebar(v, mono ? gayaV.merge(_mono) : gayaV),
                    child: Text(
                      v,
                      textAlign: TextAlign.right,
                      style: mono ? gayaV.merge(_mono) : gayaV,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// CSS flex-shrink on a two-item row: as `Flexible(flex: …)` each side gives
/// way in proportion to its natural width ([tambah]: padding and line).
int _flex(BuildContext c, String t, TextStyle g, [double tambah = 0]) {
  final tp = TextPainter(
    text: TextSpan(text: t, style: g),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(c),
  )..layout();
  final w = ((tp.width + tambah) * 10).ceil();
  tp.dispose();
  return w < 1 ? 1 : w;
}

/// Bottom bar: `permukaan`, top 1 `garis`, padding 12 20 22.
class _Bawah extends StatelessWidget {
  const _Bawah(this.anak);
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: _sela(anak, 8),
      ),
    );
  }
}

List<Widget> _sela(List<Widget> w, double jarak) => [
  for (final (i, x) in w.indexed) ...[if (i > 0) SizedBox(height: jarak), x],
];

Widget _gulir(
  EdgeInsets padding,
  double jarak,
  List<Widget> anak, [
  ScrollController? kendali,
]) => SingleChildScrollView(
  controller: kendali,
  padding: padding,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: _sela(anak, jarak),
  ),
);

/// Header badge: 13/700, radius 6, padding 4 10 inside a 1.5 line.
class _LencanaKepala extends StatelessWidget {
  const _LencanaKepala({required this.dibalik});
  final bool dibalik;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: dibalik ? c.permukaan : c.tinta,
        shape: GarisBorder.penuh(dibalik ? c.tinta3 : c.tinta, radius: 6),
      ),
      child: Text(
        dibalik ? 'Dibalik' : 'Dibukukan',
        softWrap: false,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: dibalik ? c.tinta2 : c.permukaan,
        ),
      ),
    );
  }
}

// ── detail ────────────────────────────────────────────────────────────────

class _Detail extends ConsumerStatefulWidget {
  const _Detail();
  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  final _guliran = ScrollController();
  var _diAtas = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The board remounts detail on every return: back on top, at the top.
    final diAtas = ModalRoute.isCurrentOf(context) ?? true;
    // A deep link mounts detail under the child unlaid-out: nothing to reset yet.
    if (diAtas &&
        !_diAtas &&
        _guliran.hasClients &&
        _guliran.position.hasContentDimensions) {
      _guliran.jumpTo(0);
    }
    _diAtas = diAtas;
  }

  @override
  void dispose() {
    _guliran.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = _papan(context);
    final d = _data(context, ref);
    final caption = TextStyle(fontSize: 13, color: c.tinta3);
    if (d == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Koreksi',
            kembaliKe: Layar.keuangan,
            labelKembali: 'Kembali ke Beranda',
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Transaksi tidak ditemukan.', style: caption),
          ),
        ],
      );
    }
    final t = d.asal;
    final tutup = d.tutup, bulan = d.bulan;
    final buka = !tutup && !d.dibalik && !d.menunggu;
    final setuju = t.approvalMode == ApprovalMode.external
        ? ref.watch(persetujuanProvider(t.id))?.berlaku
        : null;
    final param = GoRouterState.of(context).pathParameters;
    final lampirkan = Tombol(
      'Lampirkan dokumen pendukung',
      onPressed: () {
        ref.read(pilihanDokumenProvider.notifier).pilih(t.id);
        context.dorongKe(Layar.fotoDokumen);
      },
      jenis: JenisTombol.kedua,
      ukuran: UkuranTombol.sedang,
    );
    Future<void> bukukan() async {
      final r = await bukukanRangkaian(ref, t.id);
      p.ubah(() => p.pesan = r);
      if (r == null && context.mounted) {
        context.dorongKe(Layar.koreksi, param: param, anak: 'hasil');
      }
    }

    // `pudar .2s` on the view's root, inside the route's own `masuk`.
    return Gerak(
      Kerangka.pudar,
      lama: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: t.voucher ?? '',
            judulMono: true,
            kembaliKe: Layar.keuangan,
            labelKembali: 'Kembali ke Beranda',
            ujung: _LencanaKepala(dibalik: d.dibalik),
          ),
          Expanded(
            child: _gulir(const EdgeInsets.fromLTRB(20, 8, 20, 24), 16, [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rp(d.rincian.baris.jumlah),
                    style: _mono.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    t.description,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${d.maAsal.split(' ').first} · '
                    '${tglPanjang(t.effectiveDate.awal)}',
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                ],
              ),
              if (d.dibalik)
                Tekan(
                  onTap: () => context.dorongKe(
                    Layar.koreksi,
                    param: param,
                    anak: 'hasil',
                  ),
                  radius: 12,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.centerLeft,
                    decoration: ShapeDecoration(
                      color: c.permukaan,
                      shape: GarisBorder.penuh(c.tinta, radius: 12),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Dibalik oleh No. Bukti '),
                          TextSpan(
                            text: d.pembalikan?.voucher ?? '',
                            style: _mono,
                          ),
                          const TextSpan(text: ' · lihat rangkaian'),
                        ],
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (tutup)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: c.tinta,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$bulan sudah ditutup.',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(
                          text:
                              ' Transaksi ini final dan laporan resminya '
                              'dibekukan.',
                        ),
                      ],
                    ),
                    style: TextStyle(fontSize: 14, color: c.permukaan),
                  ),
                ),
              _Rincian([
                for (final (k, v, _) in d.rincian.fakta) (k, v, false),
              ]),
              if (t.approvalMode == ApprovalMode.external)
                setuju == null
                    ? KartuPersetujuan.belum(
                        kepala: 'Persetujuan di luar aplikasi',
                        onCatat: () => context.dorongKe(
                          Layar.persetujuan,
                          param: {'id': t.id},
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          KartuPersetujuan.sudah(
                            kepala: 'Persetujuan di luar aplikasi',
                            pemberi: setuju.nama,
                            jabatan: setuju.jabatan,
                            tanggal: setuju.tanggal,
                            cara: setuju.cara,
                            dicatatOleh: setuju.oleh,
                            dicatatPada: setuju.pada,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Tautan(
                              ke: Layar.persetujuan,
                              param: {'id': t.id},
                              child: const SizedBox(
                                height: 44,
                                child: Center(
                                  widthFactor: 1,
                                  child: TautanTeks(
                                    'Ganti catatan persetujuan',
                                    berat: FontWeight.w700,
                                    ukuran: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              if (d.dokumen case final dok?)
                Kartu(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Dokumen pendukung',
                        style: TextStyle(fontSize: 14, color: c.tinta2),
                      ),
                      Text(
                        dok.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              for (final k in d.kejadian)
                Gerak(
                  Kerangka.muncul,
                  lama: const Duration(milliseconds: 300),
                  child: Kartu(
                    status: GarisStatus.terpilih,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _JudulKejadian(),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            k.explanation.facts,
                            style: TextStyle(fontSize: 14, color: c.tinta2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Angka dan laporan resmi $bulan tidak berubah.',
                            style: caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (p.pesan case final r?) _penolakan(r),
              if (d.menunggu)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _sela([
                    Text(
                      d.pengganti == null
                          ? 'Pembalikan dicatat sebagai draf, belum masuk '
                                'saldo.'
                          : 'Pembalikan dan transaksi koreksi dicatat sebagai '
                                'draf, belum masuk saldo.',
                      style: TextStyle(fontSize: 14, color: c.tinta2),
                    ),
                    Tombol(
                      'Periksa dan bukukan',
                      onPressed: bukukan,
                      jenis: JenisTombol.tinta,
                    ),
                  ], 8),
                ),
              if (buka)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _sela([
                    Tombol(
                      'Koreksi dengan pembalikan',
                      onPressed: () {
                        p.ubah(() => p.pesan = null);
                        context.dorongKe(
                          Layar.koreksi,
                          param: param,
                          anak: 'pembalikan',
                        );
                      },
                      jenis: JenisTombol.tinta,
                    ),
                    lampirkan,
                    Text(
                      'Jumlah, tanggal, Kas/Bank, peruntukan, Lingkup dan Mata '
                      'Anggaran tidak dapat diubah langsung.',
                      style: caption,
                    ),
                  ], 8),
                ),
              if (tutup)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _sela([
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'Tidak dapat dilakukan: koreksi dengan '
                                'pembalikan.',
                            style: TextStyle(
                              color: c.tinta,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' $bulan sudah ditutup. Yang masih dapat Anda '
                                'lakukan:',
                          ),
                        ],
                      ),
                      style: TextStyle(fontSize: 14, color: c.tinta2),
                    ),
                    Tombol(
                      'Catat kejadian',
                      onPressed: () => context.dorongKe(
                        Layar.koreksi,
                        param: param,
                        anak: 'kejadian',
                      ),
                      jenis: JenisTombol.tinta,
                    ),
                    lampirkan,
                    Text(
                      'Dokumen susulan hanya mengubah Status sekarang, bukan '
                      'laporan resmi.',
                      style: caption,
                    ),
                  ], 8),
                ),
            ], _guliran),
          ),
        ],
      ),
    );
  }
}

/// "Kejadian setelah tutup buku" + the "Belum ditindaklanjuti" badge; on
/// the board both shrink and wrap (the badge too, unlike LencanaStatus).
class _JudulKejadian extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style;
    const judul = 'Kejadian setelah tutup buku',
        lencana = 'Belum ditindaklanjuti';
    final gJudul = dasar.merge(
      const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    );
    final gLencana = dasar.merge(
      TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.tinta2),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: _flex(context, judul, gJudul),
          child: Text(judul, style: gJudul),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: _flex(context, lencana, gLencana, 21),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: ShapeDecoration(
              shape: GarisBorder.penuh(c.tinta3, radius: 6),
            ),
            child: Text(lencana, style: gLencana),
          ),
        ),
      ],
    );
  }
}

// ── pembalikan (screen `koreksi`) ─────────────────────────────────────────

class _Pembalikan extends ConsumerStatefulWidget {
  const _Pembalikan();
  @override
  ConsumerState<_Pembalikan> createState() => _PembalikanState();
}

class _PembalikanState extends ConsumerState<_Pembalikan> {
  TextEditingController? _alasan;

  @override
  void dispose() {
    _alasan?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = _papan(context);
    final d = _data(context, ref);
    if (d == null) return const SizedBox.shrink();
    final maPilih = _maDipilih(p, d);
    final isi = _alasan ??= TextEditingController(text: p.alasan);
    final ok = IsianAlasan.terisi(p.alasan);
    final label = p.kor
        ? 'Bukukan pembalikan dan koreksi'
        : 'Bukukan pembalikan';
    const sebab = 'Isi alasan untuk melanjutkan.';
    final judulKecil = TextStyle(fontSize: 14, color: c.tinta2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaPonsel(
          judul: 'Koreksi dengan pembalikan',
          onKembali: () => _keDetail(context),
        ),
        Expanded(
          child: _gulir(const EdgeInsets.fromLTRB(20, 8, 20, 20), 18, [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Transaksi '),
                  TextSpan(
                    text: d.asal.voucher,
                    style: _mono.copyWith(color: c.tinta),
                  ),
                  const TextSpan(
                    text:
                        ' tetap tercatat. Sebuah pembalikan meniadakan '
                        'pengaruhnya, lalu transaksi koreksi mencatat yang '
                        'benar.',
                  ),
                ],
              ),
              style: judulKecil,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: _celahArea),
              child: IsianAlasan(
                controller: isi,
                onChanged: (v) => p.ubah(() => p.alasan = v),
                contoh: 'Contoh: Mata Anggaran keliru',
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Yang dibuat', style: judulKecil),
                const SizedBox(height: 8),
                for (final m in _mode)
                  _KartuPilih(
                    dipilih: p.mode == m.id,
                    onTap: () => p.ubah(() => p.mode = m.id),
                    radio: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.n,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          m.s,
                          style: TextStyle(fontSize: 13, color: c.tinta3),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (p.kor)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Mata Anggaran pada transaksi koreksi',
                    style: judulKecil,
                  ),
                  const SizedBox(height: 8),
                  for (final (i, m) in d.pilihanMa.indexed)
                    _KartuPilih(
                      dipilih: maPilih == m.$1,
                      onTap: () => p.ubah(() => p.ma = m.$1),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${d.maAsal.split(' ').first} ${m.$1}',
                                  style: _mono.copyWith(
                                    fontSize: 13,
                                    color: c.tinta2,
                                  ),
                                ),
                                Text(
                                  m.$2,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            i == 0 ? 'asal' : '',
                            style: TextStyle(fontSize: 13, color: c.tinta3),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            Kartu(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _sela([
                  const Text(
                    'Yang ikut terdampak',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Bulan terdampak: ${d.bulan} · Belum ditutup',
                    style: judulKecil,
                  ),
                  Text(
                    'Persetujuan pada transaksi asal tidak ikut pindah ke '
                    'transaksi koreksi.',
                    style: judulKecil,
                  ),
                  Text(
                    d.asal.allocations.any((a) => a.caseId != null)
                        ? 'Kasus uang muka, titipan atau penggantian biaya '
                              'yang terkait ikut berubah.'
                        : 'Tidak ada uang muka, titipan atau pencocokan '
                              'rekening koran yang terkait.',
                    style: judulKecil,
                  ),
                ], 6),
              ),
            ),
          ]),
        ),
        _Bawah([
          if (!ok) Text(sebab, style: judulKecil),
          TombolBersyarat(
            label: label,
            tindakan: label,
            alasan: ok ? '' : sebab,
            periksa: () => IsianAlasan.terisi(isi.text) ? '' : sebab,
            sudahMulai: false,
            warnaSiap: JenisTombol.utama,
            teksBelumRedup: true,
            onPressed: () async {
              final param = GoRouterState.of(context).pathParameters;
              p.ubah(() => p.alasan = isi.text);
              final r = await bukukanKoreksi(
                ref,
                d,
                alasan: isi.text,
                ma: p.kor ? maPilih : null,
              );
              p.ubah(() => p.pesan = r);
              if (!context.mounted) return;
              // The form leaves the stack: Back from hasil lands on detail;
              // a refusal shows on detail with the drafts to book.
              if (r == null) {
                context.pushReplacement(
                  Layar.koreksi.lokasi(param: param, anak: 'hasil'),
                );
              } else {
                context.naikKe(Layar.koreksi, param: param);
              }
            },
          ),
        ]),
      ],
    );
  }
}

/// A choice card: `permukaan`, selected 2 `tinta` / unselected 1 `garisTegas`.
/// [radio]: the "Yang dibuat" form (60 high, radius 14, padding 10 14, a
/// 24 px radio); else the Mata Anggaran form (56, radius 12, padding 8 14).
class _KartuPilih extends StatelessWidget {
  const _KartuPilih({
    required this.dipilih,
    required this.onTap,
    required this.child,
    this.radio = false,
  });
  final bool dipilih, radio;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final r = radio ? 14.0 : 12.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Tekan(
        onTap: onTap,
        dipilih: dipilih,
        radius: r,
        child: Container(
          constraints: BoxConstraints(minHeight: radio ? 60 : 56),
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: radio ? 10 : 8,
          ),
          decoration: ShapeDecoration(
            color: c.permukaan,
            shape: GarisBorder.penuh(
              dipilih ? c.tinta : c.garisTegas,
              tebal: dipilih ? 2 : 1,
              radius: r,
            ),
          ),
          child: Row(
            children: [
              if (radio) ...[
                // A content-box div: 20 inside the 2 px ring, 24 outside.
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: c.tinta, width: 2),
                  ),
                  child: dipilih
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.tinta,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

// ── hasil ─────────────────────────────────────────────────────────────────

class _Hasil extends ConsumerWidget {
  const _Hasil();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final d = _data(context, ref);
    if (d == null) return const SizedBox.shrink();
    final balik = d.pembalikan, ganti = d.pengganti;
    final kor = ganti != null && ganti.isPosted;
    final asal = d.asal.voucher ?? '';
    final alasan = balik == null
        ? ''
        : ref.watch(alasanPembalikanProvider(d.asal.id));
    final caption = TextStyle(fontSize: 13, color: c.tinta3);
    Widget tali(int tunda) => Padding(
      padding: const EdgeInsets.only(left: 28),
      child: Row(
        children: [
          Gerak(
            Kerangka.tali(18),
            lama: const Duration(milliseconds: 250),
            tunda: Duration(milliseconds: tunda),
            child: ColoredBox(color: c.tinta),
          ),
        ],
      ),
    );
    Widget muncul(int tunda, Widget w) => Gerak(
      Kerangka.muncul,
      lama: const Duration(milliseconds: 400),
      tunda: Duration(milliseconds: tunda),
      child: w,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: const Text(
                  'Koreksi dibukukan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                kor
                    ? 'Dua No. Bukti baru dibukukan bersama sebagai satu '
                          'rangkaian.'
                    : 'Satu No. Bukti baru dibukukan.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _KartuRantai(
                  noBukti: asal,
                  lencana: Gerak(
                    Kerangka.capTegak,
                    lama: const Duration(milliseconds: 500),
                    tunda: const Duration(milliseconds: 200),
                    child: const LencanaStatus(
                      'Dibalik',
                      bentuk: BentukLencana.garis,
                    ),
                  ),
                  judul: 'Transaksi asal',
                  jumlah: rp(d.rincian.baris.jumlah),
                  keterangan:
                      '${d.maAsal} · tetap tampil di daftar dan laporan',
                  dibalik: true,
                ),
                tali(500),
                Gerak(
                  Kerangka.balik,
                  lama: const Duration(milliseconds: 500),
                  tunda: const Duration(milliseconds: 700),
                  kurva: PalakatMotion.keluar,
                  child: _KartuRantai(
                    noBukti: balik?.voucher ?? '',
                    judul: 'Pembalikan',
                    jumlah: balik == null ? '' : rp(signedAmount(balik)),
                    keterangan:
                        'Pembalikan dari No. Bukti $asal · tidak dapat diubah '
                        'atau dibalik',
                  ),
                ),
                if (kor) ...[
                  tali(1200),
                  muncul(
                    1400,
                    _KartuRantai(
                      noBukti: ganti.voucher ?? '',
                      judul: 'Transaksi koreksi',
                      jumlah: rp(signedAmount(ganti)),
                      keterangan:
                          'Koreksi dari No. Bukti $asal · '
                          '${labelKoreksi(ref, ganti)}',
                    ),
                  ),
                ],
                muncul(
                  1700,
                  Container(
                    margin: const EdgeInsets.only(top: 18),
                    padding: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: c.tinta, width: 1.5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            'Pengaruh pada Saldo buku ${d.kasBank}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          pengaruhTeks(d.pengaruh),
                          style: _mono.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (alasan.isNotEmpty)
                  muncul(
                    1700,
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Alasan: $alasan', style: caption),
                    ),
                  ),
              ],
            ),
          ),
        ),
        _Bawah([
          Tombol(
            'Kembali ke transaksi asal',
            onPressed: () => _keDetail(context),
            jenis: JenisTombol.kedua,
          ),
        ]),
      ],
    );
  }
}

/// One card of the phone chain (the board's own padding 12 16 and badges;
/// RangkaianKoreksi draws the preview and web forms).
class _KartuRantai extends StatelessWidget {
  const _KartuRantai({
    required this.noBukti,
    required this.judul,
    required this.jumlah,
    required this.keterangan,
    this.lencana,
    this.dibalik = false,
  });
  final String noBukti, judul, jumlah, keterangan;
  final Widget? lencana;
  final bool dibalik;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final warna = dibalik ? c.tinta2 : c.tinta;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: c.permukaan,
        shape: GarisBorder.penuh(dibalik ? c.tinta3 : c.tinta, radius: 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                noBukti,
                style: _mono.copyWith(fontSize: 13, color: c.tinta2),
              ),
              lencana ??
                  const LencanaStatus(
                    'Dibukukan',
                    bentuk: BentukLencana.tinta,
                    kepala: true,
                  ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    judul,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: warna,
                    ),
                  ),
                ),
                Text(
                  jumlah,
                  style: _mono.copyWith(
                    fontWeight: FontWeight.w500,
                    color: warna,
                  ),
                ),
              ],
            ),
          ),
          Text(keterangan, style: TextStyle(fontSize: 13, color: c.tinta3)),
        ],
      ),
    );
  }
}

// ── kejadian ──────────────────────────────────────────────────────────────

class _Kejadian extends ConsumerStatefulWidget {
  const _Kejadian();
  @override
  ConsumerState<_Kejadian> createState() => _KejadianState();
}

class _KejadianState extends ConsumerState<_Kejadian> {
  TextEditingController? _kejadian;

  /// The two optional fields, only to know the form was typed into.
  String _dampak = '', _pj = '';

  @override
  void dispose() {
    _kejadian?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final p = _papan(context);
    final d = _data(context, ref);
    if (d == null) return const SizedBox.shrink();
    final isi = _kejadian ??= TextEditingController(text: p.kejadian);
    const sebab = 'Penjelasan belum diisi.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaPonsel(
          judul: 'Catat kejadian',
          onKembali: () => _keDetail(context),
        ),
        Expanded(
          child: _gulir(const EdgeInsets.fromLTRB(20, 8, 20, 20), 16, [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: c.tinta,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Kejadian setelah tutup buku hanya mencatat. Kejadian tidak '
                'mengubah angka apa pun, tidak menghapus selisih, dan tidak '
                'menghilangkan hambatan tutup buku.',
                style: TextStyle(fontSize: 14, color: c.permukaan),
              ),
            ),
            _Rincian([
              ('Periode', '${d.bulan} · Sudah ditutup', false),
              ('Transaksi', d.asal.voucher ?? '', true),
            ]),
            Padding(
              padding: const EdgeInsets.only(bottom: _celahArea),
              child: IsianAlasan(
                controller: isi,
                onChanged: (v) => p.ubah(() => p.kejadian = v),
                label: 'Penjelasan',
                baris: 3,
                contoh: 'Apa yang ditemukan, apa adanya',
              ),
            ),
            IsianTeks(
              label: 'Dampak pada rekonsiliasi',
              jarakLabel: 6,
              petunjuk: 'Misalnya: tidak ada',
              onChanged: (v) => setState(() => _dampak = v),
            ),
            IsianTeks(
              label: 'Penanggung jawab',
              jarakLabel: 6,
              petunjuk: 'Nama dan jabatan',
              onChanged: (v) => setState(() => _pj = v),
            ),
            Text(
              'Penyelesaian keuangan dicatat terpisah dari penjelasan, '
              'setelah ada keputusan Jemaat.',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ]),
        ),
        _Bawah([
          TombolBersyarat(
            label: 'Catat kejadian',
            tindakan: 'Catat kejadian',
            alasan: IsianAlasan.terisi(p.kejadian) ? '' : sebab,
            periksa: () => IsianAlasan.terisi(isi.text) ? '' : sebab,
            // Rule A02: the sentence the board lacks, once typed into.
            sudahMulai: [p.kejadian, _dampak, _pj].any((t) => t.isNotEmpty),
            teksBelumRedup: true,
            onPressed: () async {
              p.ubah(() => p.kejadian = isi.text);
              final r = await catatKejadian(
                ref,
                d,
                penjelasan: isi.text,
                dampak: _dampak,
                penanggungJawab: _pj,
              );
              p.ubah(() => p.pesan = r);
              if (context.mounted) _keDetail(context);
            },
          ),
        ]),
      ],
    );
  }
}
