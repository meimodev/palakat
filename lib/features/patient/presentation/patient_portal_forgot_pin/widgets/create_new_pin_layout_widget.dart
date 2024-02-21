import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class CreateNewPinLayoutWidget extends StatefulWidget {
  const CreateNewPinLayoutWidget({
    super.key,
    required this.tecPin,
    required this.tecPinConfirm,
    required this.onChangedPinAndPinConfirmText,
  });

  final TextEditingController tecPin;
  final TextEditingController tecPinConfirm;

  final void Function() onChangedPinAndPinConfirmText;

  @override
  State<CreateNewPinLayoutWidget> createState() =>
      _CreateNewPinLayoutWidgetState();
}

class _CreateNewPinLayoutWidgetState extends State<CreateNewPinLayoutWidget> {
  @override
  void initState() {
    super.initState();

    widget.onChangedPinAndPinConfirmText();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputFormWidget(
          controller: widget.tecPin,
          label: LocaleKeys.text_sixDigitsPin.tr(),
          hintText: "${LocaleKeys.text_enter.tr()} "
              "${LocaleKeys.text_sixDigitsPin.tr()}",
          hasIconState: false,
          keyboardType: TextInputType.text,
          hasBorderState: false,
          onChanged: (_) {
            setState(() {});
            widget.onChangedPinAndPinConfirmText();
          },
          validator: ValidationBuilder(label: LocaleKeys.text_sixDigitsPin.tr())
              .required()
              .build(),
        ),
        Gap.customGapHeight(30),
        InputFormWidget(
          controller: widget.tecPinConfirm,
          label: LocaleKeys.text_confirmationPin.tr(),
          hintText: "${LocaleKeys.text_enter.tr()} "
              "${LocaleKeys.text_confirmationPin.tr()}",
          hasIconState: false,
          keyboardType: TextInputType.text,
          hasBorderState: false,
          onChanged: (_) {
            setState(() {});
            widget.onChangedPinAndPinConfirmText();
          },
          validator:
              ValidationBuilder(label: LocaleKeys.text_confirmationPin.tr())
                  .required()
                  .same(widget.tecPin.text.toString())
                  .build(),
        ),
      ],
    );
  }
}
