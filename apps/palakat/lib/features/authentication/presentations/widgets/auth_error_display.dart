import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

/// Error display widget for authentication screens
///
/// Displays error messages with an icon and optional retry button.
/// Follows the Material 3 design system with red color scheme for errors.
class AuthErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AuthErrorDisplay({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Material(
        color: BaseColor.red[50],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          side: BorderSide(color: BaseColor.red[200]!, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error icon in red circle
                  Container(
                    width: BaseSize.w24,
                    height: BaseSize.w24,
                    decoration: BoxDecoration(
                      color: BaseColor.red[100],
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.error_outline,
                      size: BaseSize.w16,
                      color: BaseColor.red[700],
                    ),
                  ),
                  Gap.w12,
                  // Error message
                  Expanded(
                    child: Text(
                      message,
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.red[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              // Optional retry button
              if (onRetry != null) ...[
                Gap.h12,
                SizedBox(
                  height: BaseSize.h36,
                  child: OutlinedButton(
                    onPressed: onRetry,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BaseColor.red[700],
                      side: BorderSide(color: BaseColor.red[300]!, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                      ),
                    ),
                    child: Text(
                      "Retry",
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.red[700],
                        fontWeight: FontWeight.w600,
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
