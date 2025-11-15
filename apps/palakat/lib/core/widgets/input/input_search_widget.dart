import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/extension/extension.dart';

/// A common widget search bar
///
/// Input Form Search Widget lets the user enter text and
/// clear text with 'x' button
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
  });

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// Set the field to read only
  ///
  /// If null the value is false
  final bool readOnly;

  /// Hint of field
  final String? hint;

  /// On changed callback of field
  final ValueChanged<String>? onChanged;

  /// Callback if field is tapped
  final VoidCallback? onTap;

  /// Callback if 'x' icon is tapped
  final VoidCallback? onTapClear;

  /// Callback onSubmitted
  final Function(String value)? onSubmitted;

  /// Callback onEditingComplete
  final VoidCallback? onEditingComplete;

  /// Callback onSubmitted
  final BoxConstraints? constraints;

  /// Set the 'x' button is show or no
  ///
  /// If not set default value is false
  final bool isShowClearButton;

  final Widget? suffixIcon;

  static final _border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(BaseSize.radiusLg),
      borderSide: BorderSide(
        color: BaseColor.neutral.shade20,
        width: 1,
      ));

  static final BoxConstraints _iconConstraints = BoxConstraints(
    minWidth: BaseSize.w16,
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: onTap,
      controller: controller,
      readOnly: readOnly,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onEditingComplete: onEditingComplete,
      style: BaseTypography.titleMedium.fontColor(BaseColor.neutral.shade70),
      decoration: InputDecoration(
        fillColor: BaseColor.white,
        filled: true,
        border: _border,
        enabledBorder: _border,
        focusedBorder: _border,
        hintText: hint,
        hintStyle:
            BaseTypography.titleMedium.fontColor(BaseColor.neutral.shade40),
        contentPadding: EdgeInsets.zero,
        constraints: constraints ??
            BoxConstraints(
              minHeight: BaseSize.h52,
              maxHeight: BaseSize.h52,
            ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(
              left: BaseSize.w16,
              right: BaseSize.w8,
              bottom: BaseSize.customHeight(2)),
          child: Assets.icons.line.search.svg(
              width: BaseSize.w20,
              height: BaseSize.w20,
              colorFilter: BaseColor.neutral.shade40.filterSrcIn),
        ),
        prefixIconConstraints: _iconConstraints,
        suffixIcon: isShowClearButton || suffixIcon != null
            ? suffixIcon ??
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: onTapClear,
                  icon: Assets.icons.line.times
                      .svg(colorFilter: BaseColor.neutral.shade50.filterSrcIn),
                )
            : null,
      ),
    );
  }
}
