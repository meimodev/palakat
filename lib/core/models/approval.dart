
import 'package:freezed_annotation/freezed_annotation.dart';

import 'models.dart';

part 'approval.freezed.dart';
part 'approval.g.dart';

@freezed
abstract class Approval with _$Approval {
  const factory Approval({
    required int id,
    required String description,
    required Membership supervisor,
    required List<Approver> approvers,
    @DateTimeConverterTimestamp() DateTime? createdAt,
    @DateTimeConverterTimestamp() DateTime? updatedAt,
  }) = _Approval;

  factory Approval.fromJson(Map<String, dynamic> json) =>
      _$ApprovalFromJson(json);
}
