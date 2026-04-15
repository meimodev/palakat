import 'package:freezed_annotation/freezed_annotation.dart';

import 'financial_account_number.dart';

part 'member_position.freezed.dart';

part 'member_position.g.dart';

@freezed
abstract class MemberPosition with _$MemberPosition {
  const factory MemberPosition({
    int? id,
    required int churchId,
    required String name,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default([]) List<LinkedApprovalRule> approvalRules,
  }) = _MemberPosition;

  factory MemberPosition.fromJson(Map<String, dynamic> data) =>
      _$MemberPositionFromJson(data);
}
