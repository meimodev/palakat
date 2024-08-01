import 'package:palakat/core/models/models.dart';

class DummyData {
  String title = 'KJ NO.999';
  String subTitle = 'KAMI PUJI DENGAN RIANG DIKAY ALLAH YANG BESAR';
  List<String> source = [
    'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhtYjgaP0wMSHtHk_Sb59VNs7jU0UGC-wNkigoqxT0SnZtlSu3LK0xc0nDj3KbN0nyBdYr4iK1Iyl0AMCQcER2_hnz7LO_vGx8B5Aa9HsIjkjcQmqZUzswLMpPyjoVnC1V-PFbMyNuvd3OzGCLpKCXZX-WMBXYK2BKhlGyOy9oAJhvV7vBkmfKiAJJM/s736/IMG-20220325-WA0032.jpg',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSzFxtFXz3P2AI7Yz3sIMfDtim_wROjrNwetA&s',
  ];
  final List<SongPart> data = [
    SongPart(
      type: 'verse 1',
      content:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
    ),
    SongPart(
        type: 'verse 2',
        content:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation '),
    SongPart(type: 'back to verse 1', content: ''),
    SongPart(type: 'back to verse 3', content: ''),
    SongPart(
      type: 'chorus',
      content:
          'at. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequ',
    ),
    SongPart(type: 'Link youtube / video title', content: ''),
  ];
}
