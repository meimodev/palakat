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

class SongBookScreen extends ConsumerWidget {
  const SongBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(songProvider);
    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenTitleWidget.titleOnly(
            title: "Song Book",
          ),
          Gap.h24,
          InputWidget.text(
            hint: "Search title / lyrics",
            endIcon: Assets.icons.line.search,
            borderColor: BaseColor.primary3,
            onChanged: (query) {
              // ref
              //     .read(songProvider.notifier)
              //     .searchSongs(query); // Mengubah state sesuai input
            },
          ),
          Gap.h12,
          state.isEmpty
              ? const Text(
                  'No songs found.') // Tampilkan pesan jika tidak ada lagu yang cocok
              : ListView.separated(
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
                            params: {
                              RouteParamKey.song: song.toJson(),
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}
