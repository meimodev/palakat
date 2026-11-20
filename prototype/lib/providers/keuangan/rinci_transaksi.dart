import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/finance/finance.dart';
import '../core_repositories.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';
import 'beranda.dart';
import '../../domain/core/core.dart' show ScopeRef;
import 'transaksi.dart';

/// One fact of the detail panel: key, value, value in `bata`.
typedef FaktaTransaksi = (String, String, bool);

/// What an action of the detail panel does.
enum JenisAksi {
  /// "Periksa dan bukukan": finalize in place.
  bukukan,

  /// "Ubah", "Pilih Mata Anggaran": load the draft into Catat, then open it.
  ubah,

  /// A link (push) to [AksiTransaksi.ke].
  tautan,
}

class AksiTransaksi {
  const AksiTransaksi(
    this.label,
    this.jenis, {
    this.ke,
    this.param = const {},
    this.anak,
    this.utama = false,
    this.dokumen,
  });

  final String label;
  final JenisAksi jenis;
  final Layar? ke;
  final Map<String, String> param;
  final String? anak;
  final bool utama;

  /// The transaction a document screen ([ke]) works on: pick it in
  /// `pilihanDokumenProvider` before opening (those routes carry no id).
  final String? dokumen;
}

/// The transaction detail (WebTransaksi and TabTransaksi panel; Main
/// `detail/:id` may share it): the list row, facts, what can be done and
/// why not, and Riwayat.
class RincianTransaksi {
  const RincianTransaksi({
    required this.baris,
    required this.catatanBaris,
    required this.fakta,
    required this.aksi,
    required this.catatan,
    required this.riwayat,
  });

  final BarisTransaksi baris;

  /// The table's third line: 'Belum masuk saldo · Mata Anggaran belum
  /// dipilih', 'Dokumen pendukung wajib, belum ada', 'Pembalikan',
  /// 'Dibalik oleh No. Bukti …', 'Tidak pernah dibukukan'.
  final String? catatanBaris;
  final List<FaktaTransaksi> fakta;
  final List<AksiTransaksi> aksi;

  /// The note under the actions.
  final String catatan;

  /// Newest first.
  final List<String> riwayat;

  Transaction get transaksi => baris.transaksi;
}

/// [RincianTransaksi] of transaction [id]; null when the viewer cannot see
/// it.
final rincianTransaksiProvider = Provider.family<RincianTransaksi?, String>((
  ref,
  id,
) {
  ref.watch(revisionProvider);
  final tx = ref.watch(transactionRepositoryProvider);
  final t = tx.get(id);
  if (t == null) return null;
  final akun = ref.watch(accountRepositoryProvider);
  final dana = ref.watch(fundRepositoryProvider);
  final org = ref.watch(orgRepositoryProvider);
  final orang = ref.watch(peopleRepositoryProvider);
  final master = ref.watch(masterRepositoryProvider);
  final bukti = ref.watch(evidenceRepositoryProvider);
  final setuju = ref.watch(approvalRepositoryProvider);
  final periode = ref
      .watch(periodRepositoryProvider)
      .period(periodIdOf(t.effectiveDate.tahun, t.effectiveDate.bulan));

  Account? cariAkun(String? i) =>
      akun.accounts(includeInactive: true).where((a) => a.id == i).firstOrNull;
  String? nomor(String? i) => i == null ? null : tx.get(i)?.voucher;
  String nama(String? personId) =>
      personId == null ? '' : orang.person(personId)?.short ?? personId;

  final baris = barisTransaksi(t, cariAkun, (i) => tx.get(i)?.voucher);

  // ---- facts ----
  final perluMa = [
    for (final a in t.allocations)
      if (_perluMa(t.typeOf(a))) a,
  ];
  final maKosong = perluMa.any((a) => a.masterCode == null);
  final tanpaPersetujuan =
      t.approvalMode == ApprovalMode.external &&
      !setuju
          .forTransaction(t.id)
          .any((r) => r.status == ApprovalStatus.recorded);
  final statusBukti = _statusBukti(t, bukti.forTransaction(t.id));
  final kurang = <String>[
    if (t.total <= 0) 'jumlah belum diisi',
    if (t.allocations.any((a) => t.accountOf(a) == null))
      'Kas/Bank belum dipilih',
    if (t.allocations.any((a) => a.fundId == null)) 'peruntukan belum dipilih',
    if (maKosong) 'Mata Anggaran belum dipilih',
    if (tanpaPersetujuan) 'persetujuan belum dicatat',
  ];

  final danaNama = {
    for (final a in t.allocations)
      if (a.fundId != null) dana.fund(a.fundId!)?.name ?? a.fundId!,
  };
  final lingkup = {
    for (final a in t.allocations)
      if (a.scopeId != null)
        a.scopeId == ScopeRef.jemaatId
            ? 'Jemaat'
            : org.scope(a.scopeId!)?.name ?? a.scopeId!,
  };
  final ma = {
    for (final a in perluMa)
      if (a.masterCode != null)
        labelMataAnggaran(master, a.masterCode!, t.effectiveDate),
  };
  final keluar = postingSigns[t.type]?.expense != 0;
  final masuk = postingSigns[t.type]?.income != 0;
  final kunciDana = keluar
      ? 'Diambil dari peruntukan'
      : masuk
      ? 'Masuk ke peruntukan'
      : 'Peruntukan';
  final dibukukanPada = t.finalizedAt == null ? null : tglJam(t.finalizedAt!);
  final dokumen = switch (statusBukti) {
    (EvidenceStatus.notRequired, _) => null,
    (EvidenceStatus.requiredMissing, _) => ('Wajib, belum ada', true),
    (EvidenceStatus.uploaded, _) => ('Diunggah, belum diverifikasi', false),
    (EvidenceStatus.verified, final oleh) => (
      'Terverifikasi${oleh == null ? '' : ' (oleh ${nama(oleh)})'}',
      false,
    ),
    (EvidenceStatus.exceptionAccepted, _) => ('Dikecualikan', false),
  };

  final List<FaktaTransaksi> fakta;
  if (t.status == TransactionStatus.cancelled) {
    fakta = [
      if (t.cancelReason != null) ('Alasan', t.cancelReason!, false),
      ('Dibatalkan oleh', nama(t.cancelledBy), false),
      if (t.cancelledAt != null)
        ('Dibatalkan pada', tglJam(t.cancelledAt!), false),
    ];
  } else if (t.type == TransactionType.reversal) {
    fakta = [
      ('Pembalikan dari', 'No. Bukti ${nomor(t.reversalOf) ?? '—'}', false),
      ?_fakta('Dibukukan pada', dibukukanPada),
    ];
  } else if (t.isReversed) {
    final koreksi = t.correctedBy == null ? null : tx.get(t.correctedBy!);
    fakta = [
      ('Dibalik oleh', 'No. Bukti ${nomor(t.reversedBy) ?? '—'}', false),
      if (koreksi != null)
        (
          'Transaksi koreksi',
          koreksi.voucher == null ? 'Draf' : 'No. Bukti ${koreksi.voucher}',
          false,
        ),
      if (ma.isNotEmpty) ('Mata Anggaran', ma.join('; '), false),
      ?_fakta('Dibukukan pada', dibukukanPada),
    ];
  } else {
    fakta = [
      danaNama.isEmpty
          ? (kunciDana, 'Peruntukan belum dipilih', true)
          : (kunciDana, danaNama.join(', '), false),
      if (lingkup.isNotEmpty) ('Lingkup', lingkup.join(', '), false),
      if (perluMa.isNotEmpty)
        maKosong
            ? ('Mata Anggaran', 'Mata Anggaran belum dipilih', true)
            : ('Mata Anggaran', ma.join('; '), false),
      if (t.isDraft)
        switch (t.approvalMode) {
          ApprovalMode.notRequired => (
            'Persetujuan',
            'Tidak diperlukan (aturan: ${t.approvalRule ?? 'transaksi rutin'})',
            false,
          ),
          _ =>
            tanpaPersetujuan
                ? ('Persetujuan', 'Persetujuan belum dicatat', true)
                : ('Persetujuan', 'Sudah dicatat', false),
        },
      if (dokumen != null) ('Dokumen pendukung', dokumen.$1, dokumen.$2),
      if (t.status == TransactionStatus.reviewed)
        (
          'Pemeriksa kedua',
          'Sudah diperiksa oleh ${nama(t.reviewedBy)}',
          false,
        ),
      ?_fakta('Dibukukan pada', dibukukanPada),
    ];
  }

  // ---- actions and note ----
  final tutup = periode?.isClosed ?? false;
  final bulan = periode == null ? '' : namaBulan(periode);
  final lampir = AksiTransaksi(
    'Lampirkan dokumen pendukung',
    JenisAksi.tautan,
    ke: Layar.fotoDokumen,
    anak: 'unggah',
    dokumen: t.id,
  );
  AksiTransaksi koreksi({bool utama = false}) => AksiTransaksi(
    'Koreksi dengan pembalikan',
    JenisAksi.tautan,
    ke: Layar.koreksi,
    param: {'id': t.id},
    utama: utama,
  );
  final batalkan = AksiTransaksi(
    'Batalkan',
    JenisAksi.tautan,
    ke: Layar.draf,
    param: {'id': t.id},
  );

  final List<AksiTransaksi> aksi;
  final String catatan;
  if (t.status == TransactionStatus.cancelled) {
    aksi = const [];
    catatan =
        'Hanya dapat dilihat. Transaksi ini tidak pernah punya No. Bukti.';
  } else if (t.isDraft && tutup) {
    aksi = [
      AksiTransaksi(
        'Pindah tanggal',
        JenisAksi.tautan,
        ke: Layar.draf,
        param: {'id': t.id},
        utama: true,
      ),
      batalkan,
    ];
    catatan =
        '$bulan sudah ditutup. Yang masih dapat Anda lakukan: pindah tanggal '
        'ke bulan yang belum ditutup, atau batalkan. Keduanya memerlukan '
        'alasan.';
  } else if (t.isDraft && kurang.isEmpty) {
    aksi = [
      const AksiTransaksi(
        'Periksa dan bukukan',
        JenisAksi.bukukan,
        utama: true,
      ),
      // DM 5.1: a reversal is not edited.
      if (t.reversalOf == null) const AksiTransaksi('Ubah', JenisAksi.ubah),
      AksiTransaksi(
        'Pindah tanggal',
        JenisAksi.tautan,
        ke: Layar.draf,
        param: {'id': t.id},
      ),
      batalkan,
    ];
    catatan = 'Semua syarat terpenuhi. Pindah tanggal dan Batalkan memerlukan alasan.';
  } else if (t.isDraft) {
    aksi = [
      if (maKosong)
        const AksiTransaksi('Pilih Mata Anggaran', JenisAksi.ubah, utama: true),
      if (tanpaPersetujuan)
        AksiTransaksi(
          'Catat persetujuan',
          JenisAksi.tautan,
          ke: Layar.persetujuan,
          param: {'id': t.id},
          utama: !maKosong,
        ),
      if (dokumen?.$2 ?? false) lampir,
      if (t.reversalOf == null) const AksiTransaksi('Ubah', JenisAksi.ubah),
      batalkan,
    ];
    catatan = 'Tidak dapat dilakukan: Bukukan. ${_kalimat(kurang)}';
  } else if (t.type == TransactionType.reversal) {
    aksi = [
      AksiTransaksi(
        'Lihat transaksi asal',
        JenisAksi.tautan,
        ke: Layar.koreksi,
        param: {'id': t.reversalOf ?? t.id},
      ),
    ];
    catatan = 'Pembalikan tidak dapat diubah atau dibalik.';
  } else if (t.isReversed) {
    aksi = [
      AksiTransaksi(
        'Lihat pembalikan',
        JenisAksi.tautan,
        ke: Layar.koreksi,
        param: {'id': t.reversedBy!},
      ),
      if (t.correctedBy != null)
        AksiTransaksi(
          'Lihat transaksi koreksi',
          JenisAksi.tautan,
          ke: Layar.koreksi,
          param: {'id': t.correctedBy!},
        ),
    ];
    catatan = 'Transaksi asal tetap tampil di daftar dan laporan.';
  } else if (tutup) {
    aksi = const [];
    catatan =
        'Transaksi $bulan tidak dapat diubah, dibalik, atau dikoreksi. Yang '
        'masih dapat Anda lakukan: catat kejadian setelah tutup buku.';
  } else {
    final (s, _) = statusBukti;
    aksi = switch (s) {
      EvidenceStatus.requiredMissing => [
        AksiTransaksi(
          lampir.label,
          JenisAksi.tautan,
          ke: lampir.ke,
          anak: lampir.anak,
          utama: true,
          dokumen: t.id,
        ),
        AksiTransaksi(
          'Catat pengecualian',
          JenisAksi.tautan,
          ke: Layar.dokumen,
          dokumen: t.id,
        ),
        koreksi(),
      ],
      EvidenceStatus.uploaded => [
        AksiTransaksi(
          'Verifikasi',
          JenisAksi.tautan,
          ke: Layar.lihatDokumen,
          param: {'id': t.id},
          utama: true,
        ),
        lampir,
        koreksi(),
      ],
      _ => [lampir, koreksi()],
    };
    catatan = switch (s) {
      EvidenceStatus.requiredMissing =>
        'Menjadi hambatan tutup buku sampai dokumen terverifikasi atau '
            'dikecualikan dengan alasan.',
      EvidenceStatus.uploaded =>
        'Jumlah, tanggal, Kas/Bank, peruntukan, Lingkup dan Mata Anggaran '
            'tidak dapat diubah lagi.',
      _ => 'Koreksi hanya lewat pembalikan, selama $bulan belum ditutup.',
    };
  }

  // ---- table note ----
  final String? catatanBaris;
  if (t.status == TransactionStatus.cancelled) {
    catatanBaris = 'Tidak pernah dibukukan';
  } else if (t.isDraft) {
    catatanBaris = [
      'Belum masuk saldo',
      if (maKosong) 'Mata Anggaran belum dipilih',
      if (t.status == TransactionStatus.reviewed) 'Sudah diperiksa',
    ].join(' · ');
  } else if (t.type == TransactionType.reversal) {
    catatanBaris = 'Pembalikan';
  } else if (t.isReversed) {
    catatanBaris = baris.catatan;
  } else if (statusBukti.$1 == EvidenceStatus.requiredMissing) {
    catatanBaris = 'Dokumen pendukung wajib, belum ada';
  } else {
    catatanBaris = null;
  }

  // ---- Riwayat ----
  final riwayat = [
    if (t.cancelledAt != null)
      '${tglJam(t.cancelledAt!)} · Dibatalkan oleh ${nama(t.cancelledBy)}',
    if (t.finalizedAt != null)
      '${tglJam(t.finalizedAt!)} · Dibukukan oleh ${nama(t.finalizedBy)}',
    if (t.reviewedAt != null && t.reviewedBy != t.finalizedBy)
      '${tglJam(t.reviewedAt!)} · Diperiksa oleh ${nama(t.reviewedBy)}',
    '${tgl(t.createdAt)} · Draf dicatat oleh ${nama(t.createdBy)}',
  ];

  return RincianTransaksi(
    baris: baris,
    catatanBaris: catatanBaris,
    fakta: fakta,
    aksi: aksi,
    catatan: catatan,
    riwayat: riwayat,
  );
});

FaktaTransaksi? _fakta(String k, String? v) => v == null ? null : (k, v, false);

/// A part of this type needs a Mata Anggaran.
bool _perluMa(TransactionType t) {
  final s = postingSigns[t];
  return s != null &&
      (s.income != 0 ||
          s.expense != 0 ||
          s.transitIn != 0 ||
          s.transitOut != 0);
}

/// The evidence projection (DM 5.3) and who verified it.
(EvidenceStatus, String?) _statusBukti(
  Transaction t,
  List<EvidenceItem> items,
) {
  final v = items
      .where((e) => e.state == EvidenceItemState.verified)
      .lastOrNull;
  if (items.any((e) => e.state == EvidenceItemState.exception)) {
    return (EvidenceStatus.exceptionAccepted, null);
  }
  if (v != null) return (EvidenceStatus.verified, v.decidedBy ?? v.by);
  if (items.any((e) => e.state == EvidenceItemState.uploaded)) {
    return (EvidenceStatus.uploaded, null);
  }
  return (
    t.evidenceRequired
        ? EvidenceStatus.requiredMissing
        : EvidenceStatus.notRequired,
    null,
  );
}

/// 'Mata Anggaran belum dipilih dan persetujuan belum dicatat.'
String _kalimat(List<String> kurang) {
  final s = '${kurang.join(' dan ')}.';
  return s[0].toUpperCase() + s.substring(1);
}
