import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/food_menu_request/presentations/food_menu_request_summary/widgets/widgets.dart';

class OtherServiceWidget extends StatelessWidget {
  const OtherServiceWidget({
    super.key,
    required this.otherService,
    required this.onCheckedChanged,
  });

  final List<Map<String, dynamic>> otherService;
  final Function(int, bool) onCheckedChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: BaseSize.h4),
      decoration: BoxDecoration(
        border: Border.all(color: BaseColor.neutral.shade20, width: 1),
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: Column(
          children: [
            Row(
              children: [
                Assets.icons.line.pill.svg(
                    height: BaseSize.customHeight(24),
                    width: BaseSize.customHeight(24),
                    colorFilter: BaseColor.primary3.filterSrcIn),
                Gap.w8,
                Text(
                  LocaleKeys.text_otherService.tr(),
                  style: TypographyTheme.bodySemiBold.toNeutral80,
                ),
              ],
            ),
            Gap.h8,
            const HLineDivider(),
            Gap.h8,
            for (int i = 0; i < otherService.length; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CheckBoxWidget.primary(
                        value: otherService[i]['ischecked'],
                        onChanged: (newValue) {
                          onCheckedChanged(i, newValue);
                        },
                        size: CheckboxSize.small,
                      ),
                      Gap.w8,
                      Expanded(
                        child: Text(
                          otherService[i]['service_name'],
                          style: TypographyTheme.textMSemiBold.toNeutral80,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          softWrap: true,
                        ),
                      ),
                      Gap.w12,
                      Text(
                        otherService[i]['price'],
                        style: TypographyTheme.textMRegular.toNeutral80,
                      ),
                    ],
                  ),
                  Gap.h4,
                  Gap.h16,
                ],
              ),
          ],
        ),
      ),
    );
  }
}
