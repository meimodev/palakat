import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class BottomSheetSortWidget extends StatelessWidget {
  const BottomSheetSortWidget({
    super.key,
    required this.onSelectedSort,
  });

  final void Function(String value) onSelectedSort;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Assets.icons.line.sort.svg(
        width: BaseSize.w24,
        height: BaseSize.w24,
        colorFilter: BaseColor.primary3.filterSrcIn,
      ),
      onTap: () {
        showSelectSingleWidget<String>(
          context,
          title: LocaleKeys.text_location.tr(),
          selectedValue: null,
          getLabel: (val) => val,
          getValue: (val) => val,
          onSave: (val) {
            onSelectedSort(val);
          },
          options: [
            LocaleKeys.text_highestToLowest.tr(),
            LocaleKeys.text_lowestToHighest.tr(),
          ],
        );
      },
    );
  }
}
