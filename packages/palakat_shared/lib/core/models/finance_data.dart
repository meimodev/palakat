import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/finance_type.dart';

part 'finance_data.freezed.dart';
part 'finance_data.g.dart';

/// Data transfer object for passing finance data between screens.
/// Used when attaching financial records to activities during publishing.
/// Requirements: 3.4
@freezed
abstract class FinanceData with _$FinanceData {
  const factory FinanceData({
    /// The type of financial record (revenue or expense)
    required FinanceType type,

    /// The amount in the smallest currency unit
    required int amount,

    /// The account number string associated with the record
    /// Kept for backward compatibility
    required String accountNumber,

    /// The description of the account number
    String? accountDescription,

    /// The payment method used (CASH or CASHLESS)
    required PaymentMethod paymentMethod,

    /// The ID of the selected FinancialAccountNumber record
    /// Used to link the finance record to a predefined account number
    /// Requirements: 3.4
    int? financialAccountNumberId,
  }) = _FinanceData;

  factory FinanceData.fromJson(Map<String, dynamic> json) =>
      _$FinanceDataFromJson(json);
}
