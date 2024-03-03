import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';
import 'package:palakat/core/widgets/widgets.dart';

class CardOverviewPublishingListItemWidget extends StatelessWidget {
  const CardOverviewPublishingListItemWidget({
    super.key,
    required this.title,
    required this.type,
    required this.onPressedCard,
  });

  final String title;
  final VoidCallback onPressedCard;
  final String type;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressedCard,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: BaseSize.w12,
          horizontal: BaseSize.w12,
        ),
        decoration: BoxDecoration(
          color: BaseColor.cardBackground1,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: BaseTypography.bodySmall.bold,
            ),
            ChipsWidget(title: type, ),
          ],
        ),
      ),
    );
  }
}
