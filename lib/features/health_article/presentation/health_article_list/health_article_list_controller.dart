import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/health_article/presentation/health_article_list/health_article_list_state.dart';
import 'package:halo_hermina/core/constants/enums/news_articles_category_enum.dart';
import 'package:halo_hermina/features/health_article/domain/news_articles_model.dart';

final List<NewsArticlesModel> _data = <NewsArticlesModel>[
  NewsArticlesModel(
    title:
    'Holistic Approaches to Stress Management: Balancing Mind and Body',
    category: NewsArticlesCategory.mcu,
    date: '30 Jun 2023',
    hospital: 'Hermina Jatinegara',
    imageUrl: 'https://images.unsplash.com/photo-1519494140681-8b17d830a3e9',
  ),
  NewsArticlesModel(
    title:
    'Nutrition Essentials: Building a Strong Foundation for Good Health',
    category: NewsArticlesCategory.vaccine,
    date: '30 Jun 2023',
    hospital: 'Hermina Jatinegara',
    imageUrl: 'https://images.unsplash.com/photo-1519494140681-8b17d830a3e9',
  ),
  NewsArticlesModel(
    title: 'The Science of Sleep: Unlocking the Secrets to Restful Nights',
    category: NewsArticlesCategory.maternity,
    date: '30 Jun 2023',
    hospital: 'Hermina Jatinegara',
    imageUrl: 'https://images.unsplash.com/photo-1519494140681-8b17d830a3e9',
  ),
  NewsArticlesModel(
    title: 'The Science of Sleep: Unlocking the Secrets to Restful Nights',
    category: NewsArticlesCategory.mcu,
    date: '30 Jun 2023',
    hospital: 'Hermina Jatinegara',
    imageUrl: 'https://images.unsplash.com/photo-1519494140681-8b17d830a3e9',
  ),
  NewsArticlesModel(
    title: 'The Science of Sleep: Unlocking the Secrets to Restful Nights',
    category: NewsArticlesCategory.vaccine,
    date: '30 Jun 2023',
    hospital: 'Hermina Jatinegara',
    imageUrl: 'https://images.unsplash.com/photo-1519494140681-8b17d830a3e9',
  ),
  NewsArticlesModel(
    title: 'The Science of Sleep: Unlocking the Secrets to Restful Nights',
    category: NewsArticlesCategory.maternity,
    date: '30 Jun 2023',
    hospital: 'Hermina Jatinegara',
    imageUrl: 'https://images.unsplash.com/photo-1519494140681-8b17d830a3e9',
  )
];


class HealthArticleListController
    extends StateNotifier<HealthArticleListState> {

  HealthArticleListController() : super( HealthArticleListState(data: _data));


}

final healthArticleListControllerProvider = StateNotifierProvider.autoDispose<
    HealthArticleListController, HealthArticleListState>(
  (ref) {
    return HealthArticleListController();
  },
);
