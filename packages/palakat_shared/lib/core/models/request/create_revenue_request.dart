import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';

part 'create_revenue_request.freezed.dart';
part 'create_revenue_request.g.dart';

/// Request model for creating a new revenue record.
/// Used by RevenueRepository.createRevenue method.
@freezed
abstract class CreateRevenueRequest with _$CreateRevenueRequest {
  const factory CreateRevenueRequest({
    /// The account number associated with the revenue
    required String accountNumber,

    /// The revenue amount in the smallest currency unit
    required int amount,

    /// The church ID this revenue belongs to
    required int churchId,

    /// Optional activity ID if the revenue is linked to an activity
    int? activityId,

    /// The payment method used (CASH or CASHLESS)
    required PaymentMethod paymentMethod,

    /// Optional ID of the FinancialAccountNumber record
    /// Used to link the revenue to a predefined account number
    /// Requirements: 2.3
    int? financialAccountNumberId,
  }) = _CreateRevenueRequest;

  factory CreateRevenueRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateRevenueRequestFromJson(json);
}
