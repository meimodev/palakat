import 'package:freezed_annotation/freezed_annotation.dart';

part 'cash_account.freezed.dart';
part 'cash_account.g.dart';

/// Represents a cash account belonging to a church. Revenue/Expense records
/// must be attached to a cash account so the server can keep the matching
/// CashMutation in sync.
@freezed
abstract class CashAccount with _$CashAccount {
  const factory CashAccount({
    required int id,
    required String name,
    @Default('IDR') String currency,
    @Default(0) int openingBalance,
    int? balance,
    required int churchId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CashAccount;

  factory CashAccount.fromJson(Map<String, dynamic> json) =>
      _$CashAccountFromJson(json);
}
