import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../providers/actor.dart';
import '../../providers/clock.dart';
import '../../providers/keuangan/pemeriksa.dart';
import '../../providers/keuangan/rinci_transaksi.dart';
import '../../providers/keuangan/transaksi.dart';
import '../../providers/repositories_keuangan.dart';

import '../../theme/palakat_tema.dart';

/// A detail row of Pemeriksa and WebPemeriksa: label 14 `tinta2` and value
/// 14/600 in a `space-between` flex row, gap 16. When both do not fit, each
/// shrinks in proportion to its own width, as CSS `flex-shrink: 1` does.
class BarisRincian extends StatelessWidget {
  const BarisRincian(
    this.label,
    this.nilai, {
    super.key,
    this.warna,
    this.kanan = false,
    this.atas = true,
    this.vertikal = 11,
  });

  final String label, nilai;

  /// Value colour; inherits `tinta` when null.
  final Color? warna;

  /// The value's `text-align: right`.
  final bool kanan;

  /// The 1 px `garis` line above (every row but the first).
  final bool atas;

  /// Row padding top and bottom: 11 phone, 10 web.
  final double vertikal;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final gayaLabel = TextStyle(fontSize: 14, color: c.tinta2);
    final gayaNilai = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: warna,
    );
    final dasar = DefaultTextStyle.of(context).style;
    final skala = MediaQuery.textScalerOf(context);
    double lebar(String t, TextStyle g) {
      final p = TextPainter(
        text: TextSpan(text: t, style: dasar.merge(g)),
        textDirection: TextDirection.ltr,
        textScaler: skala,
      )..layout();
      final w = p.width;
      p.dispose();
      return w;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: vertikal),
      decoration: atas
          ? BoxDecoration(
              border: Border(top: BorderSide(color: c.garis)),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: (lebar(label, gayaLabel) * 100).round(),
            child: Text(label, style: gayaLabel),
          ),
          const SizedBox(width: 16),
          Flexible(
            flex: (lebar(nilai, gayaNilai) * 100).round(),
            child: Text(
              nilai,
              textAlign: kanan ? TextAlign.right : TextAlign.left,
              style: gayaNilai,
            ),
          ),
        ],
      ),
    );
  }
}

/// What Pemeriksa and WebPemeriksa show for one transaction of the queue
/// (a draft awaiting the check, or one booked from this screen).
class TampilPemeriksa {
  const TampilPemeriksa({
    required this.t,
    required this.pencatat,
    required this.pemeriksa,
    required this.kasBank,
    required this.jumlah,
    required this.peruntukan,
    required this.lingkup,
    required this.mataAnggaran,
    required this.dokumen,
    required this.tolakTandai,
    required this.bendahara,
  });

  final Transaction t;
  final String pencatat;

  /// Who marked it checked; null while it is not.
  final String? pemeriksa;
  final String kasBank, peruntukan, lingkup;
  final int jumlah;

  /// 'Belanja 5.05.02.00 Sewa peralatan'; 'Mata Anggaran belum dipilih'.
  final String mataAnggaran;
  final String dokumen;

  /// Why the viewer cannot mark it, the board's sentence (after
  /// "Tidak dapat dilakukan: "); null when they can.
  final String? tolakTandai;

  /// The viewer books (finance.finalize): "Bukukan" and "Ubah".
  final bool bendahara;

  bool get draf => t.status == TransactionStatus.draft;
  bool get diperiksa => t.status == TransactionStatus.reviewed;
  bool get dibukukan => t.isPosted;
}

/// [id] as Pemeriksa shows it; null when it is gone. [web]: WebPemeriksa's
/// shorter maker refusal.
TampilPemeriksa? tampilPemeriksa(WidgetRef ref, String id, {bool web = false}) {
  final r = ref.watch(rincianTransaksiProvider(id));
  final t = ref.watch(transactionRepositoryProvider).get(id);
  final a = ref.watch(actorProvider);
  if (r == null || t == null || a == null) return null;
  final can = ref.watch(canProvider);
  final hari = ref.watch(hariIniProvider);
  String fakta(String kunci, [String kosong = '']) =>
      r.fakta.where((x) => x.$1 == kunci).firstOrNull?.$2 ?? kosong;

  final pemeriksaKedua = [
    for (final p in can.whoCan(
      Capability.financeReview,
      ScopeRef.jemaat,
      at: hari,
    ))
      if (p.id != t.createdBy &&
          can
              .grantsFor(
                p.id,
                Capability.financeReview,
                ScopeRef.jemaat,
                at: hari,
              )
              .any((g) => g.kind != GrantKind.cover))
        p.name,
  ].join(', ');
  final g = can.grantFor(
    a,
    Capability.financeReview,
    ScopeRef.jemaat,
    at: hari,
  );
  final String? tolak;
  if (!t.isDraft) {
    tolak = null;
  } else if (pemeriksaKedua.isEmpty && t.createdBy == a.personId) {
    tolak =
        'belum ada pemeriksa kedua yang ditunjuk. Yang perlu bertindak: BPMJ '
        'menunjuk pemeriksa kedua.';
  } else if (g?.kind == GrantKind.cover) {
    tolak =
        'Operator yang menjalankan jabatan kosong tidak dapat menjadi '
        'pemeriksa. Pemeriksa kedua: $pemeriksaKedua.';
  } else if (t.createdBy == a.personId) {
    tolak = web
        ? 'Anda yang mencatat transaksi ini. Pemeriksa kedua: $pemeriksaKedua.'
        : 'Anda yang mencatat transaksi ini, jadi orang lain yang harus '
              'menandainya sudah diperiksa. Pemeriksa kedua: $pemeriksaKedua.';
  } else {
    tolak = null;
  }
  return TampilPemeriksa(
    t: t,
    pencatat: ref.watch(namaPendekProvider(t.createdBy)),
    pemeriksa: t.status == TransactionStatus.draft || t.reviewedBy == null
        ? null
        : ref.watch(namaPendekProvider(t.reviewedBy!)),
    kasBank: r.baris.kasBank,
    jumlah: r.baris.jumlah,
    peruntukan: fakta('Diambil dari peruntukan', fakta('Peruntukan')),
    lingkup: fakta('Lingkup'),
    mataAnggaran: fakta('Mata Anggaran', 'Mata Anggaran belum dipilih'),
    dokumen: fakta('Dokumen pendukung', 'Tidak wajib'),
    tolakTandai: tolak,
    bendahara: can.can(
      a,
      Capability.financeFinalize,
      ScopeRef.jemaat,
      at: hari,
    ),
  );
}

/// "Masuk sebagai **{nama}, {jabatan}** · Wajib pemeriksa kedua: {hidup|mati}".
({String siapa, String aturan}) masukSebagaiPemeriksa(WidgetRef ref) {
  final a = ref.watch(actorProvider);
  final hari = ref.watch(hariIniProvider);
  final hidup = ref
      .watch(settingsRepositoryProvider)
      .rulesInForce(at: hari)
      .secondChecker;
  if (a == null) return (siapa: '', aturan: hidup ? 'hidup' : 'mati');
  final can = ref.watch(canProvider);
  final g =
      can.grantFor(a, Capability.financeFinalize, ScopeRef.jemaat, at: hari) ??
      can.grantFor(a, Capability.financeReview, ScopeRef.jemaat, at: hari);
  // The boards word the post without " Jemaat" ("Bendahara").
  final jabatan = (g?.title ?? '').replaceFirst(RegExp(r' Jemaat$'), '');
  final nama = ref.watch(namaPendekProvider(a.personId));
  return (
    siapa: jabatan.isEmpty ? nama : '$nama, $jabatan',
    aturan: hidup ? 'hidup' : 'mati',
  );
}

/// The commands of Pemeriksa and WebPemeriksa, and which draft is selected.
mixin LogikaPemeriksa<W extends ConsumerStatefulWidget> on ConsumerState<W> {
  /// The tapped row; else the first.
  String? pilih;

  /// Booked from this screen: they leave the queue but stay listed, stamped.
  final dibukukan = <String>[];

  /// The last command's refusal and the transaction it was for.
  Refusal? tolak;
  String? tolakUntuk;

  /// The queue's ids, then those booked here.
  List<String> daftarId(List<BarisPemeriksa> antrean) {
    final ids = [for (final b in antrean) b.transaksi.id];
    return [...ids, ...dibukukan.where((id) => !ids.contains(id))];
  }

  String? terpilih(List<String> ids) =>
      ids.contains(pilih) ? pilih : ids.firstOrNull;

  void pilihBaris(String id) => setState(() {
    pilih = id;
    tolak = null;
  });

  Future<void> _jalankan(
    Transaction t,
    Future<Result<Object?>> Function(Actor a, String kunci) perintah, {
    void Function()? berhasil,
  }) async {
    final a = ref.read(actorProvider);
    if (a == null) return;
    final r = await perintah(a, kunciBaru(a.personId, ref.read(clockProvider)));
    if (!mounted) return;
    setState(() {
      tolak = r.refusal;
      tolakUntuk = t.id;
      if (r.isOk) berhasil?.call();
    });
  }

  /// "Tandai sudah diperiksa".
  void tandai(Transaction t) => _jalankan(
    t,
    (a, k) => ref
        .read(transactionRepositoryProvider)
        .review(a, t.id, expectedRevision: t.revision, idempotencyKey: k),
  );

  /// "Bukukan": finalize; the row stays listed with its stamp.
  void bukukan(Transaction t) => _jalankan(
    t,
    (a, k) => ref
        .read(transactionRepositoryProvider)
        .finalize(a, t.id, expectedRevision: t.revision, idempotencyKey: k),
    berhasil: () => dibukukan.add(t.id),
  );

  /// "Ubah dan kembalikan ke Draf": a change to the parts returns a checked
  /// draft to Draf and drops the check and recorded approvals (DM 5.1).
  // ponytail: re-sends the same parts as the material change; a dedicated
  // "kembalikan ke Draf" command would say so in the audit line.
  void kembalikan(Transaction t) => _jalankan(
    t,
    (a, k) => ref
        .read(transactionRepositoryProvider)
        .editDraft(
          a,
          t.id,
          TransactionPatch(allocations: List.of(t.allocations)),
          expectedRevision: t.revision,
          idempotencyKey: k,
        ),
  );
}
