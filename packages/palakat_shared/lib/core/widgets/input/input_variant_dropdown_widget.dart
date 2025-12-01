import 'package:flutter/material.dart';

import '../divider_widget.dart';

/// A theme-aware dropdown input variant widget.
///
/// Uses [Theme.of(context)] for styling instead of hardcoded constants,
/// making it compatible with both palakat and palakat_admin apps.
///
/// Supports custom display builders for rendering selected values.
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

  /// Hint text displayed when no value is selected.
  final String hint;

  /// List of available options.
  final List<T> options;

  /// Currently selected value.
  final T? currentInputValue;

  /// Callback when the value changes.
  final ValueChanged<T> onChanged;

  /// Callback that returns a result when the dropdown is tapped.
  final Future<T?> Function() onPressedWithResult;

  /// Icon displayed at the end of the dropdown.
  final Widget? endIcon;

  /// Border color override.
  final Color? borderColor;

  /// Error text to display.
  final String? errorText;

  /// Validator function.
  final String? Function(String?)? validators;

  /// Auto-validate mode.
  final AutovalidateMode? autoValidateMode;

  /// Function to get the display label for an option.
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
    final theme = Theme.of(context);

    final effectiveBorderColor = errorText != null && errorText!.isNotEmpty
        ? theme.colorScheme.error
        : (widget.borderColor ?? theme.colorScheme.outline);

    return IntrinsicHeight(
      child: Material(
        clipBehavior: Clip.hardEdge,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: effectiveBorderColor, width: 1.5),
        ),
        color: theme.colorScheme.surface,
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
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildDisplayContent(theme)),
                const SizedBox(width: 8),
                const DividerWidget(height: double.infinity),
                const SizedBox(width: 8),
                widget.endIcon ??
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                if (errorText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisplayContent(ThemeData theme) {
    // If no value selected, show hint
    if (currentValue == null) {
      return Text(
        widget.hint,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
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
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
