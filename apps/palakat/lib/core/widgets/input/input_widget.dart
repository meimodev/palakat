import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';

import 'input_variant_binary_option_widget.dart';
import 'input_variant_dropdown_widget.dart';
import 'input_variant_text_widget.dart';

enum InputWidgetVariant { text, dropdown, binaryOption }

class InputWidget<T> extends StatefulWidget {
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
    this.leadIcon,
    this.inputFormatters,
  }) : onPressedWithResult = null,
       options = null,
       optionLabel = null,
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
    required this.optionLabel,
    this.leadIcon,
  }) : controller = null,
       maxLines = 1,
       textInputType = null,
       borderColor = null,
       inputFormatters = null,
       variant = InputWidgetVariant.dropdown;

  const InputWidget.binaryOption({
    super.key,
    required this.options,
    required this.label,
    required this.onChanged,
    this.currentInputValue,
    this.errorText,
    this.validators,
    required this.optionLabel,
  }) : variant = InputWidgetVariant.binaryOption,
       endIcon = null,
       leadIcon = null,
       maxLines = null,
       hint = null,
       controller = null,
       onPressedWithResult = null,
       borderColor = null,
       textInputType = null,
       inputFormatters = null,
       assert(
         options != null && options.length > 0,
         "options cannot be null or empty",
       );

  final int? maxLines;
  final String? hint;
  final String? label;
  final InputWidgetVariant variant;
  final void Function(T value)? onChanged;
  final String? errorText;

  //variant text
  final TextEditingController? controller;
  final SvgGenImage? endIcon;
  final SvgGenImage? leadIcon;
  final Color? borderColor;
  final Future<T?> Function()? onPressedWithResult;
  final T? currentInputValue;
  final List<T>? options;
  final TextInputType? textInputType;
  final String Function(T option)? optionLabel;
  final List<TextInputFormatter>? inputFormatters;

  final String? Function(String)? validators;

  @override
  State<InputWidget> createState() => _InputWidgetState<T>();
}

class _InputWidgetState<T> extends State<InputWidget<T>> {
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    errorMessage = widget.errorText ?? '';
  }

  @override
  void didUpdateWidget(InputWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText) {
      errorMessage = widget.errorText ?? '';
    }
  }

  void validateInput(String input) {
    if (widget.validators != null) {
      final validators = widget.validators!;
      final newErrorMessage = validators(input) ?? "";

      // Only call setState if error message actually changed
      if (errorMessage != newErrorMessage) {
        setState(() {
          errorMessage = newErrorMessage;
        });
      }
    }
  }

  void onChanged(T val) {
    validateInput(
      widget.optionLabel != null ? widget.optionLabel!(val) : val as String,
    );

    if (widget.onChanged != null) {
      widget.onChanged!(val);
    }
  }

  Color? get borderColor => errorMessage.isNotEmpty
      ? BaseColor.error.withValues(alpha: .5)
      : widget.borderColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabelWidget(),
        widget.variant == InputWidgetVariant.binaryOption
            ? InputVariantBinaryOptionWidget<T>(
                options: widget.options!,
                currentInputValue: widget.currentInputValue,
                onChanged: onChanged,
                borderColor: borderColor,
                optionLabel: widget.optionLabel!,
              )
            : const SizedBox(),
        widget.variant == InputWidgetVariant.dropdown
            ? InputVariantDropdownWidget<T>(
                hint: widget.hint!,
                options: widget.options ?? [],
                currentInputValue: widget.currentInputValue,
                onChanged: onChanged,
                onPressedWithResult: widget.onPressedWithResult!,
                endIcon: widget.endIcon,
                borderColor: borderColor,
                optionLabel: widget.optionLabel!,
              )
            : const SizedBox(),
        widget.variant == InputWidgetVariant.text
            ? InputVariantTextWidget(
                onChanged: (value) => onChanged(value as T),
                leadIcon: widget.leadIcon,
                maxLines: widget.maxLines,
                hint: widget.hint,
                controller: widget.controller,
                endIcon: widget.endIcon,
                textInputType: widget.textInputType,
                borderColor: borderColor,
                inputFormatters: widget.inputFormatters,
                initialValue: widget.currentInputValue?.toString(),
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
      padding: EdgeInsets.only(top: BaseSize.customHeight(3)),
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
