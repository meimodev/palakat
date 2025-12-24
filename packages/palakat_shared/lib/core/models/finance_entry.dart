import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/activity.dart';

enum FinanceEntryType {
  revenue,
  expense;

  String get name => switch (this) {
    FinanceEntryType.revenue => 'REVENUE',
    FinanceEntryType.expense => 'EXPENSE',
  };

  static FinanceEntryType fromString(String value) {
    return FinanceEntryType.values.firstWhere(
      (e) => e.name == value.toUpperCase(),
      orElse: () => FinanceEntryType.revenue,
    );
  }
}

class FinanceEntry {
  final int? id;
  final FinanceEntryType type;
  final String accountNumber;
  final int amount;
  final PaymentMethod paymentMethod;
  final int churchId;
  final int? activityId;
  final Activity? activity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FinanceEntry({
    this.id,
    required this.type,
    required this.accountNumber,
    required this.amount,
    required this.paymentMethod,
    required this.churchId,
    this.activityId,
    this.activity,
    this.createdAt,
    this.updatedAt,
  });

  factory FinanceEntry.fromJson(Map<String, dynamic> json) {
    final paymentMethodStr = json['paymentMethod'] as String? ?? 'CASH';
    final paymentMethod = paymentMethodStr.toUpperCase() == 'CASHLESS'
        ? PaymentMethod.cashless
        : PaymentMethod.cash;

    return FinanceEntry(
      id: json['id'] as int?,
      type: FinanceEntryType.fromString(json['type'] as String? ?? 'REVENUE'),
      accountNumber: json['accountNumber'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      paymentMethod: paymentMethod,
      churchId: json['churchId'] as int? ?? 0,
      activityId: json['activityId'] as int?,
      activity: json['activity'] != null
          ? Activity.fromJson(json['activity'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'accountNumber': accountNumber,
      'amount': amount,
      'paymentMethod': paymentMethod == PaymentMethod.cashless
          ? 'CASHLESS'
          : 'CASH',
      'churchId': churchId,
      'activityId': activityId,
      'activity': activity?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  FinanceEntry copyWith({
    int? id,
    FinanceEntryType? type,
    String? accountNumber,
    int? amount,
    PaymentMethod? paymentMethod,
    int? churchId,
    int? activityId,
    Activity? activity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinanceEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      accountNumber: accountNumber ?? this.accountNumber,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      churchId: churchId ?? this.churchId,
      activityId: activityId ?? this.activityId,
      activity: activity ?? this.activity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
