import 'package:flutter/material.dart';

/// Enum representing the type of financial record.
enum FinanceType { revenue, expense }

/// Extension providing display properties for FinanceType.
extension FinanceTypeExtension on FinanceType {
  /// Returns the display name for the finance type.
  String get displayName {
    switch (this) {
      case FinanceType.revenue:
        return 'Revenue';
      case FinanceType.expense:
        return 'Expense';
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
