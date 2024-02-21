import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/health_article/presentation/health_article_search/widgets/health_article_search_widget.dart';

class HealthArticleSearchScreen extends ConsumerWidget {
  const HealthArticleSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBarWidget(actions: [
        Container(
          width: BaseSize.customWidth(320),
          height: BaseSize.customHeight(50),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.fromBorderSide(
              BorderSide(width: 1, color: BaseColor.neutral.shade20),
            ),
          ),
          child: const HealthArticleSearchWidget(),
        ),
      ]),
    );
  }
}
