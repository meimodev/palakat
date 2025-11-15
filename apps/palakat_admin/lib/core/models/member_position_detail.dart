import 'package:freezed_annotation/freezed_annotation.dart';


part 'member_position_detail.freezed.dart';

part 'member_position_detail.g.dart';

@freezed
abstract class MemberPositionDetail with _$MemberPositionDetail {
  const factory MemberPositionDetail({
    int? id,
    required int churchId,
    required String name,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default([]) List<String> positions,
    String? accountName,
  }) = _MemberPositionDetail;

  factory MemberPositionDetail.fromJson(Map<String, dynamic> data) =>
      _$MemberPositionDetailFromJson(data);
}
