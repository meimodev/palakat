import 'package:palakat_shared/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:palakat_shared/constants.dart';
import 'package:palakat_shared/theme.dart';

class CardBipra extends StatelessWidget {
  const CardBipra({
    super.key,
    required this.bipra,
    required this.onPressed,
    this.columnName,
  });

  final Bipra bipra;
  final VoidCallback onPressed;
  final String? columnName;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      elevation: 2,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: Theme.of(context).colorScheme.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Abbreviation in gradient circle
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  bipra.abv,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: AppColors.surfaceContainerLowest,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Gap.w16,
              // Bipra name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (columnName != null && columnName!.isNotEmpty)
                          ? '${bipra.name} (${columnName!})'
                          : bipra.name,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Gap.w8,
              // Arrow indicator
              Icon(
                Icons.chevron_right,
                size: 24.0,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
