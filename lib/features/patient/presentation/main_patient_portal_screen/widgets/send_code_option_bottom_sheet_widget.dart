import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:halo_hermina/features/domain.dart';

void showSendCodeOptionBottomSheet(
  BuildContext context, {
  required void Function(OtpProvider provider) onPressedSubmitChooseOption,
  bool isResend = true,
}) {
  showCustomDialogWidget(
    context,
    title: isResend
        ? LocaleKeys.text_resendCode.tr()
        : LocaleKeys.text_sendCode.tr(),
    onTap: () {},
    hideButtonsGap: true,
    hideButtons: true,
    isScrollControlled: true,
    content: SendCodeOptionBottomSheetWidget(
      options: [
        LocaleKeys.text_sms.tr(),
        LocaleKeys.text_whatsApp.tr(),
      ],
      onPressedSubmit: (value) {
        Navigator.pop(context);
        onPressedSubmitChooseOption(
          value == LocaleKeys.text_whatsApp.tr()
              ? OtpProvider.whatsapp
              : OtpProvider.sms,
        );
      },
    ),
  );
}

class SendCodeOptionBottomSheetWidget extends StatefulWidget {
  const SendCodeOptionBottomSheetWidget({
    super.key,
    required this.onPressedSubmit,
    required this.options,
  });

  final void Function(String selectedValue) onPressedSubmit;
  final List<String> options;

  @override
  State<SendCodeOptionBottomSheetWidget> createState() =>
      _SendCodeOptionBottomSheetWidgetState();
}

class _SendCodeOptionBottomSheetWidgetState
    extends State<SendCodeOptionBottomSheetWidget> {
  String selectedValue = "";

  void handleOnChangeValue(String value) {
    setState(() => selectedValue = value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < widget.options.length; i++)
          _buildItem<String>(
            title: widget.options[i],
            selectedValue: selectedValue,
            value: widget.options[i],
            onChangeValue: handleOnChangeValue,
          ),
        Gap.h40,
        BottomActionWrapper(
          actionButton: ButtonWidget.primary(
            text: LocaleKeys.text_submit.tr(),
            onTap: selectedValue.isEmpty
                ? null
                : () => widget.onPressedSubmit(selectedValue),
          ),
        )
      ],
    );
  }

  Widget _buildItem<T>({
    required String title,
    required String value,
    required Function(String value) onChangeValue,
    required String selectedValue,
  }) {
    return InkWell(
      onTap: () => onChangeValue(value),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap.h20,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TypographyTheme.textMRegular.toNeutral80,
                ),
                RadioWidget<String>.primary(
                  value: value,
                  groupValue: selectedValue,
                  onChanged: (_) => onChangeValue(value),
                ),
              ],
            ),
            Gap.h20,
            Container(
              color: BaseColor.neutral.shade10,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }
}
