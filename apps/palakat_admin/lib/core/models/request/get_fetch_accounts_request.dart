import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_fetch_accounts_request.freezed.dart';
part 'get_fetch_accounts_request.g.dart';

@freezed
abstract class GetFetchAccountsRequest with _$GetFetchAccountsRequest {
// ignore: invalid_annotation_target
@JsonSerializable(includeIfNull: false)
  const factory GetFetchAccountsRequest({
    int? churchId,
    String? search,
    String? position,
  }) = _GetFetchAccountsRequest;

  factory GetFetchAccountsRequest.fromJson(Map<String, dynamic> json) =>
      _$GetFetchAccountsRequestFromJson(json);
}