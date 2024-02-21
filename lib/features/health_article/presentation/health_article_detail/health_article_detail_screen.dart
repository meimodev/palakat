import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'health_article_detail_controller.dart';
import 'widgets/widgets.dart';

class HealthArticleDetailScreen extends ConsumerWidget {
  const HealthArticleDetailScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(healthArticleDetailControllerProvider.notifier);
    final state = ref.watch(healthArticleDetailControllerProvider);

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
