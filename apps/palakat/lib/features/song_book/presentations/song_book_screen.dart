import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat/features/song_book/data/song_category_model.dart';
import 'package:palakat/features/song_book/presentations/song_book_motion_widget.dart';
import 'package:palakat_shared/palakat_shared.dart'
    hide Gap, Column, LoadingWrapper;

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

class _SongDbMetaHeader extends StatelessWidget {
  const _SongDbMetaHeader({required this.metaFuture});

  final Future<
    ({String? version, DateTime? updatedAt, int songsCount, int booksCount})
  >?
  metaFuture;

  String _formatDate(BuildContext context, DateTime value) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(value.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder(
      future: metaFuture,
      builder: (context, snapshot) {
        final meta = snapshot.data;
        final version = meta?.version;
        final updatedAt = meta?.updatedAt;
        final songsCount = meta?.songsCount;
        final booksCount = meta?.booksCount;

        final updatedText = updatedAt == null
            ? l10n.lbl_notSpecified
            : _formatDate(context, updatedAt);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(
                  AppIcons.info,
                  size: 14.0,
                  color: AppColors.onSurfaceVariant,
                ),
                Gap.w8,
                Expanded(
                  child: Text(
                    l10n.songBook_databaseTitle,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            Gap.h8,
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _SongDbMetaChip(
                  icon: AppIcons.info,
                  label: version == null || version.trim().isEmpty
                      ? l10n.songBook_versionFallback
                      : 'v${version.trim()}',
                ),
                _SongDbMetaChip(
                  icon: AppIcons.music,
                  label: l10n.songBook_songsCount(songsCount ?? 0),
                ),
                _SongDbMetaChip(
                  icon: AppIcons.reader,
                  label: l10n.songBook_booksCount(booksCount ?? 0),
                ),
                _SongDbMetaChip(icon: AppIcons.calendar, label: updatedText),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SongDbMetaChip extends StatelessWidget {
  const _SongDbMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceBright,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.neutral, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 14.0, color: AppColors.onSurfaceVariant),
          Gap.w8,
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SongDbUpdateBanner extends StatelessWidget {
  const _SongDbUpdateBanner({
    required this.remoteMetaFuture,
    required this.isUpdating,
    required this.onTapUpdate,
  });

  final Future<({DateTime? updatedAt, double? sizeInKB})>? remoteMetaFuture;
  final bool isUpdating;
  final VoidCallback? onTapUpdate;

  String _formatDate(BuildContext context, DateTime value) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(value.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder(
      future: remoteMetaFuture,
      builder: (context, snapshot) {
        final meta = snapshot.data;
        final updatedAt = meta?.updatedAt;
        final subtitle = updatedAt == null
            ? l10n.songBook_updateAvailableSubtitle
            : l10n.songBook_updateAvailableSubtitleWithDate(
                _formatDate(context, updatedAt),
              );

        return Material(
          color: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: AppColors.primary, width: 1),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final shouldStack =
                  constraints.maxWidth < 420 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.15;
              final actionButton = ButtonWidget.outlined(
                text: isUpdating
                    ? l10n.songBook_updatingAction
                    : l10n.songBook_updateAction,
                onTap: isUpdating ? null : onTapUpdate,
                isShrink: true,
              );

              return Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          alignment: Alignment.center,
                          child: FaIcon(
                            AppIcons.refresh,
                            size: 14.0,
                            color: AppColors.primary,
                          ),
                        ),
                        Gap.w10,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.songBook_updateAvailableTitle,
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onPrimary,
                                    ),
                                maxLines: shouldStack ? 2 : 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Gap.h4,
                              Text(
                                subtitle,
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      color: AppColors.onPrimary.withValues(
                                        alpha: 0.82,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: shouldStack ? 3 : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (!shouldStack) ...[Gap.w12, actionButton],
                      ],
                    ),
                    if (shouldStack) ...[
                      Gap.h12,
                      Align(
                        alignment: Alignment.centerLeft,
                        child: actionButton,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _SongBookScreenState extends ConsumerState<SongBookScreen> {
  Future<
    ({String? version, DateTime? updatedAt, int songsCount, int booksCount})
  >?
  _songDbMetaFuture;

  Future<({DateTime? updatedAt, double? sizeInKB})>? _remoteSongDbMetaFuture;

  ProviderSubscription<dynamic>? _songBookListener;
  final _searchController = TextEditingController();
  bool _ignoreNextSearch = false;

  @override
  void initState() {
    super.initState();
    _songDbMetaFuture = ref.read(songRepositoryProvider).getSongDbMetadata();
    _remoteSongDbMetaFuture = ref
        .read(songRepositoryProvider)
        .getRemoteSongDbMetadata();

    _songBookListener = ref.listenManual(songBookControllerProvider, (
      prev,
      next,
    ) {
      final wasDownloading = prev?.isDownloadingDb == true;
      final nowDownloading = next.isDownloadingDb;
      final downloadCompleted = wasDownloading && !nowDownloading;
      final ok = downloadCompleted && next.errorMessage == null;
      if (ok) {
        setState(() {
          _songDbMetaFuture = ref
              .read(songRepositoryProvider)
              .getSongDbMetadata(forceRefresh: true);
          _remoteSongDbMetaFuture = ref
              .read(songRepositoryProvider)
              .getRemoteSongDbMetadata(forceRefresh: true);
        });
      }

      final wasChecking = prev?.isCheckingDbUpdate == true;
      final nowChecking = next.isCheckingDbUpdate;
      final checkCompleted = wasChecking && !nowChecking;
      if (checkCompleted) {
        setState(() {
          _remoteSongDbMetaFuture = ref
              .read(songRepositoryProvider)
              .getRemoteSongDbMetadata(forceRefresh: true);
        });
      }
    });
  }

  @override
  void dispose() {
    _songBookListener?.close();
    _songBookListener = null;
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(SongBookController controller, String query) {
    if (_ignoreNextSearch) {
      _ignoreNextSearch = false;
      return;
    }
    controller.searchSongs(query);
  }

  void _openBook(SongBookController controller, SongCategory category) {
    _ignoreNextSearch = true;
    _searchController.text = category.title;
    controller.searchSongs(category.id);
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
        const SizedBox.shrink(),
        // 16px = 2 * 8px grid spacing (Requirement 2.4)
        const SizedBox.shrink(),
        // Category cards list with 8px spacing (Requirement 2.4)
        _SongBookGrid(
          categories: state.categories,
          songCountForCategory: controller.getSongCountForCategory,
          onBookTap: (category) => _openBook(controller, category),
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
      shimmerPlaceholder: PalakatShimmerPlaceholders.listSection(),
      child: state.filteredSongs.isEmpty
          ? SongBookAnimatedPresence(
              visible: state.filteredSongs.isEmpty,
              child: const _EmptySearchStateWidget(),
            )
          : ListView.separated(
              itemCount: state.filteredSongs.length,
              // 8px grid spacing (Requirement 2.4)
              separatorBuilder: (context, index) => Gap.h8,
              itemBuilder: (context, index) {
                final song = state.filteredSongs[index];
                // Use SongItemCard for consistent styling (Requirement 1.4)
                return SongBookReveal(
                  key: ValueKey('song-result-${song.id}'),
                  delay: Duration(milliseconds: 60 + (index * 35)),
                  child: SongItemCard(
                    song: song,
                    searchQuery: state.searchQuery,
                    onTap: () => _navigateToSongDetail(song),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildBrowseView(SongBookController controller, SongBookState state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCategoryView(controller, state),
          Gap.h16,
          if (state.hasDbUpdate) ...[
            SongBookReveal(
              delay: const Duration(milliseconds: 60),
              child: _SongDbUpdateBanner(
                remoteMetaFuture: _remoteSongDbMetaFuture,
                isUpdating: state.isDownloadingDb,
                onTapUpdate: state.isDownloadingDb
                    ? null
                    : controller.downloadDbAndLoadSongs,
              ),
            ),
            Gap.h12,
          ],
          SongBookReveal(
            delay: const Duration(milliseconds: 110),
            child: _SongDbMetaHeader(metaFuture: _songDbMetaFuture),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.read(songBookControllerProvider.notifier);
    final state = ref.watch(songBookControllerProvider);
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion =
        (mediaQuery?.disableAnimations ?? false) ||
        (mediaQuery?.accessibleNavigation ?? false);

    // Use state's isSearching for view transition (Requirement 3.4)
    // This ensures proper state management between category view and search results
    final isSearching = state.isSearching;

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SongBookReveal(
            child: ScreenTitleWidget.titleOnly(title: l10n.songBook_title),
          ),
          // 16px = 2 * 8px grid spacing (Requirement 2.4)
          Gap.h16,
          if (state.needsDownload)
            Expanded(
              child: SongBookReveal(
                delay: const Duration(milliseconds: 60),
                child: _DownloadRequiredState(
                  isDownloading: state.isDownloadingDb,
                  errorMessage: state.errorMessage,
                  onTapDownload: controller.downloadDbAndLoadSongs,
                ),
              ),
            )
          else ...[
            SongBookReveal(
              delay: const Duration(milliseconds: 50),
              child: SearchField(
                controller: _searchController,
                hint: l10n.songBook_searchHint,
                onSearch: (query) => _handleSearch(controller, query),
                debounceMilliseconds: 500,
                isLoading: state.isLoading && state.isSearching,
                prefixIcon: FaIcon(
                  AppIcons.search,
                  size: 20,
                  color: AppColors.primary,
                ),
                borderRadius: 8.0,
              ),
            ),
            Gap.h12,
            Expanded(
              child: AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 240),
                reverseDuration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) {
                  if (reduceMotion) {
                    return child;
                  }

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.03),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(isSearching ? 'song-search' : 'song-browse'),
                  child: isSearching
                      ? _buildSearchResultsView(controller, state)
                      : _buildBrowseView(controller, state),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DownloadRequiredState extends StatelessWidget {
  const _DownloadRequiredState({
    required this.isDownloading,
    required this.errorMessage,
    required this.onTapDownload,
  });

  final bool isDownloading;
  final String? errorMessage;
  final VoidCallback onTapDownload;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Material(
          color: AppColors.surfaceContainerLow,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: AppColors.neutral, width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56.0,
                  height: 56.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: FaIcon(
                    AppIcons.download,
                    size: 24.0,
                    color: AppColors.onPrimary,
                  ),
                ),
                Gap.h16,
                Text(
                  l10n.songBook_downloadRequiredTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gap.h6,
                Text(
                  l10n.songBook_downloadRequiredSubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (errorMessage != null &&
                    errorMessage!.trim().isNotEmpty) ...[
                  Gap.h12,
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                Gap.h16,
                SizedBox(
                  width: double.infinity,
                  child: ButtonWidget.primary(
                    text: l10n.songBook_downloadRequiredButton,
                    isLoading: isDownloading,
                    onTap: isDownloading ? null : onTapDownload,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SongBookGrid extends StatelessWidget {
  const _SongBookGrid({
    required this.categories,
    required this.songCountForCategory,
    required this.onBookTap,
  });

  final List<SongCategory> categories;
  final int Function(String categoryId) songCountForCategory;
  final ValueChanged<SongCategory> onBookTap;

  int _columnCount(double width, double textScale) {
    final normalizedScale = textScale < 1.0
        ? 1.0
        : textScale > 1.3
        ? 1.3
        : textScale;
    final effectiveWidth = width / normalizedScale;

    if (effectiveWidth >= 900) return 3;
    if (effectiveWidth >= 360) return 2;
    return 1;
  }

  double _childAspectRatio(int columnCount, double textScale) {
    final isLargeText = textScale > 1.1;

    switch (columnCount) {
      case 1:
        return isLargeText ? 1.45 : 1.75;
      case 2:
        return isLargeText ? 1.0 : 1.18;
      default:
        return isLargeText ? 0.96 : 1.08;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final columnCount = _columnCount(constraints.maxWidth, textScale);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            childAspectRatio: _childAspectRatio(columnCount, textScale),
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return SongBookReveal(
              key: ValueKey('song-category-${category.id}'),
              delay: Duration(milliseconds: 50 + (index * 35)),
              child: _SongBookGridCard(
                category: category,
                songCount: songCountForCategory(category.id),
                onTap: () => onBookTap(category),
              ),
            );
          },
        );
      },
    );
  }
}

class _SongBookGridCard extends StatelessWidget {
  const _SongBookGridCard({
    required this.category,
    required this.songCount,
    required this.onTap,
  });

  final SongCategory category;
  final int songCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.maxWidth < 180 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.1;

        return Material(
          color: AppColors.surfaceContainerLow,
          elevation: 0,
          borderRadius: BorderRadius.circular(8.0),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8.0),
            splashColor: AppColors.primary.withValues(alpha: 0.08),
            highlightColor: AppColors.primary.withValues(alpha: 0.05),
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: AppColors.neutral, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: isCompact ? 32.0 : 36.0,
                        height: isCompact ? 32.0 : 36.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: FaIcon(
                          AppIcons.libraryMusic,
                          size: isCompact ? 14.0 : 16.0,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      Gap.w6,
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: isCompact ? 4.0 : 0),
                          child: Text(
                            category.abbreviation,
                            style:
                                (isCompact
                                        ? Theme.of(
                                            context,
                                          ).textTheme.bodyMedium!
                                        : Theme.of(
                                            context,
                                          ).textTheme.titleMedium!)
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap.h8,
                  Text(
                    category.title,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: isCompact ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    l10n.songBook_songsCount(songCount),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: isCompact ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
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
    final l10n = context.l10n;

    return Material(
      color: AppColors.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: AppColors.neutral, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48.0,
              height: 48.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: FaIcon(
                AppIcons.searchOff,
                size: 20.0,
                color: AppColors.onPrimary,
              ),
            ),
            Gap.h12,
            Text(
              l10n.songBook_emptyTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap.h4,
            Text(
              l10n.songBook_emptySubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
