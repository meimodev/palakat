import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';

class CardArticlesWidget extends StatelessWidget {
  const CardArticlesWidget({
    super.key,
    required this.title,
    required this.onPressedCard,
    required this.categories,
  });

  final String title;
  final VoidCallback onPressedCard;
  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressedCard,
      child: Container(
        decoration: BoxDecoration(
          color: BaseColor.cardBackground1,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w12,
          vertical: BaseSize.h12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: BaseTypography.bodySmall,
            ),
            Gap.h6,
            Wrap(
              runSpacing: BaseSize.h6,
              direction: Axis.horizontal,
              children: [
                ...categories
                    .map(
                      (e) => ChipsWidget(
                        title: e,
                        icon: Assets.icons.line.trash,
                      ),
                    )
                    .toList(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
