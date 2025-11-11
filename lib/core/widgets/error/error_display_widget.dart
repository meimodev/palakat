import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

/// Error display widget with retry button for mobile app
///
/// Shows a Material 3 styled error card with:
/// - Error icon
/// - Error message
/// - Retry button (if onRetry provided)
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

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(BaseSize.w24),
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: BaseColor.red[50],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: BaseColor.red[200]!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error icon and message
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: BaseSize.w40,
                    height: BaseSize.w40,
                    decoration: BoxDecoration(
                      color: BaseColor.red[100],
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.error_outline,
                      size: BaseSize.w20,
                      color: BaseColor.red[700],
                    ),
                  ),
                  Gap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Error',
                          style: BaseTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: BaseColor.red[900],
                          ),
                        ),
                        Gap.h4,
                        Text(
                          message,
                          style: BaseTypography.bodyMedium.copyWith(
                            color: BaseColor.red[800],
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
                    icon: Icon(
                      Icons.refresh,
                      size: BaseSize.w16,
                    ),
                    label: const Text('Retry'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BaseColor.red[700],
                      side: BorderSide(
                        color: BaseColor.red[300]!,
                        width: 1,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: BaseSize.w16,
                        vertical: BaseSize.w12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
