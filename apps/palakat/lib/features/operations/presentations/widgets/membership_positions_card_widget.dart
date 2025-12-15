import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
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
    return Material(
      // Neutral surface color for card background (Requirement 3.2)
      color: BaseColor.surfaceMedium,
      elevation: 1,
      // Subtle shadow for depth (Requirement 3.3)
      shadowColor: BaseColor.neutral90.withValues(alpha: 0.08),
      surfaceTintColor: BaseColor.primary[50],
      shape: RoundedRectangleBorder(
        // 16px border radius (Requirement 3.3)
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        // 16px padding = 2 * 8px grid (Requirement 3.4)
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with icon and count badge
            Row(
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: BoxDecoration(
                    // Primary teal light shade for icon background
                    color: BaseColor.primary[100],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BaseColor.primary[200]!.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    AppIcons.badge,
                    size: BaseSize.w20,
                    // Primary teal dark shade for icon
                    color: BaseColor.primary[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    context.l10n.tbl_positions,
                    style: BaseTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.textPrimary,
                    ),
                  ),
                ),
                // Position count badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: BaseSize.w10,
                    vertical: BaseSize.h4,
                  ),
                  decoration: BoxDecoration(
                    color: BaseColor.primary[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: BaseColor.primary[200]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    membership.membershipPositions.length.toString(),
                    style: BaseTypography.labelMedium.copyWith(
                      color: BaseColor.primary[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Gap.h16,
            // Position chips with 8px spacing (Requirement 3.4)
            Wrap(
              spacing: BaseSize.w8,
              runSpacing: BaseSize.h8,
              children: membership.membershipPositions.map((pos) {
                return ChipsWidget(title: pos.name);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
