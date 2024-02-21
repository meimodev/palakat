import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/card/card_widget.dart';
import 'package:halo_hermina/core/widgets/chips/chips_widget.dart';
import 'package:halo_hermina/core/constants/enums/news_articles_category_enum.dart';
import 'package:halo_hermina/features/health_article/domain/news_articles_model.dart';

class NewsArticlesListItemWidget extends StatelessWidget {
  const NewsArticlesListItemWidget({
    super.key,
    required this.data,
    required this.onPressedCard,
    this.showCategory = true,
  });

  final bool showCategory;
  final NewsArticlesModel data;
  final void Function(NewsArticlesModel data) onPressedCard;

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w16,
        vertical: BaseSize.w16,
      ),
      onTap: () => onPressedCard(data),
      content: [
        SizedBox(
          height: BaseSize.customHeight(120),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                ),
                child: Image.network(
                  data.imageUrl,
                  width: BaseSize.customWidth(100),
                  height: BaseSize.customWidth(100),
                  fit: BoxFit.cover,
                ),
              ),
              Gap.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    showCategory
                        ? ChipsWidget(
                            title: data.category.nameTranslated,
                            color: BaseColor.primary1,
                            textColor: BaseColor.primary3,
                            size: ChipsSize.small,
                          )
                        : const SizedBox(),
                    Gap.h4,
                    Text(
                      data.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TypographyTheme.textLSemiBold,
                      textAlign: TextAlign.left,
                    ),
                    Gap.h8,
                    Row(
                      children: [
                        Text("${LocaleKeys.text_by.tr()} ",
                            style: TypographyTheme.textXSRegular.toNeutral50,
                            textAlign: TextAlign.left),
                        Flexible(
                          child: Text(data.hospital,
                              overflow: TextOverflow.ellipsis,
                              style: TypographyTheme.textXSSemiBold.toPrimary,
                              textAlign: TextAlign.left),
                        ),
                        Gap.w4,
                        Assets.icons.fill.ellipse.svg(
                          width: BaseSize.w4,
                          height: BaseSize.w4,
                          colorFilter: BaseColor.neutral.shade20.filterSrcIn,
                        ),
                        Gap.w4,
                        Text(
                          data.date,
                          style: TypographyTheme.textXSRegular
                              .copyWith(color: BaseColor.neutral.shade50),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
