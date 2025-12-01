import 'package:freezed_annotation/freezed_annotation.dart';

import 'finance_type.dart';

part 'financial_account_number.freezed.dart';
part 'financial_account_number.g.dart';

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
  }) = _FinancialAccountNumber;

  factory FinancialAccountNumber.fromJson(Map<String, dynamic> json) =>
      _$FinancialAccountNumberFromJson(json);
}
