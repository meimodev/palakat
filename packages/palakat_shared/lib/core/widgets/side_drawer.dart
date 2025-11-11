import 'package:flutter/material.dart';

class SideDrawer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onClose;
  final Widget content;
  final Widget? footer;
  final double width;
  final bool isLoading;
  final String loadingMessage;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const SideDrawer({
    super.key,
    required this.title,
    this.subtitle,
    required this.onClose,
    required this.content,
    this.footer,
    this.width = 420,
    this.isLoading = false,
    this.loadingMessage = 'Loading...',
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      child: Container(
        width: width,
        height: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: content,
                  ),
                  if (isLoading)
                    Positioned.fill(
                      child: Container(
                        color: theme.colorScheme.surface.withValues(alpha: 0.8),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(strokeWidth: 3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                loadingMessage,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (!isLoading && errorMessage != null)
                    Positioned.fill(
                      child: Container(
                        color: theme.colorScheme.surface,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 36,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Something went wrong',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                errorMessage!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              if (onRetry != null)
                                FilledButton.icon(
                                  onPressed: onRetry,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (footer != null && !isLoading && errorMessage == null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}
