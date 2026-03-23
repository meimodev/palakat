import 'package:palakat_shared/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:palakat_shared/core/models/column.dart' as model;
import 'package:palakat_shared/theme.dart';

class CardColumn extends StatelessWidget {
  const CardColumn({super.key, required this.column, required this.onPressed});

  final model.Column column;
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
                    Icons.account_tree_rounded,
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
                        column.name,
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap.h4,
                      Row(
                        children: [
                          Icon(
                            Icons.tag_rounded,
                            size: 14.0,
                            color: AppColors.onSurfaceVariant,
                          ),
                          Gap.w4,
                          Expanded(
                            child: Text(
                              'Column ${column.id}',
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
