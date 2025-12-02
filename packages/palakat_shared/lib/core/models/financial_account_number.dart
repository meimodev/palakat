import 'package:freezed_annotation/freezed_annotation.dart';

import 'finance_type.dart';

part 'financial_account_number.freezed.dart';
part 'financial_account_number.g.dart';

/// A lightweight reference to an approval rule containing only id and name.
/// Used when including linked approval rule information in financial account responses.
@freezed
abstract class LinkedApprovalRule with _$LinkedApprovalRule {
  const factory LinkedApprovalRule({required int id, required String name}) =
      _LinkedApprovalRule;

  factory LinkedApprovalRule.fromJson(Map<String, dynamic> json) =>
      _$LinkedApprovalRuleFromJson(json);
}

@freezed
abstract class FinancialAccountNumber with _$FinancialAccountNumber {
  const factory FinancialAccountNumber({
    required int id,
    required String accountNumber,
    String? description,
    required FinanceType type,
    int? churchId,
    DateTime? createdAt,
    DateTime? updatedAt,

    /// The approval rule linked to this financial account (if any).
    /// Only populated when includeApprovalRule is true in the API request.
    LinkedApprovalRule? approvalRule,
  }) = _FinancialAccountNumber;

  factory FinancialAccountNumber.fromJson(Map<String, dynamic> json) =>
      _$FinancialAccountNumberFromJson(json);
}
