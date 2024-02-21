import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';


class PatientRegistrationStatusTag extends StatelessWidget {
  const PatientRegistrationStatusTag(
      {super.key, required this.registered});

  final bool registered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w8,
        vertical: BaseSize.customWidth(3.5),
      ),
      decoration: BoxDecoration(
        color: registered ? BaseColor.primary1 : BaseColor.yellow.shade50,
        border: Border.all(
            width: 1,
            color: registered ? BaseColor.primary2 : BaseColor.yellow.shade100),
        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
      ),
      child: Text(
        registered
            ? LocaleKeys.text_registered.tr()
            : LocaleKeys.text_unRegistered.tr(),
        style: TypographyTheme.textSRegular.copyWith(
          color: registered ? BaseColor.primary3 : BaseColor.yellow.shade500,
        ),
      ),
    );
  }
}
