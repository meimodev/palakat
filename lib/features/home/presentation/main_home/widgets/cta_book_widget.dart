import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class CTABookWidget extends StatelessWidget {
  const CTABookWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BaseSize.radiusLg),
          color: BaseColor.primary4),
      child: GestureDetector(
        onTap: () {
          context.pushNamed(AppRoute.searchDoctor);
        },
        child: Stack(
          children: [
            Positioned(
              right: -BaseSize.w36,
              top: BaseSize.customHeight(-38),
              child: SizedBox(
                width: BaseSize.customWidth(169),
                height: BaseSize.customWidth(154),
                child: Assets.images.ctaBookOrnament.image(fit: BoxFit.fill),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Assets.images.chatBox.image(width: 52.9),
                  Gap.w12,
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.text_bookDoctor.tr(),
                          style: TypographyTheme.textSBold.toWhite,
                        ),
                        Gap.h4,
                        Text(
                          LocaleKeys.text_makeAnAppointmentWith.tr(),
                          style: TypographyTheme.textXSRegular.toWhite,
                        )
                      ],
                    ),
                  ),
                  Gap.w20,
                  ButtonWidget.primary(
                    color: BaseColor.white,
                    textColor: BaseColor.primary3,
                    overlayColor: BaseColor.white.withOpacity(.5),
                    isShrink: true,
                    text: LocaleKeys.text_bookNow.tr(),
                    buttonSize: ButtonSize.small,
                    padding: EdgeInsets.symmetric(
                        horizontal: BaseSize.w16, vertical: 8),
                    onTap: () {
                      context.pushNamed(
                        AppRoute.searchDoctor,
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
