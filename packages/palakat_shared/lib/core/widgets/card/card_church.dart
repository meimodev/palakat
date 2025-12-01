import 'package:flutter/material.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/theme.dart';

class CardChurch extends StatelessWidget {
  const CardChurch({super.key, required this.church, required this.onPressed});

  final Church church;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.teal[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Row(
            children: [
              // Church icon
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
                  Icons.church_outlined,
                  size: BaseSize.w20,
                  color: BaseColor.teal[700],
                ),
              ),
              Gap.w16,
              // Church info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      church.name,
                      style: BaseTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: BaseColor.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      church.location?.name ?? '',
                      style: BaseTypography.labelMedium.copyWith(
                        color: BaseColor.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
