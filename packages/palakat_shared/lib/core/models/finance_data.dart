import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/finance_type.dart';

part 'finance_data.freezed.dart';
part 'finance_data.g.dart';

/// Data transfer object for passing finance data between screens.
/// Used when attaching financial records to activities during publishing.
@freezed
abstract class FinanceData with _$FinanceData {
  const factory FinanceData({
    /// The type of financial record (revenue or expense)
    required FinanceType type,

    /// The amount in the smallest currency unit
    required int amount,

    /// The account number associated with the record
    required String accountNumber,

    /// The payment method used (CASH or CASHLESS)
    required PaymentMethod paymentMethod,
  }) = _FinanceData;

  factory FinanceData.fromJson(Map<String, dynamic> json) =>
      _$FinanceDataFromJson(json);
}
