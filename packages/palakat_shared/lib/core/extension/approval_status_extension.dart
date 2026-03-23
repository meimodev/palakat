import 'package:flutter/material.dart';
import 'package:palakat_shared/core/theme/theme.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat_shared/core/constants/enums.dart';
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

/// Extension for ApprovalStatus enum providing display properties
extension ApprovalStatusExtension on ApprovalStatus {
  /// Display label for the approval status
  String get displayLabel {
    final l10n = _l10n();
    switch (this) {
      case ApprovalStatus.unconfirmed:
        return l10n.status_unconfirmed;
      case ApprovalStatus.approved:
        return l10n.status_approved;
      case ApprovalStatus.rejected:
        return l10n.status_rejected;
    }
  }

  /// Icon representing the approval status
  IconData get icon {
    switch (this) {
      case ApprovalStatus.unconfirmed:
        return Icons.schedule;
      case ApprovalStatus.approved:
        return Icons.check_circle;
      case ApprovalStatus.rejected:
        return Icons.cancel;
    }
  }

  /// Background color for status chips
  Color get backgroundColor {
    switch (this) {
      case ApprovalStatus.unconfirmed:
        return AppColors.warning.shade50;
      case ApprovalStatus.approved:
        return AppColors.success.shade50;
      case ApprovalStatus.rejected:
        return AppColors.error.shade50;
    }
  }

  /// Foreground/text color for status chips
  Color get foregroundColor {
    switch (this) {
      case ApprovalStatus.unconfirmed:
        return AppColors.warning.shade800;
      case ApprovalStatus.approved:
        return AppColors.success.shade800;
      case ApprovalStatus.rejected:
        return AppColors.error.shade800;
    }
  }

  /// Returns all display properties as a record for convenience
  /// Returns: (backgroundColor, foregroundColor, displayLabel, icon)
  (Color bg, Color fg, String label, IconData icon) get displayProperties {
    return (backgroundColor, foregroundColor, displayLabel, icon);
  }
}
