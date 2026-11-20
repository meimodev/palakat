import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../motion/kerangka.dart';
import '../../providers/actor.dart';
import '../../providers/clock.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/keuangan/transaksi.dart';
import '../../providers/repositories_keuangan.dart';
import '../../providers/revision.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/isian_alasan.dart';
import '../../widgets/lembar_bawah.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/status_simpan.dart';
import '../../widgets/tombol.dart';

/// The draft `/draf/:id` that Draf and WebDraf open (DP17 b, RD09): read
/// live from TransactionRepository; "Pindah tanggal" and "Batalkan" take a
/// reason. The conflict card shows when the draft changed since it opened.
mixin LogikaDraf<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// The sheet or panel: 'pindah', 'batal' or null.
  String? lembar;

  /// The month to move to ('yyyy-mm').
  String? ke;
  final alasan = TextEditingController();
  Refusal? tolak;
  int? _revDibuka;

  @override
  void dispose() {
    alasan.dispose();
    super.dispose();
  }

  String get _id => GoRouterState.of(context).pathParameters['id'] ?? '';

  /// The draft, live; null when the id is unknown.
  Transaction? get t {
    ref.watch(revisionProvider);
    final t = ref.watch(transactionRepositoryProvider).get(_id);
    if (t != null) _revDibuka ??= t.revision;
    return t;
  }

  bool get konflik {
    final x = t;
    return x != null && x.isDraft && x.revision != _revDibuka;
  }

  void muat() => setState(() {
    _revDibuka = _baca()?.revision;
    tolak = null;
  });

  Period? get bulan {
    final x = _baca();
    if (x == null) return null;
    return ref
        .read(bulanBukuProvider)
        .semua
        .where((p) => p.contains(x.effectiveDate))
        .firstOrNull;
  }

  /// The draft now, for callbacks (no watch).
  Transaction? _baca() => ref.read(transactionRepositoryProvider).get(_id);

  bool get tutup => bulan?.isClosed ?? false;

  /// The months a draft may move to: open, after its own, not in the future.
  List<Period> get pilihanBulan =>
      _pilihan(ref.watch(bulanBukuProvider), ref.watch(hariIniProvider));

  List<Period> _pilihan(BulanBuku buku, Tanggal hari) {
    final dari = bulan?.id ?? '';
    return [
      for (final p in buku.semua)
        if (!p.isClosed && p.id.compareTo(dari) > 0 && p.start <= hari) p,
    ];
  }

  String get keTerpilih => ke ?? pilihanBulan.lastOrNull?.id ?? '';

  /// The new date: today in the running month, else the month's last day.
  Tanggal _tanggalBaru(Period p) {
    final hari = ref.read(hariIniProvider);
    return p.contains(hari) ? hari : p.end;
  }

  String namaPeriode(String id) => namaBulan(
    ref.read(bulanBukuProvider).semua.firstWhere((p) => p.id == id),
  );

  /// '−Rp650.000' as the lists sign it.
  int get jumlah {
    final x = t!;
    final s = signedAmount(x);
    return s != 0 ? s : -x.total;
  }

  String get kasBank {
    final akun = ref.watch(accountRepositoryProvider);
    return namaKasBank(
      t!,
      (id) => akun
          .accounts(includeInactive: true)
          .where((a) => a.id == id)
          .firstOrNull,
    );
  }

  String _nama(String personId) => ref.watch(namaPendekProvider(personId));

  String _olehAudit(AuditRecord r) => r.via == Via.direct
      ? _nama(r.personId)
      : '${r.personName}, ${r.actingRole}';

  List<AuditRecord> get _audit => ref
      .watch(auditRepositoryProvider)
      .list(AuditFilter(ref: RecordRef('transaction', _id)));

  /// Who changed it last and when, for the conflict card.
  (String, String) get pengubah {
    final r = _audit.firstOrNull;
    return r == null
        ? (_nama(t!.createdBy), tglJam(t!.createdAt))
        : (_olehAudit(r), tglJam(r.at));
  }

  String get dibatalkanOleh => _nama(t!.cancelledBy ?? t!.createdBy);

  /// Riwayat, newest first.
  List<String> get riwayat {
    final x = t!;
    final audit = _audit;
    String baris(AuditRecord r) {
      final oleh = _olehAudit(r);
      final alasan = r.reason == null ? '' : ' · alasan: ${r.reason}';
      final teks = switch (r.action) {
        'finance.txn.draft' => 'Draf dicatat oleh $oleh',
        'finance.txn.redate' =>
          'Pindah tanggal ke ${_bulanDari(r.after)}$alasan · oleh $oleh',
        'finance.txn.cancel' => 'Dibatalkan$alasan · oleh $oleh',
        _ => '${r.summary}$alasan · oleh $oleh',
      };
      return '${tglJam(r.at)} · $teks';
    }

    return [
      for (final r in audit) baris(r),
      if (!audit.any((r) => r.action == 'finance.txn.draft'))
        '${tglJam(x.createdAt)} · Draf dicatat oleh ${_nama(x.createdBy)}',
    ];
  }

  /// 'dd/mm/yyyy' → '{Bulan} {tahun}'.
  static String _bulanDari(String? tgl) {
    final b = tgl?.split('/');
    if (b == null || b.length != 3) return tgl ?? '';
    return bulanTahun(int.parse(b[2]), int.parse(b[1]));
  }

  void buka(String l) {
    if (_baca()?.revision != _revDibuka) return;
    alasan.clear();
    setState(() {
      lembar = l;
      tolak = null;
    });
  }

  void tutupLembar() => setState(() => lembar = null);

  String _kunci(Actor a) => kunciBaru(a.personId, ref.read(clockProvider));

  /// "Pindah tanggal ke …" or "Batalkan draf".
  Future<void> simpan() async {
    final a = ref.read(actorProvider);
    final x = _baca();
    final why = alasan.text.trim();
    final buku = ref.read(bulanBukuProvider);
    final keId = ke ?? _pilihan(buku, ref.read(hariIniProvider)).lastOrNull?.id;
    if (a == null || x == null || !IsianAlasan.terisi(why)) return;
    if (lembar == 'pindah' && keId == null) return;
    final repo = ref.read(transactionRepositoryProvider);
    final rev = _revDibuka ?? x.revision;
    final r = lembar == 'pindah'
        ? await repo.redate(
            a,
            x.id,
            _tanggalBaru(buku.semua.firstWhere((p) => p.id == keId)),
            reason: why,
            expectedRevision: rev,
            idempotencyKey: _kunci(a),
          )
        : await repo.cancel(
            a,
            x.id,
            reason: why,
            expectedRevision: rev,
            idempotencyKey: _kunci(a),
          );
    if (!mounted) return;
    setState(() {
      switch (r) {
        case Ok(:final value):
          _revDibuka = value.revision;
          lembar = null;
          tolak = null;
        case Refused(:final refusal):
          tolak = refusal;
      }
    });
  }

  /// "Periksa dan bukukan" (an open month only).
  Future<void> bukukan() async {
    final a = ref.read(actorProvider);
    final x = _baca();
    if (a == null || x == null || x.revision != _revDibuka) return;
    final r = await ref
        .read(transactionRepositoryProvider)
        .finalize(
          a,
          x.id,
          expectedRevision: _revDibuka ?? x.revision,
          idempotencyKey: _kunci(a),
        );
    if (!mounted) return;
    switch (r) {
      case Ok():
        context.gantiKe(Layar.transaksiRinci, param: {'id': x.id});
      case Refused(:final refusal):
        setState(() => tolak = refusal);
    }
  }

  /// The refusal of the last command, as the board words it.
  Widget? penolakan() {
    final r = tolak;
    if (r == null) return null;
    return Penolakan(
      tindakan: r.action,
      sebab: [
        r.because,
        if (r.whoCanAct != null) 'Yang perlu bertindak: ${r.whoCanAct}.',
      ].join(' '),
      jalan: const [],
    );
  }

  /// The closed month's refusal, worded as the Draf board.
  Widget penolakanTutup() => Penolakan(
    tindakan: 'Bukukan',
    sebab:
        '${namaBulan(bulan!)} sudah ditutup, dan draf ini tidak pernah '
        'masuk laporannya. Yang masih dapat Anda lakukan: pindah '
        'tanggal ke bulan yang belum ditutup, atau batalkan.',
    jalan: const [],
  );
}

/// 20 · Draf: pindah tanggal, batalkan (docs/build/screens/06-bukti.md).
class DrafScreen extends ConsumerStatefulWidget {
  const DrafScreen({super.key});

  @override
  ConsumerState<DrafScreen> createState() => _DrafScreenState();
}

class _DrafScreenState extends ConsumerState<DrafScreen> with LogikaDraf {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final x = t;
    final draf = x != null && x.isDraft;
    final batal = x?.status == TransactionStatus.cancelled;
    final pindah = lembar == 'pindah';
    final redup = TextStyle(fontSize: 13, color: c.tinta3);
    final b = bulan;

    final isi = <Widget>[
      if (x == null)
        Text(
          'Draf tidak ditemukan.',
          style: TextStyle(fontSize: 15, color: c.tinta2),
        ),
      if (konflik)
        PitaDiubahOrangLain(oleh: pengubah.$1, jam: pengubah.$2, onMuat: muat),
      if (draf) ...[
        Container(
          padding: const EdgeInsets.all(18),
          decoration: ShapeDecoration(
            shape: GarisBorder.putus(c.putus, radius: 16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LencanaStatus(
                'Draf · belum masuk saldo',
                bentuk: BentukLencana.draf,
              ),
              const SizedBox(height: 6),
              Text(
                rp(jumlah),
                style: TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: c.tinta2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                x.description,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                '$kasBank · tanggal transaksi '
                '${tglPanjang(x.effectiveDate.awal)}',
                style: redup,
              ),
              if (b != null) ...[
                const SizedBox(height: 6),
                Text(
                  '${namaBulan(b)}${tutup ? ' · Sudah ditutup' : ' · Belum ditutup'}',
                  style: redup,
                ),
              ],
            ],
          ),
        ),
        if (tutup) penolakanTutup(),
        ?penolakan(),
      ],
      if (batal && x != null)
        Gerak(
          Kerangka.muncul,
          key: const ValueKey('batal'),
          lama: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: c.permukaan,
              border: Border.all(color: c.garis),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: c.garis,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Dibatalkan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: c.tinta2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  rp(jumlah),
                  style: TextStyle(
                    fontFamily: PalakatText.mono,
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: c.tinta3,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: c.tinta3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  x.description,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  'Alasan: ${x.cancelReason ?? ''}',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dibatalkan oleh $dibatalkanOleh, '
                  '${x.cancelledAt == null ? '' : tglJam(x.cancelledAt!)} · '
                  'tidak pernah punya No. Bukti · hanya dapat dilihat',
                  style: redup,
                ),
              ],
            ),
          ),
        ),
      if (x != null && x.isPosted)
        Text(
          'Sudah dibukukan sebagai ${x.voucher}.',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      if (x != null)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: const Text(
                'Riwayat',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
            for (final h in riwayat) ...[
              const SizedBox(height: 6),
              Text(h, style: TextStyle(fontSize: 14, color: c.tinta2)),
            ],
          ],
        ),
    ];

    Widget kedua(String label, VoidCallback onTap) {
      final tombol = Tombol(
        label,
        onPressed: onTap,
        jenis: JenisTombol.kedua,
        ukuran: UkuranTombol.sedang,
        paddingH: 20,
      );
      // Board `disabled` with its full look kept: announced as disabled, the
      // conflict card above is the reason.
      return konflik
          ? Semantics(
              button: true,
              enabled: false,
              label: label,
              child: ExcludeSemantics(child: tombol),
            )
          : tombol;
    }

    final bawah = Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border(top: BorderSide(color: c.garis)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, w) in [
            if (!tutup)
              Tombol('Periksa dan bukukan', onPressed: bukukan, paddingH: 20),
            kedua('Pindah tanggal', () => buka('pindah')),
            kedua('Batalkan', () => buka('batal')),
          ].indexed) ...[if (i > 0) const SizedBox(height: 8), w],
        ],
      ),
    );

    final pilihan = pilihanBulan;
    final keBulan = keTerpilih;
    final lembarIni = lembar == null
        ? null
        : LembarBawah(
            judul: pindah ? 'Pindah tanggal' : 'Batalkan draf',
            anakJudul: pindah
                ? 'Hanya bulan sesudahnya yang belum ditutup. Draf tetap '
                      'Draf, dan tanda sudah diperiksa atau persetujuan yang '
                      'ada akan hilang.'
                : 'Draf yang dibatalkan tidak pernah punya No. Bukti dan '
                      'tetap dapat dilihat bersama alasannya.',
            onTutup: tutupLembar,
            pegangan: false,
            masuk: Kerangka.muncul,
            labelTirai: 'Kembali ke draf',
            isi: [
              if (pindah)
                ChipPilihan<String>(
                  label: 'Pindah ke bulan',
                  pilihan: [
                    for (final p in pilihan)
                      (nilai: p.id, teks: '${namaBulan(p)} · Belum ditutup'),
                  ],
                  terpilih: keBulan,
                  onPilih: (id) => setState(() => ke = id),
                ),
              // The board's textarea is inline in a div: the line box adds
              // about 5 px below it.
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: IsianAlasan(
                  controller: alasan,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              ?penolakan(),
              Tombol(
                pindah && keBulan.isNotEmpty
                    ? 'Pindah tanggal ke ${namaPeriode(keBulan)}'
                    : pindah
                    ? 'Pindah tanggal'
                    : 'Batalkan draf',
                onPressed: simpan,
                jenis: JenisTombol.tinta,
                paddingH: 20,
                nonaktif:
                    !IsianAlasan.terisi(alasan.text) ||
                    (pindah && keBulan.isEmpty),
              ),
              Tombol(
                'Kembali',
                onPressed: tutupLembar,
                jenis: JenisTombol.teks,
                warnaTeks: c.tinta,
                paddingH: 6,
              ),
            ],
          );

    return LayarPonsel(
      layarKeuangan: true,
      overlay: [if (lembarIni != null) Positioned.fill(child: lembarIni)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Draf',
            kembaliKe: Layar.keuangan,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, w) in isi.indexed) ...[
                    if (i > 0) const SizedBox(height: 16),
                    w,
                  ],
                ],
              ),
            ),
          ),
          if (draf) bawah,
        ],
      ),
    );
  }
}
