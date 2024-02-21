import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/constants/enums/news_articles_category_enum.dart';
import 'package:halo_hermina/features/health_article/domain/news_articles_model.dart';

import 'health_article_list_controller.dart';

import 'widgets/widgets.dart';

class HealthArticleListScreen extends ConsumerWidget {
  const HealthArticleListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(healthArticleListControllerProvider.notifier);
    final state = ref.watch(healthArticleListControllerProvider);

    return NewsArticlesLayoutWidget(
      data: state.data,
      title: LocaleKeys.text_healthArticle.tr(),
      onPressedCardItem: (NewsArticlesModel value) {
        context.pushNamed(AppRoute.healthArticleDetail);
      },
      onChangedSelectedCategory: (NewsArticlesCategory value) {},
      onChangedSearchText: (String value) {},
    );
  }
}
