import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

class DashboardNoticeCardWidget extends StatelessWidget {
  const DashboardNoticeCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onPressedAction,
    this.tone = DashboardNoticeTone.primary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onPressedAction;
  final DashboardNoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = _DashboardNoticePalette.fromTone(tone);

    return Material(
      color: palette.surface,
      elevation: 1,
      shadowColor: BaseColor.black.withValues(alpha: 0.05),
      surfaceTintColor: palette.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
        side: BorderSide(color: palette.border, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: BoxDecoration(
                    color: palette.iconBackground,
                    borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: palette.iconShadow.withValues(alpha: 0.24),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: BaseSize.w18, color: palette.icon),
                ),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: BaseTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: BaseColor.primaryText,
                        ),
                      ),
                      Gap.h4,
                      Text(
                        message,
                        style: BaseTypography.bodySmall.copyWith(
                          color: BaseColor.secondaryText,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (actionLabel != null) ...[
              Gap.h12,
              OutlinedButton(
                onPressed: onPressedAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.action,
                  side: BorderSide(color: palette.actionBorder),
                  padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: BaseTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: palette.action,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum DashboardNoticeTone { primary, warning, success, danger }

class _DashboardNoticePalette {
  const _DashboardNoticePalette({
    required this.surface,
    required this.surfaceTint,
    required this.border,
    required this.iconBackground,
    required this.iconShadow,
    required this.icon,
    required this.action,
    required this.actionBorder,
  });

  final Color surface;
  final Color surfaceTint;
  final Color border;
  final Color iconBackground;
  final Color iconShadow;
  final Color icon;
  final Color action;
  final Color actionBorder;

  factory _DashboardNoticePalette.fromTone(DashboardNoticeTone tone) {
    switch (tone) {
      case DashboardNoticeTone.warning:
        return _DashboardNoticePalette(
          surface: BaseColor.yellow[50]!,
          surfaceTint: BaseColor.yellow[50]!,
          border: BaseColor.yellow[200]!,
          iconBackground: BaseColor.yellow[100]!,
          iconShadow: BaseColor.yellow[300]!,
          icon: BaseColor.yellow[800]!,
          action: BaseColor.yellow[800]!,
          actionBorder: BaseColor.yellow[300]!,
        );
      case DashboardNoticeTone.success:
        return _DashboardNoticePalette(
          surface: BaseColor.green[50]!,
          surfaceTint: BaseColor.green[50]!,
          border: BaseColor.green[200]!,
          iconBackground: BaseColor.green[100]!,
          iconShadow: BaseColor.green[300]!,
          icon: BaseColor.green[700]!,
          action: BaseColor.green[700]!,
          actionBorder: BaseColor.green[300]!,
        );
      case DashboardNoticeTone.danger:
        return _DashboardNoticePalette(
          surface: BaseColor.red[50]!,
          surfaceTint: BaseColor.red[50]!,
          border: BaseColor.red[200]!,
          iconBackground: BaseColor.red[100]!,
          iconShadow: BaseColor.red[300]!,
          icon: BaseColor.red[700]!,
          action: BaseColor.red[700]!,
          actionBorder: BaseColor.red[300]!,
        );
      case DashboardNoticeTone.primary:
        return _DashboardNoticePalette(
          surface: BaseColor.teal[50]!,
          surfaceTint: BaseColor.teal[50]!,
          border: BaseColor.teal[200]!,
          iconBackground: BaseColor.teal[100]!,
          iconShadow: BaseColor.teal[300]!,
          icon: BaseColor.teal[700]!,
          action: BaseColor.teal[700]!,
          actionBorder: BaseColor.teal[300]!,
        );
    }
  }
}
