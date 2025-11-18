import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_fetch_columns_request.freezed.dart';
part 'get_fetch_columns_request.g.dart';

@freezed
abstract class GetFetchColumnsRequest with _$GetFetchColumnsRequest {
  // ignore: invalid_annotation_target
  @JsonSerializable(includeIfNull: false)
  const factory GetFetchColumnsRequest({
    required int churchId,
    String? search,
  }) = _GetFetchColumnsRequest;

  factory GetFetchColumnsRequest.fromJson(Map<String, dynamic> json) =>
      _$GetFetchColumnsRequestFromJson(json);
}
