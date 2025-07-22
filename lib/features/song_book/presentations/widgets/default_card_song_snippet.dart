import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';

class DefaultCardSongSnippet extends StatelessWidget {
  const DefaultCardSongSnippet({
    super.key,
    required this.title,
    required this.searchQuery,
    required this.onPressed,
  });

  final String title;
  final String searchQuery;
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (title.isNotEmpty) ...[
              Text(
                title,
                style: BaseTypography.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
