import 'dart:async';

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
///
/// Example usage:
/// ```dart
/// InputSearchWidget(
///   hint: 'Search...',
///   onChanged: (value) => print(value),
///   debounceMilliseconds: 500, // Optional debounce
///   autoClearButton: true, // Auto-show clear button
/// )
/// ```
class InputSearchWidget extends StatefulWidget {
  const InputSearchWidget({
    super.key,
    this.controller,
    this.readOnly = false,
    this.hint,
    this.onChanged,
    this.onTap,
    this.onTapClear,
    this.isShowClearButton = false,
    this.autoClearButton = false,
    this.onSubmitted,
    this.onEditingComplete,
    this.constraints,
    this.suffixIcon,
    this.prefixIcon,
    this.clearIcon,
    this.debounceMilliseconds,
    this.borderRadius,
    this.focusNode,
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
  ///
  /// If [debounceMilliseconds] is set, this will be called after the debounce delay.
  final ValueChanged<String>? onChanged;

  /// Callback if field is tapped.
  final VoidCallback? onTap;

  /// Callback if 'x' icon is tapped.
  ///
  /// If not provided and [autoClearButton] is true, will clear the text automatically.
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

  /// Automatically show clear button when text is entered.
  ///
  /// If true, the clear button will appear when text is entered and disappear when empty.
  /// Takes precedence over [isShowClearButton].
  final bool autoClearButton;

  /// Custom suffix icon widget.
  final Widget? suffixIcon;

  /// Custom prefix icon widget. Defaults to search icon if not provided.
  final Widget? prefixIcon;

  final Widget? clearIcon;

  /// Debounce delay in milliseconds.
  ///
  /// If set, [onChanged] will be called after this delay instead of immediately.
  /// Useful for search fields to avoid excessive API calls.
  /// Common values: 300-500ms.
  final int? debounceMilliseconds;

  /// Border radius for the search field.
  ///
  /// Defaults to 24.
  final double? borderRadius;

  /// Focus node for the search field.
  final FocusNode? focusNode;

  @override
  State<InputSearchWidget> createState() => _InputSearchWidgetState();
}

class _InputSearchWidgetState extends State<InputSearchWidget> {
  late TextEditingController _controller;
  Timer? _debounceTimer;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _isInternalController = widget.controller == null;
  }

  @override
  void didUpdateWidget(InputSearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_isInternalController) {
        _controller.dispose();
      }
      _controller = widget.controller ?? TextEditingController();
      _isInternalController = widget.controller == null;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleTextChanged(String value) {
    if (widget.onChanged == null) return;

    if (widget.debounceMilliseconds != null &&
        widget.debounceMilliseconds! > 0) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(
        Duration(milliseconds: widget.debounceMilliseconds!),
        () => widget.onChanged!(value),
      );
    } else {
      widget.onChanged!(value);
    }
  }

  void _handleClearTap() {
    if (widget.onTapClear != null) {
      widget.onTapClear!();
    } else if (widget.autoClearButton) {
      _controller.clear();
      if (widget.onChanged != null) {
        widget.onChanged!('');
      }
    }
  }

  bool get _shouldShowClearButton {
    if (widget.autoClearButton) {
      return _controller.text.isNotEmpty;
    }
    return widget.isShowClearButton;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    InputBorder? withRadius(InputBorder? border) {
      final radius = widget.borderRadius;
      if (radius == null) return border;
      if (border is OutlineInputBorder) {
        return border.copyWith(borderRadius: BorderRadius.circular(radius));
      }
      return border;
    }

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, child) {
        final prefixIcon = widget.prefixIcon ?? const Icon(Icons.search);
        var decoration = InputDecoration(
          hintText: widget.hint,
          constraints: widget.constraints,
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(start: 12),
            child: Align(alignment: Alignment.centerLeft, child: prefixIcon),
          ),
          suffixIcon: _shouldShowClearButton || widget.suffixIcon != null
              ? widget.suffixIcon ??
                    IconButton(
                      onPressed: _handleClearTap,
                      icon: widget.clearIcon ?? const Icon(Icons.close),
                    )
              : null,
        ).applyDefaults(theme.inputDecorationTheme);

        final decorationConstraints = decoration.constraints;
        double? iconBoxSize;
        if (decorationConstraints != null) {
          if (decorationConstraints.hasBoundedHeight &&
              decorationConstraints.maxHeight.isFinite) {
            iconBoxSize = decorationConstraints.maxHeight;
          } else if (decorationConstraints.minHeight.isFinite &&
              decorationConstraints.minHeight > 0) {
            iconBoxSize = decorationConstraints.minHeight;
          }
        }

        BoxConstraints? lockIconConstraints(
          BoxConstraints? current,
          double? height,
        ) {
          final base =
              current ?? const BoxConstraints(minWidth: 48, minHeight: 48);
          final width = (base.minWidth.isFinite && base.minWidth > 0)
              ? base.minWidth
              : 48.0;
          final resolvedHeight =
              height ??
              ((base.minHeight.isFinite && base.minHeight > 0)
                  ? base.minHeight
                  : 48.0);

          if (!resolvedHeight.isFinite || resolvedHeight <= 0) return current;
          return BoxConstraints.tightFor(width: width, height: resolvedHeight);
        }

        decoration = decoration.copyWith(
          border: withRadius(decoration.border),
          enabledBorder: withRadius(decoration.enabledBorder),
          focusedBorder: withRadius(decoration.focusedBorder),
          disabledBorder: withRadius(decoration.disabledBorder),
          errorBorder: withRadius(decoration.errorBorder),
          focusedErrorBorder: withRadius(decoration.focusedErrorBorder),
          prefixIconConstraints: lockIconConstraints(
            decoration.prefixIconConstraints,
            iconBoxSize,
          ),
          suffixIconConstraints: decoration.suffixIcon == null
              ? decoration.suffixIconConstraints
              : lockIconConstraints(
                  decoration.suffixIconConstraints,
                  iconBoxSize,
                ),
        );

        return TextField(
          onTap: widget.onTap,
          controller: _controller,
          readOnly: widget.readOnly,
          focusNode: widget.focusNode,
          onChanged: _handleTextChanged,
          onSubmitted: widget.onSubmitted,
          onEditingComplete: widget.onEditingComplete,
          textAlignVertical: TextAlignVertical.center,
          decoration: decoration,
        );
      },
    );
  }
}
