import '../../core/tanggal.dart';

/// The switchable modules, in the Modul board's order (PMP 6, mock-data
/// 2.17). Core and Reports and search are always on and are not listed.
enum Module {
  finance('Keuangan'),
  churchDocuments('Dokumen gereja'),
  announcements('Pengumuman'),
  warta('Warta Jemaat', needs: announcements),
  membership('Data jemaat'),
  services('Ibadah dan kegiatan', needs: membership),
  attendance('Jumlah kehadiran', needs: services),
  panitia('Panitia'),
  unitFinance('Keuangan unit', needs: finance),
  inAppApprovals('Persetujuan di aplikasi', needs: finance);

  const Module(this.label, {this.needs});

  /// The board's module name.
  final String label;

  /// The module that must be active first (Modul board "Perlu: … aktif").
  final Module? needs;
}

/// PMP 8: OFF, ACTIVE, or READ_ONLY (switched off; reads still allowed).
enum ModuleStatus { off, active, readOnly }

/// One row of the module registry (PMP 5).
class ModuleState {
  ModuleState({
    required this.module,
    required this.status,
    this.changedBy,
    this.changedAt,
    this.reason,
    this.revision = 1,
  });

  final Module module;
  ModuleStatus status;
  String? changedBy;
  DateTime? changedAt;
  String? reason;
  int revision;
}

/// The church (PMP 5 Workspace and tenant).
class Workspace {
  Workspace({
    required this.name,
    this.timeZone = 'WITA',
    this.currency = 'IDR',
    this.fiscalYearStartMonth = 1,
    this.recordingStart,
    this.revision = 1,
  });

  /// 'Jemaat Karunia'.
  final String name;
  final String timeZone;
  final String currency;
  final int fiscalYearStartMonth;

  /// The cutover day (day 15 of M−2); finance fills it in M2.
  Tanggal? recordingStart;
  int revision;
}
