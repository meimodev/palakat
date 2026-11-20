import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import 'jangkar.dart';
import 'seed_store.dart';

/// README 5.7 (M5): the history lines of the cutover and the settings that
/// Lainnya and WebPengaturan "Riwayat" read (mock-data 2.21), and Meiske's
/// finance notifications of Pemberitahuan (mock-data 2.16, minus the
/// fault-only rows, D9). No rule change is scheduled at launch (D24: the
/// second checker is already in force), so `SettingsRepository.scheduled`
/// starts empty; the Mata Anggaran draft from M+1 is M2's.
/// The new Bendahara's appointment letter that Bendahara `serah` and
/// WebSerahTerima attach to the handover (DP39; an SK takes the year of its
/// record's date, README 5.5).
String suratPenunjukanBaru(Tanggal hari) => 'SK-BPMJ-09-${hari.tahun}';

void seedKeuanganPengaturan(SeedStore store, Jangkar a) {
  final k = store.keuangan;
  final t = store.inti;

  void jejak(
    DateTime saat,
    String aksi,
    String ringkas,
    RecordRef ref, {
    String? alasan,
  }) => t.audit.add(
    AuditRecord(
      id: store.newId('aud'),
      at: saat,
      personId: 'meiske',
      personName: t.person('meiske')!.name,
      actingRole: t.post('bendahara-jemaat')!.title,
      assignmentId: 'tugas-bendahara-jemaat-meiske',
      scopeId: ScopeRef.jemaatId,
      module: Module.finance,
      action: aksi,
      summary: ringkas,
      reason: alasan,
      ref: ref,
    ),
  );
  String bulan(Tanggal d) => bulanTahun(d.tahun, d.bulan);

  // The cutover: Mata Anggaran published, the second-checker rule set.
  for (final v in k.masterVersions) {
    if (v.status == MasterVersionStatus.published) {
      jejak(
        v.publishedAt!,
        'finance.master.publish',
        'Menerbitkan versi Mata Anggaran ${v.code} (${v.kind.name}) · '
            'berlaku mulai ${bulan(v.effectiveFrom!)}',
        RecordRef('master', v.id),
      );
    }
  }
  for (final r in k.ruleValues) {
    jejak(
      r.setAt,
      'finance.rule.set',
      'Wajib pemeriksa kedua ${r.on ? 'hidup' : 'mati'} mulai '
          '${bulan(r.effectiveFrom)}',
      RecordRef('rule', r.rule.name),
    );
  }
  // Kas Panitia HUT: deactivated on M−1 day 28 at 16.44, from M0.
  for (final x in k.accounts) {
    if (x.activeTo == null) continue;
    jejak(
      a.jam(a.bln(-1, 28), 16, 44),
      'finance.account.deactivate',
      'Menonaktifkan ${x.name} · berlaku mulai '
          '${bulan(x.activeTo!.tambahHari(1))}',
      RecordRef('account', x.id),
      alasan: x.deactivationReason,
    );
  }
  // The draft version from M+1 (M2's seed).
  final draf = k.masterVersions
      .where((v) => v.status == MasterVersionStatus.draft)
      .firstOrNull;
  if (draf != null) {
    jejak(
      draf.createdAt!,
      'finance.master.draft',
      'Membuat versi Mata Anggaran ${draf.code} · usulan berlaku mulai '
          '${bulan(draf.effectiveFrom!)}',
      RecordRef('master', draf.id),
    );
  }

  // ---------- Pemberitahuan (mock-data 2.16) ----------
  void kabar(
    String jenis,
    String judul,
    String isi,
    DateTime saat, {
    RecordRef? ref,
  }) => t.notifications.add(
    AppNotification(
      id: store.newId('kabar'),
      recipientId: 'meiske',
      type: jenis,
      module: Module.finance,
      title: judul,
      body: isi,
      createdAt: saat,
      ref: ref,
    ),
  );
  final terbuka = k.periods.where((p) => !p.isClosed).toList()
    ..sort((x, y) => x.start.compareTo(y.start));
  final berikut = terbuka.firstOrNull;
  if (berikut != null) {
    kabar(
      NotificationType.action,
      '${bulanTahun(berikut.year, berikut.month)} belum ditutup',
      'Bulan berikutnya untuk tutup buku',
      a.jam(a.hariIni, 8, 0),
      ref: RecordRef('period', berikut.id),
    );
  }
  final ditutup = k.periods.where((p) => p.isClosed).lastOrNull;
  if (ditutup?.closedAt != null) {
    kabar(
      NotificationType.file,
      'Laporan resmi siap diunduh',
      'Laporan resmi ${bulanTahun(ditutup!.year, ditutup.month)} · PDF dan '
          'Excel',
      ditutup.closedAt!,
      ref: RecordRef('period', ditutup.id),
    );
  }
  // um2 (Retret Pemuda): due T − 6 days, never before its issue (README 5.4).
  final retret = k.bySeedKey('0112');
  if (retret != null) {
    final jatuh = a.tidakSebelum(
      a.hariIni.tambahHari(-6),
      retret.effectiveDate,
    );
    kabar(
      NotificationType.due,
      'Uang muka lewat jatuh tempo',
      'Retret Pemuda · jatuh tempo $jatuh',
      a.jam(a.hariCerita(11), 7, 0),
      ref: const RecordRef('case', 'um2'),
    );
  }
  final sound = k.bySeedKey('0143');
  if (sound != null) {
    kabar(
      NotificationType.action,
      '1 dokumen pendukung wajib, belum ada',
      '${sound.voucher} · ${sound.description}',
      a.jam(a.hariCerita(11), 7, 5),
      ref: RecordRef('transaction', sound.id),
    );
  }
  // The board's "AI sedang tidak tersedia" is fault-only (D9); the budget
  // note is real.
  final dipakai = k.aiSpend.values.fold(0, (s, x) => s + x);
  kabar(
    NotificationType.ai,
    'Biaya AI bulan ini ${dipakai * 100 ~/ k.aiCap}% dari batas',
    'Pencatatan berjalan seperti biasa',
    a.jam(a.hariCerita(9), 9, 0),
  );
}
