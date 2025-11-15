import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/activity.dart';

part 'expense.freezed.dart';

part 'expense.g.dart';

@freezed
abstract class Expense with _$Expense {
  const factory Expense({
    int? id,
    String? accountNumber,
    required int amount,
    required int churchId,
    required int activityId,
    required PaymentMethod paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Activity? activity,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
}
