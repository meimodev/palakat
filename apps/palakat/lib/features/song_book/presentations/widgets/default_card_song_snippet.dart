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
    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.red[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.library_music_outlined,
                size: BaseSize.w24,
                color: BaseColor.red[600],
              ),
              Gap.h4,
              if (title.isNotEmpty) ...[
                Text(
                  title,
                  style: BaseTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: BaseColor.black,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
