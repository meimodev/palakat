import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/l10n/generated/app_localizations.dart';

AppLocalizations _l10n() {
  final localeName = intl.Intl.getCurrentLocale();
  final languageCode = localeName.split(RegExp('[_-]')).first;
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
        return Colors.orange.shade100;
      case ApprovalStatus.approved:
        return Colors.green.shade100;
      case ApprovalStatus.rejected:
        return Colors.red.shade100;
    }
  }

  /// Foreground/text color for status chips
  Color get foregroundColor {
    switch (this) {
      case ApprovalStatus.unconfirmed:
        return Colors.orange.shade800;
      case ApprovalStatus.approved:
        return Colors.green.shade800;
      case ApprovalStatus.rejected:
        return Colors.red.shade800;
    }
  }

  /// Returns all display properties as a record for convenience
  /// Returns: (backgroundColor, foregroundColor, displayLabel, icon)
  (Color bg, Color fg, String label, IconData icon) get displayProperties {
    return (backgroundColor, foregroundColor, displayLabel, icon);
  }
}
