import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../repositories/period_repository.dart';
import '../repositories/report_repository.dart';
import 'memory_finance.dart';

/// Report datasets computed from state for any month (README 4.6 point 3),
/// or read from the close snapshot. Row keys per form:
///
/// - F01 totals: opening, income, expense, expenseFromAdvance, transitIn,
///   transitOut, advanceIssued, advanceReturned, closing; rows as F10.
/// - F02 rows: transactionId, date, voucher, codes, description, accountIds,
///   in, out, balance (a reversal prints negative in its original's
///   column, D12), reversedBy (the posted reversal's voucher), correctionOf
///   (the corrected original's voucher); totals: opening, in, out, closing.
/// - F03 rows: F02's keys plus accountId, per account; totals:
///   'opening:{accountId}', 'closing:{accountId}'.
/// - F04, F06 rows: code, name, parentCode, level, postable, allowedEffect;
///   totals: versionId, versionCode.
/// - F05, F07 rows: F04's keys plus amount (headings roll up their
///   children, rows of Rp0 kept); totals: total.
/// - F08 rows: accountId, income, transitIn, advanceReturn, transferIn,
///   other, total. F09 rows: accountId, expense, transitOut, advanceIssued,
///   transferOut, other, total. Totals: the column sums.
/// - F10 rows: accountId, book, cashCount, statement, inTransit,
///   comparison, difference (null without an observation).
/// - F11 rows: accountId, observed, depositsInTransit, paymentsInTransit,
///   comparison, book, difference, matched, unmatched, status.
/// - F12 rows: kind ('posted', 'unfinished', 'draft'), transactionId,
///   voucher, date, description, amount, total, approval ('notRequired',
///   'recorded', 'missing'), evidence (EvidenceStatus name), note.
/// - F13 rows: caseId, partyId, title, opening, collected, remitted,
///   closing; totals: the sums and ownCentralization.
/// - F14 rows: n (1–8), items (ids), count.
class MemoryReportRepository implements ReportRepository {
  MemoryReportRepository(this.f, this.periods) {
    // A seeded CLOSED month (M−2, README 5.6) has its snapshot id but no
    // frozen pack: freeze it once, at its close time (README 4.6 point 3).
    // `PeriodRepository.close` builds one after closing, which freezes it.
    for (final p in f.k.periods) {
      if (!p.isClosed || p.snapshotId == null || snapshot(p.id) != null) {
        continue;
      }
      final pada = p.closedAt ?? f.now;
      f.k.snapshots.add(
        ReportSnapshot(
          year: p.year,
          month: p.month,
          frozenAt: pada,
          closedBy: p.closedBy ?? '',
          masterVersionIds: [
            for (final v in f.k.masterVersions)
              if (v.status == MasterVersionStatus.published &&
                  (v.effectiveFrom ?? p.end) <= p.end)
                v.id,
          ],
          pack: _pack(
            p.id,
            Perimeter.whole,
            ReportForm.values,
            official: true,
            cutoff: pada,
          ),
        ),
      );
    }
  }
  final MemoryFinance f;
  final PeriodRepository periods;

  /// A Fund-only viewer's perimeter is cut to their Funds (README 3.5).
  Perimeter _cut(Perimeter p) {
    final boleh = f.visibleFundIds();
    if (boleh == null) return p;
    return Perimeter(
      fundIds: p.fundIds == null ? boleh : p.fundIds!.intersection(boleh),
      accountIds: p.accountIds,
    );
  }

  /// The stored period, or an OPEN calendar month parsed from 'yyyy-mm'.
  Period _period(String id) {
    final p = f.k.periodById(id);
    if (p != null) return p;
    final [y, m] = id.split('-').map(int.parse).toList();
    return Period(
      year: y,
      month: m,
      start: Tanggal(y, m, 1),
      end: Tanggal(y, m + 1, 1).tambahHari(-1),
    );
  }

  @override
  ReportPack preview(String periodId, Perimeter perimeter) =>
      _pack(periodId, _cut(perimeter), ReportForm.values, official: false);

  ReportPack _pack(
    String periodId,
    Perimeter per,
    Iterable<ReportForm> forms, {
    required bool official,
    DateTime? cutoff,
  }) {
    final r = _Hitung(f, _period(periodId), per, periods, cutoff);
    return ReportPack(
      periodId: periodId,
      perimeter: per,
      coverageStart: r.p.start,
      coverageEnd: r.p.end,
      official: official,
      datasets: {for (final x in forms) x: r.dataset(x)},
    );
  }

  @override
  ReportSnapshot? snapshot(String periodId) {
    final p = f.k.periodById(periodId);
    if (p == null) return null;
    return f.k.snapshots
        .where((s) => s.year == p.year && s.month == p.month)
        .lastOrNull;
  }

  @override
  ReportDataset dataset(ReportSource source, ReportForm form) {
    final per = _cut(source.perimeter);
    final s = snapshot(source.periodId);
    if (s != null && per.isWhole) {
      final d = s.pack.datasets[form];
      if (d != null) return d;
    }
    return _Hitung(f, _period(source.periodId), per, periods).dataset(form);
  }

  static const _terbatas = [
    ReportForm.f02,
    ReportForm.f03,
    ReportForm.f05,
    ReportForm.f07,
    ReportForm.f12,
  ];

  @override
  RestrictedReport restricted(ReportSource source, String fundId) {
    final boleh = f.visibleFundIds();
    final per = Perimeter(
      fundIds: boleh == null || boleh.contains(fundId) ? {fundId} : const {},
    );
    final r = _Hitung(f, _period(source.periodId), per, periods);
    return RestrictedReport(
      fundId: fundId,
      datasets: {for (final x in _terbatas) x: r.dataset(x)},
    );
  }

  @override
  List<ReportTemplate> templates() => List.of(f.k.templates);

  @override
  Future<Result<ReportTemplate>> acceptTemplate(
    Actor actor,
    String templateId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => f.ctx.command(idempotencyKey, () {
    const aksi = 'Catat persetujuan format laporan';
    // RD03: the authorized church officer accepts; the Bendahara records
    // that acceptance (DP11).
    final g =
        f.ctx.grant(actor, Capability.financeAcceptTemplate, ScopeRef.jemaat) ??
        f.ctx.grant(actor, Capability.financeSettings, ScopeRef.jemaat);
    if (g == null) {
      return f.ctx.refuse(
        actor,
        Capability.financeAcceptTemplate,
        ScopeRef.jemaat,
      );
    }
    final t = f.k.templates.where((x) => x.id == templateId).firstOrNull;
    if (t == null) return f.ctx.no(aksi, 'Format laporan tidak ditemukan.');
    final basi = f.ctx.stale<ReportTemplate>(
      t.revision,
      expectedRevision,
      aksi,
    );
    if (basi != null) return basi;
    if (t.accepted) return f.ctx.no(aksi, 'Format ini sudah disetujui.');
    t
      ..acceptedBy = actor.personId
      ..acceptedAt = f.now
      ..revision += 1;
    f.audit(
      g,
      action: 'finance.template.accept',
      summary: 'Persetujuan format laporan dicatat: ${t.name}',
      ref: RecordRef('template', t.id),
    );
    return Ok(t);
  });
}

/// One computation of datasets for a period and perimeter.
class _Hitung {
  _Hitung(this.f, this.p, this.per, this.periods, [this.cutoff]);

  /// A snapshot's posting cutoff: drafts made after it are not in it.
  final DateTime? cutoff;

  final MemoryFinance f;
  final Period p;
  final Perimeter per;
  final PeriodRepository periods;

  late final Tanggal kemarin = p.start.tambahHari(-1);
  late final List<Transaction> dalam = [
    for (final t in f.k.posted)
      if (p.contains(t.effectiveDate)) t,
  ];

  bool _fund(String? id) => per.fundIds == null || per.fundIds!.contains(id);
  bool _akun(String? id) =>
      id != null && (per.accountIds == null || per.accountIds!.contains(id));
  bool _leg(Leg l) => _akun(l.accountId) && _fund(l.fundId);
  bool _bagian(Allocation a) => _fund(a.fundId) || _fund(a.toFundId);

  /// Liquid money in the perimeter at the end of [d], on [akun] or all.
  int _kas(Tanggal d, [String? akun]) {
    var n = 0;
    for (final t in f.k.posted) {
      if (t.effectiveDate > d) continue;
      for (final e in effectsOf(t)) {
        for (final l in e.legs) {
          if (_leg(l) && (akun == null || l.accountId == akun)) n += l.amount;
        }
      }
    }
    return n;
  }

  /// The accounts in the perimeter with money or a movement in the period.
  late final List<Account> akun = [
    for (final a in f.k.accounts)
      if (_akun(a.id) &&
          (_kas(kemarin, a.id) != 0 ||
              dalam.any(
                (t) => effectsOf(
                  t,
                ).any((e) => e.legs.any((l) => _leg(l) && l.accountId == a.id)),
              )))
        a,
  ];

  ReportDataset dataset(ReportForm form) => switch (form) {
    ReportForm.f01 => _f01(),
    ReportForm.f02 => _f02(),
    ReportForm.f03 => _f03(),
    ReportForm.f04 => _master(form, MasterKind.pendapatan, amounts: false),
    ReportForm.f05 => _master(form, MasterKind.pendapatan, amounts: true),
    ReportForm.f06 => _master(form, MasterKind.belanja, amounts: false),
    ReportForm.f07 => _master(form, MasterKind.belanja, amounts: true),
    ReportForm.f08 => _rekap(form, masuk: true),
    ReportForm.f09 => _rekap(form, masuk: false),
    ReportForm.f10 => _f10(),
    ReportForm.f11 => _f11(),
    ReportForm.f12 => _f12(),
    ReportForm.f13 => _f13(),
    ReportForm.f14 => _f14(),
  };

  /// In and out of [t] in the perimeter (on [akunId] when given). A
  /// reversal puts its negated amounts in its original's column (D12).
  (int, int, Set<String>) _masukKeluar(Transaction t, [String? akunId]) {
    final fak = t.type == TransactionType.reversal ? -1 : 1;
    var masuk = 0, keluar = 0;
    final ids = <String>{};
    for (final e in effectsOf(t)) {
      for (final l in e.legs) {
        if (!_leg(l) || (akunId != null && l.accountId != akunId)) continue;
        ids.add(l.accountId!);
        final asli = l.amount * fak;
        if (asli > 0) {
          masuk += asli * fak;
        } else {
          keluar -= asli * fak;
        }
      }
    }
    return (masuk, keluar, ids);
  }

  List<Map<String, Object?>> _bku(int awal, [String? akunId]) {
    var saldo = awal;
    final rows = <Map<String, Object?>>[];
    for (final t in dalam) {
      final (masuk, keluar, ids) = _masukKeluar(t, akunId);
      if (ids.isEmpty) continue;
      saldo += masuk - keluar;
      rows.add({
        'transactionId': t.id,
        'date': t.effectiveDate,
        'voucher': t.voucher,
        'codes': [
          for (final a in t.allocations)
            if (a.masterCode != null && _bagian(a)) a.masterCode,
        ],
        'description': t.description,
        'reversedBy': f.k.posted
            .where((x) => x.reversalOf == t.id)
            .firstOrNull
            ?.voucher,
        'correctionOf': f.k.transaction(t.correctionOf)?.voucher,
        'accountIds': ids.toList(),
        'in': masuk,
        'out': keluar,
        'balance': saldo,
        'accountId': ?akunId,
      });
    }
    return rows;
  }

  ReportDataset _f01() {
    var income = 0, expense = 0, dariUm = 0, tin = 0, tout = 0;
    var umKeluar = 0, umKembali = 0;
    for (final t in dalam) {
      for (final e in effectsOf(t)) {
        if (!_bagian(e.allocation)) continue;
        income += e.income;
        expense += e.expense;
        tin += e.transitIn;
        tout += e.transitOut;
        if (e.type == TransactionType.advanceSpending) dariUm += e.expense;
        if (e.type == TransactionType.advanceIssue) umKeluar += e.caseDelta;
        if (e.type == TransactionType.advanceReturn) umKembali -= e.caseDelta;
      }
    }
    return ReportDataset(
      form: ReportForm.f01,
      rows: _f10().rows,
      totals: {
        'opening': _kas(kemarin),
        'income': income,
        'expense': expense,
        'expenseFromAdvance': dariUm,
        'transitIn': tin,
        'transitOut': tout,
        'advanceIssued': umKeluar,
        'advanceReturned': umKembali,
        'closing': _kas(p.end),
      },
    );
  }

  ReportDataset _f02() {
    final awal = _kas(kemarin);
    final rows = _bku(awal);
    return ReportDataset(
      form: ReportForm.f02,
      rows: rows,
      totals: {
        'opening': awal,
        'in': rows.fold<int>(0, (s, r) => s + (r['in'] as int)),
        'out': rows.fold<int>(0, (s, r) => s + (r['out'] as int)),
        'closing': _kas(p.end),
      },
    );
  }

  ReportDataset _f03() {
    final rows = <Map<String, Object?>>[];
    final totals = <String, Object?>{};
    for (final a in akun) {
      final awal = _kas(kemarin, a.id);
      totals['opening:${a.id}'] = awal;
      totals['closing:${a.id}'] = _kas(p.end, a.id);
      rows.addAll(_bku(awal, a.id));
    }
    return ReportDataset(form: ReportForm.f03, rows: rows, totals: totals);
  }

  MasterVersion? _versi(MasterKind kind) =>
      (f.k.masterVersions
              .where(
                (v) =>
                    v.kind == kind &&
                    v.status == MasterVersionStatus.published &&
                    v.effectiveFrom != null &&
                    v.effectiveFrom! <= p.end,
              )
              .toList()
            ..sort((a, b) => a.effectiveFrom!.compareTo(b.effectiveFrom!)))
          .lastOrNull;

  ReportDataset _master(
    ReportForm form,
    MasterKind kind, {
    required bool amounts,
  }) {
    final v = _versi(kind);
    final rows = f.k.masterRows.where((r) => r.versionId == v?.id).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final sendiri = <String, int>{};
    var total = 0;
    if (amounts) {
      for (final t in dalam) {
        for (final e in effectsOf(t)) {
          if (!_bagian(e.allocation)) continue;
          final n = kind == MasterKind.pendapatan ? e.income : e.expense;
          if (n == 0) continue;
          total += n;
          final c = e.allocation.masterCode;
          if (c != null) sendiri[c] = (sendiri[c] ?? 0) + n;
        }
      }
    }
    int jumlah(String code, Set<String> lihat) {
      if (!lihat.add(code)) return 0;
      return (sendiri[code] ?? 0) +
          rows
              .where((r) => r.parentCode == code)
              .fold<int>(0, (s, r) => s + jumlah(r.code, lihat));
    }

    return ReportDataset(
      form: form,
      rows: [
        for (final r in rows)
          {
            'code': r.code,
            'name': r.name,
            'parentCode': r.parentCode,
            'level': r.level,
            'postable': r.postable,
            'allowedEffect': r.allowedEffect.name,
            if (amounts) 'amount': jumlah(r.code, {}),
          },
      ],
      totals: {
        'versionId': v?.id,
        'versionCode': v?.code,
        if (amounts) 'total': total,
      },
    );
  }

  static const _kolomMasuk = [
    'income',
    'transitIn',
    'advanceReturn',
    'transferIn',
    'other',
  ];
  static const _kolomKeluar = [
    'expense',
    'transitOut',
    'advanceIssued',
    'transferOut',
    'other',
  ];

  String _kolom(TransactionType type, {required bool masuk}) => masuk
      ? switch (type) {
          TransactionType.income => 'income',
          TransactionType.transitCollection => 'transitIn',
          TransactionType.advanceReturn => 'advanceReturn',
          TransactionType.accountTransfer ||
          TransactionType.fundTransfer => 'transferIn',
          _ => 'other',
        }
      : switch (type) {
          TransactionType.expense || TransactionType.claimPayment => 'expense',
          TransactionType.transitRemittance => 'transitOut',
          TransactionType.advanceIssue => 'advanceIssued',
          TransactionType.accountTransfer ||
          TransactionType.fundTransfer => 'transferOut',
          _ => 'other',
        };

  ReportDataset _rekap(ReportForm form, {required bool masuk}) {
    final kolom = masuk ? _kolomMasuk : _kolomKeluar;
    final rows = <Map<String, Object?>>[];
    final totals = <String, Object?>{
      for (final k in [...kolom, 'total']) k: 0,
    };
    for (final a in akun) {
      final row = <String, Object?>{
        'accountId': a.id,
        for (final k in [...kolom, 'total']) k: 0,
      };
      for (final t in dalam) {
        final fak = t.type == TransactionType.reversal ? -1 : 1;
        for (final e in effectsOf(t)) {
          for (final l in e.legs) {
            if (!_leg(l) || l.accountId != a.id) continue;
            final asli = l.amount * fak;
            if ((asli > 0) != masuk || asli == 0) continue;
            final n = asli.abs() * fak;
            final k = _kolom(e.type, masuk: masuk);
            row[k] = (row[k] as int) + n;
            row['total'] = (row['total'] as int) + n;
          }
        }
      }
      for (final k in [...kolom, 'total']) {
        totals[k] = (totals[k] as int) + (row[k] as int);
      }
      rows.add(row);
    }
    return ReportDataset(form: form, rows: rows, totals: totals);
  }

  ReconSession? _sesi(String akunId) => f.k.reconSessions
      .where((s) => s.accountId == akunId && s.periodId == p.id)
      .lastOrNull;

  CashCount? _hitung(String akunId) =>
      (f.k.cashCounts
              .where((c) => c.accountId == akunId && c.periodId == p.id)
              .toList()
            ..sort((a, b) => a.countedAt.compareTo(b.countedAt)))
          .lastOrNull;

  /// The timing items of [s] on its account: (deposits, payments).
  (int, int) _perjalanan(ReconSession? s) {
    var setor = 0, bayar = 0;
    for (final id in s?.timingItems.keys ?? const <String>[]) {
      final t = f.k.transaction(id);
      if (t == null) continue;
      for (final e in effectsOf(t)) {
        for (final l in e.legs) {
          if (l.accountId != s!.accountId) continue;
          if (l.amount > 0) setor += l.amount;
          if (l.amount < 0) bayar -= l.amount;
        }
      }
    }
    return (setor, bayar);
  }

  ReportDataset _f10() {
    final rows = <Map<String, Object?>>[];
    var buku = 0, selisih = 0;
    for (final a in akun) {
      final s = _sesi(a.id);
      final hitung = _hitung(a.id)?.total;
      final (setor, bayar) = _perjalanan(s);
      final rk = s?.statementClosing;
      final banding = a.type == AccountType.cash
          ? hitung
          : rk == null
          ? null
          : rk + setor - bayar;
      final b = _kas(p.end, a.id);
      buku += b;
      if (banding != null) selisih += b - banding;
      rows.add({
        'accountId': a.id,
        'book': b,
        'cashCount': hitung,
        'statement': rk,
        'inTransit': setor - bayar,
        'comparison': banding,
        'difference': banding == null ? null : b - banding,
      });
    }
    return ReportDataset(
      form: ReportForm.f10,
      rows: rows,
      totals: {'book': buku, 'difference': selisih},
    );
  }

  ReportDataset _f11() => ReportDataset(
    form: ReportForm.f11,
    rows: [
      for (final a in akun)
        () {
          final s = _sesi(a.id);
          final amati = a.type == AccountType.cash
              ? _hitung(a.id)?.total
              : s?.statementClosing;
          final (setor, bayar) = _perjalanan(s);
          final banding = amati == null ? null : amati + setor - bayar;
          final b = _kas(p.end, a.id);
          final baris = s == null
              ? const <StatementLine>[]
              : f.k.statementLines.where((l) => l.sessionId == s.id).toList();
          return <String, Object?>{
            'accountId': a.id,
            'observed': amati,
            'depositsInTransit': setor,
            'paymentsInTransit': bayar,
            'comparison': banding,
            'book': b,
            'difference': banding == null ? null : b - banding,
            'matched': baris
                .where((l) => l.matchedTransactionIds.isNotEmpty)
                .length,
            'unmatched': baris
                .where((l) => l.matchedTransactionIds.isEmpty)
                .length,
            'status': s?.status.name,
          };
        }(),
    ],
  );

  ReportDataset _f12() {
    final rows = <Map<String, Object?>>[];
    final urut = [...dalam]
      ..sort((a, b) {
        final s = a.series.index.compareTo(b.series.index);
        if (s != 0) return s;
        final y = a.voucherYear!.compareTo(b.voucherYear!);
        return y != 0 ? y : a.voucherNumber!.compareTo(b.voucherNumber!);
      });
    for (final t in urut) {
      if (!t.allocations.any(_bagian)) continue;
      var bersih = 0;
      for (final e in effectsOf(t)) {
        for (final l in e.legs) {
          if (_leg(l)) bersih += l.amount;
        }
      }
      rows.add({
        'kind': 'posted',
        'transactionId': t.id,
        'voucher': t.voucher,
        'date': t.effectiveDate,
        'description': t.description,
        'amount': bersih,
        'total': t.allocations
            .where(_bagian)
            .fold<int>(0, (s, a) => s + a.amount),
        'approval': t.approvalMode == ApprovalMode.notRequired
            ? 'notRequired'
            : f.k.approvalOf(t) == null
            ? 'missing'
            : 'recorded',
        'evidence': f.k.evidenceStatus(t).name,
      });
    }
    if (per.isWhole) {
      for (final u in f.k.unfinishedVouchers) {
        if (u.number == null || !p.contains(Tanggal.dari(u.allocatedAt))) {
          continue;
        }
        rows.add({
          'kind': 'unfinished',
          'voucher': voucherCode(u.series, u.year!, u.number!),
          'date': Tanggal.dari(u.allocatedAt),
          'note': u.note,
        });
      }
    }
    for (final t in f.k.transactions) {
      if (!t.isDraft || !p.contains(t.effectiveDate)) continue;
      if (cutoff != null && t.createdAt.isAfter(cutoff!)) continue;
      if (!per.isWhole && !t.allocations.any(_bagian)) continue;
      rows.add({
        'kind': 'draft',
        'transactionId': t.id,
        'date': t.effectiveDate,
        'description': t.description,
        'amount': signedAmount(t),
        'total': t.total,
      });
    }
    return ReportDataset(form: ReportForm.f12, rows: rows);
  }

  /// [c]'s outstanding at the end of [d].
  int _sisa(FinanceCase c, Tanggal d) {
    var n = 0;
    for (final t in f.k.posted) {
      if (t.effectiveDate > d) continue;
      for (final e in effectsOf(t)) {
        if (e.allocation.caseId == c.id) n += e.caseDelta;
      }
    }
    return n;
  }

  ReportDataset _f13() {
    final rows = <Map<String, Object?>>[];
    final totals = <String, Object?>{
      'opening': 0,
      'collected': 0,
      'remitted': 0,
      'closing': 0,
    };
    for (final c in f.k.cases) {
      if (c.kind != CaseKind.transit || !_fund(c.fundId)) continue;
      var masuk = 0, keluar = 0;
      for (final t in dalam) {
        for (final e in effectsOf(t)) {
          if (e.allocation.caseId != c.id) continue;
          if (e.type == TransactionType.transitCollection) {
            masuk += e.caseDelta;
          } else {
            keluar -= e.caseDelta;
          }
        }
      }
      final row = <String, Object?>{
        'caseId': c.id,
        'partyId': c.partyId,
        'title': c.title,
        'opening': _sisa(c, kemarin),
        'collected': masuk,
        'remitted': keluar,
        'closing': _sisa(c, p.end),
      };
      if (row['opening'] == 0 && masuk == 0 && keluar == 0) continue;
      for (final k in totals.keys.toList()) {
        totals[k] = (totals[k] as int) + (row[k] as int);
      }
      rows.add(row);
    }
    // ponytail: own-church centralization is Belanja on the master's
    // Sinode/Wilayah rows (DM 4.2, B002/B003); move to a policy when one
    // exists.
    var sendiri = 0;
    for (final t in dalam) {
      for (final e in effectsOf(t)) {
        final c = e.allocation.masterCode;
        if (_bagian(e.allocation) && (c == '1.1.00.00' || c == '1.2.00.00')) {
          sendiri += e.expense;
        }
      }
    }
    totals['ownCentralization'] = sendiri;
    return ReportDataset(form: ReportForm.f13, rows: rows, totals: totals);
  }

  ReportDataset _f14() {
    bool jenis(Transaction t, Set<TransactionType> s) =>
        s.contains(t.type) || t.allocations.any((a) => s.contains(a.type));
    final lampiran = <List<String>>[
      [
        for (final c in f.k.cases)
          if (c.kind == CaseKind.advance &&
              _fund(c.fundId) &&
              (_sisa(c, p.end) != 0 ||
                  dalam.any((t) => t.allocations.any((a) => a.caseId == c.id))))
            c.id,
      ],
      [
        for (final t in dalam)
          if (jenis(t, {
            TransactionType.advanceSpending,
            TransactionType.advanceReturn,
          }))
            t.id,
      ],
      // ponytail: offerings counted are Sunday "Persembahan …" receipts;
      // switch to a service link when offerings record their service.
      [
        for (final t in dalam)
          if (t.type == TransactionType.income &&
              t.effectiveDate.awal.weekday == DateTime.sunday &&
              t.description.startsWith('Persembahan'))
            t.id,
      ],
      [
        for (final t in dalam)
          if (jenis(t, {TransactionType.claimPayment})) t.id,
      ],
      [
        for (final t in dalam)
          if (f.k.evidenceStatus(t) == EvidenceStatus.exceptionAccepted) t.id,
      ],
      [
        for (final t in dalam)
          if (t.type == TransactionType.reversal) t.id,
      ],
      [
        for (final t in dalam)
          if (t.type == TransactionType.opening) t.id,
      ],
      _syaratBelum(),
    ];
    return ReportDataset(
      form: ReportForm.f14,
      rows: [
        for (final (i, items) in lampiran.indexed)
          {
            'n': i + 1,
            'items': items,
            'count': i == 7 ? 8 - items.length : items.length,
          },
      ],
    );
  }

  /// The eight close checks (TutupBuku) that blockers still fail.
  List<String> _syaratBelum() {
    final kinds = {for (final b in periods.blockers(p.id)) b.kind};
    const syarat = {
      'earlierPeriodOpen': {BlockerKind.earlierPeriodOpen},
      'reconciliation': {
        BlockerKind.statementMissing,
        BlockerKind.cashCountMissing,
        BlockerKind.notReconciled,
      },
      'classification': {BlockerKind.missingClassification},
      'approval': {BlockerKind.approvalMissing},
      'evidence': {BlockerKind.evidenceMissing},
      'drafts': {BlockerKind.openDraft},
      'imports': {BlockerKind.stagedImportRow},
      'template': {BlockerKind.templateNotAccepted},
    };
    return [
      for (final MapEntry(:key, :value) in syarat.entries)
        if (value.any(kinds.contains)) key,
    ];
  }
}
