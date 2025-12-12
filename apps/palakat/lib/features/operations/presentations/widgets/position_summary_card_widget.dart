import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/member_position.dart';
import 'package:palakat_shared/core/models/membership.dart';

/// Position summary card displaying user's current positions and role count.
/// Uses the unified teal color system with neutral backgrounds.
/// Tappable to navigate to membership details.
///
/// Requirements: 2.1, 3.1, 3.2
class PositionSummaryCard extends StatelessWidget {
  const PositionSummaryCard({
    super.key,
    required this.membership,
    required this.accountName,
    this.onTap,
  });

  final Membership membership;
  final String accountName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      // Neutral surface color for card background (Requirement 3.2)
      color: BaseColor.surfaceMedium,
      elevation: 1,
      shadowColor: BaseColor.shadow.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.primary[50],
      // 16px border radius (Requirement 3.3)
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          // 8px grid spacing - 16px = 2 * 8px (Requirement 3.4)
          padding: EdgeInsets.all(BaseSize.w16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with icon and count badge
              _PositionSummaryHeader(
                membership: membership,
                accountName: accountName,
              ),
              Gap.h16,
              // Position chips with consistent styling
              _PositionChipsList(positions: membership.membershipPositions),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header section with icon, title, and position count badge
class _PositionSummaryHeader extends StatelessWidget {
  const _PositionSummaryHeader({
    required this.membership,
    required this.accountName,
  });

  final Membership membership;
  final String accountName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon container with teal accent (Requirement 3.1)
        Container(
          width: BaseSize.w40,
          height: BaseSize.w40,
          decoration: BoxDecoration(
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
            color: BaseColor.primary[700],
          ),
        ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                accountName,
                style: BaseTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: BaseColor.textPrimary,
                ),
              ),
              Text(
                membership.church?.name ?? 'Your Positions',
                style: BaseTypography.bodyMedium.copyWith(
                  color: BaseColor.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// List of position chips with consistent styling
class _PositionChipsList extends StatelessWidget {
  const _PositionChipsList({required this.positions});

  final List<MemberPosition> positions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      // 8px grid spacing (Requirement 3.4)
      spacing: BaseSize.w8,
      runSpacing: BaseSize.h8,
      children: positions.map((pos) {
        return _PositionChip(title: pos.name);
      }).toList(),
    );
  }
}

/// Individual position chip with teal styling
class _PositionChip extends StatelessWidget {
  const _PositionChip({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      // 8px grid spacing - 8px horizontal, 4px vertical (Requirement 3.4)
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w8,
        vertical: BaseSize.h4,
      ),
      decoration: BoxDecoration(
        // Teal accent color at low opacity (Requirement 3.1)
        color: BaseColor.primary[700]!.withValues(alpha: 0.08),
        border: Border.all(
          color: BaseColor.primary[700]!.withValues(alpha: 0.24),
          width: 1,
        ),
        // 8px border radius for chips (Design spec)
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: BaseTypography.labelMedium.copyWith(
          color: BaseColor.primary[700],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
