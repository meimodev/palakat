import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

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
    final bool signed = account != null;
    final membership = account?.membership;

    return Material(
      clipBehavior: Clip.hardEdge,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: signed ? BaseColor.teal[50] : null,
      color: signed ? BaseColor.teal[50] : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: signed
            ? BorderSide(
                width: 1,
                color: BaseColor.teal[100] ?? BaseColor.neutral20,
              )
            : BorderSide.none,
      ),
      child: Container(
        decoration: signed
            ? null
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [BaseColor.blue[600]!, BaseColor.teal[500]!],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
        child: InkWell(
          onTap: onPressedCard,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: BaseSize.w16,
              vertical: BaseSize.h16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (signed)
                      Container(
                        width: BaseSize.w40,
                        height: BaseSize.w40,
                        decoration: BoxDecoration(
                          color: BaseColor.teal[100] ?? BaseColor.neutral20,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (BaseColor.teal[200] ?? BaseColor.neutral40)
                                      .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.church_outlined,
                          size: BaseSize.w20,
                          color: BaseColor.teal[700] ?? BaseColor.primaryText,
                        ),
                      ),
                    if (signed) Gap.w12,
                    if (signed && onSignOut != null)
                      IconButton(
                        onPressed: onSignOut,
                        icon: Icon(
                          Icons.logout,
                          size: BaseSize.w20,
                          color: BaseColor.red[600],
                        ),
                        tooltip: 'Sign Out',
                        style: IconButton.styleFrom(
                          backgroundColor: BaseColor.red[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    if (signed && onSignOut != null) Gap.w8,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: signed
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        mainAxisAlignment: signed
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          if (signed) ...[
                            Text(
                              account?.name ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: BaseTypography.titleLarge.copyWith(
                                color: BaseColor.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (membership?.church?.name != null) ...[
                              Gap.h4,
                              Text(
                                membership!.church!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: BaseTypography.bodyMedium.copyWith(
                                  color: BaseColor.secondaryText,
                                ),
                              ),
                            ],
                          ] else ...[
                            Icon(
                              Icons.waving_hand,
                              size: BaseSize.w32,
                              color: Colors.white,
                            ),
                            Gap.h8,
                            Text(
                              'Welcome!',
                              style: BaseTypography.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Gap.h4,
                            Text(
                              'Sign in to see your congregation information',
                              style: BaseTypography.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (signed) Gap.h16,
                // Footer: chips or CTA
                if (signed)
                  Row(
                    children: [
                      _pillChip(
                        icon: Icons.group_outlined,
                        label: (account?.calculateBipra.name ?? '').isEmpty
                            ? 'Not Set'
                            : (account?.calculateBipra.name ?? ''),
                        bg: BaseColor.teal[50] ?? BaseColor.neutral20,
                        fg: BaseColor.teal[700] ?? BaseColor.primaryText,
                        border: BaseColor.teal[200] ?? BaseColor.neutral40,
                      ),
                      Gap.w8,
                      _pillChip(
                        icon: Icons.location_city_outlined,
                        label: membership?.column?.name != null
                            ? 'Column ${membership!.column!.name}'
                            : 'Not Set',
                        bg: BaseColor.teal[50] ?? BaseColor.neutral20,
                        fg: BaseColor.teal[700] ?? BaseColor.primaryText,
                        border: BaseColor.teal[200] ?? BaseColor.neutral40,
                      ),
                    ],
                  )
                else ...[
                  Gap.h16,
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: onPressedCard,
                      icon: const Icon(Icons.login, size: 20),
                      label: Text(
                        'Sign In',
                        style: BaseTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: BaseColor.blue[700],
                        elevation: 4,
                        shadowColor: Colors.black.withValues(alpha: 0.2),
                        padding: EdgeInsets.symmetric(
                          horizontal: BaseSize.w32,
                          vertical: BaseSize.h12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
  required IconData icon,
  required String label,
  required Color bg,
  required Color fg,
  required Color border,
}) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: BaseSize.w10,
      vertical: BaseSize.h6,
    ),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(BaseSize.radiusSm),
      border: Border.all(color: border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: BaseSize.w12, color: fg),
        Gap.w6,
        Text(label, style: BaseTypography.labelMedium.copyWith(color: fg)),
      ],
    ),
  );
}
