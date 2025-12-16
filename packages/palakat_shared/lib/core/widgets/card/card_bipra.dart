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
      color: BaseColor.cardBackground1,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: BaseColor.teal[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Row(
            children: [
              // Abbreviation in gradient circle
              Container(
                width: BaseSize.w48,
                height: BaseSize.w48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [BaseColor.teal[400]!, BaseColor.teal[600]!],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: BaseColor.teal[300]!.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  bipra.abv,
                  style: BaseTypography.titleMedium.copyWith(
                    color: Colors.white,
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
                      style: BaseTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: BaseColor.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap.h4,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: BaseSize.w8,
                        vertical: BaseSize.h4,
                      ),
                      decoration: BoxDecoration(
                        color: BaseColor.teal[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: BaseColor.teal[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: BaseSize.w12,
                            color: BaseColor.teal[700],
                          ),
                          Gap.w4,
                          Text(
                            'Group',
                            style: BaseTypography.labelSmall.copyWith(
                              color: BaseColor.teal[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Gap.w8,
              // Arrow indicator
              Icon(
                Icons.chevron_right,
                size: BaseSize.w24,
                color: BaseColor.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
