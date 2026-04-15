import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/extension/approver_extension.dart';
import 'package:palakat_shared/core/models/activity.dart';
import 'package:palakat_shared/core/models/approver.dart';

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
  final List<Approver> approvers;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // Override metadata — set by a church admin
  final bool isOverridden;
  final ApprovalOverrideStatus? overrideStatus;
  final String? overrideNote;
  final DateTime? overriddenAt;

  const FinanceEntry({
    this.id,
    required this.type,
    required this.accountNumber,
    required this.amount,
    required this.paymentMethod,
    required this.churchId,
    this.activityId,
    this.activity,
    this.approvers = const [],
    this.createdAt,
    this.updatedAt,
    this.isOverridden = false,
    this.overrideStatus,
    this.overrideNote,
    this.overriddenAt,
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
      approvers:
          (json['approvers'] as List<dynamic>?)
              ?.map((e) => Approver.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      isOverridden: json['isOverridden'] as bool? ?? false,
      overrideStatus: ApprovalOverrideStatus.fromString(
        json['overrideStatus'] as String?,
      ),
      overrideNote: json['overrideNote'] as String?,
      overriddenAt: json['overriddenAt'] != null
          ? DateTime.tryParse(json['overriddenAt'] as String)
          : null,
    );
  }

  /// Effective approval status: respects admin override when present.
  ApprovalStatus get effectiveStatus => effectiveApprovalStatus(
    approvers: approvers,
    isOverridden: isOverridden,
    overrideStatus: overrideStatus,
  );

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
      'approvers': approvers.map((e) => e.toJson()).toList(),
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
    List<Approver>? approvers,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOverridden,
    ApprovalOverrideStatus? overrideStatus,
    String? overrideNote,
    DateTime? overriddenAt,
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
      approvers: approvers ?? this.approvers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOverridden: isOverridden ?? this.isOverridden,
      overrideStatus: overrideStatus ?? this.overrideStatus,
      overrideNote: overrideNote ?? this.overrideNote,
      overriddenAt: overriddenAt ?? this.overriddenAt,
    );
  }
}
