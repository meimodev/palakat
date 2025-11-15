import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_fetch_accounts_count_request.freezed.dart';
part 'get_fetch_accounts_count_request.g.dart';

@freezed
abstract class GetFetchAccountsCountRequest with _$GetFetchAccountsCountRequest {
// ignore: invalid_annotation_target
@JsonSerializable(includeIfNull: false)
  const factory GetFetchAccountsCountRequest({
    int? churchId,
  }) = _GetFetchAccountsCountRequest;

  factory GetFetchAccountsCountRequest.fromJson(Map<String, dynamic> json) =>
      _$GetFetchAccountsCountRequestFromJson(json);
}