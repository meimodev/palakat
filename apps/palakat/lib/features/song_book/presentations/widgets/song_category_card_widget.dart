import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/features/song_book/data/song_category_model.dart';
import 'package:palakat/features/song_book/presentations/widgets/song_item_card_widget.dart';
import 'package:palakat_shared/core/extension/extension.dart';
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
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.ghostBorder(0.08)),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 12),
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
        left: 8.0,
        right: 8.0,
        bottom: 8.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: songs
            .map(
              (song) => Padding(
                // 8px grid spacing (Requirement 2.4)
                padding: EdgeInsets.only(bottom: 12.0),
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
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceBright,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.ghostBorder(0.08), width: 1),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 12),
      ),
      child: Row(
        children: [
          // Teal accent icon (Requirement 2.2)
          Container(
            width: 32.0,
            height: 32.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
            ),
            child: FaIcon(
              AppIcons.musicOff,
              size: 16.0,
              color: AppColors.primary,
            ),
          ),
          Gap.w12,
          Expanded(
            child: Text(
              context.l10n.songBook_emptyTitle,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.onSurfaceVariant,
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
      color: AppColors.primary,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final shouldStackTrailing =
                  constraints.maxWidth < 360 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.1;
              final countBadge = Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 6),
                ),
                child: Text(
                  '$songCount',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
              final chevron = AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: FaIcon(
                  AppIcons.chevronDown,
                  color: AppColors.primary,
                  size: 24.0,
                ),
              );

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40.0,
                    height: 40.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                      boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 8),
                    ),
                    child: FaIcon(
                      category.icon,
                      color: AppColors.primary,
                      size: 24.0,
                    ),
                  ),
                  Gap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category.abbreviation,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                          maxLines: shouldStackTrailing ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          category.title,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          maxLines: shouldStackTrailing ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Gap.w8,
                  if (shouldStackTrailing)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [countBadge, Gap.h6, chevron],
                    )
                  else ...[
                    countBadge,
                    Gap.w8,
                    chevron,
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
