import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/enums/news_articles_category_enum.dart';
import 'package:halo_hermina/features/health_article/domain/news_articles_model.dart';
import 'package:halo_hermina/features/health_article/presentation/health_article_detail/health_article_detail_state.dart';

final _data = NewsArticlesModel(
    title: 'Holistic Approaches to Stress Management: Balancing Mind and Body',
    category: NewsArticlesCategory.maternity,
    date: '30 Jun 2023',
    hospital: 'Hermina Jatinegara',
    imageUrl: 'https://images.unsplash.com/photo-1519494140681-8b17d830a3e9',
    reviewedBy: 'dr. Iin Irnawati, SpJP, FIHA ',
    content: r"""
<p>Hello Hermina Friends!</p>

<p>In the context of &quot;National Midwife Day&quot; Hermina Solo General Hospital is giving special price promos for midwives for the Medical Check-Up examination package.</p>

<p>There is a Complete Package and a Simple Package. Come on, take advantage of this opportunity.</p>

<p>There is a Complete Package and a Simple Package. Come on, take advantage of this opportunity.</p>

<p>There is a Complete Package and a Simple Package. Come on, take advantage of this opportunity.</p>

<p>There is a Complete Package and a Simple Package. Come on, take advantage of this opportunity.</p>

<p>If Hermina Friends are interested or need further information, please contact: 0857-2288-0552 (Vinda)</p>
""");

class HealthArticleDetailController
    extends StateNotifier<HealthArticleDetailState> {
  HealthArticleDetailController()
      : super(HealthArticleDetailState(data: _data));
}

final healthArticleDetailControllerProvider = StateNotifierProvider.autoDispose<
    HealthArticleDetailController, HealthArticleDetailState>(
  (ref) {
    return HealthArticleDetailController();
  },
);
