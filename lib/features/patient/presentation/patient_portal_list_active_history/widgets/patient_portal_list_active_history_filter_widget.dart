import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class PatientPortalListActiveHistoryFilterWidget extends StatelessWidget {
  const PatientPortalListActiveHistoryFilterWidget(
      {super.key, required this.onTapSubmitFilter});

  final void Function() onTapSubmitFilter;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showCustomDialogWidget(
          context,
          isScrollControlled: true,
          title: LocaleKeys.text_filter.tr(),
          hideLeftButton: true,
          btnRightText: LocaleKeys.text_submit.tr(),
          headerActionIcon: Assets.icons.line.rotate.svg(),
          onTap: onTapSubmitFilter,
          content: const _BuildBottomSheet(),
        );
      },
      child: Assets.icons.line.filter.svg(
        colorFilter: BaseColor.primary4.filterSrcIn,
      ),
    );
  }
}

class _BuildBottomSheet extends StatelessWidget {
  const _BuildBottomSheet();

  @override
  Widget build(BuildContext context) {
    String addChoosePrefix(String text) =>
        "${LocaleKeys.text_choose.tr()} $text";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.customWidth(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gap.h24,
          InputFormWidget.dropdown(
            hintText: addChoosePrefix(LocaleKeys.text_type.tr()),
            hasIconState: false,
            label: LocaleKeys.text_type.tr(),
            onBodyTap: () {},
            validator: null,
          ),
          Gap.h24,
          Text(
            LocaleKeys.text_date.tr(),
            style: TypographyTheme.textMRegular.fontColor(
              BaseColor.neutral.shade50,
            ),
          ),
          Gap.customGapHeight(2),
          Row(
            children: [
              Expanded(
                child: InputFormWidget(
                  hintText: LocaleKeys.text_from.tr(),
                  hasIconState: false,
                  suffixIcon: Assets.icons.line.calendar.svg(
                    height: BaseSize.w24,
                    width: BaseSize.w24,
                    colorFilter: BaseColor.neutral.shade60.filterSrcIn,
                  ),
                  onBodyTap: () {},
                  validator: null,
                ),
              ),
              Gap.customGapWidth(10),
              Expanded(
                child: InputFormWidget(
                  hintText: LocaleKeys.text_to.tr(),
                  hasIconState: false,
                  suffixIcon: Assets.icons.line.calendar.svg(
                    height: BaseSize.w24,
                    width: BaseSize.w24,
                    colorFilter: BaseColor.neutral.shade60.filterSrcIn,
                  ),
                  onBodyTap: () {},
                  validator: null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
