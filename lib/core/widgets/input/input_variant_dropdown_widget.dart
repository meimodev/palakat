import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/extensions/extension.dart';
import 'package:palakat/core/widgets/divider/divider_widget.dart';

class InputVariantDropdownWidget extends StatefulWidget {
  const InputVariantDropdownWidget({
    super.key,
    required this.hint,
    required this.options,
    required this.currentInputValue,
    required this.onChanged,
    required this.onPressedWithResult,
    this.borderColor,
    this.endIcon,
    this.errorText,
    this.validators,
    this.autoValidateMode,
  });

  final String hint;
  final List<String> options;
  final String? currentInputValue;
  final ValueChanged<String> onChanged;
  final Future<String?> Function() onPressedWithResult;
  final SvgGenImage? endIcon;
  final Color? borderColor;
  final String? errorText;
  final String? Function(String?)? validators;
  final AutovalidateMode? autoValidateMode;

  @override
  State<InputVariantDropdownWidget> createState() =>
      _InputVariantDropdownWidgetState();
}

class _InputVariantDropdownWidgetState
    extends State<InputVariantDropdownWidget> {
  String currentValue = "";

  String? errorText;

  @override
  void initState() {
    super.initState();

    setState(() {});
    if (widget.currentInputValue != null) {
      setState(() {
        currentValue = widget.currentInputValue!;
      });
    }
    errorText = widget.errorText;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Material(
        clipBehavior: Clip.hardEdge,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(
            BaseSize.radiusLg,
          ),
          side: BorderSide(
            color: widget.borderColor ?? Colors.transparent,
            width: 2,
          ),
        ),
        color: BaseColor.cardBackground1,
        child: InkWell(
          onTap: () async {
            final String? result = await widget.onPressedWithResult();
            if (result != null) {
              setState(() {
                currentValue = result;
                errorText = null;
              });
              widget.onChanged(result);
            }
          },
          child: Padding(
            padding: EdgeInsets.all(BaseSize.w12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    currentValue.isEmpty ? widget.hint : currentValue,
                    style: BaseTypography.titleMedium,
                  ),
                ),
                Gap.w8,
                const DividerWidget(
                  height: double.infinity,
                ),
                Gap.w8,
                (widget.endIcon ?? Assets.icons.line.chevronDownOutline).svg(
                  width: BaseSize.w12,
                  height: BaseSize.w12,
                ),
                if (errorText != null) ...[
                  Gap.h4,
                  Text(
                    errorText!,
                    style: BaseTypography.bodySmall.toError,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
