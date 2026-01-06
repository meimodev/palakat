class SongBook {
  const SongBook({required this.id, required this.name});

  final String id;
  final String name;

  factory SongBook.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['bookId'];
    if (rawId == null) {
      throw const FormatException('Missing book id');
    }

    final rawName = json['name'] ?? json['bookName'];

    return SongBook(id: rawId.toString(), name: (rawName ?? '').toString());
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
