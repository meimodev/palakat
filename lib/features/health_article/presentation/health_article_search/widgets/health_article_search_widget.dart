import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/health_article/presentation/health_article_search/health_article_search_controller.dart';

class HealthArticleSearchWidget extends ConsumerWidget {
  const HealthArticleSearchWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(HealthArticleSearchControllerProvider.notifier);
    return Column(
      children: [
        TextField(
          controller: controller.textController,
          onSubmitted: (state) {
            context.pushNamed(AppRoute.healthArticle);
          },
          decoration: InputDecoration(
              prefixIcon: IconButton(
                  onPressed: () {},
                  icon: Assets.icons.line.search.svg(
                    width: 20.0,
                    height: 20.0,
                    colorFilter: BaseColor.neutral.shade40.filterSrcIn,
                  )),
              suffixIcon: IconButton(
                onPressed: () {
                  controller.textController.clear();
                },
                icon: Assets.icons.line.times.svg(
                  width: 24.0,
                  height: 24.0,
                  colorFilter: BaseColor.neutral.shade40.filterSrcIn,
                ),
              ),
              hintText: LocaleKeys.text_searchArticle.tr(),
              hintStyle: TextStyle(color: BaseColor.neutral.shade40),
              border: InputBorder.none),
        ),
      ],
    );
  }
}
