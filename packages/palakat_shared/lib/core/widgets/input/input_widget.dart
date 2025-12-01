import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'input_variant_binary_option_widget.dart';
import 'input_variant_dropdown_widget.dart';
import 'input_variant_text_widget.dart';

/// Enum representing the different variants of InputWidget.
enum InputWidgetVariant { text, dropdown, binaryOption }

/// A theme-aware input widget with multiple variants: text, dropdown, and binaryOption.
///
/// Uses [Theme.of(context)] for styling instead of hardcoded constants,
/// making it compatible with both palakat and palakat_admin apps.
///
/// Example usage:
/// ```dart
/// // Text input
/// InputWidget.text(
///   label: 'Name',
///   hint: 'Enter your name',
///   onChanged: (value) => print(value),
/// )
///
/// // Dropdown input
/// InputWidget.dropdown(
///   label: 'Category',
///   hint: 'Select a category',
///   options: ['A', 'B', 'C'],
///   optionLabel: (option) => option,
///   onChanged: (value) => print(value),
///   onPressedWithResult: () async => showDialog(...),
/// )
///
/// // Binary option input
/// InputWidget.binaryOption(
///   label: 'Gender',
///   options: ['Male', 'Female'],
///   optionLabel: (option) => option,
///   onChanged: (value) => print(value),
/// )
/// ```
class InputWidget<T> extends StatefulWidget {
  /// Creates a text input variant.
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
       customDisplayBuilder = null,
       variant = InputWidgetVariant.text;

  /// Creates a dropdown input variant.
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
    this.customDisplayBuilder,
  }) : controller = null,
       maxLines = 1,
       textInputType = null,
       borderColor = null,
       inputFormatters = null,
       variant = InputWidgetVariant.dropdown;

  /// Creates a binary option input variant.
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
       customDisplayBuilder = null,
       assert(
         options != null && options.length > 0,
         "options cannot be null or empty",
       );

  /// Maximum number of lines for text input.
  final int? maxLines;

  /// Hint text displayed when the input is empty.
  final String? hint;

  /// Label text displayed above the input.
  final String? label;

  /// The variant type of this input widget.
  final InputWidgetVariant variant;

  /// Callback when the input value changes.
  final void Function(T value)? onChanged;

  /// Error text to display below the input.
  final String? errorText;

  /// Text editing controller for text variant.
  final TextEditingController? controller;

  /// Icon displayed at the end of the input.
  final Widget? endIcon;

  /// Icon displayed at the start of the input.
  final Widget? leadIcon;

  /// Border color override.
  final Color? borderColor;

  /// Callback that returns a result for dropdown variant.
  final Future<T?> Function()? onPressedWithResult;

  /// Current selected value.
  final T? currentInputValue;

  /// List of options for dropdown and binaryOption variants.
  final List<T>? options;

  /// Keyboard type for text input.
  final TextInputType? textInputType;

  /// Function to get the display label for an option.
  final String Function(T option)? optionLabel;

  /// Input formatters for text input.
  final List<TextInputFormatter>? inputFormatters;

  /// Validator function for the input.
  final String? Function(String)? validators;

  /// Optional custom widget builder for displaying the selected value in dropdown.
  /// When provided, this widget will be used instead of the default text display.
  final Widget Function(T value)? customDisplayBuilder;

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

  Color? get borderColor {
    final theme = Theme.of(context);
    return errorMessage.isNotEmpty
        ? theme.colorScheme.error.withValues(alpha: 0.5)
        : widget.borderColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabelWidget(),
        if (widget.variant == InputWidgetVariant.binaryOption)
          InputVariantBinaryOptionWidget<T>(
            options: widget.options!,
            currentInputValue: widget.currentInputValue,
            onChanged: onChanged,
            borderColor: borderColor,
            optionLabel: widget.optionLabel!,
          )
        else
          const SizedBox(),
        if (widget.variant == InputWidgetVariant.dropdown)
          InputVariantDropdownWidget<T>(
            hint: widget.hint!,
            options: widget.options ?? [],
            currentInputValue: widget.currentInputValue,
            onChanged: onChanged,
            onPressedWithResult: widget.onPressedWithResult!,
            endIcon: widget.endIcon,
            borderColor: borderColor,
            optionLabel: widget.optionLabel!,
            customDisplayBuilder: widget.customDisplayBuilder,
          )
        else
          const SizedBox(),
        if (widget.variant == InputWidgetVariant.text)
          InputVariantTextWidget(
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
          )
        else
          const SizedBox(),
        _buildErrorWidget(),
      ],
    );
  }

  Widget _buildLabelWidget() {
    if (widget.label == null || widget.label!.isEmpty) {
      return const SizedBox();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildErrorWidget() {
    if (errorMessage.isEmpty) {
      return const SizedBox();
    }

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        errorMessage,
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
