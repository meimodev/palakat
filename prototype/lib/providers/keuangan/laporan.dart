import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/repositories/report_repository.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../actor.dart';
import '../core_repositories.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';
import 'beranda.dart';

/// Reports (Laporan, WebLaporan, WebPaketLaporan, the A4 and Excel views,
/// LihatTransaksi, Bukti; README 4.6 point 3, 7.1 rule 5): read models over
/// ReportRepository. Every figure comes from a dataset (D11).

/// One month's report: its datasets, and whether they are the frozen close
/// snapshot ("Laporan resmi") or a preview ("Laporan sementara").
class LaporanBulan {
  const LaporanBulan({
    required this.periode,
    required this.snapshot,
    required this.format,
    required this.namaAkun,
    required this.penutup,
    required this.pencatatFormat,
    required this.repo,
  });

  final Period periode;
  final ReportSnapshot? snapshot;

  /// The accepted report template (DP11), if any.
  final ReportTemplate? format;

  /// Account names by id.
  final Map<String, String> namaAkun;

  /// The closer's name, once closed.
  final String? penutup;

  /// Who recorded the template's acceptance.
  final String? pencatatFormat;
  final ReportRepository repo;

  bool get resmi => snapshot != null;

  ReportDataset data(ReportForm f) => repo.dataset(ReportSource(periode.id), f);

  String akun(String? id) => namaAkun[id] ?? id ?? '';
}

/// The report of [periodId] ('yyyy-mm'); null for an unknown month.
final laporanPeriodeProvider = Provider.family<LaporanBulan?, String>((
  ref,
  periodId,
) {
  ref.watch(revisionProvider);
  final per = ref.watch(periodRepositoryProvider);
  final p = per.period(periodId);
  if (p == null) return null;
  final rep = ref.watch(reportRepositoryProvider);
  final orang = ref.watch(peopleRepositoryProvider);
  final penutup = p.closedBy == null ? null : orang.person(p.closedBy!);
  final format = rep.templates().where((t) => t.accepted).firstOrNull;
  final pencatat = format == null ? null : orang.person(format.acceptedBy!);
  return LaporanBulan(
    periode: p,
    snapshot: rep.snapshot(p.id),
    format: format,
    pencatatFormat: pencatat?.shortName ?? pencatat?.name,
    namaAkun: {
      for (final a in ref.watch(accountRepositoryProvider).accounts())
        a.id: a.name,
    },
    penutup: penutup?.name,
    repo: rep,
  );
});

/// The month Laporan opens on: the month next to close once it has ended
/// (a preview), else the last closed month (official), else the running
/// month.
final laporanBulanProvider = Provider<LaporanBulan?>((ref) {
  final bb = ref.watch(bulanBukuProvider);
  final hari = ref.watch(hariIniProvider);
  final b = bb.berikutDitutup;
  final p = b != null && b.end < hari
      ? b
      : bb.semua.where((p) => p.isClosed).lastOrNull ?? b ?? bb.berjalan;
  return p == null ? null : ref.watch(laporanPeriodeProvider(p.id));
});

/// 'dd/mm/yyyy HH.mm' the snapshot was frozen.
String dibekukan(ReportSnapshot s) => tglJam(s.frozenAt);

// ---------- LihatTransaksi ----------

/// One posted transaction's part in a report figure.
typedef BarisLaporan = ({
  String id,
  String no,
  String tgl,
  String ur,
  String cat,
  int jm,
});

/// One F05/F07 figure and the parts behind it.
typedef AngkaLaporan = ({
  String id,
  String pendek,
  String lap,
  String n,
  List<BarisLaporan> rows,
  int total,
});

/// The F05 and F07 figures of [l] with an amount, and the posted parts on
/// each Mata Anggaran (a reversal negative, a split by its part).
List<AngkaLaporan> angkaLaporan(LaporanBulan l, List<Transaction> dibukukan) {
  final hasil = <AngkaLaporan>[];
  for (final (form, masuk) in [
    (ReportForm.f05, true),
    (ReportForm.f07, false),
  ]) {
    for (final r in l.data(form).rows) {
      if (r['postable'] != true || r['amount'] == 0) continue;
      final kode = r['code'] as String;
      final rows = <BarisLaporan>[];
      for (final t in dibukukan) {
        if (!l.periode.contains(t.effectiveDate)) continue;
        var n = 0;
        for (final e in effectsOf(t)) {
          if (e.allocation.masterCode == kode) {
            n += masuk ? e.income : e.expense;
          }
        }
        if (n == 0) continue;
        rows.add((
          id: t.id,
          no: t.voucher ?? '',
          tgl: '${t.effectiveDate}',
          ur: t.description,
          cat: t.type == TransactionType.reversal
              ? 'Pembalikan'
              : n != t.total
              ? 'Bagian dari ${rp(t.total)}'
              : '',
          jm: n,
        ));
      }
      hasil.add((
        id: kode,
        pendek: r['name'] as String,
        lap: form == ReportForm.f05
            ? 'F05 · Realisasi Pendapatan Menurut Mata Anggaran'
            : 'F07 · Realisasi Belanja Menurut Mata Anggaran',
        n: '${masuk ? 'Pendapatan' : 'Belanja'} $kode ${r['name']}',
        rows: rows,
        total: r['amount'] as int,
      ));
    }
  }
  return hasil;
}

final angkaLaporanProvider = Provider<List<AngkaLaporan>>((ref) {
  final l = ref.watch(laporanBulanProvider);
  if (l == null) return const [];
  return angkaLaporan(
    l,
    ref
        .watch(transactionRepositoryProvider)
        .list(l.periode.id)
        .where((t) => t.isPosted)
        .toList(),
  );
});

// ---------- Bukti ----------

/// Bukti (phone and web): a year's BKU numbers and the numbers given without
/// a posted transaction (DP7).
typedef BuktiTahun = ({
  int tahun,
  List<VoucherEntry> nomor,
  List<VoucherEntry> celah,
});

/// The BKU years with numbers, newest first.
final buktiProvider = Provider<List<BuktiTahun>>((ref) {
  ref.watch(revisionProvider);
  final tx = ref.watch(transactionRepositoryProvider);
  final tahun = {for (final p in ref.watch(bulanBukuProvider).semua) p.year};
  return [
    for (final y in tahun.toList()..sort((a, b) => b.compareTo(a)))
      if (tx.voucherSeries(VoucherSeries.bku, y) case final n when n.isNotEmpty)
        (tahun: y, nomor: n, celah: tx.gaps(VoucherSeries.bku, y)),
  ];
});

/// One Bukti Kas row (Bukti, WebBukti): an F12 posted row as the boards
/// print it.
typedef BarisBukti = ({
  String id,
  String no,
  String tgl,
  String ur,
  String tanda,
  String asal,
  int jumlah,
  String setuju,
  String dok,
  bool wajib,
});

const _setujuBukti = {
  'notRequired': 'tidak diperlukan',
  'recorded': 'sudah dicatat',
  'missing': 'belum dicatat',
};

const _dokBukti = {
  'notRequired': 'tidak diperlukan',
  'requiredMissing': 'wajib, belum ada',
  'uploaded': 'diunggah, belum diverifikasi',
  'verified': 'terverifikasi',
  'exceptionAccepted': 'dikecualikan',
};

/// The posted Bukti Kas of [periodId], newest number first (F12).
final buktiBulanProvider = Provider.family<List<BarisBukti>, String>((
  ref,
  periodId,
) {
  final l = ref.watch(laporanPeriodeProvider(periodId));
  if (l == null) return const [];
  final tx = ref.watch(transactionRepositoryProvider);
  final rows = [
    for (final r
        in l.repo
            .preview(periodId, Perimeter.whole)
            .datasets[ReportForm.f12]!
            .rows)
      if (r['kind'] == 'posted') r,
  ];
  return [
    for (final r in rows.reversed)
      () {
        final t = tx.get(r['transactionId'] as String);
        final balik = t?.reversedBy == null ? null : tx.get(t!.reversedBy!);
        return (
          id: r['transactionId'] as String,
          no: '${r['voucher']}',
          tgl: '${r['date']}',
          ur: '${r['description']}',
          tanda: balik == null ? '' : 'Dibalik oleh No. Bukti ${balik.voucher}',
          asal: t?.sourceRef ?? '',
          jumlah: r['amount'] as int,
          setuju: _setujuBukti[r['approval']] ?? '',
          dok: _dokBukti[r['evidence']] ?? '',
          wajib: r['evidence'] == 'requiredMissing',
        );
      }(),
  ];
});

/// The Bendahara in office today, for the signature lines; null while the
/// post is vacant.
final namaBendaharaProvider = Provider<String?>((ref) {
  ref.watch(revisionProvider);
  final h = ref
      .watch(roleRepositoryProvider)
      .posts()
      .where((p) => p.post.role == Role.bendaharaJemaat)
      .firstOrNull
      ?.holder;
  return h == null
      ? null
      : ref.watch(peopleRepositoryProvider).person(h.personId)?.name;
});

// ---------- Terbatas (D27, README 3.5) ----------

/// One Fund's part of a posted transaction, for a Fund-only viewer.
typedef BarisTerbatas = ({
  String id,
  String no,
  String tgl,
  String ma,
  String maPenuh,
  String lingkup,
  int jm,
});

/// What a Fund-only viewer sees: their Fund, its balance today, its parts
/// (newest first) and the last closed month's TERBATAS report.
typedef Terbatas = ({
  Fund dana,
  int saldo,
  List<BarisTerbatas> baris,
  Period? ditutup,
});

/// The signed-in viewer's Fund (the report perimeter cut to their Funds);
/// null for a whole-Jemaat viewer or nobody.
final terbatasProvider = Provider<Terbatas?>((ref) {
  ref.watch(revisionProvider);
  final bb = ref.watch(bulanBukuProvider);
  final p = bb.berjalan ?? bb.semua.lastOrNull;
  if (p == null) return null;
  final ids = ref
      .watch(reportRepositoryProvider)
      .preview(p.id, Perimeter.whole)
      .perimeter
      .fundIds;
  if (ids == null || ids.isEmpty) return null;
  final fr = ref.watch(fundRepositoryProvider);
  final dana = fr.funds().where((f) => ids.contains(f.id)).firstOrNull;
  if (dana == null) return null;
  final hari = ref.watch(hariIniProvider);
  final ma = ref.watch(masterRepositoryProvider);
  final nama = {
    for (final k in MasterKind.values)
      for (final r in ma.pickerRows(k, hari)) r.code: r.name,
  };
  final lingkup = ref.watch(orgRepositoryProvider);
  final baris = <BarisTerbatas>[];
  final tx = ref.watch(transactionRepositoryProvider).list(null).toList()
    ..sort((a, b) {
      final d = b.effectiveDate.compareTo(a.effectiveDate);
      return d != 0 ? d : (b.voucher ?? '').compareTo(a.voucher ?? '');
    });
  for (final t in tx) {
    if (!t.isPosted) continue;
    var n = 0;
    for (final e in effectsOf(t)) {
      for (final l in e.legs) {
        if (l.accountId != null && l.fundId == dana.id) n += l.amount;
      }
    }
    final a = t.allocations.where((a) => a.fundId == dana.id).firstOrNull;
    if (n == 0 || a == null) continue;
    final kode = a.masterCode;
    baris.add((
      id: t.id,
      no: t.voucher ?? '',
      tgl: '${t.effectiveDate}',
      ma: nama[kode] ?? kode ?? '',
      maPenuh: kode == null
          ? ''
          : '${n > 0 ? 'Pendapatan' : 'Belanja'} $kode ${nama[kode] ?? ''}',
      lingkup: lingkup.scope(a.scopeId ?? '')?.name ?? a.scopeId ?? '',
      jm: n,
    ));
  }
  return (
    dana: dana,
    saldo: fr.balance(dana.id, at: hari),
    baris: baris,
    ditutup: bb.semua.where((p) => p.isClosed).lastOrNull,
  );
});

/// The TERBATAS copy of [periodId] for the viewer's Fund (D27); null for a
/// whole-Jemaat viewer.
final laporanTerbatasProvider = Provider.family<RestrictedReport?, String>((
  ref,
  periodId,
) {
  final t = ref.watch(terbatasProvider);
  if (t == null) return null;
  return ref
      .watch(reportRepositoryProvider)
      .restricted(ReportSource(periodId), t.dana.id);
});
