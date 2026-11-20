import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/finance/finance.dart';
import '../actor.dart';
import '../core_repositories.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';
import 'catat.dart';

/// The read model of Kewajiban, WebKewajiban, WebKasus and the home (M3):
/// each case with the board's labels, computed from posted linked parts
/// (D11), plus its open drafts.

/// The board's kind key: 'um' Uang Muka, 'tt' Titipan, 'pb' Penggantian
/// biaya.
String jenisKasus(CaseKind k) => switch (k) {
  CaseKind.advance => 'um',
  CaseKind.transit => 'tt',
  CaseKind.claim => 'pb',
};

/// One history row of a case.
class EntriKasus {
  const EntriKasus({
    required this.nama,
    required this.no,
    required this.tgl,
    required this.cat,
    required this.jumlah,
    required this.transaksiId,
    required this.revisi,
    this.draf = false,
    this.diperiksa = false,
  });

  /// 'Pertanggungjawaban uang muka'.
  final String nama;

  /// The voucher, or '' for a draft.
  final String no;

  /// 'dd/mm/yyyy'.
  final String tgl;

  /// 'menjadi Belanja'.
  final String cat;
  final int jumlah;
  final String transaksiId;
  final int revisi;

  /// Not posted yet; [diperiksa] once the second checker marked it.
  final bool draf, diperiksa;
}

/// One case as the boards draw it.
class BarisKasus {
  const BarisKasus({
    required this.id,
    required this.jenis,
    required this.judul,
    required this.pihak,
    required this.awal,
    required this.awalCat,
    required this.terpakai,
    required this.tempo,
    required this.lewat,
    required this.dicek,
    required this.entri,
    required this.revisi,
    required this.view,
  });

  final String id;

  /// 'um' | 'tt' | 'pb'.
  final String jenis;
  final String judul, pihak;

  /// Issued, collected or claimed (posted only).
  final int awal;
  final String awalCat;

  /// Settled, returned, remitted or paid (posted only).
  final int terpakai;

  /// 'dd/mm/yyyy' or ''.
  final String tempo;
  final bool lewat;

  /// A claim checked ("klaim sudah dicek").
  final bool dicek;
  final List<EntriKasus> entri;

  /// The case's revision (expectedRevision of the case commands).
  final int revisi;
  final CaseView view;

  int get sisa => awal - terpakai;

  /// The opening (issue or collection) is still a draft.
  bool get awalDraf => awal == 0 && entri.any((e) => e.draf);

  List<EntriKasus> get draf => [
    for (final e in entri)
      if (e.draf) e,
  ];
}

String _tgl(DateTime d) => tgl(d);

/// Every case, in seed order, with its figures at today.
final daftarKasusProvider = Provider<List<BarisKasus>>((ref) {
  ref.watch(revisionProvider);
  final kasus = ref.watch(caseRepositoryProvider);
  final tx = ref.watch(transactionRepositoryProvider);
  final akun = ref.watch(accountRepositoryProvider);
  final dana = ref.watch(fundRepositoryProvider);
  final pihak = {
    for (final p in ref.watch(peopleRepositoryProvider).parties())
      p.id: p.displayName,
  };
  final semua = tx.list(null);
  final hasil = <BarisKasus>[];
  for (final v in [
    ...kasus.advances(),
    ...kasus.transits(),
    ...kasus.claims(),
  ]) {
    final c = v.kase;
    final naik = c.kind == CaseKind.advance
        ? TransactionType.advanceIssue
        : TransactionType.transitCollection;
    Transaction? pembuka;
    var jumlahPembuka = 0;
    final entri = <EntriKasus>[];
    for (final t in semua) {
      if (t.status == TransactionStatus.cancelled) continue;
      if (t.type == TransactionType.reversal) continue;
      final bagian = t.allocations.where((a) => a.caseId == c.id).toList();
      if (bagian.isEmpty) continue;
      final jumlah = bagian.fold(0, (s, a) => s + a.amount);
      final jenis = t.typeOf(bagian.first);
      if (jenis == naik) {
        if (t.isPosted) {
          pembuka ??= t;
          jumlahPembuka++;
          continue;
        }
      }
      final (nama, cat) = switch (jenis) {
        TransactionType.advanceIssue => ('Uang Muka diberikan', 'dari Kas'),
        TransactionType.advanceSpending => (
          'Pertanggungjawaban uang muka',
          'menjadi Belanja',
        ),
        TransactionType.advanceReturn => (
          'Pengembalian sisa uang muka',
          'kembali ke Kas',
        ),
        TransactionType.transitCollection => ('Titipan diterima', 'masuk'),
        TransactionType.transitRemittance => ('Penyaluran', 'bukan Belanja'),
        TransactionType.claimPayment => (
          'Penggantian biaya dibayar',
          'Belanja, dicatat satu kali',
        ),
        _ => (t.description, ''),
      };
      if (t.isReversed) continue;
      entri.add(
        EntriKasus(
          nama: nama,
          no: t.voucher ?? '',
          tgl: _tgl(t.effectiveDate.awal),
          cat: cat,
          jumlah: jumlah,
          transaksiId: t.id,
          revisi: t.revision,
          draf: t.isDraft,
          diperiksa: t.status == TransactionStatus.reviewed,
        ),
      );
    }
    final nama = pihak[c.partyId] ?? c.partyId ?? '—';
    final String awalCat;
    switch (c.kind) {
      case CaseKind.advance:
        final p = pembuka;
        awalCat = p == null
            ? 'Draf · belum masuk saldo'
            : '${p.voucher} · ${_tgl(p.effectiveDate.awal)} · dari peruntukan '
                  '${dana.fund(c.fundId)?.name ?? c.fundId}';
      case CaseKind.transit:
        final tempat = akun
            .accounts(includeInactive: true)
            .where((x) => x.id == c.accountId)
            .firstOrNull
            ?.name;
        awalCat =
            c.note ??
            (pembuka == null
                ? 'Draf · belum masuk saldo'
                : 'Dari $jumlahPembuka persembahan'
                      '${tempat == null ? '' : ' · disimpan di $tempat'}');
      case CaseKind.claim:
        awalCat =
            '${c.note ?? 'Klaim'}${v.outstanding > 0 ? ' · belum masuk saldo' : ''}';
    }
    hasil.add(
      BarisKasus(
        id: c.id,
        jenis: jenisKasus(c.kind),
        judul: c.title,
        pihak: nama,
        awal: v.amount,
        awalCat: awalCat,
        terpakai: v.reduced,
        tempo: c.dueDate == null ? '' : _tgl(c.dueDate!.awal),
        lewat: v.overdue,
        dicek: c.checkedBy != null,
        entri: entri,
        revisi: c.revision,
        view: v,
      ),
    );
  }
  return hasil;
});

/// What KasusBaru and WebKasusBaru offer today: the church's Kas/Bank with
/// their book balance, the peruntukan, the Lingkup, the Mata Anggaran rows a
/// Titipan may use, and three due dates (end of this month, mid and end of
/// the next).
class PilihanKasusBaru {
  const PilihanKasusBaru({
    required this.kasBank,
    required this.peruntukan,
    required this.lingkup,
    required this.titipan,
    required this.tempo,
  });

  final List<({String id, String nama, int saldo})> kasBank;
  final List<({String id, String nama})> peruntukan, lingkup;

  /// (code, name).
  final List<(String, String)> titipan;
  final List<Tanggal> tempo;
}

final pilihanKasusBaruProvider = Provider<PilihanKasusBaru>((ref) {
  ref.watch(revisionProvider);
  final hari = ref.watch(hariIniProvider);
  final p = ref.watch(pilihanCatatProvider(hari));
  final akun = ref.watch(accountRepositoryProvider);
  final gereja = {
    for (final a in akun.accounts())
      if (a.operatedByScopeId == null) a.id,
  };
  Tanggal akhir(int tahun, int bulan) =>
      Tanggal.dari(DateTime.utc(tahun, bulan + 1, 0));
  final depan = Tanggal.dari(DateTime.utc(hari.tahun, hari.bulan + 1));
  return PilihanKasusBaru(
    kasBank: [
      for (final x in p.kasBank)
        if (gereja.contains(x.id))
          (id: x.id, nama: x.nama, saldo: akun.balance(x.id)),
    ],
    peruntukan: p.peruntukan,
    lingkup: p.lingkup,
    titipan: [
      for (final r
          in ref
              .watch(masterRepositoryProvider)
              .pickerRows(MasterKind.pendapatan, hari))
        if (r.postable && r.allowedEffect.allowsCustody) (r.code, r.name),
    ],
    tempo: [
      akhir(hari.tahun, hari.bulan),
      Tanggal(depan.tahun, depan.bulan, 15),
      akhir(depan.tahun, depan.bulan),
    ],
  );
});
