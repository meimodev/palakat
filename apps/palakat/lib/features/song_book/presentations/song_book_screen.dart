import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat/features/song_book/data/song_category_model.dart';

import 'widgets/widgets.dart';

/// Song Book screen with category-based organization and search functionality.
/// Uses the same design patterns as the Operations screen.
///
/// Requirements: 1.1, 1.4, 2.4, 3.4
class SongBookScreen extends ConsumerStatefulWidget {
  const SongBookScreen({super.key});

  @override
  ConsumerState<SongBookScreen> createState() => _SongBookScreenState();
}

class _SongBookScreenState extends ConsumerState<SongBookScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Navigate to song detail screen
  void _navigateToSongDetail(dynamic song) {
    context.pushNamed(
      AppRoute.songBookDetail,
      extra: RouteParam(params: {RouteParamKey.song: song.toJson()}),
    );
  }

  /// Build the category view with collapsible category cards
  /// Requirements: 1.1, 1.4, 3.4 - Category view shown when not searching
  Widget _buildCategoryView(
    SongBookController controller,
    SongBookState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section header with icon - 8px grid spacing (Requirement 2.4)
        Row(
          children: [
            Container(
              width: BaseSize.w32,
              height: BaseSize.w32,
              decoration: BoxDecoration(
                color: BaseColor.primary[50],
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: FaIcon(
                AppIcons.libraryBooks,
                size: BaseSize.w16,
                color: BaseColor.primary,
              ),
            ),
            Gap.w12,
            Expanded(
              child: Text(
                "Song Categories",
                style: BaseTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: BaseColor.textPrimary,
                ),
              ),
            ),
          ],
        ),
        // 16px = 2 * 8px grid spacing (Requirement 2.4)
        Gap.h16,
        // Category cards list with 8px spacing (Requirement 2.4)
        _SongCategoryList(
          categories: state.categories,
          categoryExpansionState: state.categoryExpansionState,
          getSongsForCategory: controller.getSongsForCategory,
          onExpansionChanged: (categoryId) {
            controller.toggleCategoryExpansion(categoryId);
          },
          onSongTap: _navigateToSongDetail,
        ),
      ],
    );
  }

  /// Build search results view with song item cards
  /// Requirements: 3.3, 3.4
  Widget _buildSearchResultsView(
    SongBookController controller,
    SongBookState state,
  ) {
    return LoadingWrapper(
      loading: state.isLoading,
      hasError: state.errorMessage != null && state.isLoading == false,
      errorMessage: state.errorMessage,
      onRetry: () => controller.refreshSongs(),
      shimmerPlaceholder: Column(
        children: [
          PalakatShimmerPlaceholders.listItemCard(),
          // 8px grid spacing (Requirement 2.4)
          Gap.h8,
          PalakatShimmerPlaceholders.listItemCard(),
          Gap.h8,
          PalakatShimmerPlaceholders.listItemCard(),
        ],
      ),
      child: state.filteredSongs.isEmpty
          ? const _EmptySearchStateWidget()
          : ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: state.filteredSongs.length,
              // 8px grid spacing (Requirement 2.4)
              separatorBuilder: (context, index) => Gap.h8,
              itemBuilder: (context, index) {
                final song = state.filteredSongs[index];
                // Use SongItemCard for consistent styling (Requirement 1.4)
                return SongItemCard(
                  song: song,
                  onTap: () => _navigateToSongDetail(song),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(songBookControllerProvider.notifier);
    final state = ref.watch(songBookControllerProvider);

    // Use state's isSearching for view transition (Requirement 3.4)
    // This ensures proper state management between category view and search results
    final isSearching = state.isSearching;

    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenTitleWidget.titleOnly(title: "Song Book"),
          // 16px = 2 * 8px grid spacing (Requirement 2.4)
          Gap.h16,
          // Search input field (Requirement 3.1, 3.5)
          InputWidget.text(
            controller: _searchController,
            hint: "Search song title or number",
            endIcon: FaIcon(
              AppIcons.search,
              size: 20,
              color: BaseColor.primary,
            ),
            borderColor: BaseColor.primary,
            onChanged: (String? query) {
              // Cancel previous timer to implement debouncing (Requirement 3.2)
              _debounceTimer?.cancel();

              // Debounce search API calls by 500ms to avoid excessive requests
              _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                controller.searchSongs(query ?? '');
              });
            },
          ),
          // 16px = 2 * 8px grid spacing (Requirement 2.4)
          Gap.h16,
          // Conditional rendering: search results vs category view (Requirement 3.4)
          if (isSearching)
            _buildSearchResultsView(controller, state)
          else
            _buildCategoryView(controller, state),
        ],
      ),
    );
  }
}

/// Responsive breakpoint for switching between 1 and 2 column layouts
/// Requirements: 8.2, 8.3
const double _responsiveBreakpoint = 600.0;

/// List of song categories with collapsible sections and responsive layout.
/// Uses LayoutBuilder to detect screen width and adjust column count.
/// Requirements: 1.1, 1.4, 2.4, 8.1, 8.2, 8.3, 8.4
class _SongCategoryList extends StatelessWidget {
  const _SongCategoryList({
    required this.categories,
    required this.categoryExpansionState,
    required this.getSongsForCategory,
    required this.onExpansionChanged,
    required this.onSongTap,
  });

  final List<SongCategory> categories;
  final Map<String, bool> categoryExpansionState;
  final List<dynamic> Function(String) getSongsForCategory;
  final ValueChanged<String> onExpansionChanged;
  final ValueChanged<dynamic> onSongTap;

  /// Build a single category card widget
  /// Requirements: 8.4 - Minimum touch target of 48x48 pixels ensured by SongCategoryCard
  Widget _buildCategoryCard(SongCategory category) {
    final songs = getSongsForCategory(category.id);
    final isExpanded = categoryExpansionState[category.id] ?? false;

    return SongCategoryCard(
      category: category,
      songs: songs.cast(),
      isExpanded: isExpanded,
      onExpansionChanged: (expanded) {
        onExpansionChanged(category.id);
      },
      onSongTap: onSongTap,
    );
  }

  /// Build single column layout for narrow screens (width <= 600px)
  /// Requirements: 8.3
  Widget _buildSingleColumnLayout() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      // 8px grid spacing (Requirement 2.4)
      separatorBuilder: (context, index) => Gap.h8,
      itemBuilder: (context, index) => _buildCategoryCard(categories[index]),
    );
  }

  /// Build two column grid layout for wider screens (width > 600px)
  /// Requirements: 8.2
  Widget _buildTwoColumnLayout() {
    // Calculate number of rows needed
    final rowCount = (categories.length / 2).ceil();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rowCount,
      // 8px grid spacing (Requirement 2.4)
      separatorBuilder: (context, index) => Gap.h8,
      itemBuilder: (context, rowIndex) {
        final firstIndex = rowIndex * 2;
        final secondIndex = firstIndex + 1;
        final hasSecondItem = secondIndex < categories.length;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First column
            Expanded(child: _buildCategoryCard(categories[firstIndex])),
            // 8px grid spacing between columns (Requirement 2.4)
            Gap.w8,
            // Second column (or empty space if odd number of categories)
            Expanded(
              child: hasSecondItem
                  ? _buildCategoryCard(categories[secondIndex])
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to detect screen width and adjust layout
    // Requirements: 8.1, 8.2, 8.3
    return LayoutBuilder(
      builder: (context, constraints) {
        // Display 2 columns when width > 600px (Requirement 8.2)
        // Display 1 column when width <= 600px (Requirement 8.3)
        final useWideLayout = constraints.maxWidth > _responsiveBreakpoint;

        if (useWideLayout) {
          return _buildTwoColumnLayout();
        } else {
          return _buildSingleColumnLayout();
        }
      },
    );
  }
}

/// Empty state widget when no songs match the search query
/// Requirements: 1.5, 2.2 - Consistent styling with Operations screen
class _EmptySearchStateWidget extends StatelessWidget {
  const _EmptySearchStateWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      // 24px = 3 * 8px grid spacing (Requirement 2.4)
      padding: EdgeInsets.all(BaseSize.w24),
      decoration: BoxDecoration(
        color: BaseColor.surfaceMedium,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BaseColor.neutral[200]!, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Teal accent icon (Requirement 2.2)
          Container(
            width: BaseSize.w48,
            height: BaseSize.w48,
            decoration: BoxDecoration(
              color: BaseColor.primary[50],
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              AppIcons.searchOff,
              size: BaseSize.w24,
              color: BaseColor.primary,
            ),
          ),
          // 12px spacing
          Gap.h12,
          Text(
            "No songs found",
            textAlign: TextAlign.center,
            style: BaseTypography.titleMedium.copyWith(
              color: BaseColor.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap.h4,
          Text(
            "Try searching with different keywords",
            textAlign: TextAlign.center,
            style: BaseTypography.bodyMedium.copyWith(
              color: BaseColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
