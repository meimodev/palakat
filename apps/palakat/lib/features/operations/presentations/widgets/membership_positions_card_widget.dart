import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

/// Membership positions card widget using the monochromatic teal color system.
/// Displays user's positions with consistent styling.
/// Requirements: 3.2, 3.3
class MembershipPositionsCardWidget extends StatelessWidget {
  const MembershipPositionsCardWidget({super.key, required this.membership});

  final Membership membership;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      // Neutral surface color for card background (Requirement 3.2)
      color: Colors.transparent,
      elevation: 0,
      // Subtle shadow for depth (Requirement 3.3)
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        // 16px border radius (Requirement 3.3)
        borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
        side: BorderSide(color: AppColors.ghostBorder(0.08)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 20),
        ),
        child: Padding(
          // 16px padding = 2 * 8px grid (Requirement 3.4)
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with icon and count badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      // Primary teal light shade for icon background
                      color: AppColors.surfaceContainerLow,
                      border: Border.all(color: AppColors.ghostBorder(0.06)),
                      borderRadius: BorderRadius.circular(
                        SanctuaryLayout.radius,
                      ),
                      boxShadow: SanctuaryDepth.ambient(
                        opacity: 0.02,
                        blur: 10,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      AppIcons.badge,
                      size: 18.0,
                      // Primary teal dark shade for icon
                      color: AppColors.primary,
                    ),
                  ),
                  Gap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.tbl_positions,
                          style: theme.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Gap.h4,
                        Text(
                          membership.church?.name ?? 'Membership positions',
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Gap.w12,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      border: Border.all(color: AppColors.ghostBorder(0.06)),
                      borderRadius: BorderRadius.circular(
                        SanctuaryLayout.radius,
                      ),
                      boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
                    ),
                    child: Text(
                      membership.membershipPositions.length.toString(),
                      style: theme.textTheme.labelMedium!.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              Gap.h16,
              // Position chips with 8px spacing (Requirement 3.4)
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: membership.membershipPositions.map((pos) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(
                        SanctuaryLayout.radius,
                      ),
                      border: Border.all(color: AppColors.ghostBorder(0.08)),
                      boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
                    ),
                    child: Text(
                      pos.name,
                      style: theme.textTheme.labelMedium!.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
