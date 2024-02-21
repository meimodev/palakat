import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class AddressCardWidget extends StatelessWidget {
  final void Function()? onTap;
  final void Function()? onDelete;
  final void Function()? onEdit;
  final String label;
  final bool isPrimary;
  final bool isSelected;
  final String name;
  final String phone;
  final String? address;
  final bool outOfRange;

  const AddressCardWidget({
    super.key,
    this.onTap,
    this.onDelete,
    this.onEdit,
    required this.label,
    this.isPrimary = false,
    this.isSelected = false,
    required this.name,
    required this.phone,
    this.address,
    this.outOfRange = false,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      onTap: onTap,
      backgroundColor: isSelected ? BaseColor.primary1 : null,
      borderColor: isSelected ? BaseColor.primary3 : null,
      content: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    label,
                    style: TypographyTheme.textSRegular.toNeutral60,
                  ),
                  if (isPrimary) ...[
                    Gap.w8,
                    ChipsWidget(
                      title: LocaleKeys.text_mainAddress.tr(),
                      color: BaseColor.primary3,
                      textColor: BaseColor.white,
                      size: ChipsSize.small,
                    ),
                  ]
                ],
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: Assets.icons.line.trash.svg(
                height: BaseSize.w20,
                width: BaseSize.w20,
              ),
            ),
          ],
        ),
        Gap.h8,
        Text(
          name.toUpperCase(),
          style: TypographyTheme.textLSemiBold.toNeutral80,
        ),
        Gap.h4,
        Text(
          phone,
          style: TypographyTheme.textMRegular.toNeutral60,
        ),
        Gap.h8,
        if (address.isNotNull())
          Text(
            address!,
            style: TypographyTheme.textSRegular.toNeutral60,
          ),
        ...outOfRange
            ? [
                Gap.h20,
                InlineAlertWidget(
                  message: LocaleKeys
                      .text_locationOutOfRangePleaseDoubleCheckYourLocation
                      .tr(),
                ),
              ]
            : [const SizedBox()],
        Gap.h16,
        ButtonWidget.outlined(
          icon: Assets.icons.line.pencil.svg(
            colorFilter: BaseColor.primary3.filterSrcIn,
            height: BaseSize.w20,
            width: BaseSize.w20,
          ),
          text: LocaleKeys.text_edit.tr(),
          onTap: onEdit,
          buttonSize: ButtonSize.small,
        ),
      ],
    );
  }
}
