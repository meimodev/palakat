import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_fetch_churches_request.freezed.dart';
part 'get_fetch_churches_request.g.dart';

@freezed
abstract class GetFetchChurchesRequest with _$GetFetchChurchesRequest {
  // ignore: invalid_annotation_target
  @JsonSerializable(includeIfNull: false)
  const factory GetFetchChurchesRequest({String? search}) =
      _GetFetchChurchesRequest;

  factory GetFetchChurchesRequest.fromJson(Map<String, dynamic> json) =>
      _$GetFetchChurchesRequestFromJson(json);
}
