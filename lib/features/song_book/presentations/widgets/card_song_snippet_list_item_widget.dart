import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

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
          padding: EdgeInsets.all(BaseSize.w16),
          child: Row(
            children: [
              // Music note icon
              Container(
                width: BaseSize.w40,
                height: BaseSize.w40,
                decoration: BoxDecoration(
                  color: BaseColor.red[100],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: BaseColor.red[200]!.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.music_note,
                  size: BaseSize.w20,
                  color: BaseColor.red[700],
                ),
              ),
              Gap.w16,
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: BaseTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: BaseColor.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Gap.h4,
                    Text(
                      snippet,
                      style: BaseTypography.bodyMedium.copyWith(
                        color: BaseColor.secondaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Gap.w8,
              // Arrow icon
              Icon(
                Icons.chevron_right,
                size: BaseSize.w24,
                color: BaseColor.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
