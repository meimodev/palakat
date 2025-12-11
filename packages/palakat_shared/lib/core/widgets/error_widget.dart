import 'dart:convert';
import 'package:flutter/material.dart';
import '../extension/build_context_extension.dart';
import '../models/app_error.dart';

/// Compact error widget for inline error display
class CompactErrorWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final bool isSignInContext;

  const CompactErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.isSignInContext = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusCode = error.statusCode;
    final statusText = _statusText(context, statusCode);
    final serverMessage = _extractServerMessage(error);
    String primaryMessage = serverMessage ?? error.userMessage;

    // Auth/sign-in specific edge cases using l10n
    if (isSignInContext && statusCode != null) {
      if (statusCode == 401) {
        primaryMessage = context.l10n.err_invalidCredentials;
      } else if (statusCode == 403) {
        primaryMessage = context.l10n.err_accountLocked;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _statusIcon(statusCode),
            size: 20,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (statusText != null) ...[
                  Text(
                    statusText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer.withValues(
                        alpha: 0.9,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                Text(
                  primaryMessage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              iconSize: 16,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }

  IconData _statusIcon(int? statusCode) {
    if (statusCode == null) return Icons.error_outline;
    if (statusCode >= 500) return Icons.cloud_off;
    switch (statusCode) {
      case 400:
      case 422:
        return Icons.warning_amber_rounded;
      case 401:
        return Icons.lock_outline;
      case 403:
        return Icons.security;
      case 404:
        return Icons.search_off;
      default:
        return Icons.error_outline;
    }
  }

  String? _statusText(BuildContext context, int? statusCode) {
    if (statusCode == null) return null;
    final l10n = context.l10n;
    String label;
    if (statusCode >= 500) {
      label = l10n.err_serverError;
    } else {
      switch (statusCode) {
        case 400:
          label = l10n.err_badRequest;
          break;
        case 401:
          label = l10n.err_unauthorized;
          break;
        case 403:
          label = l10n.err_forbidden;
          break;
        case 404:
          label = l10n.err_notFound;
          break;
        case 409:
          label = l10n.err_conflict;
          break;
        case 422:
          label = l10n.err_validationError;
          break;
        default:
          label = l10n.err_error;
      }
    }
    return l10n.err_statusWithCode(statusCode, label);
  }

  String? _extractServerMessage(AppError error) {
    final details = error.details;
    if (details == null || details.trim().isEmpty) return null;

    try {
      String jsonCandidate = details.trim();
      final start = jsonCandidate.indexOf('{');
      final end = jsonCandidate.lastIndexOf('}');
      if (start >= 0 && end > start) {
        jsonCandidate = jsonCandidate.substring(start, end + 1);
      }
      if (jsonCandidate.startsWith('{') && jsonCandidate.endsWith('}')) {
        final map = jsonDecode(jsonCandidate) as Map<String, dynamic>;
        final keys = ['message', 'error', 'detail', 'title', 'msg'];
        for (final k in keys) {
          final v = map[k];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
        final errs = map['errors'];
        if (errs is List) {
          final first = errs.cast<dynamic>().firstWhere(
            (e) => e != null,
            orElse: () => null,
          );
          if (first is String && first.trim().isNotEmpty) return first.trim();
          if (first is Map) {
            final vals = first.values.cast<dynamic>().toList();
            if (vals.isNotEmpty) {
              final v = vals.first;
              if (v is String && v.trim().isNotEmpty) return v.trim();
            }
          }
        } else if (errs is Map) {
          for (final v in errs.values) {
            if (v is List && v.isNotEmpty && v.first is String) {
              return (v.first as String).trim();
            }
            if (v is String && v.trim().isNotEmpty) return v.trim();
          }
        }
      }
    } catch (_) {
      // fallthrough to regex/heuristics
    }

    final idx = details.toLowerCase().indexOf('message:');
    if (idx >= 0) {
      final msg = details.substring(idx + 8).trim();
      if (msg.isNotEmpty) return msg;
    }

    if (details.length > 300) {
      return details.substring(0, 300).trim();
    }
    return details.trim();
  }
}
