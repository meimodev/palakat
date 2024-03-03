import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

class CardSongSnippetListItemWidget extends StatelessWidget {
  const CardSongSnippetListItemWidget({
    super.key,
    required this.title,
    required this.snippet,
    required this.onPressed,
  });

  final String title;
  final String snippet;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w12,
          vertical: BaseSize.w12,
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
              style: BaseTypography.bodySmall.toBold,
            ),
            Text(snippet, style: BaseTypography.bodyMedium)
          ],
        ),
      ),
    );
  }
}
