import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';

/// Report button widget using the monochromatic teal color system.
/// Uses teal palette variations for accent colors and semantic colors appropriately.
/// Requirements: 1.1, 1.3
class ReportButtonWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final ReportButtonType type;
  final bool isLoading;
  final VoidCallback? onPressed;

  const ReportButtonWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.type = ReportButtonType.primary,
    this.isLoading = false,
    this.onPressed,
  });

  /// Get the accent color based on button type using teal palette variations
  Color get _accentColor {
    switch (type) {
      case ReportButtonType.primary:
        return AppColors.primary; // Main teal
      case ReportButtonType.secondary:
        return AppColors.primary; // Dark teal
      case ReportButtonType.info:
        return AppColors.primary; // Info teal variant
      case ReportButtonType.warning:
        return AppColors.warning; // Semantic warning
      case ReportButtonType.error:
        return AppColors.error; // Semantic error (red for accessibility)
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return Material(
      color: AppColors.surfaceContainerLow, // Neutral surface color
      elevation: 1,
      shadowColor: AppColors.tertiary.withValues(alpha: 0.05),
      surfaceTintColor: _accentColor.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.ghostBorder(0.08)),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        splashColor: AppColors.primary.withValues(alpha: 0.3),
        highlightColor: AppColors.primary.withValues(alpha: 0.5),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon Container with teal-based styling
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _accentColor.withValues(alpha: 0.24),
                  ),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 10),
                ),
                alignment: Alignment.center,
                child: isLoading
                    ? CompactLoadingWidget(
                        size: 18.0,
                        baseColor: _accentColor.withValues(alpha: 0.24),
                        highlightColor: AppColors.surface,
                      )
                    : Icon(icon, color: _accentColor, size: 24.0),
              ),

              Gap.w16,

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDisabled
                            ? AppColors.onSurfaceVariant
                            : AppColors.onSurface,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      isLoading ? 'Processing...' : description,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Gap.w8,

              // Arrow Icon
              if (!isLoading)
                Icon(
                  AppIcons.forward,
                  color: isDisabled
                      ? AppColors.onSurface.withValues(alpha: 0.38)
                      : AppColors.onSurfaceVariant,
                  size: 24.0,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Button type enum for semantic color variations
enum ReportButtonType {
  /// Primary teal color (default)
  primary,

  /// Dark teal variant
  secondary,

  /// Info teal variant
  info,

  /// Warning amber color
  warning,

  /// Error red color (for accessibility)
  error,
}
