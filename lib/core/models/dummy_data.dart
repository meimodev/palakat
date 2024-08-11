import 'package:palakat/core/models/models.dart';

class DummyData {
  String title = 'KJ NO.999';
  String subTitle = 'KAMI PUJI DENGAN RIANG DIKAY ALLAH YANG BESAR';

  final List<SongPart> data = [
    SongPart(
      type: SongPartType.verse1,
      content:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
    ),
    SongPart(
      type: SongPartType.verse2,
      content:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ',
    ),
    SongPart(
      type: SongPartType.backToVerse1,
      content: '',
    ),
    SongPart(
      type: SongPartType.backToVerse3,
      content: '',
    ),
    SongPart(
      type: SongPartType.chorus,
      content:
          'at. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequ',
    ),
    SongPart(
        type: SongPartType.youtubeLink,
        content:
            'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhtYjgaP0wMSHtHk_Sb59VNs7jU0UGC-wNkigoqxT0SnZtlSu3LK0xc0nDj3KbN0nyBdYr4iK1Iyl0AMCQcER2_hnz7LO_vGx8B5Aa9HsIjkjcQmqZUzswLMpPyjoVnC1V-PFbMyNuvd3OzGCLpKCXZX-WMBXYK2BKhlGyOy9oAJhvV7vBkmfKiAJJM/s736/IMG-20220325-WA0032.jpg'),
  ];
}
