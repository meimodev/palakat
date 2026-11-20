import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/import_repository.dart';
import '../repositories/transaction_repository.dart';
import 'memory_finance.dart';

/// Ledger import (README 4.2, DM 5.5, 6.2): STAGED → VALIDATED → REVIEWED →
/// COMMITTED. Committed rows become DRAFT transactions through
/// `TransactionRepository.createDraft`; refused and deselected rows stay with
/// their disposition.
class MemoryImportRepository implements ImportRepository {
  MemoryImportRepository(this.f, this._tx);

  final MemoryFinance f;

  /// The shared ledger: drafts go through its createDraft.
  final TransactionRepository _tx;

  static const _ref = 'import';

  @override
  List<ImportBatch> batches() => f.k.importBatches.reversed.toList();

  @override
  List<StagedRow> rows(String batchId) =>
      f.k.stagedRows.where((r) => r.batchId == batchId).toList()
        ..sort((a, b) => a.ordinal.compareTo(b.ordinal));

  ImportBatch? _batch(String id) =>
      f.k.importBatches.where((b) => b.id == id).firstOrNull;

  Grant? _grant(Actor actor) =>
      f.ctx.grant(actor, Capability.financeRecord, ScopeRef.jemaat);

  @override
  Future<Result<ImportBatch>> stage(
    Actor actor,
    SampleImport file, {
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    final g = _grant(actor);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeRecord, ScopeRef.jemaat);
    }
    final b = ImportBatch(
      id: f.ctx.store.newId('impor'),
      fileName: file.fileName,
      createdBy: actor.personId,
      createdAt: f.now,
    );
    f.k.importBatches.add(b);
    for (final (i, line) in file.lines.indexed) {
      final r = readImportLine(line, f.today);
      f.k.stagedRows.add(
        StagedRow(
          id: f.ctx.store.newId('baris'),
          batchId: b.id,
          ordinal: i + 1,
          raw: line,
          date: r.date,
          amount: r.amount,
          type: r.type,
          accountId: f.k.accounts.firstOrNull?.id,
        ),
      );
    }
    f.audit(
      g,
      action: 'finance.import.stage',
      summary: 'Ditampung: ${file.fileName} · ${file.lines.length} baris',
      ref: RecordRef(_ref, b.id),
    );
    return Ok(b);
  });

  @override
  Future<Result<ImportBatch>> validate(
    Actor actor,
    String batchId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Jalankan pengecekan';
    final g = _grant(actor);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeRecord, ScopeRef.jemaat);
    }
    final b = _batch(batchId);
    if (b == null) return f.ctx.no(aksi, 'Berkas impor tidak ditemukan.');
    if (b.status != ImportBatchStatus.staged) {
      return f.ctx.no(aksi, 'Pengecekan sudah dijalankan.');
    }
    final basi = f.ctx.stale<ImportBatch>(b.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final dilihat = <StagedRow>[];
    for (final r in rows(b.id)) {
      final tutup = r.date == null ? null : f.closedReason(r.date!);
      final sama = dilihat
          .where(
            (x) =>
                x.date == r.date &&
                x.accountId == r.accountId &&
                x.amount == r.amount &&
                x.type == r.type,
          )
          .firstOrNull;
      if (r.date == null) {
        r
          ..disposition = RowDisposition.refused
          ..reason = 'tanggal ${importDateText(r.raw)} tidak ada.';
      } else if (r.amount == null || r.amount! <= 0) {
        r
          ..disposition = RowDisposition.refused
          ..reason = 'jumlah tidak terbaca.';
      } else if (tutup != null) {
        r
          ..disposition = RowDisposition.refused
          ..reason = tutup;
      } else if (sama != null) {
        r
          ..disposition = RowDisposition.possibleDuplicate
          ..duplicateOf = sama.id
          ..reason =
              'Tanggal, Kas/Bank dan jumlah sama dengan baris '
              '${sama.ordinal}.';
      } else {
        r.disposition = RowDisposition.ok;
      }
      r
        ..selected = r.disposition == RowDisposition.ok
        ..revision += 1;
      if (r.disposition != RowDisposition.refused) dilihat.add(r);
    }
    b
      ..status = ImportBatchStatus.validated
      ..revision += 1;
    f.audit(
      g,
      action: 'finance.import.validate',
      summary: 'Pengecekan impor: ${b.fileName}',
      ref: RecordRef(_ref, b.id),
    );
    return Ok(b);
  });

  @override
  Future<Result<ImportBatch>> reviewRows(
    Actor actor,
    String batchId,
    Set<String> selection, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Tandai sudah diperiksa';
    final g = _grant(actor);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeRecord, ScopeRef.jemaat);
    }
    final b = _batch(batchId);
    if (b == null) return f.ctx.no(aksi, 'Berkas impor tidak ditemukan.');
    if (b.status != ImportBatchStatus.validated) {
      return f.ctx.no(aksi, 'Jalankan pengecekan lebih dulu.');
    }
    final basi = f.ctx.stale<ImportBatch>(b.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    for (final r in rows(b.id)) {
      if (r.disposition == RowDisposition.refused) continue;
      final pilih = selection.contains(r.id);
      if (!pilih) {
        final asal = f.k.stagedRows
            .where((x) => x.id == r.duplicateOf)
            .firstOrNull;
        r
          ..disposition = RowDisposition.deselected
          ..reason = asal == null
              ? 'tidak dipilih.'
              : 'sama dengan baris ${asal.ordinal}.';
      }
      r
        ..selected = pilih
        ..revision += 1;
    }
    b
      ..status = ImportBatchStatus.reviewed
      ..revision += 1;
    f.audit(
      g,
      action: 'finance.import.review',
      summary: 'Impor diperiksa: ${b.fileName}',
      ref: RecordRef(_ref, b.id),
    );
    return Ok(b);
  });

  @override
  Future<Result<ImportBatch>> commit(
    Actor actor,
    String batchId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Impor';
    final g = _grant(actor);
    if (g == null) {
      return f.ctx.refuse(actor, Capability.financeRecord, ScopeRef.jemaat);
    }
    final b = _batch(batchId);
    if (b == null) return f.ctx.no(aksi, 'Berkas impor tidak ditemukan.');
    if (b.status != ImportBatchStatus.reviewed) {
      return f.ctx.no(aksi, 'Tandai sudah diperiksa lebih dulu.');
    }
    final basi = f.ctx.stale<ImportBatch>(b.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final umum = f.k.funds
        .where((x) => x.ownerScopeId == ScopeRef.jemaatId)
        .firstOrNull;
    for (final r in rows(b.id)) {
      if (!r.selected || r.disposition == RowDisposition.refused) continue;
      final k = '$idempotencyKey/${r.id}';
      _tx.createDraft(
        actor,
        TransactionDraft(
          type: r.type ?? TransactionType.expense,
          effectiveDate: r.date!,
          description: importDescription(r.raw),
          accountId: r.accountId,
          importRowId: r.id,
          allocations: [
            Allocation(
              amount: r.amount!,
              fundId: umum?.id,
              scopeId: ScopeRef.jemaatId,
              masterCode: r.masterCode,
            ),
          ],
        ),
        idempotencyKey: k,
      );
      final hasil = f.ctx.store.idempotencyLog[k]! as Result<Transaction>;
      if (hasil case Ok(:final value)) {
        r
          ..committedTransactionId = value.id
          ..revision += 1;
      } else {
        r
          ..disposition = RowDisposition.refused
          ..reason = hasil.refusal?.because
          ..selected = false;
      }
    }
    b
      ..status = ImportBatchStatus.committed
      ..revision += 1;
    f.audit(
      g,
      action: 'finance.import.commit',
      summary: 'Diimpor sebagai draf: ${b.fileName}',
      ref: RecordRef(_ref, b.id),
    );
    return Ok(b);
  });
}

/// The description part of an import line ('dd/mm/yy · uraian · jumlah').
String importDescription(String raw) {
  final s = raw.split(' · ');
  return s.length > 1 ? s[1].trim() : raw.trim();
}

/// The date part as written, without its year ('31/11').
String importDateText(String raw) {
  final d = raw.split(' · ').first.trim();
  final s = d.split('/');
  return s.length == 3 ? '${s[0]}/${s[1]}' : d;
}

const _bulanSingkat = {
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'mei': 5, 'jun': 6, //
  'jul': 7, 'agu': 8, 'agt': 8, 'sep': 9, 'okt': 10, 'nop': 11, 'nov': 11,
  'des': 12,
};

/// Reads one line of a bundled sample file: 'dd/mm/yy' or 'd Mmm' (in
/// [today]'s year), and an amount ('-1250000', '650rb', '1.250.000,-'); a
/// minus sign is money out. An impossible date reads as null.
({Tanggal? date, int? amount, TransactionType type}) readImportLine(
  String raw,
  Tanggal today,
) {
  final s = raw.split(' · ');
  Tanggal? date;
  final d = s.first.trim();
  final m1 = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{2,4})$').firstMatch(d);
  final m2 = RegExp(r'^(\d{1,2}) ([A-Za-z]{3})').firstMatch(d);
  int? h, b, t;
  if (m1 != null) {
    h = int.parse(m1[1]!);
    b = int.parse(m1[2]!);
    t = int.parse(m1[3]!);
    if (t < 100) t += 2000;
  } else if (m2 != null) {
    h = int.parse(m2[1]!);
    b = _bulanSingkat[m2[2]!.toLowerCase()];
    t = today.tahun;
  }
  if (h != null && b != null && t != null) {
    final x = DateTime.utc(t, b, h);
    if (x.month == b && x.day == h) date = Tanggal(t, b, h);
  }
  final j = s.length > 2 ? s.last.trim().toLowerCase() : '';
  final keluar = j.startsWith('-');
  var angka = j.replaceAll(RegExp(r',.*$'), '').replaceAll(RegExp(r'\D'), '');
  if (j.endsWith('rb')) angka = '${angka}000';
  return (
    date: date,
    amount: int.tryParse(angka),
    type: keluar ? TransactionType.expense : TransactionType.income,
  );
}
