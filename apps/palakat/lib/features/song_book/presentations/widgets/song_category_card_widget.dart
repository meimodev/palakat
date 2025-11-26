import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/song_book/data/song_category_model.dart';
import 'package:palakat/features/song_book/presentations/widgets/song_item_card_widget.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

/// Collapsible category card that groups songs by hymnal type.
/// Uses the same visual pattern as OperationCategoryCard.
///
/// Requirements: 1.1, 1.4, 2.1, 2.2
class SongCategoryCard extends StatelessWidget {
  const SongCategoryCard({
    super.key,
    required this.category,
    required this.songs,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.onSongTap,
  });

  /// The category data to display
  final SongCategory category;

  /// List of songs in this category
  final List<Song> songs;

  /// Whether this category is currently expanded
  /// Requirements: 7.1, 7.3 - Expansion state managed externally
  final bool isExpanded;

  /// Callback when the category expansion state changes
  final ValueChanged<bool> onExpansionChanged;

  /// Callback when a song item is tapped
  final ValueChanged<Song> onSongTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BaseColor.surfaceMedium,
        borderRadius: BorderRadius.circular(BaseSize.w16),
        boxShadow: [
          BoxShadow(
            color: BaseColor.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category header with expand/collapse functionality
          _CategoryHeader(
            category: category,
            songCount: songs.length,
            isExpanded: isExpanded,
            onTap: () => onExpansionChanged(!isExpanded),
          ),

          // Song items - only visible when expanded
          AnimatedCrossFade(
            firstChild: _buildSongsList(songs),
            secondChild: const SizedBox.shrink(),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList(List<Song> songs) {
    if (songs.isEmpty) {
      return _CategoryEmptyState();
    }

    return Padding(
      // 8px grid spacing (Requirement 2.4)
      padding: EdgeInsets.only(
        left: BaseSize.w8,
        right: BaseSize.w8,
        bottom: BaseSize.w8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: songs
            .map(
              (song) => Padding(
                // 8px grid spacing (Requirement 2.4)
                padding: EdgeInsets.only(bottom: BaseSize.w8),
                child: SongItemCard(song: song, onTap: () => onSongTap(song)),
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Empty state widget for category with no songs
/// Requirements: 1.5, 2.2 - Consistent styling with Operations screen
class _CategoryEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // 16px = 2 * 8px grid spacing (Requirement 2.4)
      padding: EdgeInsets.all(BaseSize.w16),
      margin: EdgeInsets.all(BaseSize.w8),
      decoration: BoxDecoration(
        color: BaseColor.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BaseColor.neutral[200]!, width: 1),
      ),
      child: Row(
        children: [
          // Teal accent icon (Requirement 2.2)
          Container(
            width: BaseSize.w32,
            height: BaseSize.w32,
            decoration: BoxDecoration(
              color: BaseColor.primary[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.music_off_outlined,
              size: BaseSize.w16,
              color: BaseColor.primary,
            ),
          ),
          Gap.w12,
          Expanded(
            child: Text(
              'No songs available in this category',
              style: BaseTypography.bodyMedium.copyWith(
                color: BaseColor.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Category header with icon, title, song count badge, and expand/collapse indicator
class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.category,
    required this.songCount,
    required this.isExpanded,
    required this.onTap,
  });

  final SongCategory category;
  final int songCount;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaseColor.primary[50],
      child: InkWell(
        onTap: onTap,
        splashColor: BaseColor.primary.withValues(alpha: 0.1),
        highlightColor: BaseColor.primary.withValues(alpha: 0.05),
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w16),
          child: Row(
            children: [
              // Category icon
              Container(
                width: BaseSize.w40,
                height: BaseSize.w40,
                decoration: BoxDecoration(
                  color: BaseColor.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(BaseSize.w12),
                ),
                child: Icon(
                  category.icon,
                  color: BaseColor.primary,
                  size: BaseSize.w24,
                ),
              ),
              Gap.w12,
              // Category title and abbreviation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.abbreviation,
                      style: BaseTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BaseColor.textPrimary,
                      ),
                    ),
                    Text(
                      category.title,
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Song count badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSize.w8,
                  vertical: BaseSize.w4,
                ),
                decoration: BoxDecoration(
                  color: BaseColor.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(BaseSize.w12),
                ),
                child: Text(
                  '$songCount',
                  style: BaseTypography.labelSmall.copyWith(
                    color: BaseColor.primary[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Expand/collapse icon with animation
              Gap.w8,
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: BaseColor.primary,
                  size: BaseSize.w24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
