import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'widgets.dart';

class BookPackageDetailWidget extends StatelessWidget {
  const BookPackageDetailWidget({
    super.key,
    required this.onPressedBookNow,
    required this.category,
    required this.name,
    required this.price,
    this.discountPrice,
    required this.information,
    required this.preparation,
    required this.termsAndCondition,
  });

  final String category;
  final String name;
  final String price;
  final String? discountPrice;
  final String information;
  final String termsAndCondition;
  final List<String> preparation;
  final void Function() onPressedBookNow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: BaseSize.customWidth(20),
            ),
            child: Column(
              children: [
                Gap.customGapHeight(10),
                PackageInfoDiscountLayoutWidget(
                  category: category,
                  name: name,
                  price: price,
                  discountPrice: discountPrice,
                ),
                Gap.h16,
                CardWidget(
                  icon: Assets.icons.line.xRay,
                  title: LocaleKeys.text_information.tr(),
                  content: [
                    Text(
                      information,
                      style: TypographyTheme.textLRegular
                          .fontColor(BaseColor.neutral.shade60),
                    ),
                  ],
                ),
                Gap.h16,
                CardWidget(
                  icon: Assets.icons.line.listOfParts,
                  title: LocaleKeys.text_preparationAndProcedure.tr(),
                  content: _buildPreparation(preparation),
                ),
                Gap.h16,
                CardWidget(
                  icon: Assets.icons.line.listOfParts,
                  title: LocaleKeys.text_termAndConditionsSymbol.tr(),
                  content: [
                    Text(
                      termsAndCondition,
                      style: TypographyTheme.textLRegular
                          .fontColor(BaseColor.neutral.shade60),
                    ),
                  ],
                ),
                Gap.customGapHeight(38),
              ],
            ),
          ),
        ),
        BottomActionWrapper(
          actionButton: ButtonWidget.primary(
            buttonSize: ButtonSize.medium,
            text: LocaleKeys.text_bookAppointment.tr(),
            onTap: onPressedBookNow,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPreparation(List<String> preps) {
    final style =
        TypographyTheme.textLRegular.fontColor(BaseColor.neutral.shade60);
    if (preps.isEmpty) {
      return [
        Text(
          LocaleKeys.text_noPreparationRequired.tr(),
          style: style,
        ),
      ];
    }

    if (preps.length == 1) {
      return [
        Text(
          preps.first,
          style: style,
        ),
      ];
    }

    return [
      for (final string in preps)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Gap.customGapHeight(10),
                Assets.icons.fill.ellipse.svg(
                    height: BaseSize.customHeight(7),
                    width: BaseSize.customHeight(7),
                    colorFilter: BaseColor.neutral.shade60.filterSrcIn),
              ],
            ),
            Gap.w8,
            Expanded(
              child: Text(
                string,
                style: style,
              ),
            ),
          ],
        ),
    ];
  }
}
