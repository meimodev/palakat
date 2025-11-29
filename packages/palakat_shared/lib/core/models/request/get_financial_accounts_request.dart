import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_financial_accounts_request.freezed.dart';
part 'get_financial_accounts_request.g.dart';

/// Request model for fetching financial account numbers.
@Freezed(toJson: true, fromJson: true)
abstract class GetFinancialAccountsRequest with _$GetFinancialAccountsRequest {
  const factory GetFinancialAccountsRequest({
    required int churchId,
    String? search,
  }) = _GetFinancialAccountsRequest;

  factory GetFinancialAccountsRequest.fromJson(Map<String, dynamic> json) =>
      _$GetFinancialAccountsRequestFromJson(json);
}
