import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

/// Individual song card with icon, title, and subtitle.
/// Uses the same visual pattern as OperationItemCard.
///
/// Requirements: 2.3, 4.1, 4.2, 4.4
class SongItemCard extends StatelessWidget {
  const SongItemCard({super.key, required this.song, required this.onTap});

  /// The song data to display
  final Song song;

  /// Callback when the card is tapped
  final VoidCallback onTap;

  /// Border radius for the card (12px as per design spec)
  static const double borderRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaseColor.surfaceLight,
      elevation: 0,
      shadowColor: BaseColor.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: BaseColor.neutral[200]!, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        // Ripple effect with primary color at 10% opacity (Requirement 4.1)
        splashColor: BaseColor.primary.withValues(alpha: 0.1),
        highlightColor: BaseColor.primary.withValues(alpha: 0.05),
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w12),
          child: Row(
            children: [
              // Song icon container
              _SongIcon(),
              Gap.w12,
              // Title and subtitle
              Expanded(
                child: _SongContent(title: song.title, subtitle: song.subTitle),
              ),
              Gap.w8,
              // Chevron indicator
              Icon(
                Icons.chevron_right,
                color: BaseColor.textSecondary,
                size: BaseSize.w24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon container for the song card
class _SongIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: BaseSize.w48,
      height: BaseSize.w48,
      decoration: BoxDecoration(
        color: BaseColor.primary[50],
        borderRadius: BorderRadius.circular(BaseSize.w12),
      ),
      child: Icon(
        Icons.music_note,
        color: BaseColor.primary,
        size: BaseSize.w24,
      ),
    );
  }
}

/// Content section with title and subtitle
class _SongContent extends StatelessWidget {
  const _SongContent({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title (e.g., "KJ NO.1")
        Text(
          title,
          style: BaseTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: BaseColor.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Gap.h4,
        // Subtitle (song name)
        Text(
          subtitle,
          style: BaseTypography.bodySmall.copyWith(
            color: BaseColor.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
