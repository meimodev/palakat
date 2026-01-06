import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_fetch_member_position_request.freezed.dart';
part 'get_fetch_member_position_request.g.dart';

@freezed
abstract class GetFetchMemberPosition with _$GetFetchMemberPosition {
  // ignore: invalid_annotation_target
  @JsonSerializable(includeIfNull: false)
  const factory GetFetchMemberPosition({
    int? churchId,
    int? columnId,
    String? position,
    String? search,
  }) = _GetFetchMemberPosition;

  factory GetFetchMemberPosition.fromJson(Map<String, dynamic> json) =>
      _$GetFetchMemberPositionFromJson(json);
}
