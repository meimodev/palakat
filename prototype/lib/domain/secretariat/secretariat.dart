import '../../core/tanggal.dart';
import '../core/files.dart';

// The Secretariat entities (README 4.3; PMP 6.1): church documents with
// revisions, announcements, Warta editions and letter requests.

/// Kinds of church document (DokumenGereja, AlurDokumen chips).
enum DocumentKind {
  decision('Keputusan dan surat edaran'),
  minutes('Notulen rapat'),
  liturgy('Tata gereja dan liturgi'),
  memberLetter('Surat untuk anggota'),
  assetHandover('Serah terima aset panitia');

  const DocumentKind(this.label);
  final String label;
}

enum AudienceKind { all, servants, scope, person }

/// Who a document or announcement is addressed to (Q30).
class Audience {
  const Audience._(this.kind, this.label, {this.scopeId, this.personId});

  /// A Kolom, BIPRA group or Komisi: [label] is its name ('Kolom 7').
  const Audience.scope(String scopeId, String label)
    : this._(AudienceKind.scope, label, scopeId: scopeId);

  /// One member and their family (a letter).
  const Audience.person(String personId)
    : this._(
        AudienceKind.person,
        'hanya anggota dan keluarganya',
        personId: personId,
      );

  static const all = Audience._(AudienceKind.all, 'Semua anggota');
  static const servants = Audience._(
    AudienceKind.servants,
    'Pelayan dan pengurus',
  );

  final AudienceKind kind;
  final String label;
  final String? scopeId;
  final String? personId;

  @override
  bool operator ==(Object other) =>
      other is Audience &&
      other.kind == kind &&
      other.scopeId == scopeId &&
      other.personId == personId;

  @override
  int get hashCode => Object.hash(kind, scopeId, personId);
}

/// One published revision of a church document; a ralat makes a new one and
/// the old one stays openable (PMP 6.1).
class DocumentRevision {
  const DocumentRevision({
    required this.number,
    required this.signedCopy,
    required this.publishedAt,
    required this.publishedBy,
    this.ralat,
  });

  final int number;
  final SampleFile signedCopy;
  final DateTime publishedAt;
  final String publishedBy;

  /// What this revision corrects; null for the first.
  final String? ralat;
}

/// What the publish form gives.
class DocumentDraft {
  const DocumentDraft({
    required this.kind,
    required this.title,
    this.documentDate,
  });

  final DocumentKind kind;
  final String title;

  /// The date written on the document; never after today.
  final Tanggal? documentDate;
}

class ChurchDocument {
  ChurchDocument({
    required this.id,
    required this.kind,
    required this.title,
    required this.audience,
    required this.revisions,
    this.documentDate,
    this.revision = 1,
  });

  final String id;
  final DocumentKind kind;
  final String title;
  final Tanggal? documentDate;
  final Audience audience;

  /// Oldest first; never empty.
  final List<DocumentRevision> revisions;
  int revision;

  DocumentRevision get current => revisions.last;

  /// The badge: 'Diterbitkan' for the first revision, else 'Revisi {n}'.
  String get statusLabel =>
      current.number == 1 ? 'Diterbitkan' : 'Revisi ${current.number}';
}

enum AnnouncementStatus {
  draft('Draf'),
  published('Diterbitkan'),
  retired('Diarsipkan');

  const AnnouncementStatus(this.label);
  final String label;
}

class AnnouncementDraft {
  const AnnouncementDraft({
    required this.title,
    required this.body,
    required this.audience,
    this.endsOn,
  });

  final String title, body;
  final Audience audience;

  /// After this date a published announcement retires itself (DL14).
  final Tanggal? endsOn;
}

class Announcement {
  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.audience,
    required this.draftedBy,
    required this.draftedAt,
    this.endsOn,
    this.status = AnnouncementStatus.draft,
    this.publishedBy,
    this.publishedAt,
    this.revision = 1,
  });

  final String id;
  final String title;

  /// The text in force; a ralat replaces it with a new revision (DL14).
  String body;
  final Audience audience;
  final Tanggal? endsOn;
  final String draftedBy;
  final DateTime draftedAt;
  AnnouncementStatus status;
  String? publishedBy;
  DateTime? publishedAt;
  int revision;

  /// The published revisions a ralat replaced, oldest first; each stays
  /// readable as "Digantikan oleh revisi {n + 1}" (rule 723).
  final List<AnnouncementRevision> superseded = [];

  /// The number of the revision in force: 1, then 2 after a ralat.
  int get revisionNumber => superseded.length + 1;

  /// The status on [today]: a published announcement whose end date has
  /// passed is retired by itself (DL14).
  AnnouncementStatus statusAt(Tanggal today) =>
      status == AnnouncementStatus.published &&
          endsOn != null &&
          endsOn! < today
      ? AnnouncementStatus.retired
      : status;
}

/// A published text of an announcement that a ralat replaced.
class AnnouncementRevision {
  const AnnouncementRevision({
    required this.number,
    required this.body,
    required this.publishedAt,
    required this.publishedBy,
  });

  final int number;
  final String body;
  final DateTime publishedAt;
  final String publishedBy;
}

enum WartaStatus {
  draft('Draf'),
  review('Sudah diperiksa'),
  approved('Disetujui'),
  published('Diterbitkan'),
  retired('Diarsipkan');

  const WartaStatus(this.label);
  final String label;
}

/// A life event printed in an edition (Peristiwa jemaat). The name it
/// prints is computed from the member's Tampilan nama (J2, DP23).
class WartaEvent {
  const WartaEvent({required this.label, required this.personId});

  /// 'Syukur HUT pernikahan'.
  final String label;
  final String personId;
}

class WartaRalat {
  const WartaRalat({required this.text, required this.at, required this.by});
  final String text;
  final DateTime at;
  final String by;
}

/// A name shown by exception in one edition (TampilanNama rule).
class NameException {
  const NameException({
    required this.personId,
    required this.printedAs,
    required this.reason,
    required this.at,
    required this.by,
  });

  final String personId, printedAs, reason, by;
  final DateTime at;
}

class WartaEdition {
  WartaEdition({
    required this.id,
    required this.sunday,
    this.status = WartaStatus.draft,
    this.services,
    this.events = const [],
    Set<String>? announcementIds,
    this.publishedAt,
    this.publishedBy,
    this.revision = 1,
  }) : announcementIds = announcementIds ?? {};

  /// 'warta-{yyyy}-{mm}-{dd}': the route's `:edisi`.
  final String id;
  final Tanggal sunday;
  WartaStatus status;

  /// 'Subuh 05.00 · Pagi 09.00 · Malam 18.00' (Ibadah dan kegiatan).
  final String? services;

  final List<WartaEvent> events;

  /// The published announcements the Sekretaris picked for this edition
  /// (P17); for all members when published, picked by itself.
  final Set<String> announcementIds;
  DateTime? reviewedAt, approvedAt, publishedAt;
  String? reviewedBy, approvedBy, publishedBy;
  final List<WartaRalat> ralats = [];
  final List<NameException> exceptions = [];
  int revision;

  /// What it printed when published: a published edition never changes
  /// (rules 612, 643); a later Tampilan nama or close shows in the next.
  WartaPreview? printed;

  NameException? exceptionFor(String personId) =>
      exceptions.where((e) => e.personId == personId).firstOrNull;
}

/// One event as printed. [reveal] is what an exception would print, set
/// only when the member chose "Tanpa nama"; [exception] when one is
/// recorded in this edition.
typedef PrintedEvent = ({
  WartaEvent event,
  String printed,
  String? reveal,
  bool exception,
});

/// The last Sunday's Ditetapkan counts: per service and in total (J3).
typedef WartaAttendance = ({
  Tanggal sunday,
  List<({String label, int n})> parts,
  int total,
});

/// Income and spending of the latest closed month, from its snapshot (J3).
typedef WartaFinance = ({
  int year,
  int month,
  int income,
  int expense,
  DateTime? closedAt,
});

/// What the edition prints (WartaEditor sections, A4Warta).
class WartaPreview {
  const WartaPreview({
    required this.edition,
    required this.announcements,
    required this.events,
    this.attendance,
    this.finance,
  });

  final WartaEdition edition;

  /// The picked announcements that are published (P17).
  final List<Announcement> announcements;

  /// Each event and its name as printed (Tampilan nama).
  final List<PrintedEvent> events;
  final WartaAttendance? attendance;
  final WartaFinance? finance;
}

enum LetterType {
  certificate('Surat keterangan'),
  attestation('Atestasi keluar');

  const LetterType(this.label);
  final String label;
}

enum LetterStatus {
  requested('Diajukan'),
  issued('Diterbitkan'),
  refused('Tidak diterbitkan');

  const LetterStatus(this.label);
  final String label;
}

class LetterRequest {
  LetterRequest({
    required this.id,
    required this.type,
    required this.forPersonId,
    required this.forName,
    required this.requestedBy,
    required this.requestedAt,
    this.purpose,
    this.atOffice = false,
    this.household,
    this.status = LetterStatus.requested,
    this.revision = 1,
  });

  final String id;
  final LetterType type;
  final String forPersonId;

  /// As the request names them: 'Novita Wenas', 'Keluarga Lasut'.
  final String forName;
  final String requestedBy;
  final DateTime requestedAt;

  /// 'untuk melamar pekerjaan'.
  final String? purpose;

  /// Recorded by the Operator at the office for a member without a phone.
  final bool atOffice;

  /// 'Wenas-Lasut · Kolom 7', read from Data jemaat at request time.
  final String? household;
  LetterStatus status;
  String? number;
  SampleFile? signedCopy;
  String? decidedBy, refusalReason, documentId;
  DateTime? decidedAt;
  int revision;

  String get title => '${type.label} · $forName';
}

/// The Sunday whose Warta is being prepared: the first Sunday after [hari]
/// (on a Sunday, the next one; today's edition went out yesterday).
Tanggal mingguDepan(Tanggal hari) => hari.tambahHari(7 - hari.awal.weekday % 7);

/// The outgoing-letter number: 'NNN/SKet/{Roman month}/{year}' (README 5.5).
String letterNumber(int seq, Tanggal at) =>
    '${seq.toString().padLeft(3, '0')}/SKet/${_romawi[at.bulan - 1]}/${at.tahun}';

/// The sequence of a number in [letterNumber]'s shape, or null.
int? letterSeq(String number) =>
    int.tryParse(RegExp(r'^(\d+)/SKet/').firstMatch(number.trim())?[1] ?? '');

const _romawi = [
  'I',
  'II',
  'III',
  'IV',
  'V',
  'VI',
  'VII',
  'VIII',
  'IX',
  'X',
  'XI',
  'XII',
];
