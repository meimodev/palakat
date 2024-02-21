import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/appbar/appbar_widget.dart';
import 'package:halo_hermina/core/widgets/chips/chips_widget.dart';
import 'package:halo_hermina/core/widgets/scaffold/scaffold_widget.dart';
import 'package:halo_hermina/core/constants/enums/news_articles_category_enum.dart';
import 'package:halo_hermina/features/health_article/domain/news_articles_model.dart';

class NewsArticlesDetailLayoutWidget extends StatelessWidget {
  const NewsArticlesDetailLayoutWidget({
    super.key,
    required this.data,
    required this.onPressedShare,
  });

  final NewsArticlesModel data;
  final void Function() onPressedShare;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      appBar: AppBarWidget(
        backgroundColor: BaseColor.neutral.shade0,
        title: data.category.nameTranslated,
        actions: [
          InkWell(
            onTap: onPressedShare,
            child: Assets.icons.line.share.svg(
              width: BaseSize.w24,
              height: BaseSize.w24,
              colorFilter: BaseColor.neutral.shade80.filterSrcIn,
            ),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChipsWidget(
                title: data.category.nameTranslated,
                color: BaseColor.primary1,
                textColor: BaseColor.primary3,
                size: ChipsSize.small,
              ),
              Gap.h16,
              Text(
                data.title,
                style: TypographyTheme.textLSemiBold.toNeutral80,
              ),
              Gap.h16,
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      BaseSize.radiusLg,
                    ),
                  ),
                ),
                child: Image.network(
                  data.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Gap.h16,
              Row(
                children: [
                  Text(
                    '${LocaleKeys.text_postedOn.tr()}: ${data.date} ${LocaleKeys.text_by.tr()} ',
                    style: TypographyTheme.textXSRegular.toNeutral50,
                  ),
                  Text(
                    data.hospital,
                    style: TypographyTheme.textXSSemiBold.toPrimary,
                  )
                ],
              ),
              if (data.reviewedBy.isNotEmpty) ...[
                Row(
                  children: [
                    Text(
                      '${LocaleKeys.text_reviewedBy.tr()}: ',
                      style: TypographyTheme.textXSRegular.toNeutral50,
                    ),
                    Text(
                      data.reviewedBy,
                      style: TypographyTheme.textXSSemiBold.toPrimary,
                    )
                  ],
                )
              ] else ...[
                Gap.customGapHeight(1)
              ],
              Gap.h16,
              Html(
                data: data.content,
                style: {
                  "p": Style(),
                },
              ),
              Gap.h16,
            ],
          ),
        ),
      ),
    );
  }
}
