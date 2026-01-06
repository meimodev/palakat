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
import 'package:palakat_shared/palakat_shared.dart'
    hide BaseColor, BaseSize, BaseTypography, Gap, Column, LoadingWrapper;

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
    return FutureBuilder(
      future: metaFuture,
      builder: (context, snapshot) {
        final meta = snapshot.data;
        final version = meta?.version;
        final updatedAt = meta?.updatedAt;
        final songsCount = meta?.songsCount;
        final booksCount = meta?.booksCount;

        final updatedText = updatedAt == null
            ? '-'
            : _formatDate(context, updatedAt);

        return Container(
          padding: EdgeInsets.all(BaseSize.w16),
          decoration: BoxDecoration(
            color: BaseColor.surfaceMedium,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BaseColor.neutral[200]!, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      AppIcons.info,
                      size: BaseSize.w16,
                      color: BaseColor.primary,
                    ),
                  ),
                  Gap.w12,
                  Expanded(
                    child: Text(
                      'Song database',
                      style: BaseTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BaseColor.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              Gap.h12,
              Wrap(
                spacing: BaseSize.w8,
                runSpacing: BaseSize.w8,
                children: [
                  _SongDbMetaChip(
                    icon: AppIcons.info,
                    label: version == null || version.trim().isEmpty
                        ? 'v-'
                        : 'v${version.trim()}',
                  ),
                  _SongDbMetaChip(
                    icon: AppIcons.music,
                    label: '${songsCount ?? 0} songs',
                  ),
                  _SongDbMetaChip(
                    icon: AppIcons.reader,
                    label: '${booksCount ?? 0} books',
                  ),
                  _SongDbMetaChip(icon: AppIcons.calendar, label: updatedText),
                ],
              ),
            ],
          ),
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
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w12,
        vertical: BaseSize.w8,
      ),
      decoration: BoxDecoration(
        color: BaseColor.surfaceLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: BaseColor.neutral[200]!, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: BaseSize.w14, color: BaseColor.textSecondary),
          Gap.w8,
          Text(
            label,
            style: BaseTypography.bodySmall.copyWith(
              color: BaseColor.textSecondary,
              fontWeight: FontWeight.w600,
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
    return FutureBuilder(
      future: remoteMetaFuture,
      builder: (context, snapshot) {
        final meta = snapshot.data;
        final updatedAt = meta?.updatedAt;
        final subtitle = updatedAt == null
            ? 'A newer song database is available.'
            : 'Updated ${_formatDate(context, updatedAt)}';

        return Container(
          padding: EdgeInsets.all(BaseSize.w16),
          decoration: BoxDecoration(
            color: BaseColor.primary[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BaseColor.primary[100]!, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: BaseSize.w32,
                height: BaseSize.w32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  AppIcons.refresh,
                  size: BaseSize.w16,
                  color: BaseColor.primary,
                ),
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update available',
                      style: BaseTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BaseColor.textPrimary,
                      ),
                    ),
                    Gap.h4,
                    Text(
                      subtitle,
                      style: BaseTypography.bodySmall.copyWith(
                        color: BaseColor.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Gap.w12,
              ButtonWidget.outlined(
                text: isUpdating ? 'Updating…' : 'Update',
                onTap: isUpdating ? null : onTapUpdate,
                isShrink: true,
              ),
            ],
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
              itemCount: state.filteredSongs.length,
              // 8px grid spacing (Requirement 2.4)
              separatorBuilder: (context, index) => Gap.h12,
              itemBuilder: (context, index) {
                final song = state.filteredSongs[index];
                // Use SongItemCard for consistent styling (Requirement 1.4)
                return SongItemCard(
                  song: song,
                  searchQuery: state.searchQuery,
                  onTap: () => _navigateToSongDetail(song),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.read(songBookControllerProvider.notifier);
    final state = ref.watch(songBookControllerProvider);

    // Use state's isSearching for view transition (Requirement 3.4)
    // This ensures proper state management between category view and search results
    final isSearching = state.isSearching;

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitleWidget.titleOnly(title: l10n.songBook_title),
          // 16px = 2 * 8px grid spacing (Requirement 2.4)
          Gap.h16,
          if (state.needsDownload)
            _DownloadRequiredState(
              isDownloading: state.isDownloadingDb,
              errorMessage: state.errorMessage,
              onTapDownload: controller.downloadDbAndLoadSongs,
            )
          else ...[
            if (!isSearching) ...[
              if (state.hasDbUpdate)
                _SongDbUpdateBanner(
                  remoteMetaFuture: _remoteSongDbMetaFuture,
                  isUpdating: state.isDownloadingDb,
                  onTapUpdate: state.isDownloadingDb
                      ? null
                      : controller.downloadDbAndLoadSongs,
                ),
              if (state.hasDbUpdate) Gap.h12,
              _SongDbMetaHeader(metaFuture: _songDbMetaFuture),
              Gap.h16,
            ],
            // Search input field (Requirement 3.1, 3.5)
            SearchField(
              controller: _searchController,
              hint: l10n.songBook_searchHint,
              onSearch: (query) => _handleSearch(controller, query),
              debounceMilliseconds: 500,
              isLoading: state.isLoading && state.isSearching,
              prefixIcon: FaIcon(
                AppIcons.search,
                size: 20,
                color: BaseColor.primary,
              ),
              borderRadius: 8,
            ),
            // 16px = 2 * 8px grid spacing (Requirement 2.4)
            Gap.h16,
            // Conditional rendering: search results vs category view (Requirement 3.4)
            Expanded(
              child: isSearching
                  ? _buildSearchResultsView(controller, state)
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _buildCategoryView(controller, state),
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
        padding: EdgeInsets.all(BaseSize.w24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: BaseSize.w48,
              height: BaseSize.w48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: BaseColor.primary[50],
                shape: BoxShape.circle,
              ),
              child: FaIcon(
                AppIcons.download,
                size: BaseSize.w24,
                color: BaseColor.primary,
              ),
            ),
            Gap.h12,
            Text(
              l10n.songBook_downloadRequiredTitle,
              textAlign: TextAlign.center,
              style: BaseTypography.titleMedium.copyWith(
                color: BaseColor.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap.h8,
            Text(
              l10n.songBook_downloadRequiredSubtitle,
              textAlign: TextAlign.center,
              style: BaseTypography.bodyMedium.copyWith(
                color: BaseColor.textSecondary,
              ),
            ),
            if (errorMessage != null && errorMessage!.trim().isNotEmpty) ...[
              Gap.h12,
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: BaseTypography.bodyMedium.copyWith(
                  color: BaseColor.error,
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
    );
  }
}

class _SongBookGrid extends StatelessWidget {
  const _SongBookGrid({required this.categories, required this.onBookTap});

  final List<SongCategory> categories;
  final ValueChanged<SongCategory> onBookTap;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: BaseSize.w8,
        crossAxisSpacing: BaseSize.w8,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return _SongBookGridCard(
          category: category,
          onTap: () => onBookTap(category),
        );
      },
    );
  }
}

class _SongBookGridCard extends StatelessWidget {
  const _SongBookGridCard({required this.category, required this.onTap});

  final SongCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaseColor.surfaceMedium,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(BaseSize.w12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BaseColor.neutral[200]!, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: BaseSize.w32,
                    height: BaseSize.w32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: BaseColor.primary[50],
                      shape: BoxShape.circle,
                    ),
                    child: FaIcon(
                      AppIcons.libraryMusic,
                      size: BaseSize.w16,
                      color: BaseColor.primary,
                    ),
                  ),
                  Gap.w8,
                  Expanded(
                    child: Text(
                      category.abbreviation,
                      style: BaseTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BaseColor.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Gap.h8,
              Text(
                category.title,
                style: BaseTypography.bodyMedium.copyWith(
                  color: BaseColor.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
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
            alignment: Alignment.center,
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
            l10n.songBook_emptyTitle,
            textAlign: TextAlign.center,
            style: BaseTypography.titleMedium.copyWith(
              color: BaseColor.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap.h4,
          Text(
            l10n.songBook_emptySubtitle,
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
