import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/health_article/presentation/health_article_detail/widgets/news_articles_detail_widget.dart';

import 'news_and_special_offers_detail_controller.dart';

class NewsAndSpecialOffersDetailScreen extends ConsumerWidget {
  const NewsAndSpecialOffersDetailScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.read(newsAndSpecialOffersDetailControllerProvider.notifier);
    final state = ref.watch(newsAndSpecialOffersDetailControllerProvider);

    return NewsArticlesDetailLayoutWidget(
      data: state.data,
      onPressedShare: () {
        print("Share button pressed");
        Share.share(
          title: "Share Health Article",
          text: "Share Health Article",
        );
      },
    );
  }
}
