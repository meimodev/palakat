import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
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
      color: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      // 16px border radius (Requirement 3.3)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
        side: BorderSide(color: AppColors.ghostBorder(0.08)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          boxShadow: SanctuaryDepth.ambient(opacity: 0.03, blur: 20),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with icon and count badge
                _PositionSummaryHeader(
                  membership: membership,
                  accountName: accountName,
                ),
                Gap.h8,
                // Position chips with consistent styling
                _PositionChipsList(positions: membership.membershipPositions),
              ],
            ),
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
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon container with teal accent (Requirement 3.1)
        Container(
          width: 44.0,
          height: 44.0,
          decoration: BoxDecoration(
            color: AppColors.secondary.shade200,
            border: Border.all(color: AppColors.primary.shade400),
            borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
            boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 10),
          ),
          alignment: Alignment.center,
          child: Icon(AppIcons.badge, size: 18.0, color: AppColors.primary),
        ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                accountName,
                style: theme.textTheme.labelMedium!.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Gap.h2,
              Text(
                membership.church?.name ?? 'Your positions',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
      spacing: 8.0,
      runSpacing: 8.0,
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
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        // Teal accent color at low opacity (Requirement 3.1)
        color: AppColors.surfaceContainerHighest,
        border: Border.all(color: AppColors.ghostBorder(0.08), width: 1),
        // 8px border radius for chips (Design spec)
        borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
