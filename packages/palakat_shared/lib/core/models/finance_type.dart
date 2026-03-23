import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat_shared/core/theme/app_colors.dart';
import 'package:palakat_shared/l10n/generated/app_localizations.dart';

String _languageCodeFromLocaleName(String localeName) {
  final underscoreIndex = localeName.indexOf('_');
  final hyphenIndex = localeName.indexOf('-');
  final separatorIndex = underscoreIndex == -1
      ? hyphenIndex
      : hyphenIndex == -1
      ? underscoreIndex
      : underscoreIndex < hyphenIndex
      ? underscoreIndex
      : hyphenIndex;
  if (separatorIndex == -1) return localeName;
  return localeName.substring(0, separatorIndex);
}

AppLocalizations _l10n() {
  final localeName = intl.Intl.getCurrentLocale();
  final languageCode = _languageCodeFromLocaleName(localeName);
  return lookupAppLocalizations(
    Locale(languageCode.isEmpty ? 'en' : languageCode),
  );
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
    final l10n = _l10n();
    switch (this) {
      case FinanceType.revenue:
        return l10n.financeType_revenue;
      case FinanceType.expense:
        return l10n.financeType_expense;
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
        return AppColors.success;
      case FinanceType.expense:
        return AppColors.error;
    }
  }
}
