class DummyData {
  final String titles = 'KJ NO.999';

  final String subtitles = 'KAMI PUJI DENGAN RIANG DIKAY ALLAH YANG BESAR';

  final String youtube = 'Link youtube / video title';

  final String image =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSzFxtFXz3P2AI7Yz3sIMfDtim_wROjrNwetA&s';
}

class SongPartData {
  final String type;
  final String? content;

  SongPartData({required this.type, this.content});
}

class SongPart {
  List<SongPartData> data = [
    SongPartData(
      type: 'verse 1',
      content:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
    ),
    SongPartData(
      type: 'verse 2',
      content:
          'at. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequ',
    ),
    SongPartData(type: 'back to verse 1'),
    SongPartData(type: 'back to verse 3'),
    SongPartData(
      type: 'chorus',
      content:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ',
    ),
  ];
}
