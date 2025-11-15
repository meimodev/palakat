import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

class MembershipPositionsCardWidget extends StatelessWidget {
  const MembershipPositionsCardWidget({super.key, required this.membership});

  final Membership membership;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.teal[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
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
                    color: BaseColor.teal[100],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BaseColor.teal[200]!.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.badge_outlined,
                    size: BaseSize.w20,
                    color: BaseColor.teal[700],
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    "Your Positions",
                    style: BaseTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: BaseColor.black,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: BaseSize.w10,
                    vertical: BaseSize.h4,
                  ),
                  decoration: BoxDecoration(
                    color: BaseColor.teal[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: BaseColor.teal[200]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    membership.membershipPositions.length.toString(),
                    style: BaseTypography.labelMedium.copyWith(
                      color: BaseColor.teal[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Gap.h16,
            // Position chips
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
