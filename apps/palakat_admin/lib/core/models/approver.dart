import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/core/models/activity.dart';
import 'package:palakat_admin/core/models/approval_status.dart';
import 'package:palakat_admin/core/models/membership.dart';

part 'approver.freezed.dart';
part 'approver.g.dart';

@freezed
abstract class Approver with _$Approver {
  const factory Approver({
    int? id,
    int? membershipId,
    Membership? membership,
    int? activityId,
    Activity? activity,
    @Default(ApprovalStatus.unconfirmed) ApprovalStatus status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Approver;

  factory Approver.fromJson(Map<String, dynamic> json) => _$ApproverFromJson(json);
}
