import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart' as intl;

bool _isIndonesianLocale() {
  final locale = intl.Intl.getCurrentLocale();
  return locale.startsWith('id');
}

/// Enum representing the type of financial record.
/// JSON values match backend FinancialType enum (REVENUE, EXPENSE).
@JsonEnum(valueField: 'value')
enum FinanceType {
  revenue('REVENUE'),
  expense('EXPENSE');

  const FinanceType(this.value);
  final String value;
}

/// Extension providing display properties for FinanceType.
extension FinanceTypeExtension on FinanceType {
  /// Returns the display name for the finance type.
  String get displayName {
    final isId = _isIndonesianLocale();
    switch (this) {
      case FinanceType.revenue:
        return isId ? 'Pendapatan' : 'Revenue';
      case FinanceType.expense:
        return isId ? 'Pengeluaran' : 'Expense';
    }
  }

  /// Returns the icon for the finance type.
  IconData get icon {
    switch (this) {
      case FinanceType.revenue:
        return Icons.trending_up;
      case FinanceType.expense:
        return Icons.trending_down;
    }
  }

  /// Returns the color associated with the finance type.
  /// Uses teal for revenue (success) and red for expense (error).
  Color get color {
    switch (this) {
      case FinanceType.revenue:
        return const Color(0xFF009688); // Teal - success color
      case FinanceType.expense:
        return const Color(0xFFD32F2F); // Red - error color
    }
  }
}
