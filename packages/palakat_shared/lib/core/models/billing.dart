import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat_shared/core/constants/enums.dart';

part 'billing.freezed.dart';
part 'billing.g.dart';

bool _isIndonesianLocale() {
  final locale = intl.Intl.getCurrentLocale();
  return locale.startsWith('id');
}

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

  factory BillingItem.fromJson(Map<String, dynamic> json) =>
      _$BillingItemFromJson(json);

  bool get isOverdue =>
      status == BillingStatus.pending && DateTime.now().isAfter(dueDate);
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

  factory PaymentHistory.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryFromJson(json);

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
}

extension BillingTypeExtension on BillingType {
  String get displayName {
    final isId = _isIndonesianLocale();
    switch (this) {
      case BillingType.subscription:
        return isId ? 'Langganan' : 'Subscription';
      case BillingType.oneTime:
        return isId ? 'Sekali Bayar' : 'One-time';
      case BillingType.recurring:
        return isId ? 'Berulang' : 'Recurring';
    }
  }
}

extension BillingStatusExtension on BillingStatus {
  String get displayName {
    final isId = _isIndonesianLocale();
    switch (this) {
      case BillingStatus.pending:
        return isId ? 'Menunggu' : 'Pending';
      case BillingStatus.paid:
        return isId ? 'Lunas' : 'Paid';
      case BillingStatus.overdue:
        return isId ? 'Terlambat' : 'Overdue';
      case BillingStatus.cancelled:
        return isId ? 'Dibatalkan' : 'Cancelled';
      case BillingStatus.refunded:
        return isId ? 'Dikembalikan' : 'Refunded';
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    final isId = _isIndonesianLocale();
    switch (this) {
      case PaymentMethod.cash:
        return isId ? 'Tunai' : 'Cash';
      case PaymentMethod.cashless:
        return isId ? 'Non-tunai' : 'Cashless';
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
