import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';

part 'create_expense_request.freezed.dart';
part 'create_expense_request.g.dart';

/// Request model for creating a new expense record.
/// Used by ExpenseRepository.createExpense method.
@freezed
abstract class CreateExpenseRequest with _$CreateExpenseRequest {
  const factory CreateExpenseRequest({
    /// The account number associated with the expense
    required String accountNumber,

    /// The expense amount in the smallest currency unit
    required int amount,

    /// The church ID this expense belongs to
    required int churchId,

    /// Optional activity ID if the expense is linked to an activity
    int? activityId,

    /// The payment method used (CASH or CASHLESS)
    required PaymentMethod paymentMethod,

    /// Optional ID of the FinancialAccountNumber record
    /// Used to link the expense to a predefined account number
    /// Requirements: 2.4
    int? financialAccountNumberId,
  }) = _CreateExpenseRequest;

  factory CreateExpenseRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateExpenseRequestFromJson(json);
}
