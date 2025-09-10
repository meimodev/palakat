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
    final state = ref.watch(songBookControllerProvider);
    final controller = ref.read(songBookControllerProvider.notifier);
    final searchText = _searchController.text;
    final isSearching = searchText.isNotEmpty;

    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenTitleWidget.titleOnly(title: "Song Book"),
          Gap.h24,
          InputWidget.text(
            controller: _searchController,
            hint: "Search Title",
            endIcon: Assets.icons.line.search,
            borderColor: BaseColor.primary3,
            onChanged: (String? query) {
              setState(() {});

              if (query != null && query.isNotEmpty) {
                controller.searchSongs(query);
              }
            },
          ),
          Gap.h12,
          state.songs.isEmpty && isSearching
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No songs found.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : isSearching
              ? ListView.separated(
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
                )
              : GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
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
    );
  }
}
