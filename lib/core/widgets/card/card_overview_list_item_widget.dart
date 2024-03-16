import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';

class CardOverviewListItemWidget extends StatelessWidget {
  const CardOverviewListItemWidget({
    super.key,
    required this.title,
    required this.type,
    required this.onPressedCard,
  });

  final String title;
  final VoidCallback onPressedCard;
  final ActivityType type;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressedCard,
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: BaseTypography.bodySmall,
            ),
            ChipsWidget(
              title: type.name,
            ),
          ],
        ),
      ),
    );
  }
}
