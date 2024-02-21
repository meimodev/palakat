import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:palakat/core/constants/constants.dart';

enum _ButtonType {
  primary,
  outlined,
  text,
}

enum ButtonSize {
  small,
  medium,
  large,
}

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
  const ButtonWidget.primary(
      {Key? key,
      required this.text,
      this.icon,
      bool? isEnabled,
      this.textColor = BaseColor.white,
      this.color = BaseColor.primary3,
      this.focusColor = BaseColor.primary2,
      this.overlayColor = BaseColor.primaryLight,
      this.onTap,
      this.isShrink = false,
      this.buttonSize = ButtonSize.medium,
      this.isIconLeading = true,
      this.isLoading = false,
      this.isCenterContent = true,
      this.spacer = false,
      this.maxLines,
      this.useAutoSizeText = false,
      this.padding})
      : _isEnabled = isEnabled ?? onTap != null ? true : false,
        _buttonType = _ButtonType.primary,
        _isIconOnly = false,
        outlineColor = null,
        super(key: key);

  /// [INFO] : Button Primary Icon
  ///
  /// use this button for Icon Only, green dominant color, and then has no Text on it.
  ///
  /// if isEnabled null, it will check if the onTap null or not. if null, it will be Disabled
  const ButtonWidget.primaryIcon(
      {Key? key,
      required this.icon,
      bool? isEnabled,
      this.textColor = BaseColor.white,
      this.color = BaseColor.primary3,
      this.focusColor = BaseColor.primary2,
      this.overlayColor = BaseColor.primaryLight,
      this.onTap,
      this.buttonSize = ButtonSize.medium,
      this.isLoading = false,
      this.isCenterContent = true,
      this.spacer = false,
      this.maxLines,
      this.useAutoSizeText = false,
      this.padding})
      : text = '',
        _isEnabled = isEnabled ?? onTap != null ? true : false,
        _buttonType = _ButtonType.primary,
        _isIconOnly = true,
        isShrink = true,
        isIconLeading = true,
        outlineColor = null,
        super(key: key);

  /// [INFO] : Button Outlined
  ///
  /// use this button for Outlined button and then has a Text on it.
  ///
  /// if isEnabled null, it will check if the onTap null or not. if null, it will be Disabled
  const ButtonWidget.outlined(
      {Key? key,
      required this.text,
      this.icon,
      bool? isEnabled,
      this.onTap,
      this.isShrink = false,
      this.textColor = BaseColor.primary3,
      this.outlineColor = BaseColor.primary3,
      this.focusColor = BaseColor.primary2,
      this.overlayColor = BaseColor.primary2,
      this.buttonSize = ButtonSize.medium,
      this.isIconLeading = true,
      this.isLoading = false,
      this.isCenterContent = true,
      this.spacer = false,
      this.maxLines,
      this.useAutoSizeText = false,
      this.padding})
      : _isEnabled = isEnabled ?? onTap != null ? true : false,
        _buttonType = _ButtonType.outlined,
        _isIconOnly = false,
        color = BaseColor.transparent,
        super(key: key);

  /// [INFO] : Button Outlined Icon
  ///
  /// use this button for Icon Only, green dominant color, and then has no Text on it.
  ///
  /// if isEnabled null, it will check if the onTap null or not. if null, it will be Disabled
  ///
  /// `isIconOnly = true` because it only use icon, and then there's no text params
  const ButtonWidget.outlinedIcon(
      {Key? key,
      required this.icon,
      bool? isEnabled,
      this.onTap,
      this.textColor = BaseColor.primary3,
      this.outlineColor = BaseColor.primary3,
      this.focusColor = BaseColor.primary2,
      this.overlayColor = BaseColor.primary2,
      this.buttonSize = ButtonSize.medium,
      this.isLoading = false,
      this.isCenterContent = true,
      this.spacer = false,
      this.maxLines,
      this.useAutoSizeText = false,
      this.padding})
      : text = '',
        _isEnabled = isEnabled ?? onTap != null ? true : false,
        _buttonType = _ButtonType.outlined,
        _isIconOnly = true,
        isShrink = true,
        isIconLeading = true,
        color = BaseColor.transparent,
        super(key: key);

  /// [INFO] : Button Text
  ///
  /// use this button for Text without background and outlined
  ///
  /// if isEnabled null, it will check if the onTap null or not. if null,
  /// it will be Disabled
  const ButtonWidget.text(
      {Key? key,
      required this.text,
      bool? isEnabled,
      this.icon,
      this.onTap,
      this.textColor = BaseColor.primary3,
      this.focusColor = BaseColor.primary2,
      this.overlayColor = BaseColor.primary2,
      this.buttonSize = ButtonSize.medium,
      this.isIconLeading = true,
      this.isLoading = false,
      this.isCenterContent = true,
      this.spacer = false,
      this.maxLines,
      this.useAutoSizeText = false,
      this.padding})
      : _isEnabled = isEnabled ?? onTap != null ? true : false,
        _buttonType = _ButtonType.text,
        _isIconOnly = false,
        isShrink = true,
        outlineColor = null,
        color = BaseColor.white,
        super(key: key);

  /// [INFO] : Button Text Icon
  ///
  /// use this button for icon only
  ///
  /// if isEnabled null, it will check if the onTap null or not. if null,
  /// it will be Disabled
  const ButtonWidget.textIcon(
      {Key? key,
      required this.icon,
      bool? isEnabled,
      this.onTap,
      this.textColor = BaseColor.primary3,
      this.focusColor = BaseColor.primary2,
      this.overlayColor = BaseColor.primary2,
      this.buttonSize = ButtonSize.medium,
      this.isLoading = false,
      this.isCenterContent = true,
      this.spacer = false,
      this.maxLines,
      this.useAutoSizeText = false,
      this.padding})
      : text = '',
        _isEnabled = isEnabled ?? onTap != null ? true : false,
        _buttonType = _ButtonType.text,
        _isIconOnly = true,
        isShrink = true,
        isIconLeading = true,
        outlineColor = null,
        color = BaseColor.white,
        super(key: key);

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
  TextStyle? _getTextStyle() {
    TextStyle typography = BaseTypography.textMSemiBold;

    if (buttonSize == ButtonSize.large) {
      typography = BaseTypography.textLSemiBold;
    } else if (buttonSize == ButtonSize.medium) {
      typography = BaseTypography.textMBold;
    } else if (buttonSize == ButtonSize.small) {
      typography = BaseTypography.textSBold;
    }

    if (!_isEnabled) {
      if (_buttonType == _ButtonType.primary) {
        return typography.copyWith(color: BaseColor.neutral[40]);
      } else {
        return typography.copyWith(color: BaseColor.neutral[30]);
      }
    }

    return typography.copyWith(color: textColor);
  }

  /// [INFO] GET CONTENT BUTTON
  ///
  /// have 3 state, if [_isIconOnly], [hasIcon], and [textOnly]
  Widget _contentButton() {
    if (_isIconOnly) {
      return SizedBox(
        child: icon!,
      );
    }
    return Row(
      mainAxisAlignment: (isCenterContent)
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      mainAxisSize: isShrink ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (icon != null && isIconLeading) ...[
          icon!,
          Gap.w8,
        ],
        maxLines != null
            ? Expanded(
                child: AutoSizeText(
                  text,
                  style: _getTextStyle(),
                  textAlign: TextAlign.center,
                  maxLines: maxLines,
                ),
              )
            : Text(
                text,
                style: _getTextStyle(),
                textAlign: TextAlign.center,
                maxLines: maxLines,
              ),
        if (icon != null && !isIconLeading) ...[
          spacer ? const Spacer() : Gap.w8,
          icon!,
        ],
      ],
    );
  }

  /// [INFO] GET OVERLAY COLOR
  ///
  /// if button disable, it will remove overlay color
  MaterialStateProperty<Color>? _getOverlayColor() {
    return _isEnabled ? MaterialStateProperty.all(overlayColor) : null;
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
      return _isEnabled ? color : BaseColor.neutral[20];
    }
    return color;
  }

  /// [INFO] GET COLOR
  ///
  /// function to get padding for every size
  EdgeInsets _getPadding() {
    if (buttonSize == ButtonSize.small) {
      if (_isIconOnly) {
        return EdgeInsets.all(BaseSize.w8);
      } else {
        return EdgeInsets.symmetric(
          horizontal: BaseSize.w24,
          vertical: BaseSize.h8,
        );
      }
    } else if (buttonSize == ButtonSize.medium) {
      if (_isIconOnly) {
        return EdgeInsets.all(BaseSize.w12);
      } else {
        return EdgeInsets.symmetric(
          horizontal: BaseSize.w24,
          vertical: BaseSize.h12,
        );
      }
    } else {
      if (_isIconOnly) {
        return EdgeInsets.symmetric(
          horizontal: BaseSize.w16,
          vertical: BaseSize.h16,
        );
      } else {
        return EdgeInsets.symmetric(
          horizontal: BaseSize.w16,
          vertical: BaseSize.h16,
        );
      }
    }
  }

  /// [INFO] GET COLOR
  ///
  /// function to get border radius
  BorderRadius _getBorderRadius() {
    return BorderRadius.circular(BaseSize.radiusMd);
  }

  /// [INFO] GET COLOR
  ///
  /// function to get loading widget
  Widget _getLoadingWidget() {
    return SizedBox(
      height: _isIconOnly ? BaseSize.h12 : BaseSize.h18,
      width: _isIconOnly ? BaseSize.h12 : BaseSize.h18,
      child: CircularProgressIndicator(color: _getTextStyle()?.color),
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
              Visibility(
                visible: isLoading,
                child: _getLoadingWidget(),
              ),
              Visibility(
                visible: !isLoading,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: _contentButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
