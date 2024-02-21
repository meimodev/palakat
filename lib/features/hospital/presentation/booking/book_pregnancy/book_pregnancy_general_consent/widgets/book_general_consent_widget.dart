import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/config/config.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class BookGeneralConsentWidget extends StatelessWidget {
  const BookGeneralConsentWidget({
    super.key,
    required this.state,
    required this.controller,
    required this.htmlData,
  });

  final dynamic state;
  final dynamic controller;
  final String htmlData;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_generalConsent.tr(),
      ),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: BaseSize.customWidth(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    " ${LocaleKeys.text_generalConsent.tr()} ${AppConfig.appName.value}",
                    style: TypographyTheme.bodySemiBold
                        .fontColor(BaseColor.neutral.shade80),
                    textAlign: TextAlign.left,
                  ),
                  Html(
                    data: htmlData,
                    style: {
                      "p": Style(
                        fontSize: FontSize(14.0), // Set font size to 14px
                        fontWeight: FontWeight
                            .normal, // Set font weight to 400 (normal)
                      ),
                    },
                  ),
                ],
              ),
            ),
          ),
          BottomActionWrapper(
              actionButton: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(
                          WidgetTheme.getCheckboxPrimaryColor),
                      value: state.isAgree,
                      onChanged: (bool? value) {
                        controller.onAgreeChange(value);
                      },
                    ),
                  ),
                  Gap.w12,
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                              text: LocaleKeys
                                  .text_byClickingSubmitButtonGeneralConsent
                                  .tr(),
                              style: TypographyTheme.textLRegular
                                  .fontColor(BaseColor.neutral.shade60)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Gap.h20,
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ButtonWidget.outlined(
                      isShrink: true,
                      text: LocaleKeys.text_back.tr(),
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  Gap.w16,
                  Expanded(
                    child: ButtonWidget.primary(
                      color: BaseColor.primary3,
                      isShrink: true,
                      text: LocaleKeys.text_agree.tr(),
                      onTap: () => _showBottomSheet(context),
                    ),
                  ),
                ],
              ),
            ],
          )),
        ],
      ),
    );
  }
}

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
              child: Center(
                child: Assets.icons.fill.slidePanel.svg(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  child: Assets.icons.line.times.svg(),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Assets.images.check.image(
              width: BaseSize.customWidth(100),
              height: BaseSize.customWidth(100),
            ), // Replace with your image
            Gap.h24,
            Text(
              LocaleKeys.text_paymentSuccessful.tr(),
              style: TypographyTheme.textXLBold
                  .fontColor(BaseColor.neutral.shade80),
            ),
            Gap.h20,
            Text(
              LocaleKeys.text_yourPaymentHasBeenSuccessfulYouWill.tr(),
              textAlign: TextAlign.center,
              style: TypographyTheme.textLRegular
                  .fontColor(BaseColor.neutral.shade60),
            ),
            Gap.h36,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 170.0,
                  height: 50.0,
                  child: Expanded(
                    child: ButtonWidget.outlined(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      maxLines: 2,
                      isShrink: true,
                      useAutoSizeText: true,
                      buttonSize: ButtonSize.medium,
                      text: LocaleKeys.text_homepage.tr(),
                      onTap: () {
                        context.pushNamed(AppRoute.home);
                      },
                    ),
                  ),
                ),
                Gap.h16,
                SizedBox(
                  width: 170.0,
                  height: 50.0,
                  child: Expanded(
                    child: ButtonWidget.primary(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      maxLines: 2,
                      isShrink: true,
                      useAutoSizeText: true,
                      buttonSize: ButtonSize.medium,
                      text: LocaleKeys.text_listAppointment.tr(),
                      onTap: () {},
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    },
  );
}
