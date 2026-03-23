import 'package:palakat_shared/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/theme.dart';

class CardChurch extends StatelessWidget {
  const CardChurch({super.key, required this.church, required this.onPressed});

  final Church church;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.surfaceContainerLowest,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
            border: Border.all(color: AppColors.ghostBorder(0.08)),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.church_rounded,
                    size: 20.0,
                    color: AppColors.primary,
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        church.name,
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((church.location?.name ?? '').trim().isNotEmpty) ...[
                        Gap.h4,
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14.0,
                              color: AppColors.onSurfaceVariant,
                            ),
                            Gap.w4,
                            Expanded(
                              child: Text(
                                church.location!.name,
                                style: theme.textTheme.labelMedium!.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Gap.w12,
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.0,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
