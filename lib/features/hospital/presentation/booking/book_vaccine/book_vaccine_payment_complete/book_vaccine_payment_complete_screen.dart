import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/food_menu_request/presentations/food_menu_request_summary/widgets/widgets.dart';

String vaNumber = "8241002201150001";
String countDown = "00:29:24";
String paymentCreated = "Tue, 28 Mar 2023 | 12:45";
String totalPayment = "Rp. 451.000";

List<String> _mBCAPaymentNotes = [
  "Enter the BCA Mobile application",
  "Select the m-BCA menu, then enter the code m-BCA access",
  "Select m-Transfer > BCA Virtual Account",
  "Select from the Transfer List, or enter the code from Halo Hermina 8241002201150001",
  "Enter the amount you wish to pay",
  "Enter the m-BCA pin",
  "Payment is complete. Notification please kept as proof of payment",
];

List<Map<String, dynamic>> paymentMethod = [
  {
    "type": "ATM BCA",
    "content": [
      "Enter the BCA Mobile application",
      "Select the m-BCA menu, then enter the code m-BCA access",
      "Select m-Transfer > BCA Virtual Account",
      "Select from the Transfer List, or enter the code from Halo Hermina 8241002201150001",
      "Enter the amount you wish to pay",
      "Enter the m-BCA pin",
      "Payment is complete. Notification please kept as proof of payment",
    ],
  },
  {
    "type": "m-BCA (BCA Mobile)",
    "content": [
      "Enter the BCA Mobile application",
      "Select the m-BCA menu, then enter the code m-BCA access",
      "Select m-Transfer > BCA Virtual Account",
      "Select from the Transfer List, or enter the code from Halo Hermina 8241002201150001",
      "Enter the amount you wish to pay",
      "Enter the m-BCA pin",
      "Payment is complete. Notification please kept as proof of payment",
    ],
  },
  {
    "type": "Internet Banking BCA",
    "content": [
      "Enter the BCA Mobile application",
      "Select the m-BCA menu, then enter the code m-BCA access",
      "Select m-Transfer > BCA Virtual Account",
      "Select from the Transfer List, or enter the code from Halo Hermina 8241002201150001",
      "Enter the amount you wish to pay",
      "Enter the m-BCA pin",
      "Payment is complete. Notification please kept as proof of payment",
    ],
  },
];

class BookVaccinePaymentCompleteScreen extends ConsumerWidget {
  const BookVaccinePaymentCompleteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final controller = ref.watch(choosePatientControllerProvider.notifier);
    // final state = ref.watch(choosePatientControllerProvider);
    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        hasLeading: false,
        height: BaseSize.customHeight(70),
        title: " ${LocaleKeys.text_completePayment.tr()}",
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: BaseColor.neutral.shade20,
                        ),
                        borderRadius: BorderRadius.circular(
                          BaseSize.radiusLg,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.text_paymentDeadline.tr(),
                              style: TypographyTheme.textLRegular
                                  .fontColor(BaseColor.neutral.shade60),
                            ),
                            Gap.h16,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  paymentCreated,
                                  style: TypographyTheme.textLRegular
                                      .fontColor(BaseColor.neutral.shade80),
                                ),
                                Text(
                                  countDown,
                                  style: TypographyTheme.textLSemiBold
                                      .fontColor(BaseColor.red),
                                ),
                              ],
                            ),
                            Gap.h8,
                            const HLineDivider(),
                            Gap.h8,
                            Text(
                              LocaleKeys.text_virtualAccountNumber.tr(),
                              style: TypographyTheme.textLRegular
                                  .fontColor(BaseColor.neutral.shade60),
                            ),
                            Gap.h16,
                            Row(
                              children: [
                                Text(
                                  vaNumber,
                                  style: TypographyTheme.textLSemiBold
                                      .fontColor(BaseColor.neutral.shade80),
                                ),
                                Assets.icons.line.copy.svg(
                                    colorFilter:
                                        BaseColor.primary3.filterSrcIn),
                              ],
                            ),
                            Gap.h16,
                            Text(
                              "Total ${LocaleKeys.text_payment.tr()}",
                              style: TypographyTheme.textLRegular
                                  .fontColor(BaseColor.neutral.shade60),
                            ),
                            Gap.h16,
                            Text(
                              totalPayment,
                              style: TypographyTheme.textLSemiBold
                                  .fontColor(BaseColor.neutral.shade80),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: BaseColor.neutral.shade20,
                        ),
                        borderRadius: BorderRadius.circular(
                          BaseSize.radiusLg,
                        ),
                      ),
                      child: Column(
                        children: paymentMethod.map((method) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            child: ExpandablePanel(
                              theme: const ExpandableThemeData(
                                headerAlignment:
                                    ExpandablePanelHeaderAlignment.center,
                                tapBodyToCollapse: true,
                                hasIcon: true,
                                useInkWell: false,
                              ),
                              header: Text(
                                method['type'],
                                style:
                                    TypographyTheme.textLSemiBold.toNeutral80,
                              ),
                              collapsed: const HLineDivider(),
                              expanded: Column(
                                children: _buildPreparation(method['content']),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ButtonWidget.primary(
              text: LocaleKeys.text_backToHome.tr(),
              onTap: () {
                context.pushNamed(AppRoute.home);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPreparation(List<String> preps) {
    final style =
        TypographyTheme.textLRegular.fontColor(BaseColor.neutral.shade60);
    final List<Widget> iconsWithText = [];

    if (preps.isEmpty) {
      iconsWithText.add(
        Text(
          LocaleKeys.text_noPreparationRequired.tr(),
          style: style,
        ),
      );
      return iconsWithText;
    }

    for (int i = 0; i < preps.length; i++) {
      int j = i + 1;
      final row = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${j.toString()}. ",
            style: style,
          ),
          Gap.w8,
          Expanded(
            child: Text(
              preps[i],
              style: style,
            ),
          ),
        ],
      );

      iconsWithText.add(row);
    }

    return iconsWithText;
  }
}
