import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_admin/core/models/column.dart' as model;

class CardColumn extends StatelessWidget {
  const CardColumn({super.key, required this.column, required this.onPressed});

  final model.Column column;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Row(
            children: [
              // Column icon
              Container(
                width: BaseSize.w40,
                height: BaseSize.w40,
                decoration: BoxDecoration(
                  color: BaseColor.blue[100],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: BaseColor.blue[200]!.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.location_city_outlined,
                  size: BaseSize.w20,
                  color: BaseColor.blue[700],
                ),
              ),
              Gap.w16,
              // Column info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      column.name,
                      style: BaseTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: BaseColor.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap.h6,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: BaseSize.w8,
                        vertical: BaseSize.h4,
                      ),
                      decoration: BoxDecoration(
                        color: BaseColor.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: BaseColor.blue[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tag,
                            size: BaseSize.w12,
                            color: BaseColor.blue[700],
                          ),
                          Gap.w4,
                          Text(
                            'Column ${column.id}',
                            style: BaseTypography.labelSmall.copyWith(
                              color: BaseColor.blue[700],
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
