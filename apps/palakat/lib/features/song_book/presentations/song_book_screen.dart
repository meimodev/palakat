import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';

import 'widgets/widgets.dart';

class SongBookScreen extends ConsumerStatefulWidget {
  const SongBookScreen({super.key});

  @override
  ConsumerState<SongBookScreen> createState() => _SongBookScreenState();
}

class _SongBookScreenState extends ConsumerState<SongBookScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(songBookControllerProvider.notifier);
    final state = ref.watch(songBookControllerProvider);

    final searchText = _searchController.text;
    final isSearching = searchText.isNotEmpty;

    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenTitleWidget.titleOnly(title: "Song Book"),
          Gap.h16,
          InputWidget.text(
            controller: _searchController,
            hint: "Search song title or number",
            endIcon: Assets.icons.line.search,
            borderColor: BaseColor.primary3,
            onChanged: (String? query) {
              setState(() {});

              if (query != null && query.isNotEmpty) {
                controller.searchSongs(query);
              }
            },
          ),
          Gap.h16,
          // Search results or default categories
          if (isSearching)
            LoadingWrapper(
              loading: state.isLoading,
              hasError: state.errorMessage != null && state.isLoading == false,
              errorMessage: state.errorMessage,
              onRetry: () => controller.refreshSongs(),
              shimmerPlaceholder: Column(
                children: [
                  PalakatShimmerPlaceholders.listItemCard(),
                  Gap.h12,
                  PalakatShimmerPlaceholders.listItemCard(),
                  Gap.h12,
                  PalakatShimmerPlaceholders.listItemCard(),
                ],
              ),
              child: state.songs.isEmpty
                  ? Container(
                    padding: EdgeInsets.all(BaseSize.w24),
                    decoration: BoxDecoration(
                      color: BaseColor.cardBackground1,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: BaseColor.neutral20,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: BaseSize.w48,
                          color: BaseColor.secondaryText,
                        ),
                        Gap.h12,
                        Text(
                          "No songs found",
                          textAlign: TextAlign.center,
                          style: BaseTypography.titleMedium.copyWith(
                            color: BaseColor.secondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap.h4,
                        Text(
                          "Try searching with different keywords",
                          textAlign: TextAlign.center,
                          style: BaseTypography.bodyMedium.copyWith(
                            color: BaseColor.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: state.songs.length,
                    separatorBuilder: (context, index) => Gap.h12,
                    itemBuilder: (context, index) {
                      final song = state.songs[index];
                      return CardSongSnippetListItemWidget(
                        title: song.title,
                        snippet: song.subTitle,
                        onPressed: () {
                          context.pushNamed(
                            AppRoute.songBookDetail,
                            extra: RouteParam(
                              params: {RouteParamKey.song: song.toJson()},
                            ),
                          );
                        },
                      );
                    },
                  ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: BaseSize.w32,
                      height: BaseSize.w32,
                      decoration: BoxDecoration(
                        color: BaseColor.red[100],
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.library_books_outlined,
                        size: BaseSize.w16,
                        color: BaseColor.red[700],
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: Text(
                        "Song Categories",
                        style: BaseTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: BaseColor.black,
                        ),
                      ),
                    ),
                  ],
                ),
                Gap.h16,
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    DefaultCardSongSnippet(
                      title: "Nanyikanlah Nyanyian Baru Bagi Tuhan (NNBT)",
                      searchQuery: "NNBT",
                      onPressed: () {
                        _searchController.text = "NNBT";
                        controller.searchSongs("NNBT");
                        setState(() {});
                      },
                    ),
                    DefaultCardSongSnippet(
                      title: "Kidung Jemaat (KJ)",
                      searchQuery: "KJ",
                      onPressed: () {
                        _searchController.text = "KJ";
                        controller.searchSongs("KJ");
                        setState(() {});
                      },
                    ),
                    DefaultCardSongSnippet(
                      title: "Nanyikanlah Kidung Baru (NKB)",
                      searchQuery: "NKB",
                      onPressed: () {
                        _searchController.text = "NKB";
                        controller.searchSongs("NKB");
                        setState(() {});
                      },
                    ),
                    DefaultCardSongSnippet(
                      title: "Dua Sahabat Lama (DSL)",
                      searchQuery: "DSL",
                      onPressed: () {
                        _searchController.text = "DSL";
                        controller.searchSongs("DSL");
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
