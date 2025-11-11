import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/divider/divider_widget.dart';

class InputVariantDropdownWidget<T> extends StatefulWidget {
  const InputVariantDropdownWidget({
    super.key,
    required this.hint,
    required this.options,
    required this.currentInputValue,
    required this.onChanged,
    required this.onPressedWithResult,
    required this.optionLabel,
    this.borderColor,
    this.endIcon,
    this.errorText,
    this.validators,
    this.autoValidateMode,
  });

  final String hint;
  final List<T> options;
  final T? currentInputValue;
  final ValueChanged<T> onChanged;
  final Future<T?> Function() onPressedWithResult;
  final SvgGenImage? endIcon;
  final Color? borderColor;
  final String? errorText;
  final String? Function(String?)? validators;
  final AutovalidateMode? autoValidateMode;
  final String Function(T option) optionLabel;

  @override
  State<InputVariantDropdownWidget> createState() =>
      _InputVariantDropdownWidgetState<T>();
}

class _InputVariantDropdownWidgetState<T>
    extends State<InputVariantDropdownWidget<T>> {
  T? currentValue ;

  String? errorText;

  @override
  void initState() {
    super.initState();

    setState(() {});
    if (widget.currentInputValue != null) {
      setState(() {
        currentValue = widget.currentInputValue;
      });
    }
    errorText = widget.errorText;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = errorText != null && errorText!.isNotEmpty
        ? BaseColor.error
        : (widget.borderColor ?? Colors.transparent);

    return IntrinsicHeight(
      child: Material(
        clipBehavior: Clip.hardEdge,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(
            BaseSize.radiusLg,
          ),
          side: BorderSide(
            color: borderColor,
            width: 2,
          ),
        ),
        color: BaseColor.cardBackground1,
        child: InkWell(
          onTap: () async {
            final result = await widget.onPressedWithResult();
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
                    currentValue != null ? widget.optionLabel(currentValue as T) : widget.hint,
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
