import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart' as model;
import 'package:palakat/core/utils/utils.dart';

class CardColumn extends StatelessWidget {
  const CardColumn({super.key, required this.column, required this.onPressed});

  final model.Column column;
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
          padding: EdgeInsets.all(BaseSize.w12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(column.name, style: BaseTypography.titleMedium.bold),
            ],
          ),
        ),
      ),
    );
  }
}
