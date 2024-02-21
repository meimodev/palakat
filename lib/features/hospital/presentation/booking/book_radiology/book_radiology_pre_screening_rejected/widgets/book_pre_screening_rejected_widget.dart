import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/assets/fonts.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class BookPreScreeningRejectedWidget extends ConsumerWidget {
  const BookPreScreeningRejectedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScaffoldWidget(
      type: ScaffoldType.normal,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  Assets.images.unhealthy.image(
                    width: BaseSize.customWidth(88),
                    height: BaseSize.customHeight(88),
                  ),
                  Gap.h20,
                  Text(
                    LocaleKeys.text_yourHealthCriteriaIsNotAcceptable.tr(),
                    style: TypographyTheme.textXLBold.toNeutral80,
                    textAlign: TextAlign.center,
                  ),
                  Gap.customGapHeight(10),
                  RichText(
                    text: TextSpan(
                      text: LocaleKeys.text_forFurtherInformation.tr(),
                      style: TypographyTheme.textLRegular.toNeutral60
                          .copyWith(fontFamily: FontFamily.lexend),
                      children: [
                        TextSpan(
                          text: " support@halohermina.com",
                          style: TypographyTheme.textLRegular.toPrimary
                              .copyWith(fontFamily: FontFamily.lexend),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Gap.customGapHeight(30),
              ButtonWidget.primary(
                text: LocaleKeys.text_backToHome.tr(),
                onTap: () {
                  context.pushNamed(AppRoute.home);
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
