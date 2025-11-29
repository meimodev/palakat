import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/activity.dart';

part 'revenue.freezed.dart';
part 'revenue.g.dart';

@freezed
abstract class Revenue with _$Revenue {
  const factory Revenue({
    int? id,
    required String accountNumber,
    required int amount,
    required int churchId,
    int? activityId,
    required PaymentMethod paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
    Activity? activity,
  }) = _Revenue;

  factory Revenue.fromJson(Map<String, dynamic> json) =>
      _$RevenueFromJson(json);
}
