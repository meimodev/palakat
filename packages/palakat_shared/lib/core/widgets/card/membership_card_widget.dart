import 'package:flutter/material.dart';
import 'package:palakat_shared/core/theme/theme.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/theme.dart';

class MembershipCardWidget extends StatelessWidget {
  const MembershipCardWidget({
    super.key,
    required this.onPressedCard,
    this.account,
    this.onSignOut,
  });

  final Account? account;
  final VoidCallback onPressedCard;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bool signed = account != null;
    final membership = account?.membership;
    final theme = Theme.of(context);
    final bipraLabel = (account?.calculateBipra.name ?? '').isEmpty
        ? l10n.membershipCard_notSet
        : (account?.calculateBipra.name ?? '');
    final columnLabel = membership?.column?.name != null
        ? l10n.membershipCard_column(membership!.column!.name)
        : l10n.membershipCard_notSet;

    return Material(
      clipBehavior: Clip.hardEdge,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
        side: BorderSide(color: AppColors.ghostBorder(0.08)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: signed
              ? AppColors.surfaceContainerLowest
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          boxShadow: SanctuaryDepth.ambient(opacity: 0.035, blur: 22),
        ),
        child: InkWell(
          onTap: onPressedCard,
          borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: signed ? 44.0 : 52.0,
                      height: signed ? 44.0 : 52.0,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          signed
                              ? SanctuaryLayout.radius
                              : SanctuaryLayout.radiusLarge,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        signed
                            ? Icons.badge_rounded
                            : Icons.waving_hand_rounded,
                        size: signed ? 20.0 : 24.0,
                        color: AppColors.primary,
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            signed ? (account?.name ?? '') : l10n.membershipCard_welcome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge!.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Gap.h4,
                          Text(
                            signed
                                ? (membership?.church?.name ??
                                      l10n.membershipCard_pending)
                                : l10n.membershipCard_signedOutSubtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (signed && onSignOut != null) ...[
                      Gap.w12,
                      IconButton(
                        onPressed: onSignOut,
                        icon: Icon(
                          Icons.logout_rounded,
                          size: 18.0,
                          color: AppColors.error,
                        ),

                        tooltip: l10n.btn_signOut,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceContainerLow,
                          side: BorderSide(color: AppColors.ghostBorder(0.08)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              SanctuaryLayout.radius,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Gap.h16,
                if (signed)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          _pillChip(
                            context: context,
                            icon: Icons.group_outlined,
                            label: bipraLabel,
                          ),
                          _pillChip(
                            context: context,
                            icon: Icons.location_city_outlined,
                            label: columnLabel,
                          ),
                        ],
                      ),
                      Gap.h16,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 12.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(
                            SanctuaryLayout.radius,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_outward_rounded,
                              size: 18.0,
                              color: AppColors.primary,
                            ),
                            Gap.w10,
                            Expanded(
                              child: Text(
                                l10n.membershipCard_reviewDetails,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: onPressedCard,
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: Text(
                        l10n.btn_signIn,
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.0,
                          vertical: 12.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            SanctuaryLayout.radius,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Local helpers (kept in this file for reuse consistency with other widgets)
Widget _pillChip({
  required BuildContext context,
  required IconData icon,
  required String label,
}) {
  final theme = Theme.of(context);

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    decoration: BoxDecoration(
      color: AppColors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
      border: Border.all(color: AppColors.ghostBorder(0.08)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.0, color: AppColors.primary),
        Gap.w6,
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium!.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
