class AdminSongPartModel {
  AdminSongPartModel({
    required this.id,
    required this.index,
    required this.name,
    required this.content,
    required this.songId,
  });

  final int id;
  final int index;
  final String name;
  final String content;
  final int songId;

  factory AdminSongPartModel.fromJson(Map<String, dynamic> json) {
    return AdminSongPartModel(
      id: (json['id'] as num).toInt(),
      index: (json['index'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      songId: (json['songId'] as num?)?.toInt() ?? 0,
    );
  }
}
