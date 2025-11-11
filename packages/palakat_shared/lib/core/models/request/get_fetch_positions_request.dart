import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_fetch_positions_request.freezed.dart';
part 'get_fetch_positions_request.g.dart';

@freezed
abstract class GetFetchPositionsRequest with _$GetFetchPositionsRequest {
  const factory GetFetchPositionsRequest({
    required int churchId,
    String? search,
  }) = _GetFetchPositionsRequest;

  factory GetFetchPositionsRequest.fromJson(Map<String, dynamic> json) =>
      _$GetFetchPositionsRequestFromJson(json);
}
