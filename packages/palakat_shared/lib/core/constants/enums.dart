import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat_shared/l10n/generated/app_localizations.dart';

AppLocalizations _l10n() {
  final localeName = intl.Intl.getCurrentLocale();
  final languageCode = localeName.split(RegExp('[_-]')).first;
  return lookupAppLocalizations(
    Locale(languageCode.isEmpty ? 'en' : languageCode),
  );
}

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

enum ArticleType {
  @JsonValue('PREACHING_MATERIAL')
  preachingMaterial,
  @JsonValue('GAME_INSTRUCTION')
  gameInstruction,
}

enum ArticleStatus {
  @JsonValue('DRAFT')
  draft,
  @JsonValue('PUBLISHED')
  published,
  @JsonValue('ARCHIVED')
  archived,
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

enum MembershipInvitationStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('REJECTED')
  rejected,
}

enum MembershipInvitationEligibility {
  @JsonValue('ALREADY_MEMBER')
  alreadyMember,
  @JsonValue('PENDING_INVITE_EXISTS')
  pendingInviteExists,
  @JsonValue('REJECTED_PREVIOUSLY')
  rejectedPreviously,
  @JsonValue('CAN_INVITE')
  canInvite,
}

enum RequestStatus {
  @JsonValue('TODO')
  todo,
  @JsonValue('DOING')
  doing,
  @JsonValue('DONE')
  done,
  @JsonValue('REJECTED')
  rejected,
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
    final l10n = _l10n();
    switch (this) {
      case InventoryCondition.good:
        return l10n.inventoryCondition_good;
      case InventoryCondition.used:
        return l10n.inventoryCondition_used;
      case InventoryCondition.new_:
        return l10n.inventoryCondition_new;
      case InventoryCondition.notApplicable:
        return l10n.inventoryCondition_notApplicable;
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

enum DocumentInput {
  @JsonValue('INCOME')
  income,
  @JsonValue('OUTCOME')
  outcome,
}

enum CongregationReportSubtype {
  @JsonValue('WARTA_JEMAAT')
  wartaJemaat,
  @JsonValue('HUT_JEMAAT')
  hutJemaat,
  @JsonValue('KEANGGOTAAN')
  keanggotaan,
}

enum FinancialReportSubtype {
  @JsonValue('REVENUE')
  revenue,
  @JsonValue('EXPENSE')
  expense,
  @JsonValue('MUTATION')
  mutation,
}

enum ReportGenerateType {
  @JsonValue('INCOMING_DOCUMENT')
  incomingDocument,
  @JsonValue('OUTCOMING_DOCUMENT')
  outcomingDocument,
  @JsonValue('CONGREGATION')
  congregation,
  @JsonValue('SERVICES')
  services,
  @JsonValue('ACTIVITY')
  activity,
  @JsonValue('FINANCIAL')
  financial,
}

enum ReportFormat {
  @JsonValue('PDF')
  pdf,
  @JsonValue('XLSX')
  xlsx,
}

enum ReportJobStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('FAILED')
  failed,
}

enum NotificationType {
  @JsonValue('ACTIVITY_CREATED')
  activityCreated,
  @JsonValue('APPROVAL_REQUIRED')
  approvalRequired,
  @JsonValue('APPROVAL_CONFIRMED')
  approvalConfirmed,
  @JsonValue('APPROVAL_REJECTED')
  approvalRejected,
  @JsonValue('CHURCH_REQUEST_APPROVED')
  churchRequestApproved,
  @JsonValue('CHURCH_REQUEST_REJECTED')
  churchRequestRejected,
  @JsonValue('REPORT_READY')
  reportReady,
  @JsonValue('REPORT_FAILED')
  reportFailed,
  @JsonValue('MEMBER_BIRTHDAY')
  memberBirthday,
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
    final l10n = _l10n();
    switch (this) {
      case ActivityType.service:
        return l10n.activityType_service;
      case ActivityType.event:
        return l10n.activityType_event;
      case ActivityType.announcement:
        return l10n.activityType_announcement;
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
          FormFieldType.title,
          FormFieldType.location,
          FormFieldType.pinpointLocation,
          FormFieldType.date,
          FormFieldType.time,
          FormFieldType.reminder,
        ];
      case ActivityType.announcement:
        return [
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

extension FinancialReportSubtypeExtension on FinancialReportSubtype {
  String get displayName {
    final l10n = _l10n();
    switch (this) {
      case FinancialReportSubtype.revenue:
        return l10n.financialSubtype_revenue;
      case FinancialReportSubtype.expense:
        return l10n.financialSubtype_expense;
      case FinancialReportSubtype.mutation:
        return l10n.financialSubtype_mutation;
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

  @JsonValue("VERSE1")
  verse1,

  @JsonValue("VERSE2")
  verse2,

  @JsonValue("VERSE3")
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

  @JsonValue("VERSE9")
  verse9,

  @JsonValue("VERSE10")
  verse10,

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
