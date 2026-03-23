import 'package:palakat_shared/core/theme/theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../loading_widget.dart';

enum _ButtonType { primary, outlined, text }

enum ButtonSize { small, medium, large }

class ButtonWidget extends StatelessWidget {
  // [INFO]
  // for text inside button
  final String text;

  // [INFO]
  // for base color button
  final Color color;
  final Color textColor;
  final Color? outlineColor;

  // [INFO]
  // for focus color in button
  final Color focusColor;

  // [INFO]
  // when on pressed, this overlay color will show ripple effect in button
  final Color overlayColor;

  // [INFO]
  // for button type
  final _ButtonType _buttonType;

  // [INFO]
  // for determine if the button is icon only or not
  final bool _isIconOnly;

  // [INFO]
  // to make button enable or disable
  final bool _isEnabled;

  // [INFO]
  // to display icon
  final SvgPicture? icon;

  // [INFO]
  // onTap function, if onTap null, it will be disable state
  final VoidCallback? onTap;

  // [INFO]
  // isShrink if the button size follows on its contents, if false, it will resize depends on screen width
  final bool isShrink;

  // [INFO]
  // for button size
  final ButtonSize buttonSize;

  // [INFO]
  // isIconLeading for icon position
  final bool isIconLeading;

  // [INFO]
  // isLoading for loading state
  final bool isLoading;

  // [INFO]
  // maxLines for how much maximal lines
  final int? maxLines;

  // [INFO]
  // useAutoSizeText for using `AutoSizeText`
  final bool useAutoSizeText;

  // [INFO]
  // isCenter for button content alignment
  final bool isCenterContent;
  // [INFO]
  // spacer for button content spacer
  final bool spacer;

  // padding for button content padding
  final EdgeInsets? padding;

  /// [INFO] : Button Primary
  ///
  /// use this button for Primary button, green dominant color, and then has background color.
  ///
  /// if isEnabled null, it will check if the onTap null or not. if null, it will be Disabled
  const ButtonWidget.primary({
    super.key,
    required this.text,
    this.icon,
    bool? isEnabled,
    this.textColor = AppColors.onPrimary,
    this.color = AppColors.primary,
    this.focusColor = AppColors.primary,
    this.overlayColor = AppColors.primary,
    this.onTap,
    this.isShrink = false,
    this.buttonSize = ButtonSize.medium,
    this.isIconLeading = true,
    this.isLoading = false,
    this.isCenterContent = true,
    this.spacer = false,
    this.maxLines,
    this.useAutoSizeText = false,
    this.padding,
  }) : _isEnabled = isEnabled ?? onTap != null ? true : false,
       _buttonType = _ButtonType.primary,
       _isIconOnly = false,
       outlineColor = null;

  /// [INFO] : Button Primary Icon
  ///
  /// use this button for Icon Only, green dominant color, and then has no Text on it.
  ///
  /// if isEnabled null, it will check if the onTap null or not. if null, it will be Disabled
  const ButtonWidget.primaryIcon({
    super.key,
    required this.icon,
    bool? isEnabled,
    this.textColor = AppColors.onPrimary,
    this.color = AppColors.primary,
    this.focusColor = AppColors.primary,
    this.overlayColor = AppColors.primary,
    this.onTap,
    this.buttonSize = ButtonSize.medium,
    this.isLoading = false,
    this.isCenterContent = true,
    this.spacer = false,
    this.maxLines,
    this.useAutoSizeText = false,
    this.padding,
  }) : text = '',
       _isEnabled = isEnabled ?? onTap != null ? true : false,
       _buttonType = _ButtonType.primary,
       _isIconOnly = true,
       isShrink = true,
       isIconLeading = true,
       outlineColor = null;

  /// [INFO] : Button Outlined
  ///
  /// use this button for Outlined button and then has a Text on it.
  ///
  /// if isEnabled null, it will check if the onTap null or not. if null, it will be Disabled
  const ButtonWidget.outlined({
    super.key,
    required this.text,
    this.icon,
    bool? isEnabled,
    this.onTap,
    this.isShrink = false,
    this.textColor = AppColors.primary,
    this.outlineColor = AppColors.outlineVariant,
    this.focusColor = AppColors.primary,
    this.overlayColor = AppColors.primary,
    this.buttonSize = ButtonSize.medium,
    this.isIconLeading = true,
    this.isLoading = false,
    this.isCenterContent = true,
    this.spacer = false,
    this.maxLines,
    this.useAutoSizeText = false,
    this.padding,
  }) : _isEnabled = isEnabled ?? onTap != null ? true : false,
       _buttonType = _ButtonType.outlined,
       _isIconOnly = false,
       color = Colors.transparent;

  /// [INFO] : Button Outlined Icon
  ///
  /// use this button for Icon Only, green dominant color, and then has no Text on it.
  ///
  /// if isEnabled null, it will check if the onTap null or not. if null, it will be Disabled
  ///
  /// `isIconOnly = true` because it only use icon, and then there's no text params
  const ButtonWidget.outlinedIcon({
    super.key,
    required this.icon,
    bool? isEnabled,
    this.onTap,
    this.textColor = AppColors.primary,
    this.outlineColor = AppColors.outlineVariant,
    this.focusColor = AppColors.primary,
    this.overlayColor = AppColors.primary,
    this.buttonSize = ButtonSize.medium,
    this.isLoading = false,
    this.isCenterContent = true,
    this.spacer = false,
    this.maxLines,
    this.useAutoSizeText = false,
    this.padding,
  }) : text = '',
       _isEnabled = isEnabled ?? onTap != null ? true : false,
       _buttonType = _ButtonType.outlined,
       _isIconOnly = true,
       isShrink = true,
       isIconLeading = true,
       color = Colors.transparent;

  /// [INFO] : Button Text
  ///
  /// use this button for Text without background and outlined
  ///
  /// if isEnabled null, it will check if the onTap null or not. if null,
  /// it will be Disabled
  const ButtonWidget.text({
    super.key,
    required this.text,
    bool? isEnabled,
    this.icon,
    this.onTap,
    this.textColor = AppColors.primary,
    this.focusColor = AppColors.primary,
    this.overlayColor = AppColors.primary,
    this.buttonSize = ButtonSize.medium,
    this.isIconLeading = true,
    this.isLoading = false,
    this.isCenterContent = true,
    this.spacer = false,
    this.maxLines,
    this.useAutoSizeText = false,
    this.padding,
  }) : _isEnabled = isEnabled ?? onTap != null ? true : false,
       _buttonType = _ButtonType.text,
       _isIconOnly = false,
       isShrink = true,
       outlineColor = null,
       color = AppColors.surfaceContainerLowest;

  /// [INFO] : Button Text Icon
  ///
  /// use this button for icon only
  ///
  /// if isEnabled null, it will check if the onTap null or not. if null,
  /// it will be Disabled
  const ButtonWidget.textIcon({
    super.key,
    required this.icon,
    bool? isEnabled,
    this.onTap,
    this.textColor = AppColors.primary,
    this.focusColor = AppColors.primary,
    this.overlayColor = AppColors.primary,
    this.buttonSize = ButtonSize.medium,
    this.isLoading = false,
    this.isCenterContent = true,
    this.spacer = false,
    this.maxLines,
    this.useAutoSizeText = false,
    this.padding,
  }) : text = '',
       _isEnabled = isEnabled ?? onTap != null ? true : false,
       _buttonType = _ButtonType.text,
       _isIconOnly = true,
       isShrink = true,
       isIconLeading = true,
       outlineColor = null,
       color = AppColors.surfaceContainerLowest;

  /// [INFO] GET BORDER
  ///
  /// if button disable, it will remove outlined border
  Border? _getBorder() {
    if (_isEnabled && _buttonType == _ButtonType.outlined) {
      return Border.all(color: outlineColor ?? color);
    }
    return null;
  }

  /// [INFO] GET TEXTSTYLE
  ///
  /// getTextStyle function is to get textstyle for button for every size
  TextStyle? _getTextStyle(BuildContext context) {
    TextStyle typography = Theme.of(context).textTheme.headlineSmall!.toBold;

    if (buttonSize == ButtonSize.large) {
      typography = Theme.of(context).textTheme.headlineSmall!.toBold;
    } else if (buttonSize == ButtonSize.medium) {
      typography = Theme.of(context).textTheme.titleMedium!.toBold;
    } else if (buttonSize == ButtonSize.small) {
      typography = Theme.of(context).textTheme.labelSmall!.toBold;
    }

    if (!_isEnabled) {
      if (_buttonType == _ButtonType.primary) {
        return typography.copyWith(color: AppColors.neutral);
      } else {
        return typography.copyWith(color: AppColors.neutral);
      }
    }

    return typography.copyWith(color: textColor);
  }

  /// [INFO] GET CONTENT BUTTON
  ///
  /// have 3 state, if [_isIconOnly], [hasIcon], and [textOnly]
  Widget _contentButton(BuildContext context) {
    if (_isIconOnly) {
      return SizedBox(child: icon!);
    }
    return Row(
      mainAxisAlignment: (isCenterContent)
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      mainAxisSize: isShrink ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (icon != null && isIconLeading) ...[icon!, const SizedBox(width: 8)],
        maxLines != null
            ? Expanded(
                child: AutoSizeText(
                  text,
                  style: _getTextStyle(context),
                  textAlign: TextAlign.center,
                  maxLines: maxLines,
                ),
              )
            : Flexible(
                child: Text(
                  text,
                  style: _getTextStyle(context),
                  textAlign: TextAlign.center,
                  maxLines: maxLines,
                ),
              ),
        if (icon != null && !isIconLeading) ...[
          spacer ? const Spacer() : const SizedBox(width: 8),
          icon!,
        ],
      ],
    );
  }

  /// [INFO] GET OVERLAY COLOR
  ///
  /// if button disable, it will remove overlay color
  WidgetStateProperty<Color>? _getOverlayColor() {
    return _isEnabled ? WidgetStateProperty.all(overlayColor) : null;
  }

  /// [INFO] GET FOCUS COLOR
  ///
  /// if button disable, it will remove focus color
  Color? _getFocusColor() {
    return _isEnabled ? focusColor : null;
  }

  /// [INFO] GET COLOR
  ///
  /// if button disable, it will change color to neutral
  Color? _getColor() {
    if (_buttonType == _ButtonType.primary) {
      return _isEnabled ? color : AppColors.neutral;
    }
    return color;
  }

  /// [INFO] GET COLOR
  ///
  /// function to get padding for every size
  EdgeInsets _getPadding() {
    if (buttonSize == ButtonSize.small) {
      if (_isIconOnly) {
        return EdgeInsets.all(8.0);
      } else {
        return EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0);
      }
    } else if (buttonSize == ButtonSize.medium) {
      if (_isIconOnly) {
        return EdgeInsets.all(12.0);
      } else {
        return EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0);
      }
    } else {
      if (_isIconOnly) {
        return EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);
      } else {
        return EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);
      }
    }
  }

  /// [INFO] GET COLOR
  ///
  /// function to get border radius
  BorderRadius _getBorderRadius() {
    return BorderRadius.circular(SanctuaryLayout.radius);
  }

  /// [INFO] GET COLOR
  ///
  /// function to get loading widget
  Widget _getLoadingWidget(BuildContext context) {
    final indicatorColor = _getTextStyle(context)?.color ?? AppColors.onPrimary;

    return CompactLoadingWidget(
      size: _isIconOnly ? 12.0 : 18.0,
      baseColor: indicatorColor.withValues(alpha: 0.52),
      highlightColor: indicatorColor.withValues(alpha: 0.95),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: _getBorderRadius(),
      color: _getColor(),
      child: InkWell(
        borderRadius: _getBorderRadius(),
        onTap: _isEnabled && isLoading == false
            ? () {
                FocusManager.instance.primaryFocus?.unfocus();
                onTap?.call();
              }
            : null,
        focusColor: _getFocusColor(),
        overlayColor: _getOverlayColor(),
        child: Container(
          width: isShrink ? null : double.infinity,
          padding: padding ?? _getPadding(),
          decoration: BoxDecoration(
            border: _getBorder(),
            borderRadius: _getBorderRadius(),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Visibility(visible: isLoading, child: _getLoadingWidget(context)),
              Visibility(
                visible: !isLoading,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: _contentButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
