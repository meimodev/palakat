import 'package:flutter/material.dart';
import 'package:palakat_shared/core/models/column.dart' as model;
import 'package:palakat_shared/theme.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    Text(
                      'Column ${column.id}',
                      style: BaseTypography.labelMedium.copyWith(
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
      ),
    );
  }
}
