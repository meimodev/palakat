import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:halo_hermina/core/assets/fonts.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class TermsAndConditionDialogWidget extends StatefulWidget {
  const TermsAndConditionDialogWidget({
    super.key,
    required this.onTapTermsAndCondition,
    required this.onChangedCheck,
  });

  final void Function() onTapTermsAndCondition;
  final void Function(bool value) onChangedCheck;

  @override
  State<TermsAndConditionDialogWidget> createState() =>
      _TermsAndConditionDialogWidgetState();
}

class _TermsAndConditionDialogWidgetState
    extends State<TermsAndConditionDialogWidget> {
  bool checked = false;

  void handleOnChangeChecked(bool? value) {
    setState(() => checked = value ?? false);
    widget.onChangedCheck(checked);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: checked,
          onChanged: handleOnChangeChecked,
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.resolveWith(
            WidgetTheme.getCheckboxPrimaryColor,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: LocaleKeys.text_byClickingSubmitButtonIReadAndAgreeWithAll
                  .tr(),
              style: TypographyTheme.textMRegular.toNeutral60.copyWith(
                fontFamily: FontFamily.lexend,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  handleOnChangeChecked(!checked);
                },
              children: [
                TextSpan(
                  text: " ${LocaleKeys.text_termAndConditions.tr()}",
                  style: TypographyTheme.textMSemiBold.toPrimary,
                  recognizer: TapGestureRecognizer()
                    ..onTap = widget.onTapTermsAndCondition,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void showTermsAndConditionDialog(
  BuildContext context, {
  required String htmlDataTermsAndCondition,
  required void Function() onPressedAgree,
  required void Function() onTapTermsAndCondition,
  required void Function(bool checked) onChangedCheck,
}) {
  showCustomDialogWidget(
    context,
    btnLeftText: LocaleKeys.text_cancel.tr(),
    btnRightText: LocaleKeys.text_agree.tr(),
    title: LocaleKeys.text_termAndConditionsSymbol.tr(),
    onTap: onPressedAgree,
    isScrollControlled: true,
    content: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.customWidth(16),
          ),
          child: Html(
            data: htmlDataTermsAndCondition,
            style: {
              "body": Style(
                fontSize: FontSize(16.0),
                fontWeight: FontWeight.normal,
              ),
              "ol": Style(padding: HtmlPaddings(left: HtmlPadding(30))),
            },
          ),
        ),
        // Gap.customGapHeight(30),
        TermsAndConditionDialogWidget(
          onTapTermsAndCondition: onTapTermsAndCondition,
          onChangedCheck: onChangedCheck,
        ),
      ],
    ),
  );
}
