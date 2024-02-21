import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/core/constants/enums/news_articles_category_enum.dart';
import 'package:halo_hermina/features/health_article/domain/news_articles_model.dart';

import 'widgets.dart';

class NewsArticlesLayoutWidget extends StatefulWidget {
  const NewsArticlesLayoutWidget({
    super.key,
    required this.data,
    required this.title,
    this.showCategory = true,
    required this.onPressedCardItem,
    required this.onChangedSelectedCategory,
    required this.onChangedSearchText,
  });

  final bool showCategory;
  final List<NewsArticlesModel> data;
  final String title;
  final void Function(NewsArticlesModel value) onPressedCardItem;
  final void Function(NewsArticlesCategory value) onChangedSelectedCategory;
  final void Function(String value) onChangedSearchText;

  @override
  State<NewsArticlesLayoutWidget> createState() =>
      _NewsArticlesLayoutWidgetState();
}

class _NewsArticlesLayoutWidgetState extends State<NewsArticlesLayoutWidget> {
  bool searching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
          backgroundColor: BaseColor.neutral.shade0,
          title: widget.title,
          searching: searching,
          onTapButtonCloseSearch: () => setState(() => searching = false),
          actions: [
            InkWell(
              child: Assets.icons.line.search.svg(
                width: BaseSize.w24,
                height: BaseSize.w24,
              ),
              onTap: () => setState(() => searching = true),
            ),
          ]),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: BaseSize.h20),
        child: Column(
          children: [
            widget.showCategory
                ? NewsArticlesTagHeaderWidget(
                    tags: widget.data.map((e) => e.category).toSet().toList(),
                    onChangedTag: widget.onChangedSelectedCategory,
                  )
                : const SizedBox(),
            Gap.h16,
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
                physics: const BouncingScrollPhysics(),
                itemCount: widget.data.length,
                itemBuilder: (_, index) {
                  return NewsArticlesListItemWidget(
                    showCategory: widget.showCategory,
                    data: widget.data[index],
                    onPressedCard: widget.onPressedCardItem,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
