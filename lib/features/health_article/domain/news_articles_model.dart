import 'package:halo_hermina/core/constants/enums/news_articles_category_enum.dart';

class NewsArticlesModel {
  final String title;
  final NewsArticlesCategory category;
  final String imageUrl;
  final String hospital;
  final String date;
  final String reviewedBy;
  final String content;

  NewsArticlesModel({
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.hospital,
    required this.date,
    this.reviewedBy = '',
    this.content = '',
  });
}
