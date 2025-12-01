import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/finance_type.dart';
import 'church.dart';
import 'financial_account_number.dart';
import 'member_position.dart';

part 'approval_rule.freezed.dart';
part 'approval_rule.g.dart';

@freezed
abstract class ApprovalRule with _$ApprovalRule {
  const factory ApprovalRule({
    int? id,
    required String name,
    String? description,
    @Default(true) bool active,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? churchId,
    Church? church,
    @Default([]) List<MemberPosition> positions,
    ActivityType? activityType,
    FinanceType? financialType,
    int? financialAccountNumberId,
    FinancialAccountNumber? financialAccountNumber,
  }) = _ApprovalRule;

  factory ApprovalRule.fromJson(Map<String, dynamic> json) =>
      _$ApprovalRuleFromJson(json);
}
