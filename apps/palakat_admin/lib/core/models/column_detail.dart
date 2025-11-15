import 'package:freezed_annotation/freezed_annotation.dart';

part 'column_detail.freezed.dart';

part 'column_detail.g.dart';

@freezed
abstract class ColumnDetail with _$ColumnDetail {
  const factory ColumnDetail({
    int? id,
    required String name,
    DateTime? createdAt,
    DateTime? updatedAt,
    required int churchId,
    @Default([]) List<ColumnDetailMembership> memberships,
  }) = _ColumnDetail;

  factory ColumnDetail.fromJson(Map<String, dynamic> json) =>
      _$ColumnDetailFromJson(json);
}

@freezed
abstract class ColumnDetailMembership with _$ColumnDetailMembership {
  const factory ColumnDetailMembership({
    required int membershipId,
    required String name,
  }) = _ColumnDetailMembership;

  factory ColumnDetailMembership.fromJson(Map<String, dynamic> json) =>
      _$ColumnDetailMembershipFromJson(json);
}
