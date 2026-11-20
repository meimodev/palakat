import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/akhir_bulan.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/keuangan/catat.dart';
import '../../providers/repositories_keuangan.dart';
import '../../providers/revision.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/input_format.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'selesaikan_unit_isi.dart';

/// KeuanganUnit + AlurUnit (phone) and WebAlurUnit (web), one body (README
/// 7.1): the unit treasurer books only in the unit's Fund on the Kas/Bank
/// the unit operates (DL26, DL32), sees the unit's drafts, booked rows and
/// readiness; the church Bendahara sees the unit blockers of the month to
/// close and clears each with a reason (DL33, SelesaikanUnit's body).
mixin KeuanganUnitLogika<T extends ConsumerStatefulWidget>
    on KeadaanSelesaikan<T> {
  String _jenis = '';
  String? _ma, _kas;
  String pesan = '';
  Refusal? _tolakForm, _tolakSiap;

  /// The refusal of the last "Bukukan" of each draft.
  final _tolak = <String, Refusal>{};
  final jml = TextEditingController();
  final ur = TextEditingController();

  @override
  void dispose() {
    jml.dispose();
    ur.dispose();
    super.dispose();
  }

  /// The church Bendahara's side (DL33).
  bool get sisiBendahara {
    final a = ref.watch(actorProvider);
    return a != null &&
        ref
            .watch(canProvider)
            .can(
              a,
              Capability.financeClearUnitBlocker,
              ScopeRef.jemaat,
              at: ref.watch(hariIniProvider),
            );
  }

  /// The unit post of the signed-in treasurer, or null.
  Grant? get unit {
    final a = ref.watch(actorProvider);
    if (a == null) return null;
    return ref
        .watch(canProvider)
        .grantsOf(a.personId, at: ref.watch(hariIniProvider))
        .where(
          (g) =>
              g.kind != GrantKind.member &&
              g.scopeId != ScopeRef.jemaatId &&
              g.capabilities.contains(Capability.unitFinanceRecord),
        )
        .firstOrNull;
  }

  String get namaUnit =>
      ref.watch(orgRepositoryProvider).scope(unit?.scopeId ?? '')?.name ?? '';

  int get _n => int.tryParse(jml.text.replaceAll('.', '')) ?? 0;

  /// The first unmet reason of "Bukukan" on the form, '' when met.
  String get sebab {
    final u = unit;
    if (_jenis.isEmpty) return 'jenis belum dipilih.';
    if (_ma == null) return 'Mata Anggaran belum dipilih.';
    if (_n <= 0) return 'jumlah belum diisi.';
    if (_kas == null) return 'Kas/Bank belum dipilih.';
    final akun = ref
        .read(accountRepositoryProvider)
        .accounts()
        .where((a) => a.id == _kas)
        .firstOrNull;
    if (u == null || akun?.operatorAt(ref.read(hariIniProvider)) != u.scopeId) {
      return 'Kas/Bank ini tidak dikelola $namaUnit.';
    }
    if (ur.text.trim().isEmpty) return 'uraian belum diisi.';
    return '';
  }

  bool get _mulai =>
      _jenis.isNotEmpty ||
      jml.text.isNotEmpty ||
      _kas != null ||
      ur.text.isNotEmpty;

  void _ubah(VoidCallback f) => setState(() {
    f();
    pesan = '';
    _tolakForm = null;
  });

  Future<void> _bukukan(Fund dana) async {
    final u = unit!;
    final tx = ref.read(transactionRepositoryProvider);
    final r = await perintah(
      ref,
      (a, k) => tx.createDraft(
        a,
        TransactionDraft(
          type: _jenis == 'Pendapatan'
              ? TransactionType.income
              : TransactionType.expense,
          effectiveDate: ref.read(hariIniProvider),
          description: ur.text.trim(),
          accountId: _kas,
          allocations: [
            Allocation(
              amount: _n,
              fundId: dana.id,
              scopeId: u.scopeId,
              masterCode: _ma,
            ),
          ],
        ),
        idempotencyKey: k,
      ),
    );
    if (!mounted || r == null) return;
    if (r case Refused(:final refusal)) {
      setState(() => _tolakForm = refusal);
      return;
    }
    setState(() {
      _jenis = '';
      _ma = _kas = null;
      jml.clear();
      ur.clear();
    });
    await bukukanDraf(r.value);
  }

  Future<void> bukukanDraf(Transaction t) async {
    final r = await perintah(
      ref,
      (a, k) => ref
          .read(transactionRepositoryProvider)
          .finalize(a, t.id, expectedRevision: t.revision, idempotencyKey: k),
    );
    if (!mounted || r == null) return;
    setState(() {
      if (r case Refused(:final refusal)) {
        _tolak[t.id] = refusal;
        pesan = '';
      } else {
        _tolak.remove(t.id);
        pesan = 'Dibukukan di peruntukan $namaUnit.';
      }
    });
  }

  Future<void> _nyatakan(BarisKesiapan b) async {
    final p = ref.read(bulanBukuProvider).berikutDitutup;
    if (p == null) return;
    final r = await perintah(
      ref,
      (a, k) => ref
          .read(periodRepositoryProvider)
          .attest(a, b.dana.id, p.id, idempotencyKey: k),
    );
    if (mounted) setState(() => _tolakSiap = r?.refusal);
  }

  static const _mono = TextStyle(
    fontFamily: PalakatText.mono,
    fontWeight: FontWeight.w500,
  );

  static Widget _penolakan(Refusal r) => Penolakan(
    tindakan: r.action,
    sebab: r.whoCanAct == null
        ? r.because
        : '${r.because} Yang perlu bertindak: ${r.whoCanAct}.',
    jalan: const [],
    ukuranTeks: 14,
  );

  /// The content blocks after the header (phone) or title block (web), in
  /// order; the screen puts its column gap between them. [web] draws the
  /// unit's form and lists as the two-column row.
  List<Widget> blok({required bool web}) {
    ref.watch(revisionProvider);
    if (sisiBendahara) return blokSelesaikan(context, this, web: web);
    final u = unit;
    if (u == null) return const [];
    final c = context.warna;
    final ket = TextStyle(fontSize: 13, color: c.tinta3);
    final hari = ref.watch(hariIniProvider);
    final org = ref.watch(orgRepositoryProvider);
    final nama = namaUnit;
    final akunRepo = ref.watch(accountRepositoryProvider);
    final tx = ref.watch(transactionRepositoryProvider);
    final semuaAkun = akunRepo.accounts();
    final dana = [
      for (final f in ref.watch(fundRepositoryProvider).funds())
        if (f.ownerScopeId == u.scopeId && f.activeAt(hari)) f,
    ];
    final danaId = {for (final f in dana) f.id};
    String namaDana(Transaction t) => {
      for (final a in t.allocations)
        dana.where((f) => f.id == a.fundId).firstOrNull?.name ??
            ref.watch(fundRepositoryProvider).fund(a.fundId ?? '')?.name ??
            '',
    }.join(', ');
    String jumlah(Transaction t) =>
        rp(t.type == TransactionType.expense ? -t.total : t.total);
    final bulan = ref.watch(bulanBukuProvider);
    final draf = [
      for (final t in tx.drafts())
        if (t.unitScopeId == u.scopeId) t,
    ];
    final buku = bulan.berjalan == null
        ? const <Transaction>[]
        : [
            for (final t in tx.list(bulan.berjalan!.id).reversed)
              if (t.isPosted &&
                  t.allocations.any((a) => danaId.contains(a.fundId)))
                t,
          ];
    final pilihan = ref.watch(pilihanCatatProvider(hari));
    final ma = [
      for (final r
          in _jenis == 'Pendapatan' ? pilihan.pendapatan : pilihan.belanja)
        if (r.postable) r,
    ];
    final s = sebab;
    final ids = {
      for (final t in [...draf, ...buku]) t.id,
    };
    final riw = [
      for (final r
          in ref
              .watch(auditRepositoryProvider)
              .list(const AuditFilter(actionPrefix: 'finance.')))
        if (ids.contains(r.ref?.id))
          '${tgl(r.at)} · ${r.summary} · ${r.actorLine}',
    ];

    Widget pil<V>(
      String label,
      V? nilai,
      List<(V, String)> a,
      ValueChanged<V> f,
    ) => ChipPilihan<V>(
      label: label,
      jarakLabel: 6,
      jarakBawah: 0,
      pilihan: [for (final (v, t) in a) (nilai: v, teks: t)],
      terpilih: nilai,
      onPilih: (v) => _ubah(() => f(v)),
    );

    final form = <Widget>[
      pil<String>(
        'Jenis',
        _jenis.isEmpty ? null : _jenis,
        const [('Pendapatan', 'Pendapatan'), ('Belanja', 'Belanja')],
        (v) {
          if (v != _jenis) _ma = null;
          _jenis = v;
        },
      ),
      if (_jenis.isNotEmpty)
        pil<String>('Mata Anggaran', _ma, [
          for (final r in ma) (r.code, r.name),
        ], (v) => _ma = v),
      IsianAlur(
        label: 'Jumlah (Rp)',
        controller: jml,
        petunjuk: '0',
        keterangan: rpDigit(jml.text.replaceAll('.', '')),
        keyboard: TextInputType.number,
        formatter: const [RupiahInputFormatter(sisakanNol: true)],
        onChanged: (_) => _ubah(() {}),
      ),
      pil<String>('Kas/Bank', _kas, [
        for (final a in semuaAkun) (a.id, a.name),
      ], (v) => _kas = v),
      if (dana.isNotEmpty)
        _BarisInfo(
          _jenis == 'Pendapatan'
              ? 'Masuk ke peruntukan'
              : 'Diambil dari peruntukan',
          dana.first.name,
        ),
      IsianAlur(
        label: 'Uraian',
        controller: ur,
        petunjuk: 'Contoh: Persembahan Ibadah Kolom',
        onChanged: (_) => _ubah(() {}),
      ),
      if (_tolakForm case final r?)
        _penolakan(r)
      else if (_mulai && s.isNotEmpty)
        Penolakan(
          tindakan: 'Bukukan',
          sebab: s,
          jalan: const [],
          ukuranTeks: 14,
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Bukukan',
            tindakan: 'Bukukan',
            alasan: s,
            periksa: () => sebab,
            sudahMulai: false,
            onPressed: () {
              if (dana.isNotEmpty) _bukukan(dana.first);
            },
          ),
        ],
      ),
    ];

    final kartuDraf = [
      for (final t in draf)
        Kartu(
          status: GarisStatus.draf,
          child: _kolom([
            KepalaKartu(
              judul: 'Draf · ${t.description}',
              ujung: Text(jumlah(t), style: _mono),
            ),
            _BarisInfo(
              t.type == TransactionType.income
                  ? 'Masuk ke peruntukan'
                  : 'Diambil dari peruntukan',
              namaDana(t),
            ),
            for (final id in {for (final a in t.allocations) t.accountOf(a)})
              if (semuaAkun.where((a) => a.id == id).firstOrNull
                  case final akun?)
                _BarisInfo(
                  'Kas/Bank',
                  '${akun.name} · dikelola oleh '
                      '${akun.operatorAt(t.effectiveDate) == null ? 'Bendahara Jemaat' : org.scope(akun.operatorAt(t.effectiveDate)!)?.name}',
                ),
            _BarisInfo('Tanggal transaksi', '${t.effectiveDate}'),
            Text(
              t.status == TransactionStatus.reviewed
                  ? 'Sudah diperiksa · belum masuk saldo'
                  : 'Belum masuk saldo',
              style: ket,
            ),
            if (_tolak[t.id] case final r?) _penolakan(r),
            BarisTombol(
              anak: [
                Tombol(
                  'Bukukan',
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.sedang,
                  onPressed: () => bukukanDraf(t),
                ),
              ],
            ),
          ], 6),
        ),
    ];

    final daftar = <Widget>[
      for (final a in semuaAkun)
        if (a.operatorAt(hari) == u.scopeId)
          Kartu(
            child: _kolom([
              KepalaKartu(
                judul: a.name,
                ujung: Text(rp(akunRepo.balance(a.id)), style: _mono),
              ),
              Text(
                'Dikelola oleh $nama · saldo buku, hanya yang sudah dibukukan',
                style: ket,
              ),
            ], 6),
          ),
      if (bulan.berjalan != null)
        Semantics(
          header: true,
          child: Text(
            'Peruntukan $nama · ${namaBulan(bulan.berjalan!)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      for (final t in buku)
        Kartu(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: _kolom([
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.description,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  jumlah(t),
                  style: const TextStyle(fontFamily: PalakatText.mono),
                ),
              ],
            ),
            Text('${t.voucher} · ${t.effectiveDate} · Dibukukan', style: ket),
          ], 2),
        ),
      for (final b in ref.watch(kesiapanProvider))
        if (danaId.contains(b.dana.id))
          Kartu(
            child: _kolom([
              KepalaKartu(
                judul:
                    'Pernyataan kesiapan · ${b.dana.name} · '
                    '${namaBulan(bulan.berikutDitutup!)}',
                ujung: switch (b.lihat.state) {
                  ReadinessState.current => const LencanaStatus(
                    'Sudah dinyatakan siap',
                    bentuk: BentukLencana.laut,
                  ),
                  ReadinessState.waived => const LencanaStatus(
                    'Dibebaskan',
                    bentuk: BentukLencana.peran,
                  ),
                  ReadinessState.invalidated => const LencanaStatus(
                    'Perlu dinyatakan lagi',
                    bentuk: BentukLencana.bata,
                  ),
                  ReadinessState.missing => const LencanaStatus(
                    'Belum ada',
                    bentuk: BentukLencana.bata,
                  ),
                },
              ),
              Text(
                'Perubahan pada transaksi '
                '${namaBulan(bulan.berikutDitutup!)} di peruntukan ini '
                'membuat pernyataan perlu dinyatakan lagi.',
                style: ket,
              ),
              if (_tolakSiap case final r?) _penolakan(r),
              if (b.milikSaya &&
                  (b.lihat.state == ReadinessState.missing ||
                      b.lihat.state == ReadinessState.invalidated))
                BarisTombol(
                  anak: [
                    Tombol(
                      'Nyatakan siap',
                      jenis: JenisTombol.tinta,
                      onPressed: () => _nyatakan(b),
                    ),
                  ],
                ),
            ], 6),
          ),
      Text(
        'Tutup buku dilakukan Bendahara Jemaat untuk seluruh Jemaat. '
        'Bendahara unit menyiapkan: membukukan, merekonsiliasi Kas/Bank '
        'unit, dan menyatakan siap.',
        style: ket,
      ),
    ];

    return [
      if (pesan.isNotEmpty) Pesan(Text(pesan)),
      Kartu(
        status: GarisStatus.terpilih,
        radius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Keuangan unit: $nama.',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text:
                    ' Anda membukukan hanya di peruntukan $nama, pada '
                    'Kas/Bank yang dikelola $nama.',
              ),
            ],
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ),
      if (web)
        BarisLentur(
          jarak: 28,
          jarakBaris: 20,
          anak: [
            Lentur(
              dasar: 420,
              tumbuh: 1.3,
              child: _kolom([...form, ...kartuDraf], 12),
            ),
            Lentur(dasar: 340, child: _kolom(daftar, 12)),
          ],
        )
      else ...[
        ...form,
        ...kartuDraf,
        ...daftar,
      ],
      if (riw.isNotEmpty) RiwayatAlur(baris: riw),
    ];
  }
}

Widget _kolom(List<Widget> anak, double jarak) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  mainAxisSize: MainAxisSize.min,
  children: [
    for (var i = 0; i < anak.length; i++) ...[
      if (i > 0) SizedBox(height: jarak),
      anak[i],
    ],
  ],
);

/// Blocks with a [jarak] gap between them (the boards' column `gap`).
// ponytail: letterSpacing 0 stops TextField taking the M3 bodyLarge 0.5
// spacing (the theme merges Typography defaults); drop once lib/theme sets it.
Widget kolomAlurUnit(List<Widget> anak, double jarak) => DefaultTextStyle.merge(
  style: const TextStyle(letterSpacing: 0),
  child: _kolom(anak, jarak),
);

/// KitAlur's info row, but sized like the boards' flex row: both spans start
/// at their one-line width and, when they do not fit, shrink in proportion to
/// it (CSS `flex-shrink: 1`), so a long value also wraps the label
/// ('Dicatat oleh' on the phone). The shared BarisInfo never wraps the label.
class _BarisInfo extends StatelessWidget {
  const _BarisInfo(this.label, this.nilai);

  final String label, nilai;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final dasar = DefaultTextStyle.of(context).style
        .merge(const TextStyle(fontSize: 14));
    final gl = dasar.copyWith(color: c.tinta2);
    final gn = dasar.copyWith(color: c.tinta, fontWeight: FontWeight.w600);
    final skala = MediaQuery.textScalerOf(context);
    double lebar(String t, TextStyle g) {
      final p = TextPainter(
        text: TextSpan(text: t, style: g),
        textDirection: TextDirection.ltr,
        textScaler: skala,
      )..layout();
      final w = p.width;
      p.dispose();
      return w;
    }

    return LayoutBuilder(
      builder: (context, k) {
        final ruang = k.maxWidth - 16;
        final l = lebar(label, gl), n = lebar(nilai, gn);
        final lebih = l + n - ruang;
        final lebarLabel = lebih <= 0
            ? l
            : math.max(
                // min-content: the longest word.
                label.split(' ').map((w) => lebar(w, gl)).reduce(math.max),
                l - lebih * l / (l + n),
              );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: lebarLabel.ceilToDouble(),
              child: Text(label, style: gl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(nilai, textAlign: TextAlign.right, style: gn),
            ),
          ],
        );
      },
    );
  }
}
