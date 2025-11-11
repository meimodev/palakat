import 'dart:convert';
import 'package:flutter/material.dart';
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
    final statusText = _statusText(statusCode);
    final serverMessage = _extractServerMessage(error);
    String primaryMessage = serverMessage ?? error.userMessage;

    // Auth/sign-in specific edge cases
    if (isSignInContext && statusCode != null) {
      if (statusCode == 401) {
        primaryMessage = 'Incorrect email/phone and password combination.';
      } else if (statusCode == 403) {
        primaryMessage = 'Your account is temporarily locked. Please wait 5 minutes and try again.';
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
          Icon(_statusIcon(statusCode), size: 20, color: theme.colorScheme.error),
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
                      color: theme.colorScheme.onErrorContainer.withValues(alpha: 0.9),
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
        return Icons.warning_amber_rounded; // validation/client error
      case 401:
        return Icons.lock_outline; // unauthorized
      case 403:
        return Icons.security; // forbidden
      case 404:
        return Icons.search_off; // not found
      default:
        return Icons.error_outline;
    }
  }

  String? _statusText(int? statusCode) {
    if (statusCode == null) return null;
    String label;
    if (statusCode >= 500) {
      label = 'Server error';
    } else {
      switch (statusCode) {
        case 400:
          label = 'Bad request';
          break;
        case 401:
          label = 'Unauthorized';
          break;
        case 403:
          label = 'Forbidden';
          break;
        case 404:
          label = 'Not found';
          break;
        case 409:
          label = 'Conflict';
          break;
        case 422:
          label = 'Validation error';
          break;
        default:
          label = 'Error';
      }
    }
    return '$statusCode • $label';
  }

  String? _extractServerMessage(AppError error) {
    // Prefer explicit message if it's not a generic one
    // If details contains a JSON-like message, try to surface it.
    final details = error.details;
    if (details == null || details.trim().isEmpty) return null;

    // Try to parse a simple JSON map and extract common keys
    try {
      String jsonCandidate = details.trim();
      // If details includes prefix like "Status: 401, Data: { ... }", try to extract the JSON object substring
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
        // Sometimes server sends validation errors under 'errors' as map/list
        final errs = map['errors'];
        if (errs is List) {
          final first = errs.cast<dynamic>().firstWhere((e) => e != null, orElse: () => null);
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
            if (v is List && v.isNotEmpty && v.first is String) return (v.first as String).trim();
            if (v is String && v.trim().isNotEmpty) return v.trim();
          }
        }
      }
    } catch (_) {
      // fallthrough to regex/heuristics
    }

    // Heuristic: extract after 'message:'
    final idx = details.toLowerCase().indexOf('message:');
    if (idx >= 0) {
      final msg = details.substring(idx + 8).trim();
      if (msg.isNotEmpty) return msg;
    }

    // Otherwise, return details but clamp length
    if (details.length > 300) {
      return details.substring(0, 300).trim();
    }
    return details.trim();
  }
}
