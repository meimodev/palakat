class ArticleModel {
  ArticleModel({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.slug,
    required this.content,
    required this.likesCount,
    this.excerpt,
    this.coverImageUrl,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String type;
  final String status;
  final String title;
  final String slug;
  final String content;
  final String? excerpt;
  final String? coverImageUrl;
  final DateTime? publishedAt;
  final int likesCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return ArticleModel(
      id: (json['id'] as num).toInt(),
      type: json['type']?.toString() ?? 'PREACHING_MATERIAL',
      status: json['status']?.toString() ?? 'DRAFT',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      excerpt: json['excerpt']?.toString(),
      content: json['content']?.toString() ?? '',
      coverImageUrl: json['coverImageUrl']?.toString(),
      publishedAt: parseDate(json['publishedAt']),
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }
}
