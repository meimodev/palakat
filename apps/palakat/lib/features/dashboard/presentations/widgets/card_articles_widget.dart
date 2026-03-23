import 'package:flutter/material.dart';
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
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: AppColors.ghostBorder(0.08)),
          boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 12),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 12.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium!),
            Gap.h6,
            Wrap(
              runSpacing: 6.0,
              direction: Axis.horizontal,
              children: [...categories.map((e) => ChipsWidget(title: e))],
            ),
          ],
        ),
      ),
    );
  }
}
