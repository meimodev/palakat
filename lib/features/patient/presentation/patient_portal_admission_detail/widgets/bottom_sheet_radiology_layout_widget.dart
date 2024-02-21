import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/patient/presentation/patient_portal_admission_detail/widgets/empty_list_layout_widget.dart';

class BottomSheetRadiologyLayoutWidget extends StatelessWidget {
  const BottomSheetRadiologyLayoutWidget({
    super.key,
    required this.list,
  });

  final List<Map<String, dynamic>> list;

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const EmptyListLayoutWidget();
    }

    return SingleChildScrollView(
      child: Padding(
        padding: horizontalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gap.h24,
            for (int i = 0; i < list.length; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    list[i]["title"],
                    style: TypographyTheme.textMSemiBold.toNeutral80,
                  ),
                  Gap.h12,
                  Text(
                    "${LocaleKeys.text_finding.tr()}: ",
                    style: TypographyTheme.textMRegular.toNeutral60,
                  ),
                  for (int j = 0; j < list[i]["contents"].length; j++)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        j == 0 ? Gap.h4 : const SizedBox(),
                        Text(
                          "${list[i]["contents"][j]["text"].toString().toUpperCase()}: "
                          "${list[i]["contents"][j]["value"]}",
                          style: TypographyTheme.textMRegular.toNeutral60,
                        ),
                        Gap.h4,
                      ],
                    ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
