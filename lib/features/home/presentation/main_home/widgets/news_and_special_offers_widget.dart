import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

final List<String> _imgList = [
  'https://images.unsplash.com/photo-1627495396837-a756c3267f77',
  'https://images.unsplash.com/photo-1627495396837-a756c3267f77',
  'https://images.unsplash.com/photo-1627495396837-a756c3267f77',
  'https://images.unsplash.com/photo-1627495396837-a756c3267f77',
];

class NewsAndSpecialOffersWidget extends ConsumerWidget {
  const NewsAndSpecialOffersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final controller = ref.read(homeControllerProvider.notifier);
    // final state = ref.watch(homeControllerProvider);

    return Column(
      children: [
        Row(
          children: [
            Text(
              LocaleKeys.text_newsAndSpecialOffers.tr(),
              style: TypographyTheme.textLSemiBold,
            ),
            const Spacer(),
            Flexible(
              child: GestureDetector(
                onTap: () => context.pushNamed(
                  AppRoute.newsAndSpecialOffers,
                ),
                child: Text(
                  LocaleKeys.text_viewAll.tr(),
                  style: TypographyTheme.textMSemiBold
                      .fontColor(BaseColor.primary3),
                ),
              ),
            ),
          ],
        ),
        Gap.h20,
        CarouselSliderWidget<String>(
          items: _imgList,
          itemBuilder: (_, __, imgUrl) {
            return Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                horizontal: BaseSize.customWidth(6),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  BaseSize.radiusMd,
                ),
              ),
              child: Image.network(
                imgUrl,
                fit: BoxFit.fill,
              ),
            );
          },
        ),
      ],
    );
  }
}
