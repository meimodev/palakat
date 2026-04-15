import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/extension/approver_extension.dart';
import 'package:palakat_shared/core/models/approver.dart';
import 'package:palakat_shared/core/models/document.dart';
import 'package:palakat_shared/core/models/file_manager.dart';
import 'package:palakat_shared/core/models/location.dart';
import 'package:palakat_shared/core/models/membership.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

@freezed
abstract class Activity with _$Activity {
  const Activity._();

  const factory Activity({
    int? id,
    int? supervisorId,
    Bipra? bipra,
    required String title,
    String? description,
    int? locationId,
    required DateTime date,
    String? note,
    int? fileId,
    FileManager? file,
    int? documentId,
    Document? document,
    @Default(ActivityType.service) ActivityType activityType,
    Reminder? reminder,
    required DateTime createdAt,
    DateTime? updatedAt,
    required Membership supervisor,
    @Default([]) List<Approver> approvers,
    Location? location,
    bool? hasRevenue,
    bool? hasExpense,
    @Default([]) List<ActivityFinance> revenues,
    @Default([]) List<ActivityFinance> expenses,
    // Override metadata — set by a church admin
    @Default(false) bool isOverridden,
    @JsonKey(fromJson: _overrideStatusFromJson) ApprovalOverrideStatus? overrideStatus,
    String? overrideNote,
    DateTime? overriddenAt,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  /// Effective approval status: respects admin override when present.
  ApprovalStatus get effectiveStatus => effectiveApprovalStatus(
    approvers: approvers,
    isOverridden: isOverridden,
    overrideStatus: overrideStatus,
  );
}

ApprovalOverrideStatus? _overrideStatusFromJson(dynamic value) =>
    ApprovalOverrideStatus.fromString(value as String?);


@freezed
abstract class ActivityFinance with _$ActivityFinance {
  const factory ActivityFinance({
    int? id,
    int? amount,
    String? accountNumber,
    String? paymentMethod,
    FinancialAccountInfo? financialAccountNumber,
  }) = _ActivityFinance;

  factory ActivityFinance.fromJson(Map<String, dynamic> json) =>
      _$ActivityFinanceFromJson(json);
}

@freezed
abstract class FinancialAccountInfo with _$FinancialAccountInfo {
  const factory FinancialAccountInfo({
    String? accountNumber,
    String? description,
  }) = _FinancialAccountInfo;

  factory FinancialAccountInfo.fromJson(Map<String, dynamic> json) =>
      _$FinancialAccountInfoFromJson(json);
}
