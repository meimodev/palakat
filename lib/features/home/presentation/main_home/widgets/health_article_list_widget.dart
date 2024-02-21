import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/home/presentation/main_home/widgets/widgets.dart';

List<Map<String, dynamic>> _articles = [
  {
    "title": "Breast-Conserving Surgery with or without Irradiation",
    "image": "https://images.unsplash.com/photo-1519494140681-8b17d830a3e9",
    "tags": ['Cancer', '+2 More']
  },
  {
    "title": "Breast-Conserving Surgery with or without Irradiation",
    "image": "https://images.unsplash.com/photo-1519494140681-8b17d830a3e9",
    "tags": ['Cancer', '+2 More']
  },
  {
    "title": "Breast-Conserving Surgery with or without Irradiation",
    "image": "https://images.unsplash.com/photo-1519494140681-8b17d830a3e9",
    "tags": ['Cancer', '+2 More']
  },
  {
    "title": "Breast-Conserving Surgery with or without Irradiation",
    "image": "https://images.unsplash.com/photo-1519494140681-8b17d830a3e9",
    "tags": ['Cancer', '+2 More']
  },
];

class HealthArticleListWidget extends StatelessWidget {
  const HealthArticleListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              LocaleKeys.text_healthArticle.tr(),
              style: TypographyTheme.textLSemiBold,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => {context.pushNamed(AppRoute.healthArticle)},
              child: Text(
                LocaleKeys.text_viewAll.tr(),
                style:
                    TypographyTheme.textMSemiBold.fontColor(BaseColor.primary3),
              ),
            ),
          ],
        ),
        Gap.h20,
        SizedBox(
          height: BaseSize.customHeight(300),
          child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              separatorBuilder: (_, __) => Gap.w12,
              itemCount: _articles.length,
              itemBuilder: (_, index) {
                var image = _articles[index]['image'];
                var title = _articles[index]['title'];
                var tags = _articles[index]['tags'];

                return SizedBox(
                  width: BaseSize.customWidth(288),
                  child: HealthArticleItemWidget(
                    image: image,
                    title: title,
                    tags: tags,
                    onTap: () =>
                        {context.pushNamed(AppRoute.healthArticleDetail)},
                  ),
                );
              }),
        ),
      ],
    );
  }
}
