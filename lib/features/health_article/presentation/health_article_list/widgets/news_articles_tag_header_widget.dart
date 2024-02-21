import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/widgets/chips/chips_widget.dart';
import 'package:halo_hermina/core/constants/enums/news_articles_category_enum.dart';

class NewsArticlesTagHeaderWidget extends StatefulWidget {
  const NewsArticlesTagHeaderWidget({
    super.key,
    required this.tags,
    required this.onChangedTag,
  });

  final List<NewsArticlesCategory> tags;
  final void Function(NewsArticlesCategory value) onChangedTag;

  @override
  State<NewsArticlesTagHeaderWidget> createState() =>
      _NewsArticlesTagHeaderWidgetState();
}

class _NewsArticlesTagHeaderWidgetState
    extends State<NewsArticlesTagHeaderWidget> {
  NewsArticlesCategory selected = NewsArticlesCategory.all;

  @override
  Widget build(BuildContext context) {
    final tagsWithAll = [NewsArticlesCategory.all,...widget.tags ];
    return SizedBox(
      height: BaseSize.h36,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: tagsWithAll.length,
        padding: horizontalPadding,
        itemBuilder: (context, index) {
          final tag = tagsWithAll[index];
          return ChipsWidget(
            onTap: () {
              setState(() => selected = tag);
              widget.onChangedTag(tag);
            },
            title: tag.nameTranslated,
            isSelected: selected == tag,
          );
        },
        separatorBuilder: (context, index) {
          return Gap.customGapWidth(10);
        },
      ),
    );
  }
}
