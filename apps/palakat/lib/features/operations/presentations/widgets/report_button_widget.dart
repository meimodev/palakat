import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

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
        return BaseColor.primary[500]!; // Main teal
      case ReportButtonType.secondary:
        return BaseColor.primary[700]!; // Dark teal
      case ReportButtonType.info:
        return BaseColor.info; // Info teal variant
      case ReportButtonType.warning:
        return BaseColor.warning; // Semantic warning
      case ReportButtonType.error:
        return BaseColor.error; // Semantic error (red for accessibility)
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return Material(
      color: BaseColor.surfaceMedium, // Neutral surface color
      elevation: 1,
      shadowColor: BaseColor.neutral90.withValues(alpha: 0.05),
      surfaceTintColor: _accentColor.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        splashColor: BaseColor.primary[100]!.withValues(alpha: 0.3),
        highlightColor: BaseColor.primary[50]!.withValues(alpha: 0.5),
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Row(
            children: [
              // Icon Container with teal-based styling
              Container(
                width: BaseSize.w48,
                height: BaseSize.w48,
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          width: BaseSize.w20,
                          height: BaseSize.w20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _accentColor,
                            ),
                          ),
                        ),
                      )
                    : Icon(icon, color: _accentColor, size: BaseSize.w24),
              ),

              Gap.w16,

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: BaseTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDisabled
                            ? BaseColor.textSecondary
                            : BaseColor.textPrimary,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      isLoading ? 'Processing...' : description,
                      style: BaseTypography.bodyMedium.copyWith(
                        color: BaseColor.textSecondary,
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
                  Icons.chevron_right,
                  color: isDisabled
                      ? BaseColor.textDisabled
                      : BaseColor.textSecondary,
                  size: BaseSize.w24,
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
