import 'package:flutter/material.dart';

/// A common search bar widget that uses theme-based styling.
///
/// Input Form Search Widget lets the user enter text and
/// clear text with 'x' button.
///
/// The input form search widget calls the [onChanged] callback whenever
/// the user changes the text.
///
/// To control the text that is displayed in the input form search widget, use
/// the [controller].
class InputSearchWidget extends StatelessWidget {
  const InputSearchWidget({
    super.key,
    this.controller,
    this.readOnly = false,
    this.hint,
    this.onChanged,
    this.onTap,
    this.onTapClear,
    this.isShowClearButton = false,
    this.onSubmitted,
    this.onEditingComplete,
    this.constraints,
    this.suffixIcon,
    this.prefixIcon,
  });

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// Set the field to read only.
  ///
  /// If null the value is false.
  final bool readOnly;

  /// Hint text for the field.
  final String? hint;

  /// On changed callback of field.
  final ValueChanged<String>? onChanged;

  /// Callback if field is tapped.
  final VoidCallback? onTap;

  /// Callback if 'x' icon is tapped.
  final VoidCallback? onTapClear;

  /// Callback onSubmitted.
  final Function(String value)? onSubmitted;

  /// Callback onEditingComplete.
  final VoidCallback? onEditingComplete;

  /// Box constraints for the search field.
  final BoxConstraints? constraints;

  /// Set the 'x' button visibility.
  ///
  /// If not set default value is false.
  final bool isShowClearButton;

  /// Custom suffix icon widget.
  final Widget? suffixIcon;

  /// Custom prefix icon widget. Defaults to search icon if not provided.
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(
        color: colorScheme.outline.withValues(alpha: 0.3),
        width: 1,
      ),
    );

    const iconConstraints = BoxConstraints(minWidth: 16);

    return TextField(
      onTap: onTap,
      controller: controller,
      readOnly: readOnly,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onEditingComplete: onEditingComplete,
      style: theme.textTheme.titleMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        fillColor: colorScheme.surface,
        filled: true,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 1),
        ),
        hintText: hint,
        hintStyle: theme.textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        contentPadding: EdgeInsets.zero,
        constraints:
            constraints ?? const BoxConstraints(minHeight: 52, maxHeight: 52),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8, bottom: 2),
          child:
              prefixIcon ??
              Icon(
                Icons.search,
                size: 20,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
        ),
        prefixIconConstraints: iconConstraints,
        suffixIcon: isShowClearButton || suffixIcon != null
            ? suffixIcon ??
                  IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: onTapClear,
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  )
            : null,
      ),
    );
  }
}
