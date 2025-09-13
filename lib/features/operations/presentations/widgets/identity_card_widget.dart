import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart' hide Column;

class IdentityCardWidget extends StatelessWidget {
  const IdentityCardWidget({
    super.key,
    required this.membership,
    required this.onTap,
  });

  final Membership membership;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final initials = "a";

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(BaseSize.w8),
      child: InkWell(
        borderRadius: BorderRadius.circular(BaseSize.w8),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(BaseSize.w12),
          decoration: BoxDecoration(
            color: BaseColor.primary3, // Or another color from your theme
            borderRadius: BorderRadius.circular(BaseSize.w8),
            boxShadow: [
              BoxShadow(
                color: BaseColor.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: BaseSize.radiusMd,
                backgroundColor: BaseColor.white,
                child: Text(
                  initials,
                  style: BaseTypography.titleMedium.copyWith(
                    color: BaseColor.primary3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      membership.account?.name ?? "",
                      style: BaseTypography.bodyMedium.copyWith(
                        color: BaseColor.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      membership.positions.join(' • '),
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Gap.w8,
              Icon(
                Icons.chevron_right,
                color: BaseColor.white.withValues(alpha: 0.9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
