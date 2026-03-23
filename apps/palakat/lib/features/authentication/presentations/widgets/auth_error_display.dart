import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';

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
    return Material(
      color: AppColors.errorContainer,
      elevation: 1,
      shadowColor: AppColors.error.withValues(alpha: 0.08),
      surfaceTintColor: AppColors.errorContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: AppColors.error.withValues(alpha: 0.24),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.18),
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    AppIcons.error,
                    size: 16.0,
                    color: AppColors.error.shade700,
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (onRetry != null) ...[
              Gap.h12,
              ButtonWidget.outlined(
                text: context.l10n.btn_retry,
                onTap: onRetry,
                buttonSize: ButtonSize.small,
                textColor: AppColors.error.shade700,
                outlineColor: AppColors.error.withValues(alpha: 0.28),
                focusColor: AppColors.error.withValues(alpha: 0.08),
                overlayColor: AppColors.error.withValues(alpha: 0.08),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
