import 'package:flutter/material.dart';

class AppSnackbars {
  AppSnackbars._();

  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    int? statusCode,
  }) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.errorContainer;
    final onColor = theme.colorScheme.onErrorContainer;

    final codePrefix = statusCode == null ? '' : '[$statusCode] ';
    final derivedTitle = title ?? _statusTitle(statusCode);
    final hint = _statusHint(statusCode);
    final displayMessage = hint.isEmpty ? '$codePrefix$message' : '$codePrefix$message ($hint)';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        content: Row(
          children: [
            Icon(Icons.error_outline, color: onColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                derivedTitle.isNotEmpty ? '$derivedTitle: $displayMessage' : displayMessage,
                style: theme.textTheme.bodyMedium?.copyWith(color: onColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, {required String message, String? title}) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primaryContainer;
    final onColor = theme.colorScheme.onPrimaryContainer;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: onColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title != null && title.isNotEmpty ? '$title: $message' : message,
                style: theme.textTheme.bodyMedium?.copyWith(color: onColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _statusTitle(int? statusCode) {
    if (statusCode == null) return '';
    if (statusCode >= 500) return 'Server Error';
    switch (statusCode) {
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 409:
        return 'Conflict';
      case 422:
        return 'Validation Error';
      case 429:
        return 'Too Many Requests';
      default:
        return 'Error';
    }
  }

  static String _statusHint(int? statusCode) {
    if (statusCode == null) return '';
    if (statusCode >= 500) return 'Please try again later';
    switch (statusCode) {
      case 400:
        return 'Check your input';
      case 401:
        return 'Please sign in again';
      case 403:
        return 'Insufficient permissions';
      case 404:
        return 'Resource not found';
      case 409:
        return 'State conflict';
      case 422:
        return 'Validation failed';
      case 429:
        return 'Slow down';
      default:
        return '';
    }
  }
}
