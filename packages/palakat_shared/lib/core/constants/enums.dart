import 'package:freezed_annotation/freezed_annotation.dart';

enum Gender {
  @JsonValue("MALE")
  male,
  @JsonValue("FEMALE")
  female,
}

enum MaritalStatus {
  @JsonValue("SINGLE")
  single,
  @JsonValue("MARRIED")
  married,
}

enum ActivityType {
  @JsonValue("SERVICE")
  service,
  @JsonValue("EVENT")
  event,
  @JsonValue("ANNOUNCEMENT")
  announcement,
}

@JsonEnum(valueField: 'abv')
enum Bipra {
  elder("Lanjut Usia", "ELD"),
  fathers("Pria / Kaum Bapa", "PKB"),
  mothers("Wanita / Kaum Ibu", "WKI"),
  youths("Pemuda", "PMD"),
  teens("Remaja", "RMJ"),
  kids("Anak Sekolah Minggu", "ASM");

  const Bipra(this.name, this.abv);

  final String name;
  final String abv;
}

@JsonEnum(valueField: 'value')
enum Reminder {
  tenMinutes("10 Minutes Before", "TEN_MINUTES"),
  thirtyMinutes("30 Minutes Before", "THIRTY_MINUTES"),
  oneHour("1 Hour Before", "ONE_HOUR"),
  twoHour("2 Hour Before", "TWO_HOURS");

  const Reminder(this.name, this.value);

  final String name;
  final String value;
}

enum MapOperationType { pinPoint, read }

enum ApprovalStatus {
  @JsonValue('UNCONFIRMED')
  unconfirmed,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('REJECTED')
  rejected,
}

enum RequestStatus {
  @JsonValue('TODO')
  todo,
  @JsonValue('DOING')
  doing,
  @JsonValue('DONE')
  done,
}

// ===== Centralized reusable enums =====

// Account-related
enum UserRole {
  @JsonValue('administrator')
  administrator,
  @JsonValue('moderator')
  moderator,
  @JsonValue('member')
  member,
}

enum AccountStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('suspended')
  suspended,
}

// Activities
// enum ActivityStatus {
//   @JsonValue('planned')
//   planned,
//   @JsonValue('ongoing')
//   ongoing,
//   @JsonValue('completed')
//   completed,
//   @JsonValue('cancelled')
//   cancelled,
// }

// Errors
enum ErrorType {
  @JsonValue('network')
  network,
  @JsonValue('validation')
  validation,
  @JsonValue('authentication')
  authentication,
  @JsonValue('authorization')
  authorization,
  @JsonValue('notFound')
  notFound,
  @JsonValue('serverError')
  serverError,
  @JsonValue('unknown')
  unknown,
}

// Navigation / UI
enum PageTransitionType {
  fadeWithScale,
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  fade,
}

// Inventory
enum InventoryCondition {
  good,
  used,
  new_,
  notApplicable;

  String get displayName {
    switch (this) {
      case InventoryCondition.good:
        return 'Good';
      case InventoryCondition.used:
        return 'Used';
      case InventoryCondition.new_:
        return 'New';
      case InventoryCondition.notApplicable:
        return 'N/A';
    }
  }
}

// Billing
enum BillingType {
  @JsonValue('subscription')
  subscription,
  @JsonValue('oneTime')
  oneTime,
  @JsonValue('recurring')
  recurring,
}

enum BillingStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('paid')
  paid,
  @JsonValue('overdue')
  overdue,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('refunded')
  refunded,
}

enum PaymentMethod {
  @JsonValue('CASH')
  cash,
  @JsonValue('CASHLESS')
  cashless,
}

enum GeneratedBy {
  @JsonValue('MANUAL')
  manual,
  @JsonValue('SYSTEM')
  system,
}

/// Form field types for activity creation forms.
/// Used to configure which fields are required/optional based on activity type.
enum FormFieldType {
  bipra,
  title,
  location,
  pinpointLocation,
  date,
  time,
  reminder,
  note,
  description,
  file,
}

extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.service:
        return 'Service';
      case ActivityType.event:
        return 'Event';
      case ActivityType.announcement:
        return 'Announcement';
    }
  }

  /// Returns the list of required form fields for this activity type.
  /// SERVICE/EVENT: bipra, title, location, pinpointLocation, date, time, reminder
  /// ANNOUNCEMENT: bipra, title, description, file
  List<FormFieldType> get requiredFields {
    switch (this) {
      case ActivityType.service:
      case ActivityType.event:
        return [
          FormFieldType.bipra,
          FormFieldType.title,
          FormFieldType.location,
          FormFieldType.pinpointLocation,
          FormFieldType.date,
          FormFieldType.time,
          FormFieldType.reminder,
        ];
      case ActivityType.announcement:
        return [
          FormFieldType.bipra,
          FormFieldType.title,
          FormFieldType.description,
          FormFieldType.file,
        ];
    }
  }

  /// Returns the list of optional form fields for this activity type.
  /// SERVICE/EVENT: note
  /// ANNOUNCEMENT: none
  List<FormFieldType> get optionalFields {
    switch (this) {
      case ActivityType.service:
      case ActivityType.event:
        return [FormFieldType.note];
      case ActivityType.announcement:
        return [];
    }
  }
}

enum SongPartType {
  @JsonValue("INTRO")
  intro,

  @JsonValue("OUTRO")
  outro,

  @JsonValue("VERSE")
  verse,

  @JsonValue("VERSE2")
  verse2,

  @JsonValue("VERSE4")
  verse3,

  @JsonValue("VERSE4")
  verse4,

  @JsonValue("VERSE5")
  verse5,

  @JsonValue("VERSE6")
  verse6,

  @JsonValue("VERSE7")
  verse7,

  @JsonValue("VERSE8")
  verse8,

  @JsonValue("REFRAIN")
  refrain,

  @JsonValue("PRECHORUS")
  preChorus,

  @JsonValue("CHORUS")
  chorus,

  @JsonValue("CHORUS2")
  chorus2,

  @JsonValue("CHORUS3")
  chorus3,

  @JsonValue("CHORUS4")
  chorus4,

  @JsonValue("BRIDGE")
  bridge,

  @JsonValue("HOOK")
  hook,
}

enum ReportType { income, expense, inventory }
