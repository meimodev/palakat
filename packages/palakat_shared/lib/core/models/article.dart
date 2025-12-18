import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';

part 'article.freezed.dart';
part 'article.g.dart';

@freezed
abstract class Article with _$Article {
  const factory Article({
    int? id,
    ArticleType? type,
    ArticleStatus? status,
    String? title,
    String? slug,
    String? excerpt,
    String? content,
    String? coverImageUrl,
    DateTime? publishedAt,
    int? likesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Article;

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);
}

@freezed
abstract class ArticleLikeResult with _$ArticleLikeResult {
  const factory ArticleLikeResult({
    required bool liked,
    required int likesCount,
  }) = _ArticleLikeResult;

  factory ArticleLikeResult.fromJson(Map<String, dynamic> json) =>
      _$ArticleLikeResultFromJson(json);
}
