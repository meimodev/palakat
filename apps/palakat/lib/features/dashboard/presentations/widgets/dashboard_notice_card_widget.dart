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
      shadowColor: AppColors.primary.withValues(alpha: 0.05),
      surfaceTintColor: palette.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: palette.border, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: palette.iconBackground,
                    border: Border.all(
                      color: palette.icon.withValues(alpha: 0.24),
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 18.0, color: palette.icon),
                ),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap.h4,
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.35,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
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
                  backgroundColor: palette.action.withValues(alpha: 0.08),
                  foregroundColor: palette.action,
                  side: BorderSide(color: palette.actionBorder),
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: palette.action,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          surface: AppColors.warning.shade50,
          surfaceTint: AppColors.warning.shade100,
          border: AppColors.warning.shade200,
          iconBackground: AppColors.warning.shade100,
          iconShadow: AppColors.warning.shade200,
          icon: AppColors.warning.shade700,
          action: AppColors.warning.shade800,
          actionBorder: AppColors.warning.shade300,
        );
      case DashboardNoticeTone.success:
        return _DashboardNoticePalette(
          surface: AppColors.success.shade50,
          surfaceTint: AppColors.success.shade100,
          border: AppColors.success.shade200,
          iconBackground: AppColors.success.shade100,
          iconShadow: AppColors.success.shade200,
          icon: AppColors.success.shade700,
          action: AppColors.success.shade800,
          actionBorder: AppColors.success.shade300,
        );
      case DashboardNoticeTone.danger:
        return _DashboardNoticePalette(
          surface: AppColors.error.shade50,
          surfaceTint: AppColors.error.shade100,
          border: AppColors.error.shade200,
          iconBackground: AppColors.error.shade100,
          iconShadow: AppColors.error.shade200,
          icon: AppColors.error.shade700,
          action: AppColors.error.shade800,
          actionBorder: AppColors.error.shade300,
        );
      case DashboardNoticeTone.primary:
        return _DashboardNoticePalette(
          surface: AppColors.secondary.shade50,
          surfaceTint: AppColors.secondary.shade100,
          border: AppColors.secondary.shade200,
          iconBackground: AppColors.secondary.shade100,
          iconShadow: AppColors.secondary.shade200,
          icon: AppColors.secondary.shade700,
          action: AppColors.secondary.shade800,
          actionBorder: AppColors.secondary.shade300,
        );
    }
  }
}
