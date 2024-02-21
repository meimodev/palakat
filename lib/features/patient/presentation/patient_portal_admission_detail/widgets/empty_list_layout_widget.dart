import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class EmptyListLayoutWidget extends StatelessWidget {
  const EmptyListLayoutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: BaseSize.customHeight(80),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.icons.line.treatment.svg(
                width: BaseSize.customWidth(70),
                height: BaseSize.customHeight(70),
                colorFilter: BaseColor.neutral.shade40.filterSrcIn),
            Gap.customGapHeight(10),
            Text(
              LocaleKeys.text_noDataAvailable.tr(),
              style: TypographyTheme.textMRegular.toNeutral50,
            ),
          ],
        ),
      ),
    );
  }
}
