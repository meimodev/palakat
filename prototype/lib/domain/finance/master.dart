import '../../core/tanggal.dart';

/// The two Mata Anggaran trees (DM 3 MasterVersion kind).
enum MasterKind { pendapatan, belanja }

/// `allowed_effect_kinds` of a row (RD10): "Boleh untuk". Unset means
/// ECONOMIC only, and a CUSTODY (titipan) allocation is refused on it.
enum AllowedEffect {
  /// 'Milik sendiri' (ECONOMIC).
  owned,

  /// 'Titipan' (TRANSIT).
  custody,

  /// 'Keduanya'.
  both,

  /// '' (shown as 'belum diisi').
  unset;

  bool get allowsOwned => this != custody;
  bool get allowsCustody => this == custody || this == both;
}

/// DM 5.5: DRAFT → REVIEWED → PUBLISHED; published content is immutable.
enum MasterVersionStatus { draft, reviewed, published }

/// One version of one tree (DM 3 MasterVersion). Both trees of a release
/// share [code] ('{tahun}.1').
class MasterVersion {
  MasterVersion({
    required this.id,
    required this.kind,
    required this.code,
    required this.status,
    this.effectiveFrom,
    this.createdBy,
    this.createdAt,
    this.reviewedBy,
    this.reviewedAt,
    this.publishedBy,
    this.publishedAt,
    this.revision = 1,
  });

  /// '{kind}-{code}': 'belanja-{tahun}.1'.
  final String id;
  final MasterKind kind;
  final String code;
  MasterVersionStatus status;

  /// The 1st of the month it takes effect (a draft: proposed).
  Tanggal? effectiveFrom;
  String? createdBy;
  DateTime? createdAt;
  String? reviewedBy;
  DateTime? reviewedAt;
  String? publishedBy;
  DateTime? publishedAt;
  int revision;
}

/// One row of a version (DM 3 MasterRow), keyed by (version, code).
class MasterRow {
  MasterRow({
    required this.versionId,
    required this.code,
    required this.name,
    required this.order,
    this.parentCode,
    this.level = 1,
    this.postable = true,
    this.allowedEffect = AllowedEffect.unset,
    this.active = true,
    this.revision = 1,
  });

  final String versionId;

  /// Exact source string: '1.3.53.07.00'.
  final String code;
  String name;

  /// Source order within the version.
  int order;
  String? parentCode;
  int level;

  /// False for a group heading ('Judul kelompok, tidak dapat dibukukan').
  bool postable;
  AllowedEffect allowedEffect;
  bool active;
  int revision;
}
