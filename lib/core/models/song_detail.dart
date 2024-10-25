import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart';

class SongDetail extends StateNotifier<List<Song>> {
  SongDetail() : super(_initialSongs);

  static final List<Song> _initialSongs = List.generate(
    10,
    (index) => Song(
      id: 'id$index',
      title: 'KJ NO.$index',
      subTitle: 'SUBTITLE FOR THIS SUBTITLE IN $index',
      urlImage:
          'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhtYjgaP0wMSHtHk_Sb59VNs7jU0UGC-wNkigoqxT0SnZtlSu3LK0xc0nDj3KbN0nyBdYr4iK1Iyl0AMCQcER2_hnz7LO_vGx8B5Aa9HsIjkjcQmqZUzswLMpPyjoVnC1V-PFbMyNuvd3OzGCLpKCXZX-WMBXYK2BKhlGyOy9oAJhvV7vBkmfKiAJJM/s736/IMG-20220325-WA0032.jpg',
      urlVideo:
          'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhtYjgaP0wMSHtHk_Sb59VNs7jU0UGC-wNkigoqxT0SnZtlSu3LK0xc0nDj3KbN0nyBdYr4iK1Iyl0AMCQcER2_hnz7LO_vGx8B5Aa9HsIjkjcQmqZUzswLMpPyjoVnC1V-PFbMyNuvd3OzGCLpKCXZX-WMBXYK2BKhlGyOy9oAJhvV7vBkmfKiAJJM/s736/IMG-20220325-WA0032.jpg',
      composition: [
        SongPartType.verse,
        SongPartType.verse2,
        SongPartType.chorus,
        SongPartType.verse,
        SongPartType.verse2,
        SongPartType.chorus,
      ],
      definition: [
        const SongPart(
          type: SongPartType.verse,
          content:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
        ),
        const SongPart(
          type: SongPartType.verse2,
          content:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ',
        ),
        const SongPart(
          type: SongPartType.chorus,
          content:
              'at. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequ',
        ),
      ],
    ),
  );

  void searchSongs(String query) {
    state = _initialSongs
        .where((song) =>
            song.title.toLowerCase().contains(query.toLowerCase()) ||
            song.subTitle.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

final songProvider = StateNotifierProvider<SongDetail, List<Song>>((ref) {
  return SongDetail();
});
