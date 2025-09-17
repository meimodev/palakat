// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/constants/enums/enums.dart';

import 'models.dart';

part 'approver.freezed.dart';

part 'approver.g.dart';

@freezed
abstract class Approver with _$Approver {
  const factory Approver({
    required int id,
    required ApprovalStatus status,
    required Membership membership,
    @DateTimeConverterTimestamp() DateTime? createdAt,
    @DateTimeConverterTimestamp() DateTime? updatedAt,
  }) = _Approver;

  factory Approver.fromJson(Map<String, dynamic> json) =>
      _$ApproverFromJson(json);
}
