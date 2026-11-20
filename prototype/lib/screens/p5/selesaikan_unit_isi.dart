import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../providers/actor.dart';
import '../../providers/clock.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/akhir_bulan.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/repositories_keuangan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

/// What the Bendahara Jemaat does for a unit's blocker (DL33).
enum _Aksi { pindah, batal, pastikan, bebaskan }

/// SelesaikanUnit and WebSelesaikanUnit (spec 21): the unit blockers of the
/// next month to close, each cleared with a reason
/// (`PeriodRepository.clearUnitBlocker`, `waive`; a draft can also be
/// cancelled); the unit's treasurer is told. Views: the list, the reason
/// form of one item, and what this visit cleared.
mixin KeadaanSelesaikan<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Sits inside the scrolling body, to find its Scrollable.
  final kunciIsi = GlobalKey();
  final alasan = TextEditingController();

  /// The item whose reason form is open, and the action.
  ButirHambatan? _butir;
  _Aksi? _aksi;
  Refusal? _tolak;

  /// What this visit cleared: (title, line).
  final List<(String, String)> _selesai = [];

  @override
  void dispose() {
    alasan.dispose();
    super.dispose();
  }

  void _buka(ButirHambatan b, _Aksi a) {
    setState(() {
      _butir = b;
      _aksi = a;
      _tolak = null;
      alasan.clear();
    });
    _keAtas();
  }

  void _segarkan() => setState(() {});

  void _kembali() {
    setState(() {
      _butir = null;
      _tolak = null;
    });
    _keAtas();
  }

  void _keAtas() => WidgetsBinding.instance.addPostFrameCallback((_) {
    final c = kunciIsi.currentContext;
    if (c != null) Scrollable.maybeOf(c)?.position.jumpTo(0);
  });

  /// The new date of a moved draft: today in the running month, else the
  /// first day of the next open month (RD09).
  Tanggal? _tanggalBaru(Transaction t) {
    final hari = ref.read(hariIniProvider);
    final ke = ref
        .read(bulanBukuProvider)
        .semua
        .where((p) => !p.isClosed && p.start > t.effectiveDate)
        .firstOrNull;
    return ke == null ? null : (ke.contains(hari) ? hari : ke.start);
  }

  Future<void> _jalankan(String judul, String baris) async {
    final b = _butir, a = _aksi;
    final why = alasan.text.trim();
    if (b == null || a == null || why.isEmpty) return;
    final per = ref.read(periodRepositoryProvider);
    final tx = ref.read(transactionRepositoryProvider);
    final rek = ref.read(reconciliationRepositoryProvider);
    final blok = b.blocker;
    final Result<Object?>? r = switch (a) {
      _Aksi.pindah => await perintah(
        ref,
        (x, k) => per.clearUnitBlocker(
          x,
          BlockerKind.openDraft,
          blok.transactionId!,
          reason: why,
          expectedRevision: tx.get(blok.transactionId!)?.revision ?? 0,
          idempotencyKey: k,
        ),
      ),
      _Aksi.batal => await perintah(
        ref,
        (x, k) => tx.cancel(
          x,
          blok.transactionId!,
          reason: why,
          expectedRevision: tx.get(blok.transactionId!)?.revision ?? 0,
          idempotencyKey: k,
        ),
      ),
      _Aksi.pastikan => await perintah(
        ref,
        (x, k) => per.clearUnitBlocker(
          x,
          BlockerKind.notReconciled,
          blok.accountId!,
          reason: why,
          expectedRevision:
              rek
                  .session(
                    blok.accountId!,
                    ref.read(bulanBukuProvider).berikutDitutup!.id,
                  )
                  ?.revision ??
              0,
          idempotencyKey: k,
        ),
      ),
      _Aksi.bebaskan => await perintah(
        ref,
        (x, k) => per.clearUnitBlocker(
          x,
          blok.kind,
          blok.fundId!,
          reason: why,
          expectedRevision:
              ref.read(bulanBukuProvider).berikutDitutup?.revision ?? 0,
          idempotencyKey: k,
        ),
      ),
    };
    if (!mounted) return;
    if (r == null || r.refusal != null) {
      setState(() => _tolak = r?.refusal);
      return;
    }
    final a0 = ref.read(actorProvider);
    final saya = ref.read(peopleRepositoryProvider).person(a0?.personId ?? '');
    final saat = tglJam(ref.read(clockProvider).now());
    setState(() {
      _selesai.add((
        judul,
        '$baris. Diselesaikan oleh Bendahara Jemaat (alasan: $why) · '
            '${saya?.name}, $saat',
      ));
      _butir = null;
    });
    _keAtas();
  }
}

/// The blocks of the current view (gap 16 between them, set by the caller).
/// [web] puts the reason form in the two-column row.
List<Widget> blokSelesaikan(
  BuildContext context,
  KeadaanSelesaikan s, {
  required bool web,
}) {
  final ref = s.ref;
  final c = context.warna;
  Text kecil(String t) =>
      Text(t, style: TextStyle(fontSize: 13, color: c.tinta3));
  const draf = LencanaStatus('Draf', bentuk: BentukLencana.draf);
  const dikerjakan = LencanaStatus(
    'Sedang dikerjakan',
    bentuk: BentukLencana.garis,
  );
  final tb = ref.watch(tutupBukuProvider);
  final p = tb.periode;
  final nama = p == null ? '' : namaBulan(p);
  final tx = ref.watch(transactionRepositoryProvider);
  final org = ref.watch(orgRepositoryProvider);
  final orang = ref.watch(peopleRepositoryProvider);
  final dana = ref.watch(fundRepositoryProvider);
  String unit(String? id) => org.scope(id ?? '')?.name ?? '';
  final daftar = [
    for (final h in tb.hambatan)
      if (h.dariUnit) h,
  ];
  Widget kedua(String t, ButirHambatan b, _Aksi a) => Tombol(
    t,
    onPressed: () => s._buka(b, a),
    jenis: JenisTombol.kedua,
    ukuran: UkuranTombol.sedang,
  );

  /// The card of [b] (title, badge, lines) and its actions.
  (String, Widget, List<Widget>, List<Widget>) isi(ButirHambatan b) {
    final blok = b.blocker;
    switch (blok.kind) {
      case BlockerKind.openDraft:
        final t = tx.get(blok.transactionId!);
        final pembuat = orang.person(t?.createdBy ?? '');
        return (
          'Draf · ${t?.description}',
          draf,
          [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text:
                        '${unit(blok.unitScopeId)} · bertanggal '
                        '${t?.effectiveDate} · ',
                  ),
                  TextSpan(
                    text: rp(-(t?.total ?? 0)),
                    style: const TextStyle(
                      fontFamily: PalakatText.mono,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              strutStyle: barisCampur(context),
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            kecil('Dicatat ${pembuat?.name}. Menghalangi tutup buku $nama.'),
          ],
          [
            kedua('Pindah tanggal', b, _Aksi.pindah),
            kedua('Batalkan', b, _Aksi.batal),
          ],
        );
      case BlockerKind.notReconciled ||
          BlockerKind.cashCountMissing ||
          BlockerKind.statementMissing:
        final r = ref.watch(rekonAkunProvider(blok.accountId!));
        final hitung = r?.hitung;
        return (
          'Rekonsiliasi ${r?.akun.name} · $nama',
          dikerjakan,
          [
            _Info('Saldo buku', rp(r?.buku ?? 0)),
            _Info(
              hitung == null
                  ? 'Hasil hitung kas'
                  : 'Hasil hitung kas (dicatat unit ${tgl(hitung.countedAt)})',
              r?.amati == null ? kosong : rp(r!.amati!),
            ),
            if ((r?.selisih ?? 0) != 0)
              _Info(
                'Selisih belum dijelaskan',
                rp(r!.selisih!.abs()),
                berat: FontWeight.w600,
                warna: c.bata,
              ),
            kecil(
              r?.amati == null
                  ? 'Bendahara ${unit(blok.unitScopeId)} belum menghitung kas.'
                  : 'Bendahara ${unit(blok.unitScopeId)} belum memastikan.',
            ),
          ],
          [
            if (r?.amati != null && r!.selisih == 0)
              kedua('Pastikan dari hitung kas unit', b, _Aksi.pastikan),
            if ((r?.selisih ?? 0) != 0)
              Penolakan(
                tindakan: 'Pastikan rekonsiliasi',
                sebab: 'selisih belum dijelaskan ${rp(r!.selisih!.abs())}.',
                jalan: const [],
              ),
          ],
        );
      case BlockerKind.readinessMissing || BlockerKind.readinessInvalidated:
        final d = dana.fund(blok.fundId!);
        return (
          'Kesiapan peruntukan ${d?.name} · $nama',
          LencanaStatus(
            blok.kind == BlockerKind.readinessMissing
                ? 'Belum ada'
                : 'Perlu lagi',
            bentuk: BentukLencana.bata,
          ),
          [
            kecil(
              'Bendahara unit: ${orang.person(d?.preparerPersonId ?? '')?.name}. '
              'Menghalangi tutup buku $nama.',
            ),
          ],
          [kedua('Bebaskan', b, _Aksi.bebaskan)],
        );
      default:
        return (b.judul, dikerjakan, [kecil(b.sub)], const []);
    }
  }

  // The reason form of one item.
  final buka = s._butir;
  if (buka != null) {
    final (judul, lencana, baris, _) = isi(buka);
    final t = buka.blocker.transactionId == null
        ? null
        : tx.get(buka.blocker.transactionId!);
    final baru = t == null ? null : s._tanggalBaru(t);
    final (aksiLabel, judulForm, garis) = switch (s._aksi!) {
      _Aksi.pindah => (
        'Pindah tanggal',
        'Pindah tanggal · ${t?.description}',
        'Dipindah ke $baru',
      ),
      _Aksi.batal => (
        'Batalkan',
        'Batalkan · ${t?.description}',
        'Dibatalkan, tanpa nomor bukti',
      ),
      _Aksi.pastikan => (
        'Pastikan dari hitung kas unit',
        judul,
        'Dipastikan dari hitung kas yang dicatat unit',
      ),
      _Aksi.bebaskan => ('Bebaskan', judul, 'Dibebaskan'),
    };
    final kartu = _KartuUnit(
      judul: judulForm,
      lencana: lencana,
      anak: [
        ...baris,
        if (s._aksi == _Aksi.pindah) ...[
          _Info('Tanggal transaksi baru', '$baru', mono: false),
          kecil(
            'Hanya bulan yang Belum ditutup. Draf tetap Draf; tidak ada yang '
            'dibukukan.',
          ),
        ],
      ],
    );
    final kosongAlasan = s.alasan.text.trim().isEmpty;
    final tombol = BarisTombol(
      anak: [
        Tombol(
          aksiLabel,
          onPressed: kosongAlasan ? null : () => s._jalankan(judul, garis),
          jenis: JenisTombol.tinta,
          nonaktif: kosongAlasan,
          warnaTeks: kosongAlasan ? c.tinta2 : null,
        ),
        Tombol('Kembali', onPressed: s._kembali, jenis: JenisTombol.teks),
      ],
    );
    final isian = DefaultTextStyle.merge(
      style: const TextStyle(letterSpacing: 0),
      child: IsianAlur(
        label: 'Alasan · wajib',
        controller: s.alasan,
        baris: 3,
        onChanged: (_) => s._segarkan(),
      ),
    );
    final akhir = [
      if (kosongAlasan) kecil('Tidak dapat dilakukan: alasan belum diisi.'),
      if (s._tolak != null)
        Penolakan(
          tindakan: s._tolak!.action,
          sebab: s._tolak!.because,
          jalan: const [],
        ),
    ];
    if (!web) return [kartu, isian, tombol, ...akhir];
    return [
      BarisLentur(
        jarak: 28,
        jarakBaris: 20,
        anak: [
          Lentur(dasar: 420, tumbuh: 1.3, child: kartu),
          Lentur(
            dasar: 340,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [isian, tombol, ...akhir],
            ),
          ),
        ],
      ),
    ];
  }

  final units = {for (final h in daftar) unit(h.blocker.unitScopeId)}.toList();
  return [
    if (daftar.isNotEmpty)
      Kartu(
        status: GarisStatus.draf,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text:
                    'Tutup buku $nama terhalang ${daftar.length} hal dari '
                    '${units.join(' dan ')}.',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: ' '),
              TextSpan(
                text:
                    'Bendahara Jemaat dapat menyelesaikannya dengan alasan; '
                    'bendahara unitnya diberi tahu.',
                style: TextStyle(color: c.tinta2),
              ),
            ],
          ),
          style: const TextStyle(fontSize: 14),
        ),
      )
    else
      Kartu(
        status: GarisStatus.ditutup,
        isi: c.lautLembut,
        child: Text(
          'Tidak ada hambatan dari unit untuk tutup buku $nama.',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    for (final b in daftar)
      () {
        final (judul, lencana, baris, aksi) = isi(b);
        return _KartuUnit(
          judul: judul,
          lencana: lencana,
          anak: [
            ...baris,
            if (aksi.isNotEmpty) BarisTombol(anak: aksi),
          ],
        );
      }(),
    for (final (judul, baris) in s._selesai)
      _KartuUnit(
        judul: judul,
        lencana: const LencanaStatus(
          'Diselesaikan',
          bentuk: BentukLencana.laut,
        ),
        anak: [kecil(baris)],
      ),
    if (s._selesai.isNotEmpty)
      kecil(
        'Pemberitahuan terkirim ke bendahara unitnya. Semuanya tampil di '
        'konfirmasi tutup buku di bawah pengecualian, beserta alasannya.',
      ),
  ];
}

/// A 14 px line holding a mono span inside sans text. Chrome rounds each
/// font's ascent and descent to whole pixels (sans 15/3, mono 14/4) and the
/// line box spans both, so it is one pixel taller than `14 × line-height`.
StrutStyle barisCampur(BuildContext context) => StrutStyle(
  fontFamily: PalakatText.sans,
  fontSize: 14,
  height: (14 * (DefaultTextStyle.of(context).style.height ?? 1.4) + 1) / 14,
  leadingDistribution: TextLeadingDistribution.even,
  forceStrutHeight: true,
);

/// The board's card: `permukaan`, 1 `garis`, radius 14, padding 14 16,
/// column gap 6, head row title 700 + badge.
class _KartuUnit extends StatelessWidget {
  const _KartuUnit({
    required this.judul,
    required this.lencana,
    required this.anak,
  });

  final String judul;
  final Widget lencana;
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KepalaKartu(judul: judul, ujung: lencana),
        for (final a in anak) ...[const SizedBox(height: 6), a],
      ],
    ),
  );
}

/// Info row: 14, label `tinta2` (wraps), value right-aligned; amounts mono
/// 500 inside the 600 value. Unlike `BarisInfo` the label may wrap.
class _Info extends StatelessWidget {
  const _Info(
    this.label,
    this.nilai, {
    this.mono = true,
    this.berat,
    this.warna,
  });

  final String label;
  final String nilai;
  final bool mono;
  final FontWeight? berat;
  final Color? warna;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label, style: TextStyle(color: c.tinta2)),
          ),
          const SizedBox(width: 16),
          Text(
            nilai,
            textAlign: TextAlign.right,
            strutStyle: mono ? barisCampur(context) : null,
            style: TextStyle(
              color: warna ?? c.tinta,
              fontFamily: mono ? PalakatText.mono : null,
              fontWeight: berat ?? (mono ? FontWeight.w500 : FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
