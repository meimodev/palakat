import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class ForgotPinLayoutWidget extends StatelessWidget {
  const ForgotPinLayoutWidget({super.key, required this.tecVerificationCode});

  final TextEditingController tecVerificationCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputFormWidget(
          controller: tecVerificationCode,
          label: LocaleKeys.text_verificationCode.tr(),
          hintText: "${LocaleKeys.text_enter.tr()} "
              "${LocaleKeys.text_verificationCode.tr()}",
          hasIconState: false,
          keyboardType: TextInputType.text,
          hasBorderState: false,
          validator:
          ValidationBuilder(label: LocaleKeys.text_verificationCode.tr())
              .required()
              .build(),
        ),
        Gap.customGapHeight(30),
      ],
    );
  }
}
