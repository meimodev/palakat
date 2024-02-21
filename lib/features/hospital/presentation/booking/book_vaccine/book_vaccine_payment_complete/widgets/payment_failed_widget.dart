import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class PaymentFailedWidget extends StatelessWidget {
  const PaymentFailedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      type: ScaffoldType.accountGradient,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.images.moneyFailed.image(
              height: BaseSize.customHeight(100),
              width: BaseSize.customWidth(100),
            ),
            Gap.h20,
            Text(
              LocaleKeys.text_paymentFailed.tr(),
              style: TypographyTheme.textXLBold
                  .fontColor(BaseColor.neutral.shade80),
            ),
            Gap.h16,
            Text(
              LocaleKeys.text_yourPaymentIsFailed.tr(),
              style: TypographyTheme.textLRegular
                  .fontColor(BaseColor.neutral.shade60),
              textAlign: TextAlign.center,
            ),
            Gap.h16,
            ButtonWidget.primary(
              text: LocaleKeys.text_backToPaymentMethod.tr(),
              isEnabled: true,
              onTap: () {
                context.pushNamed(AppRoute.selfCheckInConsultationVirtualQueue);
              },
            ),
            Gap.h16,
            ButtonWidget.outlined(
              text: LocaleKeys.text_backToHome.tr(),
              isEnabled: true,
              onTap: () {
                // context.pushNamed(AppRoute.home);
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
