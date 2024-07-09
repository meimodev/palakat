import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart' hide Column;
import 'package:palakat/core/utils/utils.dart';

class CardChurch extends StatelessWidget {
  const CardChurch({
    super.key,
    required this.church,
    required this.onPressed,
  });

  final Church church;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: BaseColor.cardBackground1,
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.all(
            BaseSize.w12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                church.name,
                style: BaseTypography.titleMedium.bold,
              ),
              Text(
                church.location?.name ?? "",
                style: BaseTypography.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
