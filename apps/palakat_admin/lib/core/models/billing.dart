import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/core/constants/enums.dart';

part 'billing.freezed.dart';
part 'billing.g.dart';

@freezed
abstract class BillingItem with _$BillingItem {
  const BillingItem._();

  const factory BillingItem({
    String? id,
    required String description,
    required double amount,
    required BillingType type,
    required BillingStatus status,
    required DateTime dueDate,
    DateTime? paidDate,
    PaymentMethod? paymentMethod,
    String? transactionId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BillingItem;

  factory BillingItem.fromJson(Map<String, dynamic> json) => _$BillingItemFromJson(json);

  bool get isOverdue => status == BillingStatus.pending && DateTime.now().isAfter(dueDate);
  bool get isPaid => status == BillingStatus.paid;
  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
}

@freezed
abstract class PaymentHistory with _$PaymentHistory {
  const PaymentHistory._();

  const factory PaymentHistory({
    String? id,
    required String billingItemId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? transactionId,
    required DateTime paymentDate,
    String? notes,
    required String processedBy,
  }) = _PaymentHistory;

  factory PaymentHistory.fromJson(Map<String, dynamic> json) => _$PaymentHistoryFromJson(json);

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
}

extension BillingTypeExtension on BillingType {
  String get displayName {
    switch (this) {
      case BillingType.subscription:
        return 'Subscription';
      case BillingType.oneTime:
        return 'One-time';
      case BillingType.recurring:
        return 'Recurring';
    }
  }
}

extension BillingStatusExtension on BillingStatus {
  String get displayName {
    switch (this) {
      case BillingStatus.pending:
        return 'Pending';
      case BillingStatus.paid:
        return 'Paid';
      case BillingStatus.overdue:
        return 'Overdue';
      case BillingStatus.cancelled:
        return 'Cancelled';
      case BillingStatus.refunded:
        return 'Refunded';
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.cashless:
        return 'Cashless';
    }
  }

  /// Returns the icon and color for this payment method
  (IconData icon, Color color) get iconAndColor {
    switch (this) {
      case PaymentMethod.cash:
        return (Icons.money, Colors.orange);
      case PaymentMethod.cashless:
        return (Icons.contactless, Colors.indigo);
    }
  }

  IconData get icon => iconAndColor.$1;
  Color get color => iconAndColor.$2;
}

