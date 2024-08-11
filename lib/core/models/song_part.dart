class SongPart {
  final SongPartType type;
  final String content;

  SongPart({required this.type, required this.content});
}

enum SongPartType {
  verse1('Verse 1'),
  verse2('Verse 2'),
  backToVerse1('Back to Verse 1'),
  backToVerse3('Back to Verse 3'),
  chorus('Chorus'),
  youtubeLink('Link youtube / video title');

  final String displayName;

  const SongPartType(this.displayName);
}
