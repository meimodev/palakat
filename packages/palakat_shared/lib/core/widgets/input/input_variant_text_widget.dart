import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../divider_widget.dart';

/// A theme-aware text input variant widget.
///
/// Uses [Theme.of(context)] for styling instead of hardcoded constants,
/// making it compatible with both palakat and palakat_admin apps.
///
/// Features focus state styling with visual feedback.
class InputVariantTextWidget extends StatelessWidget {
  const InputVariantTextWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.maxLines,
    this.hint,
    this.endIcon,
    this.textInputType,
    this.borderColor,
    this.errorText,
    this.initialValue,
    this.leadIcon,
    this.inputFormatters,
  });

  /// Initial value for the text field.
  final String? initialValue;

  /// Text editing controller.
  final TextEditingController? controller;

  /// Callback when the text changes.
  final void Function(String value)? onChanged;

  /// Maximum number of lines.
  final int? maxLines;

  /// Hint text displayed when the input is empty.
  final String? hint;

  /// Icon displayed at the start of the input.
  final Widget? leadIcon;

  /// Icon displayed at the end of the input.
  final Widget? endIcon;

  /// Keyboard type.
  final TextInputType? textInputType;

  /// Border color override.
  final Color? borderColor;

  /// Error text to display.
  final String? errorText;

  /// Input formatters.
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;

          final effectiveBorderColor = hasFocus
              ? theme.colorScheme.primary
              : (borderColor ?? theme.colorScheme.outline);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(
                color: effectiveBorderColor,
                width: hasFocus ? 2 : 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: hasFocus
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leadIcon != null) _buildLeadIcon(theme),
                Expanded(child: _buildTextFormField(theme)),
                if (endIcon != null) _buildEndIcon(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextFormField(ThemeData theme) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      keyboardType: textInputType,
      initialValue: initialValue,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: theme.colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildLeadIcon(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        leadIcon!,
        const SizedBox(width: 12),
        const DividerWidget(height: 20),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildEndIcon() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [const SizedBox(width: 12), endIcon!],
    );
  }
}
