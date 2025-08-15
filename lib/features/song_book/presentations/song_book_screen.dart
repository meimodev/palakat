import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart' hide Column;
import 'package:palakat/core/routing/routing.dart';
import 'package:palakat/core/widgets/widgets.dart';

import 'widgets/widgets.dart';

// final List<Song> _data = List.generate(
//   10,
//   (index) => Song(
//     id: 'id$index',
//     title: 'KJ NO.$index',
//     subTitle: 'SUBTITLE FOR THIS SUBTITLE IN $index',
//     urlImage:
//         'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhtYjgaP0wMSHtHk_Sb59VNs7jU0UGC-wNkigoqxT0SnZtlSu3LK0xc0nDj3KbN0nyBdYr4iK1Iyl0AMCQcER2_hnz7LO_vGx8B5Aa9HsIjkjcQmqZUzswLMpPyjoVnC1V-PFbMyNuvd3OzGCLpKCXZX-WMBXYK2BKhlGyOy9oAJhvV7vBkmfKiAJJM/s736/IMG-20220325-WA0032.jpg',
//     urlVideo:
//         'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhtYjgaP0wMSHtHk_Sb59VNs7jU0UGC-wNkigoqxT0SnZtlSu3LK0xc0nDj3KbN0nyBdYr4iK1Iyl0AMCQcER2_hnz7LO_vGx8B5Aa9HsIjkjcQmqZUzswLMpPyjoVnC1V-PFbMyNuvd3OzGCLpKCXZX-WMBXYK2BKhlGyOy9oAJhvV7vBkmfKiAJJM/s736/IMG-20220325-WA0032.jpg',
//     composition: [
//       SongPartType.verse,
//       SongPartType.verse2,
//       SongPartType.chorus,
//       SongPartType.verse,
//       SongPartType.verse2,
//       SongPartType.chorus,
//     ],
//     definition: [
//       const SongPart(
//         type: SongPartType.verse,
//         content:
//             'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
//       ),
//       const SongPart(
//         type: SongPartType.verse2,
//         content:
//             'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ',
//       ),
//       const SongPart(
//         type: SongPartType.chorus,
//         content:
//             'at. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequ',
//       ),
//     ],
//   ),
// );

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
    final state = ref.watch(songProvider);
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
                ref.read(songProvider.notifier).searchSongs(query);
              }
            },
          ),
          Gap.h12,
          state.isEmpty && isSearching
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
                  itemCount: state.length,
                  separatorBuilder: (context, index) => Gap.h12,
                  itemBuilder: (context, index) {
                    final song = state[index];
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
                        ref.read(songProvider.notifier).searchSongs("NNBT");
                        setState(() {});
                      },
                    ),
                    DefaultCardSongSnippet(
                      title: "Kidung Jemaat (KJ)",
                      searchQuery: "KJ",
                      onPressed: () {
                        _searchController.text = "KJ";
                        ref.read(songProvider.notifier).searchSongs("KJ");
                        setState(() {});
                      },
                    ),
                    DefaultCardSongSnippet(
                      title: "Nanyikanlah Kidung Baru (NKB)",
                      searchQuery: "NKB",
                      onPressed: () {
                        _searchController.text = "NKB";
                        ref.read(songProvider.notifier).searchSongs("NKB");
                        setState(() {});
                      },
                    ),
                    DefaultCardSongSnippet(
                      title: "Dua Sahabat Lama (DSL)",
                      searchQuery: "DSL",
                      onPressed: () {
                        _searchController.text = "DSL";
                        ref.read(songProvider.notifier).searchSongs("DSL");
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
