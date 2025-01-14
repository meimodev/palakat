import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

import 'input_variant_binary_option_widget.dart';
import 'input_variant_dropdown_widget.dart';
import 'input_variant_text_widget.dart';

enum InputWidgetVariant {
  text,
  dropdown,
  binaryOption,
}

class InputWidget extends StatefulWidget {
  const InputWidget.text({
    super.key,
    this.maxLines = 1,
    this.hint,
    this.label,
    this.onChanged,
    this.controller,
    this.currentInputValue,
    this.endIcon,
    this.textInputType,
    this.borderColor,
    this.errorText,
    this.validators,
  })  : onPressedWithResult = null,
        options = null,
        variant = InputWidgetVariant.text;

  const InputWidget.dropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.onChanged,
    required this.onPressedWithResult,
    this.currentInputValue,
    this.options,
    this.endIcon,
    this.errorText,
    this.validators,
  })  : controller = null,
        maxLines = 1,
        textInputType = null,
        borderColor = null,
        variant = InputWidgetVariant.dropdown;

  const InputWidget.binaryOption({
    super.key,
    required this.options,
    required this.label,
    required this.onChanged,
    this.currentInputValue,
    this.errorText,
    this.validators,
  })  : variant = InputWidgetVariant.binaryOption,
        endIcon = null,
        maxLines = null,
        hint = null,
        controller = null,
        onPressedWithResult = null,
        borderColor = null,
        textInputType = null,
        assert(options != null && options.length > 0,
            "options cannot be null or empty");

  final int? maxLines;
  final String? hint;
  final String? label;
  final InputWidgetVariant variant;
  final void Function(String value)? onChanged;
  final String? errorText;

  //variant text
  final TextEditingController? controller;
  final SvgGenImage? endIcon;
  final Color? borderColor;
  final Future<String?> Function()? onPressedWithResult;
  final String? currentInputValue;
  final List<String>? options;
  final TextInputType? textInputType;

  final String? Function(String)? validators;

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (widget.errorText != null) {
      setState(() {
        errorMessage = widget.errorText!;
      });
    }

  }

  void validateInput(String input) {
    if (widget.validators != null) {
      final validators = widget.validators!;
      final res = validators(input) ?? "";
      setState(() {
        errorMessage = res;
      });
    }
  }

  void onChanged(String val) {
    validateInput(val);
    if (widget.onChanged != null) {
      widget.onChanged!(val);
    }
  }

  Color? get borderColor => errorMessage.isNotEmpty
      ? BaseColor.error.withOpacity(.5)
      : widget.borderColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabelWidget(),
        widget.variant == InputWidgetVariant.binaryOption
            ? InputVariantBinaryOptionWidget(
                options: widget.options!,
                currentInputValue: widget.currentInputValue,
                onChanged: onChanged,
                borderColor: borderColor,
              )
            : const SizedBox(),
        widget.variant == InputWidgetVariant.dropdown
            ? InputVariantDropdownWidget(
                hint: widget.hint!,
                options: widget.options ?? [],
                currentInputValue: widget.currentInputValue,
                onChanged: onChanged,
                onPressedWithResult: widget.onPressedWithResult!,
                endIcon: widget.endIcon,
                borderColor: borderColor,
              )
            : const SizedBox(),
        widget.variant == InputWidgetVariant.text
            ? InputVariantTextWidget(
                onChanged: onChanged,
                maxLines: widget.maxLines,
                hint: widget.hint,
                controller: widget.controller,
                endIcon: widget.endIcon,
                textInputType: widget.textInputType,
                borderColor: borderColor,
                // autoValidateMode: widget.autoValidateMode,
                // validators: widget.validators,
              )
            : const SizedBox(),
        _buildErrorWidget(),
      ],
    );
  }

  Widget _buildLabelWidget() {
    if (widget.label == null || widget.label!.isEmpty) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: BaseTypography.bodyMedium.toSecondary,
        ),
        Gap.h6,
      ],
    );
  }

  Widget _buildErrorWidget() {
    if (errorMessage.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: EdgeInsets.only(
        top: BaseSize.customHeight(3),
      ),
      child: Text(
        errorMessage,
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: BaseTypography.bodySmall.toError,
      ),
    );
  }
}
