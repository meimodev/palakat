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
    this.customDisplayBuilder,
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

  /// Optional custom widget builder for displaying the selected value.
  /// When provided, this widget will be used instead of the default text display.
  final Widget Function(T value)? customDisplayBuilder;

  @override
  State<InputVariantDropdownWidget> createState() =>
      _InputVariantDropdownWidgetState<T>();
}

class _InputVariantDropdownWidgetState<T>
    extends State<InputVariantDropdownWidget<T>> {
  T? currentValue;

  String? errorText;

  @override
  void initState() {
    super.initState();
    currentValue = widget.currentInputValue;
    errorText = widget.errorText;
  }

  @override
  void didUpdateWidget(InputVariantDropdownWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentInputValue != oldWidget.currentInputValue) {
      currentValue = widget.currentInputValue;
    }
    if (widget.errorText != oldWidget.errorText) {
      errorText = widget.errorText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = errorText != null && errorText!.isNotEmpty
        ? BaseColor.error
        : (widget.borderColor ?? BaseColor.neutral30);

    return IntrinsicHeight(
      child: Material(
        clipBehavior: Clip.hardEdge,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(BaseSize.radiusLg),
          side: BorderSide(color: borderColor, width: 1.5),
        ),
        color: BaseColor.white,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        elevation: 1,
        child: InkWell(
          onTap: () async {
            final result = await widget.onPressedWithResult();
            if (result != null || widget.options.contains(null)) {
              setState(() {
                currentValue = result;
                errorText = null;
              });
              widget.onChanged(result as T);
            }
          },
          child: Padding(
            padding: EdgeInsets.all(BaseSize.w12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildDisplayContent()),
                Gap.w8,
                const DividerWidget(height: double.infinity),
                Gap.w8,
                (widget.endIcon ?? Assets.icons.line.chevronDownOutline).svg(
                  width: BaseSize.w12,
                  height: BaseSize.w12,
                  colorFilter: ColorFilter.mode(
                    BaseColor.neutral60,
                    BlendMode.srcIn,
                  ),
                ),
                if (errorText != null) ...[
                  Gap.h4,
                  Text(errorText!, style: BaseTypography.bodySmall.toError),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisplayContent() {
    // If no value selected, show hint
    if (currentValue == null) {
      return Text(
        widget.hint,
        style: BaseTypography.titleMedium.copyWith(
          color: BaseColor.neutral50,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    // If custom display builder provided, use it
    if (widget.customDisplayBuilder != null) {
      return widget.customDisplayBuilder!(currentValue as T);
    }

    // Default: show text label
    return Text(
      widget.optionLabel(currentValue as T),
      style: BaseTypography.titleMedium.copyWith(
        color: BaseColor.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
