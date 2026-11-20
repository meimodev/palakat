import '../../core/tanggal.dart';

/// Person status (PMP 5; DL8).
enum PersonStatus { unconfirmed, active, deceased }

enum Sex { male, female }

/// Minimal identity (PMP 5). Membership adds the member profile.
class Person {
  Person({
    required this.id,
    required this.name,
    this.shortName,
    this.status = PersonStatus.active,
    this.birthDate,
    this.sex,
    this.phone,
    this.backupEmail,
    this.isSystem = false,
    this.revision = 1,
  });

  final String id;

  /// As drawn: 'Pnt. Hendrik Rumagit'.
  String name;

  /// How finance boards abbreviate: 'Meiske L.'; null when not drawn.
  String? shortName;
  PersonStatus status;
  Tanggal? birthDate;
  Sex? sex;

  /// Sign-in number and the optional backup email (AkunSaya).
  String? phone;
  String? backupEmail;

  /// The Petugas verifikasi: a system actor used only by board timers.
  final bool isSystem;
  int revision;

  /// [shortName] when there is one, else [name].
  String get short => shortName ?? name;
}

/// A counterparty (DM 3 Party): display identity and an optional link to a
/// Person. Ledger rows hold only the Party id (RD11).
class Party {
  Party({
    required this.id,
    required this.displayName,
    this.personId,
    this.contact,
    this.revision = 1,
  });

  final String id;
  String displayName;
  String? personId;
  String? contact;
  int revision;
}
