import '../../core/tanggal.dart';
import '../core/people.dart';

/// Marital status as the boards word it. "Pernah menikah" counts as married
/// for BIPRA (DataAnggota: "Yang pernah menikah tetap Bapa atau Ibu").
enum MaritalStatus {
  never('Belum pernah menikah'),
  married('Sudah menikah');

  const MaritalStatus(this.label);
  final String label;
}

/// The BIPRA groups (DL28).
enum Bipra {
  anak('Anak'),
  remaja('Remaja'),
  pemuda('Pemuda'),
  bapa('Bapa'),
  ibu('Ibu');

  const Bipra(this.label);
  final String label;
}

/// Completed years on [at].
int ageAt(Tanggal birth, Tanggal at) {
  var n = at.tahun - birth.tahun;
  if (at.bulan < birth.bulan ||
      (at.bulan == birth.bulan && at.hari < birth.hari)) {
    n--;
  }
  return n;
}

/// DL28 with the one fixed set of church limits (GMIM, DataAnggota): Anak
/// before 12, Remaja 12 to 17, Pemuda 18 and over and never married; Bapa or
/// Ibu once married. Null while birth date, sex or marital status is unknown.
Bipra? computeBipra({
  required Tanggal? birthDate,
  required Sex? sex,
  required MaritalStatus? marital,
  required Tanggal at,
}) {
  if (birthDate == null || sex == null || marital == null) return null;
  if (marital == MaritalStatus.married) {
    return sex == Sex.male ? Bipra.bapa : Bipra.ibu;
  }
  final u = ageAt(birthDate, at);
  return u < 12 ? Bipra.anak : (u < 18 ? Bipra.remaja : Bipra.pemuda);
}

/// One Kolom a member belongs to, from [start] to [end] (null: open).
class KolomStint {
  KolomStint({required this.kolomId, this.start, this.end});
  final String kolomId;
  final Tanggal? start;
  Tanggal? end;

  bool inForce(Tanggal at) =>
      (start == null || start! <= at) && (end == null || at <= end!);
}

/// The member profile a Person gains in Data jemaat (PMP 6.1).
class MemberProfile {
  MemberProfile({
    required this.personId,
    required this.kolom,
    this.householdId,
    this.marital,
    this.memberSince,
    this.importBatchId,
    this.importLine,
    this.importedAt,
    this.revision = 1,
  });

  final String personId;

  /// Kolom history, oldest first (DataAnggota "Kolom" card).
  final List<KolomStint> kolom;
  String? householdId;
  MaritalStatus? marital;
  final Tanggal? memberSince;

  /// Set when the person came from a paper member book.
  String? importBatchId;
  int? importLine;
  DateTime? importedAt;

  /// The Penatua Kolom's correction of one case, with its reason (DL28).
  Bipra? bipraOverride;
  String? bipraOverrideReason;
  int revision;

  /// The Kolom in force at [at]: the stint in force, else the latest begun.
  String kolomAt(Tanggal at) {
    for (final s in kolom.reversed) {
      if (s.inForce(at)) return s.kolomId;
    }
    for (final s in kolom.reversed) {
      if (s.start == null || s.start! <= at) return s.kolomId;
    }
    return kolom.first.kolomId;
  }
}

enum HouseholdStatus {
  unconfirmed('Belum dikonfirmasi'),
  awaiting('Menunggu verifikasi'),
  active('Aktif');

  const HouseholdStatus(this.label);
  final String label;
}

/// A family (Keluarga): its name without "Keluarga", its Kolom, members.
class Household {
  Household({
    required this.id,
    required this.name,
    required this.kolomId,
    required this.memberIds,
    this.representativeId,
    this.status = HouseholdStatus.active,
    this.importedAt,
    this.defaultNameForm = NameForm.familyName,
    this.revision = 1,
  });

  final String id;

  /// 'Wenas-Lasut'.
  final String name;
  String kolomId;
  final List<String> memberIds;
  String? representativeId;
  HouseholdStatus status;
  DateTime? importedAt;

  /// The family default the representative sets (TampilanNama).
  NameForm defaultNameForm;
  int revision;
}

/// What waits for verification (VerificationRepository.queue).
enum ItemKind { application, lifeEvent, dataChange, household }

enum ItemStatus {
  submitted('Diajukan'),
  verified('Diverifikasi'),
  returned('Dikembalikan'),
  declined('Tidak diterima');

  const ItemStatus(this.label);
  final String label;
}

enum LifeEventKind {
  birth('Kelahiran'),
  baptism('Baptisan'),
  sidi('Sidi'),
  marriage('Pernikahan'),
  death('Kematian'),
  kolomMove('Pindah Kolom'),
  transferIn('Atestasi masuk'),
  transferOut('Atestasi keluar'),
  stay('Tinggal sementara');

  const LifeEventKind(this.label);
  final String label;
}

/// A membership application (ApplicationRepository.apply).
class ApplicationForm {
  const ApplicationForm({
    required this.name,
    required this.birthDate,
    required this.sex,
    required this.marital,
    required this.kolomId,
    this.householdId,
  });

  final String name;
  final Tanggal birthDate;
  final Sex sex;
  final MaritalStatus marital;
  final String kolomId;
  final String? householdId;
}

/// A life event as submitted (ApplicationRepository.submitLifeEvent).
class LifeEventDraft {
  const LifeEventDraft({
    required this.kind,
    required this.personIds,
    required this.date,
    this.fromKolomId,
    this.toKolomId,
    this.effective,
    this.householdId,
    this.replaces,
  });

  final LifeEventKind kind;

  /// Who it is for; both spouses for a marriage.
  final List<String> personIds;
  final Tanggal date;
  final String? fromKolomId;
  final String? toKolomId;

  /// A Kolom move takes effect on this date.
  final Tanggal? effective;

  /// A Kolom move moves the whole household.
  final String? householdId;

  /// The returned item this one resubmits.
  final String? replaces;
}

/// One item of a verification queue.
class VerificationItem {
  VerificationItem({
    required this.id,
    required this.kind,
    required this.scopeId,
    required this.submittedBy,
    required this.submittedAt,
    this.status = ItemStatus.submitted,
    this.subjectPersonId,
    this.householdId,
    this.application,
    this.event,
    this.attachment,
    this.change,
    this.consentVersion,
    this.paperForm,
    this.revision = 1,
  });

  final String id;
  final ItemKind kind;

  /// The Kolom whose verifier decides it.
  final String scopeId;
  final String submittedBy;
  final DateTime submittedAt;
  ItemStatus status;

  /// The person the item is about (applicant, data change subject).
  String? subjectPersonId;
  final String? householdId;
  final ApplicationForm? application;
  final LifeEventDraft? event;

  /// The letter or certificate of a life event.
  final String? attachment;

  /// What a data change changes.
  final String? change;
  final String? consentVersion;

  /// The signed paper confirmation form of a household.
  final String? paperForm;

  String? decidedBy;
  DateTime? decidedAt;
  String? reason;

  /// Set when a resubmission replaces this returned item.
  String? replacedBy;

  /// The Kolom whose verifier already verified it; a Kolom move needs both
  /// its Kolom (Peristiwa: "Diverifikasi oleh Penatua Kolom asal dan
  /// tujuan").
  final Set<String> verifiedScopes = {};
  int revision;

  bool get open => status == ItemStatus.submitted;
}

enum ConsentChannel { app, paper }

/// A consent record (PMP 6.1): person, text version, date, channel, who gave
/// it.
class Consent {
  Consent({
    required this.id,
    required this.personId,
    required this.version,
    required this.at,
    required this.channel,
    required this.givenBy,
    this.paperForm,
    this.revision = 1,
  });

  final String id;
  final String personId;
  final String version;
  final DateTime at;
  final ConsentChannel channel;
  final String givenBy;
  final String? paperForm;
  DateTime? withdrawnAt;
  int revision;

  bool get inForce => withdrawnAt == null;
}

/// A withdrawal and deletion request (DL13). Once executed it holds no
/// personal data: [personId] is cleared and only date, channel and who
/// carried it out remain.
class DeletionRequest {
  DeletionRequest({
    required this.id,
    required this.personId,
    required this.channel,
    required this.recordedBy,
    required this.at,
    required this.reason,
    this.revision = 1,
  });

  final String id;
  String? personId;
  final ConsentChannel channel;
  final String recordedBy;
  final DateTime at;
  final String reason;
  String? executedBy;
  DateTime? executedAt;
  int revision;

  bool get done => executedAt != null;
}

enum ImportStatus {
  staged('Ditampung'),
  checked('Lolos pengecekan'),
  imported('Sudah diimpor');

  const ImportStatus(this.label);
  final String label;
}

enum RowStatus { ok, incomplete, refused, duplicate, imported, merged }

/// One line of a paper member book.
class ImportRow {
  ImportRow({
    required this.id,
    required this.line,
    required this.bookText,
    required this.name,
    required this.kolomId,
    this.birthDate,
    this.sex,
    this.marital,
    this.personId,
    this.householdKey,
    this.yearMissing = false,
  });

  final String id;
  final int line;

  /// As written: 'WENAS FERRY, lhr 3-8-71, Kol 7'.
  final String bookText;
  final String name;
  final String kolomId;
  Tanggal? birthDate;
  final Sex? sex;
  final MaritalStatus? marital;

  /// A known person this row is, or the person the import created.
  String? personId;

  /// Rows of one family share it; a household id when the family exists.
  final String? householdKey;

  /// The book's year is incomplete: the Operator completes the date.
  bool yearMissing;
  RowStatus status = RowStatus.ok;
  String? note;
}

/// A paper member book being imported (Staged → checked → imported).
class ImportBatch {
  ImportBatch({
    required this.id,
    required this.source,
    required this.kolomId,
    required this.rows,
    this.status = ImportStatus.staged,
    this.importedAt,
    this.importedBy,
    this.revision = 1,
  });

  final String id;

  /// The book's name and years: 'Buku anggota Kolom 7 · {from}–{to}'.
  final String source;
  final String kolomId;
  final List<ImportRow> rows;
  ImportStatus status;
  DateTime? importedAt;
  String? importedBy;
  int revision;
}

/// The rows of a sample book handed to MemberImportRepository.stage.
class SampleBook {
  const SampleBook({
    required this.source,
    required this.kolomId,
    required this.rows,
  });
  final String source;
  final String kolomId;
  final List<ImportRow> rows;
}

enum DuplicateStatus { open, merged, notSame }

enum DuplicateDecision { merge, notSame }

/// A possible duplicate found by the check: never merged by itself.
class DuplicateCase {
  DuplicateCase({
    required this.id,
    required this.batchId,
    required this.rowId,
    required this.existingPersonId,
    this.revision = 1,
  });

  final String id;
  final String batchId;
  final String rowId;
  final String existingPersonId;
  DuplicateStatus status = DuplicateStatus.open;
  String? decidedBy;
  DateTime? decidedAt;
  String? reason;
  int revision;
}

/// How a member's name prints in publications (TampilanNama).
enum NameForm {
  fullName('Nama lengkap'),
  familyName('Nama keluarga'),
  familyKolom('Keluarga + Kolom'),
  kolom('Kolom'),
  bipra('BIPRA'),
  bipraKolom('BIPRA + Kolom'),
  none('Tanpa nama');

  const NameForm(this.label);
  final String label;
}

/// A member's own choice; without one the family default applies.
class MaskingPreference {
  MaskingPreference({
    required this.personId,
    required this.form,
    this.revision = 1,
  });
  final String personId;
  NameForm form;
  int revision;
}

/// Where a name prints: a Warta follows the name form; a letter is issued
/// to the person and prints the full name.
enum PrintContext { warta, letter }

/// A member as the screens read it: the person, the profile, the household,
/// the Kolom and BIPRA in force today.
class Member {
  const Member({
    required this.person,
    required this.profile,
    required this.household,
    required this.kolomId,
    required this.bipra,
    required this.bipraComputed,
  });

  final Person person;
  final MemberProfile profile;
  final Household? household;
  final String kolomId;

  /// The override when set, else [bipraComputed].
  final Bipra? bipra;
  final Bipra? bipraComputed;
}

/// One row of a verifier's queue: an item routed to the actor, or an item of
/// the actor's own family in their scope, which they may not verify
/// ([blocked], the refusal reason) and which goes to [forwardedTo] instead.
class QueueEntry {
  const QueueEntry(this.item, {this.blocked, this.forwardedTo});
  final VerificationItem item;
  final String? blocked;
  final String? forwardedTo;
}

/// The consent text version every application and confirmation records.
const consentVersion = 'versi 1';

/// "Keluarga Wenas-Lasut" or the person's name: what an item is about.
String itemSubject(
  VerificationItem i,
  String Function(String personId) name,
  String? Function(String householdId) family,
) {
  final e = i.event;
  if (e != null && e.kind == LifeEventKind.kolomMove && i.householdId != null) {
    return 'Keluarga ${family(i.householdId!) ?? ''}';
  }
  if (e != null) return e.personIds.map(name).join(' dan ');
  if (i.application != null) return i.application!.name;
  if (i.householdId != null) {
    final f = family(i.householdId!) ?? '';
    return i.kind == ItemKind.household ? f : 'Keluarga $f';
  }
  return i.subjectPersonId == null ? '' : name(i.subjectPersonId!);
}

/// The queue title of an item (AntreanVerifikasi rows).
String itemTitle(
  VerificationItem i,
  String Function(String personId) name,
  String? Function(String householdId) family,
) {
  final s = itemSubject(i, name, family);
  return switch (i.kind) {
    ItemKind.application => 'Permohonan menjadi anggota · $s',
    ItemKind.lifeEvent => 'Peristiwa: ${i.event!.kind.label} · $s',
    ItemKind.dataChange => 'Perubahan data · $s',
    ItemKind.household => 'Konfirmasi keluarga · $s',
  };
}
