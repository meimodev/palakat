import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../providers/actor.dart';
import '../../providers/clock.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/keuangan/dokumen.dart';
import '../../providers/keuangan/isian.dart';
import '../../providers/keuangan/rinci_transaksi.dart';
import '../../providers/keuangan/transaksi.dart';
import '../../providers/repositories_keuangan.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

const _filter = ['Semua', 'Draf', 'Dibukukan', 'Dibalik', 'Dibatalkan'];

/// CSS half-leading for the two large texts (h1 26, amount 32), where
/// Flutter's proportional default sits 2–4 px lower than Chrome. ponytail:
/// small text keeps the default because Chrome's rounded line boxes match it
/// better; HalamanWeb could set this for all text (sharedNeeds).
const _rata = TextLeadingDistribution.even;

/// Web · Transaksi dan koreksi (spec 02-awal.md, WebTransaksi): the running
/// month's transactions from [daftarTransaksiProvider] (drafts first, then
/// newest first) and the selected row's [rincianTransaksiProvider] panel.
/// Layar.transaksiRinci opens it with that row selected; tablet shows it as
/// TabTransaksi.
class WebTransaksiScreen extends ConsumerStatefulWidget {
  const WebTransaksiScreen({super.key});

  @override
  ConsumerState<WebTransaksiScreen> createState() => _WebTransaksiScreenState();
}

class _WebTransaksiScreenState extends ConsumerState<WebTransaksiScreen> {
  String _f = 'Semua';
  String? _pilih;

  /// Booked here and selected: the sweep and the stamp.
  String? _baru;

  /// The last refused command, for the row it was about.
  ({String id, Refusal r})? _tolak;

  void _pilihBaris(String id) => setState(() => _pilih = id);

  Future<void> _bukukan(Transaction t) async {
    final a = ref.read(actorProvider);
    if (a == null) return;
    final r = await ref
        .read(transactionRepositoryProvider)
        .finalize(
          a,
          t.id,
          expectedRevision: t.revision,
          idempotencyKey: kunciBaru(a.personId, ref.read(clockProvider)),
        );
    if (!mounted) return;
    setState(() {
      _baru = r.isOk ? t.id : null;
      _tolak = switch (r) {
        Refused(:final refusal) => (id: t.id, r: refusal),
        Ok() => null,
      };
    });
  }

  /// "Ubah", "Pilih Mata Anggaran": Catat opens with this draft.
  void _ubah(Transaction t) {
    ref
        .read(isianCatatProvider.notifier)
        .buka(
          IsianCatat(
            jenis: t.type,
            jumlah: t.total,
            uraian: t.description,
            tanggal: t.effectiveDate,
            drafId: t.id,
          ),
        );
    context.dorongKe(Layar.catat);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final bulan = ref.watch(bulanBukuProvider);
    final berjalan = bulan.berjalan;
    final semua = [
      ...ref.watch(
        daftarTransaksiProvider((
          periodId: berjalan?.id,
          saring: SaringTransaksi.semua,
          accountId: null,
          fundId: null,
        )),
      ),
      ...ref.watch(drafBulanLaluProvider),
    ];
    // Drafts first, as drawn; each group newest first.
    final data = [
      ...semua.where((b) => b.transaksi.isDraft),
      ...semua.where((b) => !b.transaksi.isDraft),
    ];
    final drafTutup = ref.watch(berandaKeuanganProvider).drafBulanTutup;
    final idRute = GoRouterState.of(context).pathParameters['id'];
    final pilih = _pilih ?? idRute ?? data.firstOrNull?.transaksi.id;
    final rinci = pilih == null
        ? null
        : ref.watch(rincianTransaksiProvider(pilih));
    final bulanTeks = berjalan == null
        ? 'Pilih bulan'
        : '${namaBulan(berjalan)} · '
              '${berjalan.isClosed ? 'Sudah ditutup' : 'Belum ditutup'}';

    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        layarKeuangan: true,
        nav: const NavSamping(item: navKeuangan, aktif: 1),
        isi: [
          _Kepala(bulan: bulanTeks),
          DeretTautan(
            web: true,
            anak: [
              for (final (:t, :ke, :param) in [
                (
                  t: 'Daftar Bukti Kas',
                  ke: Layar.bukti,
                  param: const <String, String>{},
                ),
                if (pilih != null)
                  (
                    t: 'Koreksi dengan pembalikan',
                    ke: Layar.koreksi,
                    param: {'id': pilih},
                  ),
                if (drafTutup.isNotEmpty)
                  (
                    t: 'Draf di bulan yang sudah ditutup',
                    ke: Layar.draf,
                    param: {'id': drafTutup.first.id},
                  ),
                (
                  t: 'Pengembalian',
                  ke: Layar.pengembalian,
                  param: const <String, String>{},
                ),
                (t: 'Cari', ke: Layar.cari, param: const <String, String>{}),
              ])
                Tautan(
                  ke: ke,
                  param: param,
                  child: SizedBox(
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1,
                      child: TautanTeks(t),
                    ),
                  ),
                ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in _filter)
                ChipSatu(
                  teks: f,
                  dipilih: _f == f,
                  padding: 16,
                  onTap: () => setState(() => _f = f),
                ),
            ],
          ),
          BarisLentur(
            jarak: 24,
            anak: [
              Lentur(dasar: 520, tumbuh: 999, child: _tabel(c, data, pilih)),
              if (rinci != null)
                Lentur(
                  dasar: 360,
                  child: _Panel(
                    r: rinci,
                    baru: _baru == rinci.transaksi.id,
                    penolakan: _tolak?.id == rinci.transaksi.id
                        ? _tolak!.r
                        : null,
                    onBukukan: () => _bukukan(rinci.transaksi),
                    onUbah: () => _ubah(rinci.transaksi),
                    pilihDokumen: ref
                        .read(pilihanDokumenProvider.notifier)
                        .pilih,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// A row passes the chip: "Draf" covers checked drafts too.
  bool _lolos(BarisTransaksi b) => switch (_f) {
    'Semua' => true,
    'Draf' => b.transaksi.isDraft,
    final f => b.status == f,
  };

  Widget _tabel(PalakatWarna c, List<BarisTransaksi> data, String? pilih) {
    Widget baris({
      required Widget status,
      required Widget tgl,
      required Widget ur,
      required Widget jm,
    }) => Row(
      children: [
        SizedBox(width: 104, child: status),
        const SizedBox(width: 12),
        SizedBox(width: 88, child: tgl),
        const SizedBox(width: 12),
        Expanded(child: ur),
        const SizedBox(width: 12),
        SizedBox(width: 124, child: jm),
      ],
    );

    final isi = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.tinta2,
            ),
            child: baris(
              status: const Text('Status'),
              tgl: const Text('Tanggal'),
              ur: const Text('Uraian · No. Bukti · Kas/\u2060Bank'),
              jm: const Text('Jumlah (Rp)', textAlign: TextAlign.right),
            ),
          ),
        ),
        for (final r in data)
          if (_lolos(r))
            () {
              final t = r.transaksi;
              final on = pilih == t.id;
              final batal = t.status == TransactionStatus.cancelled;
              final cat = ref
                  .watch(rincianTransaksiProvider(t.id))
                  ?.catatanBaris;
              return Tekan(
                onTap: () => _pilihBaris(t.id),
                dipilih: on,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 56),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    color: on
                        ? c.lautLembut
                        : t.isDraft
                        ? c.kertas
                        : c.permukaan,
                    border: Border(top: BorderSide(color: c.garis)),
                  ),
                  // box-shadow: inset 3px 0 0 laut
                  foregroundDecoration: on
                      ? BoxDecoration(
                          border: Border(
                            left: BorderSide(color: c.laut, width: 3),
                          ),
                        )
                      : null,
                  child: DefaultTextStyle.merge(
                    style: const TextStyle(fontSize: 14),
                    child: baris(
                      status: Align(
                        alignment: Alignment.centerLeft,
                        child: _Lencana(r.status, r.status),
                      ),
                      tgl: Text(r.tanggal, style: TextStyle(color: c.tinta2)),
                      ur: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.description,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: t.voucher == null
                                      ? '—'
                                      : _putusKode(t.voucher!),
                                  style: const TextStyle(
                                    fontFamily: PalakatText.mono,
                                  ),
                                ),
                                TextSpan(text: ' · ${r.kasBank}'),
                              ],
                            ),
                            style: TextStyle(fontSize: 13, color: c.tinta2),
                          ),
                          if (cat != null)
                            Text(
                              _putusKode(cat),
                              style: TextStyle(fontSize: 13, color: c.tinta3),
                            ),
                        ],
                      ),
                      jm: Text(
                        rp(r.jumlah),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: PalakatText.mono,
                          fontWeight: FontWeight.w500,
                          color: t.isDraft || batal ? c.tinta3 : c.tinta,
                          decoration: batal ? TextDecoration.lineThrough : null,
                          decorationColor: c.tinta3,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }(),
      ],
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, k) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: k.maxWidth < 470 ? 470 : k.maxWidth,
            child: isi,
          ),
        ),
      ),
    );
  }
}

/// The board's `B` badge map (13/700, padding 3 9, radius 6, 1.5 line). It
/// wraps when squeezed, as the panel's long Draf label does. Dibatalkan is a
/// `kertas` field and edge here (LencanaStatus `abu` uses `garis`; board wins).
class _Lencana extends StatelessWidget {
  const _Lencana(this.st, this.label);
  final String st, label;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final (GarisBorder garis, Color? isi, Color teks) = switch (st) {
      'Draf' || 'Sudah diperiksa' => (
        GarisBorder.putus(c.putus, radius: 6),
        null,
        c.tinta2,
      ),
      'Dibukukan' => (
        GarisBorder.penuh(c.tinta, radius: 6),
        c.tinta,
        c.permukaan,
      ),
      'Dibalik' => (
        GarisBorder.penuh(c.tinta3, radius: 6),
        c.permukaan,
        c.tinta2,
      ),
      _ => (GarisBorder.penuh(c.kertas, radius: 6), c.kertas, c.tinta2),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: ShapeDecoration(color: isi, shape: garis),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: teks,
        ),
      ),
    );
  }
}

/// Max-content and min-content (widest word) width of [t] in [g].
(double, double) _ukurTeks(BuildContext context, String t, TextStyle g) {
  final skala = MediaQuery.textScalerOf(context);
  double w(String x) {
    final tp = TextPainter(
      text: TextSpan(text: x, style: g),
      textDirection: TextDirection.ltr,
      textScaler: skala,
    )..layout();
    final h = tp.width.ceilToDouble();
    tp.dispose();
    return h;
  }

  // Words end at spaces and at the break points [_putusKode] marks.
  final kata = t.split(RegExp('[ \u200B]'));
  return (w(t), kata.map(w).reduce((a, b) => a > b ? a : b));
}

/// CSS `flex: 0 1 auto` items ((max, min) content widths) in a row [w] wide
/// with [jarak] gaps: they shrink in proportion to their width, never below
/// their min-content.
List<double> _susut(List<(double, double)> u, double jarak, double w) {
  final ukuran = [for (final x in u) x.$1];
  final beku = List.filled(u.length, false);
  while (true) {
    var tetap = jarak * (u.length - 1), dasar = 0.0;
    for (var i = 0; i < u.length; i++) {
      if (beku[i]) {
        tetap += ukuran[i];
      } else {
        dasar += u[i].$1;
      }
    }
    final kurang = tetap + dasar - w;
    if (kurang <= 0 || dasar == 0) return ukuran;
    var langgar = false;
    for (var i = 0; i < u.length; i++) {
      if (beku[i]) continue;
      ukuran[i] = u[i].$1 - kurang * u[i].$1 / dasar;
      if (ukuran[i] < u[i].$2) {
        ukuran[i] = u[i].$2;
        beku[i] = true;
        langgar = true;
      }
    }
    if (!langgar) return ukuran;
  }
}

/// h1, month pill, Impor, + Catat transaksi: `flex-wrap`, the h1
/// `flex: 1 1 200px`, the links at their own width.
class _Kepala extends StatelessWidget {
  const _Kepala({required this.bulan});

  /// '{Bulan} {tahun} · Belum ditutup'.
  final String bulan;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style;
    final skala = MediaQuery.textScalerOf(context);
    double lebar(String t, FontWeight b, double tepi) {
      final tp = TextPainter(
        text: TextSpan(
          text: t,
          style: dasar.copyWith(fontWeight: b),
        ),
        textDirection: TextDirection.ltr,
        textScaler: skala,
      )..layout();
      final w = tp.width;
      tp.dispose();
      return (w + tepi).ceilToDouble();
    }

    return BarisLentur(
      jarak: 12,
      rata: CrossAxisAlignment.center,
      anak: [
        const Lentur(
          dasar: 200,
          child: Text(
            'Transaksi',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              leadingDistribution: _rata,
            ),
          ),
        ),
        Lentur(
          dasar: lebar(bulan, FontWeight.w600, 34),
          tumbuh: 0,
          child: Tautan(
            ke: Layar.pilihBulan,
            radius: 999,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: c.permukaan,
                border: Border.all(color: c.garisTegas),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                bulan,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        Lentur(
          dasar: lebar('Impor', FontWeight.w700, 35),
          tumbuh: 0,
          child: const Tombol(
            'Impor',
            onPressed: null,
            ke: Layar.impor,
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.kecil,
          ),
        ),
        Lentur(
          dasar: lebar('+ Catat transaksi', FontWeight.w700, 36),
          tumbuh: 0,
          child: const Tombol(
            '+ Catat transaksi',
            onPressed: null,
            ke: Layar.catat,
            ukuran: UkuranTombol.kecil,
            paddingH: 18,
          ),
        ),
      ],
    );
  }
}

/// The `aside`: booking card, facts, actions, Riwayat for row [p].
class _Panel extends StatelessWidget {
  const _Panel({
    required this.r,
    required this.baru,
    required this.penolakan,
    required this.onBukukan,
    required this.onUbah,
    required this.pilihDokumen,
  });

  final RincianTransaksi r;

  /// Booked here and selected: the sweep and the stamp.
  final bool baru;

  /// A refused "Periksa dan bukukan" of this row.
  final Refusal? penolakan;
  final VoidCallback onBukukan, onUbah;
  final void Function(String id) pilihDokumen;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final t = r.transaksi;
    final b = r.baris;
    final draf = t.isDraft;
    final rw = r.riwayat;
    const h2 = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
    const mono = PalakatText.mono;

    final kartu = Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: draf ? null : c.permukaan,
        shape: draf
            ? GarisBorder.putus(c.putus, radius: 16)
            : GarisBorder.penuh(c.tinta, radius: 16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, k) {
                    final label = draf
                        ? '${b.status} · belum masuk saldo'
                        : b.status;
                    final kanan = _putusKode(
                      baru ? 'No. Bukti ${b.nomor}' : b.nomor,
                    );
                    final gKanan = TextStyle(
                      fontFamily: mono,
                      fontSize: 14,
                      fontWeight: baru ? FontWeight.w600 : FontWeight.w400,
                      color: baru ? c.laut : c.tinta2,
                    );
                    final dasar = DefaultTextStyle.of(context).style;
                    final (bMaks, bMin) = _ukurTeks(
                      context,
                      label,
                      dasar.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                    );
                    final (kMaks, kMin) = _ukurTeks(
                      context,
                      kanan,
                      dasar.merge(gKanan),
                    );
                    // badge: padding 18 + line 3; stamp: padding 20 + line 4
                    final tepi = baru ? 24.0 : 0.0;
                    final w = _susut(
                      [(bMaks + 21, bMin + 21), (kMaks + tepi, kMin + tepi)],
                      8,
                      k.maxWidth,
                    );
                    final teksKanan = Text(kanan, style: gKanan);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: w[0],
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _Lencana(b.status, label),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: w[1],
                          child: baru
                              ? Gerak(
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
                                      border: Border.all(
                                        color: c.laut,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: teksKanan,
                                  ),
                                )
                              : teksKanan,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  rp(b.jumlah),
                  style: TextStyle(
                    fontFamily: mono,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -1,
                    leadingDistribution: _rata,
                    color: draf || t.status == TransactionStatus.cancelled
                        ? c.tinta2
                        : c.tinta,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.description,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  '${b.kasBank} · tanggal transaksi ${b.tanggal}',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ],
            ),
          ),
          if (baru) const SapuTinta(),
        ],
      ),
    );

    final fakta = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < r.fakta.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: i == 0
                  ? null
                  : BoxDecoration(
                      border: Border(top: BorderSide(color: c.garis)),
                    ),
              child: _BarisFakta(r.fakta[i]),
            ),
        ],
      ),
    );

    final tindakan = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text('Yang dapat dilakukan', style: h2),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in r.aksi)
              Tombol(
                a.label,
                onPressed: switch (a.jenis) {
                  JenisAksi.bukukan => onBukukan,
                  JenisAksi.ubah => onUbah,
                  JenisAksi.tautan when a.dokumen != null => () {
                    pilihDokumen(a.dokumen!);
                    context.dorongKe(a.ke!, param: a.param, anak: a.anak);
                  },
                  JenisAksi.tautan => null,
                },
                ke: a.dokumen == null ? a.ke : null,
                param: a.param,
                anak: a.anak,
                jenis: a.utama ? JenisTombol.utama : JenisTombol.kedua,
                ukuran: UkuranTombol.kecil,
                lebarPenuh: false,
                ukuranTeks: 14,
              ),
          ],
        ),
        if (penolakan case final p?) ...[
          const SizedBox(height: 8),
          Penolakan(
            tindakan: p.action,
            sebab: p.whoCanAct == null
                ? p.because
                : '${p.because} Yang perlu bertindak: ${p.whoCanAct}.',
            jalan: const [],
            ukuranTeks: 14,
          ),
        ],
        const SizedBox(height: 8),
        Text(r.catatan, style: TextStyle(fontSize: 13, color: c.tinta3)),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text('Riwayat', style: h2),
        ),
        for (final t in rw) ...[
          const SizedBox(height: 4),
          Text(t, style: TextStyle(fontSize: 14, color: c.tinta2)),
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        kartu,
        const SizedBox(height: 14),
        fakta,
        const SizedBox(height: 14),
        tindakan,
      ],
    );
  }
}

/// Key and value, `justify-content: space-between; gap: 16px`. Both shrink
/// as CSS flex items do ([_susut]).
class _BarisFakta extends StatelessWidget {
  const _BarisFakta(this.f);
  final FaktaTransaksi f;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style.copyWith(fontSize: 14);
    final gk = dasar.copyWith(color: c.tinta2);
    final gv = dasar.copyWith(
      fontWeight: FontWeight.w600,
      color: f.$3 ? c.bata : c.tinta,
    );
    return LayoutBuilder(
      builder: (context, k) {
        final [wk, wv] = _susut(
          [_ukurTeks(context, f.$1, gk), _ukurTeks(context, f.$2, gv)],
          16,
          k.maxWidth,
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: wk,
              child: Text(f.$1, style: gk),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: wv,
              child: Text(f.$2, style: gv, textAlign: TextAlign.right),
            ),
          ],
        );
      },
    );
  }
}

/// Chrome breaks a voucher code (BKU-yyyy-nnnn) only after a hyphen that follows a
/// digit; Flutter breaks it elsewhere. Mark those places, and keep the rest.
String _putusKode(String s) => s
    .replaceAllMapped(RegExp(r'([A-Z])-'), (m) => '${m[1]}\u2060-')
    .replaceAllMapped(RegExp(r'(\d)-'), (m) => '${m[1]}-\u200B');
