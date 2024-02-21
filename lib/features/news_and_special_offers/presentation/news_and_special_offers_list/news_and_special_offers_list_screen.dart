import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';

import 'package:halo_hermina/features/health_article/presentation/health_article_list/widgets/news_articles_layout_widget.dart';
import 'package:halo_hermina/core/constants/enums/news_articles_category_enum.dart';
import 'package:halo_hermina/features/health_article/domain/news_articles_model.dart';
import 'package:halo_hermina/features/news_and_special_offers/presentation/news_and_special_offers_list/news_and_special_offers_list_controller.dart';

class NewsAndSpecialOffersListScreen extends ConsumerWidget {
  const NewsAndSpecialOffersListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.read(newsAndSpecialOffersListControllerProvider.notifier);
    final state = ref.watch(newsAndSpecialOffersListControllerProvider);

    return NewsArticlesLayoutWidget(
      data: state.data,
      title: LocaleKeys.text_newsAndSpecialOffers.tr(),
      onPressedCardItem: (NewsArticlesModel value) {
        context.pushNamed(AppRoute.healthArticleDetail);
      },
      onChangedSelectedCategory: (NewsArticlesCategory value) {},
      onChangedSearchText: (String value) {},
    );
  }
}
