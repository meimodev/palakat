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
      color: BaseColor.red[50],
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      surfaceTintColor: BaseColor.red[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
        side: BorderSide(color: BaseColor.red[200]!, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: BaseSize.w36,
                  height: BaseSize.w36,
                  decoration: BoxDecoration(
                    color: BaseColor.red[100],
                    borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: BaseColor.red[200]!.withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    AppIcons.error,
                    size: BaseSize.w16,
                    color: BaseColor.red[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    message,
                    style: BaseTypography.bodyMedium.copyWith(
                      color: BaseColor.red[800],
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
                textColor: BaseColor.red[700]!,
                outlineColor: BaseColor.red[300]!,
                focusColor: BaseColor.red[100]!,
                overlayColor: BaseColor.red[50]!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
