import 'dart:async';

import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/ai_repository.dart';
import 'memory_finance.dart';

/// The boards' fixed AI proposals and the monthly budget (README 4.6 point
/// 6). Owns the timers that stand for the AI service (README 3.7);
/// [cancelTimers] stops them.
class MemoryAiRepository implements AiRepository {
  MemoryAiRepository(this.f);
  final MemoryFinance f;
  final _timers = <Timer>[];

  /// The boards' delays: AIFoto 1400 ms, BantuanAI 1300 ms; AIMataAnggaran
  /// and AIBulan show their proposal at once.
  static const delays = {
    AiKind.receiptPhoto: Duration(milliseconds: 1400),
    AiKind.sentence: Duration(milliseconds: 1300),
    AiKind.masterRow: Duration.zero,
    AiKind.monthEnd: Duration.zero,
  };

  void cancelTimers() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  String get _bulanIni => periodIdOf(f.today.tahun, f.today.bulan);

  @override
  AiBudget budget() => AiBudget(
    periodId: _bulanIni,
    cap: f.k.aiCap,
    spent: f.k.aiSpend[_bulanIni] ?? 0,
    cost: f.k.aiCost,
  );

  /// Day 6 of last month: the story's "6 Oktober" seen from November.
  Tanggal get _hariNota {
    final t = f.today;
    final n = t.tahun * 12 + t.bulan - 2;
    return Tanggal(n ~/ 12, n % 12 + 1, 6);
  }

  /// The board's fixed proposal for [kind] (Kas/Bank, peruntukan and
  /// Lingkup are never suggested, D01).
  AiResult _fixed(AiKind kind, AiInput input) => switch (kind) {
    AiKind.receiptPhoto => AiResult(
      amount: 1250000,
      payee: 'Toko Sinar',
      date: _hariNota,
      lines: const [
        AiLine('5.01.02.00', 1000000),
        AiLine('5.02.01.00', 250000),
      ],
    ),
    AiKind.sentence => AiResult(
      amount: 1250000,
      payee: 'PLN',
      date: _hariNota,
      lines: const [AiLine('5.01.02.00', 1250000)],
    ),
    AiKind.masterRow => _masterRow(input),
    AiKind.monthEnd => const AiResult(),
  };

  /// AIMataAnggaran: one row; two rows when the text names two amounts; no
  /// amounts when the AI is unsure ('ibadah padang').
  AiResult _masterRow(AiInput input) {
    final t = input.text.toLowerCase();
    if (t.contains('padang')) {
      return const AiResult(
        unsure: true,
        lines: [AiLine('5.04.01.00', null), AiLine('5.05.02.00', null)],
      );
    }
    if (RegExp('rp').allMatches(t).length >= 2) {
      return const AiResult(
        amount: 480000,
        lines: [AiLine('5.02.01.00', 300000), AiLine('5.01.02.00', 180000)],
      );
    }
    final jumlah = input.amount ?? 480000;
    return AiResult(amount: jumlah, lines: [AiLine('5.02.01.00', jumlah)]);
  }

  /// Returns the proposal PENDING at once in the idempotency log; the
  /// Future completes with it READY after the board's delay. The cost is
  /// added when it is asked for.
  @override
  Future<Result<AiProposal>> propose(
    Actor actor,
    AiKind kind,
    AiInput input, {
    required String idempotencyKey,
  }) {
    final log = f.ctx.store.idempotencyLog;
    final lama = log[idempotencyKey];
    if (lama != null) return Future.value(lama as Result<AiProposal>);
    Future<Result<AiProposal>> tolak(Refused<AiProposal> r) {
      log[idempotencyKey] = r;
      return Future.value(r);
    }

    const aksi = 'Buat usulan';
    final g =
        f.ctx.grant(actor, Capability.financeRecord, ScopeRef.jemaat) ??
        f.ctx.grant(actor, Capability.unitFinanceRecord, ScopeRef.anywhere);
    if (g == null) {
      return tolak(
        f.ctx.refuse(actor, Capability.financeRecord, ScopeRef.jemaat),
      );
    }
    if (budget().usedUp) {
      return tolak(
        f.ctx.no(
          aksi,
          'Batas biaya AI per bulan tercapai. Mencatat, membukukan dan tutup '
          'buku berjalan seperti biasa.',
        ),
      );
    }
    final p = AiProposal(
      id: f.ctx.store.newId('ai'),
      kind: kind,
      input: input,
      cost: f.k.aiCost,
      requestedBy: actor.personId,
      requestedAt: f.now,
    );
    f.k.aiProposals.add(p);
    f.k.aiSpend.update(_bulanIni, (n) => n + p.cost, ifAbsent: () => p.cost);
    f.audit(
      g,
      action: 'finance.ai.propose',
      summary: 'Meminta usulan AI',
      ref: RecordRef('ai', p.id),
    );
    final r = Ok(p);
    log[idempotencyKey] = r;
    f.ctx.changed();
    final selesai = Completer<Result<AiProposal>>();
    late final Timer timer;
    timer = Timer(delays[kind]!, () {
      _timers.remove(timer);
      p
        ..status = AiProposalStatus.ready
        ..result = _fixed(kind, input)
        ..readyAt = f.now
        ..revision += 1;
      f.ctx.changed();
      selesai.complete(r);
    });
    _timers.add(timer);
    return selesai.future;
  }

  @override
  Future<Result<AiProposal>> dispose(
    Actor actor,
    String proposalId,
    AiDisposition disposition, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Pakai usulan';
    final p = f.k.aiProposals.where((x) => x.id == proposalId).firstOrNull;
    if (p == null) return f.ctx.no(aksi, 'Usulan tidak ditemukan.');
    if (p.status == AiProposalStatus.pending) {
      return f.ctx.no(aksi, 'Usulan belum siap.');
    }
    if (p.status == AiProposalStatus.disposed) {
      return f.ctx.no(aksi, 'Usulan ini sudah dipakai atau diabaikan.');
    }
    final basi = f.ctx.stale<AiProposal>(p.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final g =
        f.ctx.grant(actor, Capability.financeRecord, ScopeRef.jemaat) ??
        f.ctx.grant(actor, Capability.unitFinanceRecord, ScopeRef.anywhere);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeRecord, ScopeRef.jemaat);
    }
    p
      ..status = AiProposalStatus.disposed
      ..disposition = disposition
      ..disposedBy = actor.personId
      ..disposedAt = f.now
      ..revision += 1;
    f.audit(
      g,
      action: 'finance.ai.dispose',
      summary: switch (disposition) {
        AiDisposition.accepted => 'Usulan AI dipakai',
        AiDisposition.edited => 'Usulan AI dipakai dengan perubahan',
        AiDisposition.rejected => 'Usulan AI diabaikan',
      },
      ref: RecordRef('ai', p.id),
    );
    return Ok(p);
  });
}
