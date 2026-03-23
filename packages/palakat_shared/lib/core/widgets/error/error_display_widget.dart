import 'package:flutter/material.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/theme/theme.dart';

/// Error display widget with retry button
///
/// Shows a Material 3 styled error card with:
/// - Error icon
/// - Error message
/// - Retry button (if onRetry provided)
///
/// This is a platform-agnostic error widget that can be used
/// across both mobile and web applications.
///
/// Usage:
/// ```dart
/// ErrorDisplayWidget(
///   message: 'Failed to load data',
///   onRetry: () => controller.fetchData(),
/// )
/// ```
class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final EdgeInsets? padding;
  final String? title;

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.padding,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          side: BorderSide(
            color: AppColors.error.withValues(alpha: 0.16),
            width: 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
            boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Error icon and message
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(
                          SanctuaryLayout.radius,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.error_outline,
                        size: 20,
                        color: colorScheme.error,
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title ?? l10n.err_error,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Gap.h4,
                          Text(
                            message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Retry button (if callback provided)
                if (onRetry != null) ...[
                  Gap.h16,
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: Text(l10n.btn_retry),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(
                          color: colorScheme.error.withValues(alpha: 0.35),
                          width: 1,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            SanctuaryLayout.radius,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
