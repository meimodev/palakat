import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/home/presentation/main_home/widgets/widgets.dart';

class OurHospitalListWidget extends StatelessWidget {
  const OurHospitalListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              LocaleKeys.text_ourHospitals.tr(),
              style: TypographyTheme.textLSemiBold,
            ),
            const Spacer(),
            Flexible(
              child: GestureDetector(
                onTap: () => {context.pushNamed(AppRoute.ourHospital)},
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: OurHospitalItemWidget(
                    title: "Hermina Hospital Serpong",
                    onTap: () {},
                    image:
                        "https://images.unsplash.com/photo-1626315869436-d6781ba69d6e")),
            Gap.w12,
            Expanded(
                child: OurHospitalItemWidget(
                    title: "Hermina Hospital Serpong",
                    onTap: () {},
                    image:
                        "https://images.unsplash.com/photo-1626315869436-d6781ba69d6e")),
            Gap.w12,
            Expanded(
                child: OurHospitalItemWidget(
                    title: "Hermina Hospital Serpong",
                    onTap: () {},
                    image:
                        "https://images.unsplash.com/photo-1626315869436-d6781ba69d6e"))
          ],
        )
      ],
    );
  }
}
