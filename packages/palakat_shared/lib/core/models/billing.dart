import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/l10n/generated/app_localizations.dart';

part 'billing.freezed.dart';
part 'billing.g.dart';

AppLocalizations _l10n() {
  final localeName = intl.Intl.getCurrentLocale();
  final languageCode = localeName.split(RegExp('[_-]')).first;
  return lookupAppLocalizations(
    Locale(languageCode.isEmpty ? 'en' : languageCode),
  );
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
    final l10n = _l10n();
    switch (this) {
      case BillingType.subscription:
        return l10n.billingType_subscription;
      case BillingType.oneTime:
        return l10n.billingType_oneTime;
      case BillingType.recurring:
        return l10n.billingType_recurring;
    }
  }
}

extension BillingStatusExtension on BillingStatus {
  String get displayName {
    final l10n = _l10n();
    switch (this) {
      case BillingStatus.pending:
        return l10n.billingStatus_pending;
      case BillingStatus.paid:
        return l10n.billingStatus_paid;
      case BillingStatus.overdue:
        return l10n.billingStatus_overdue;
      case BillingStatus.cancelled:
        return l10n.billingStatus_cancelled;
      case BillingStatus.refunded:
        return l10n.billingStatus_refunded;
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    final l10n = _l10n();
    switch (this) {
      case PaymentMethod.cash:
        return l10n.paymentMethod_cash;
      case PaymentMethod.cashless:
        return l10n.paymentMethod_cashless;
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
