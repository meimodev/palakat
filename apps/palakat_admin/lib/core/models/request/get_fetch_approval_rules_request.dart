import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_fetch_approval_rules_request.freezed.dart';
part 'get_fetch_approval_rules_request.g.dart';

@freezed
abstract class GetFetchApprovalRulesRequest with _$GetFetchApprovalRulesRequest {
  const factory GetFetchApprovalRulesRequest({
    required int churchId,
    String? search,
    bool? active,
    int? positionId,
  }) = _GetFetchApprovalRulesRequest;

  factory GetFetchApprovalRulesRequest.fromJson(Map<String, dynamic> json) =>
      _$GetFetchApprovalRulesRequestFromJson(json);
}
