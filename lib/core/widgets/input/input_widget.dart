import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

class InputFormWidget extends StatefulWidget {
  const InputFormWidget({
    super.key,
    required this.hintText,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.isActive = true,
    this.label,
    this.isImportant = false,
    this.keyboardType,
    this.textInputAction,
    bool hasIconState = true,
    this.maxLength,
    this.maxLines,
    this.helperText,
    this.error,
    this.hasBorderState = true,
    this.outsidePrefix,
    this.prefix,
    this.prefixIcon,
    this.suffixIcon,
    this.isIdrFormatted = false,
    this.isInputNumber = false,
    this.description,
    this.isNpwpFormat = false,
    this.isKtpFormat = false,
    this.readOnly = false,
    this.inputFormatters,
    this.onBodyTap,
    this.hasValidateMessage = true,
    this.scrollPadding,
    this.clearBorder = false,
    this.descriptionStyle,
    this.valueTextStyle,
    this.counterTextStyle,
  })  : isObscure = false,
        onObscureTap = null,
        hasIconState = validator == null ? false : hasIconState,
        isDropdown = false;

  const InputFormWidget.password({
    super.key,
    required this.hintText,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.isActive = true,
    this.label,
    this.isImportant = false,
    this.isObscure = true,
    this.textInputAction,
    this.onObscureTap,
    this.helperText,
    this.error,
    this.maxLength,
    this.hasBorderState = true,
    this.prefix,
    this.outsidePrefix,
    this.isInputNumber = false,
    this.description,
    this.isNpwpFormat = false,
    this.isKtpFormat = false,
    this.inputFormatters,
    this.hasValidateMessage = true,
    this.scrollPadding,
    this.clearBorder = false,
    this.descriptionStyle,
    this.valueTextStyle,
    this.counterTextStyle,
    this.prefixIcon,
  })  : hasIconState = false,
        onBodyTap = null,
        readOnly = false,
        isDropdown = false,
        keyboardType = TextInputType.visiblePassword,
        maxLines = 1,
        isIdrFormatted = false,
        suffixIcon = null;

  const InputFormWidget.dropdown({
    super.key,
    required this.hintText,
    required this.onBodyTap,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.validator,
    this.isActive = true,
    this.keyboardType,
    this.label,
    this.isImportant = false,
    this.onChanged,
    this.onEditingComplete,
    bool hasIconState = true,
    this.textInputAction,
    this.maxLines,
    this.maxLength,
    this.helperText,
    this.error,
    this.hasBorderState = true,
    this.prefix,
    this.outsidePrefix,
    this.isInputNumber = false,
    this.suffixIcon,
    this.description,
    this.isNpwpFormat = false,
    this.isKtpFormat = false,
    this.inputFormatters,
    this.hasValidateMessage = true,
    this.scrollPadding,
    this.clearBorder = false,
    this.descriptionStyle,
    this.valueTextStyle,
    this.counterTextStyle,
    this.prefixIcon,
  })  : isObscure = false,
        onObscureTap = null,
        readOnly = true,
        hasIconState = validator == null ? false : hasIconState,
        isDropdown = true,
        isIdrFormatted = false;

  const InputFormWidget.idrFormat({
    super.key,
    required this.hintText,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.isActive = true,
    this.label,
    this.isImportant = false,
    this.textInputAction,
    bool hasIconState = true,
    this.maxLines,
    this.maxLength,
    this.helperText,
    this.error,
    this.suffixIcon,
    this.hasBorderState = true,
    this.description,
    this.isNpwpFormat = false,
    this.isKtpFormat = false,
    this.inputFormatters,
    this.hasValidateMessage = true,
    this.scrollPadding,
    this.clearBorder = false,
    this.descriptionStyle,
    this.valueTextStyle,
    this.counterTextStyle,
    this.prefixIcon,
  })  : isObscure = false,
        onObscureTap = null,
        hasIconState = validator == null ? false : hasIconState,
        onBodyTap = null,
        readOnly = false,
        isDropdown = false,
        prefix = "IDR",
        outsidePrefix = null,
        isIdrFormatted = true,
        keyboardType = TextInputType.number,
        isInputNumber = true;

  /// [INFO]
  /// Below are required parameters :
  final String hintText;

  /// [INFO]
  /// Below are optional parameters :
  final TextEditingController? controller;
  final String? initialValue;
  final bool isImportant;
  final String? label;
  final void Function(String value)? onChanged;
  final VoidCallback? onEditingComplete;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onBodyTap;
  final bool readOnly;
  final bool isDropdown;
  final int? maxLength;
  final int? maxLines;
  final String? outsidePrefix;
  final String? prefix;
  final Widget? suffixIcon;
  final bool clearBorder;
  final bool isIdrFormatted;
  final bool isInputNumber;
  final bool isNpwpFormat;
  final bool isKtpFormat;
  final FocusNode? focusNode;
  final TextStyle? descriptionStyle;
  final TextStyle? valueTextStyle;
  final TextStyle? counterTextStyle;

  /// [INFO]
  /// if [validator] null, it will make iconState dissapear
  ///
  final String? Function(String? value)? validator;
  final bool? isActive;

  /// [INFO]
  /// [hasIconState] is if we want use icon state (success or fail) or not.
  /// set false if you don't want to use it

  final bool hasIconState;
  final bool hasBorderState;

  /// [INFO]
  /// [isObscure] is for obscureText, only works on [InputFormWidget.password()]

  final bool isObscure;

  /// [INFO]
  /// [onObscureTap] for callback when obscure icon tapped, if onObscureTap
  /// null, it will make eye icon dissapear

  final VoidCallback? onObscureTap;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? helperText;
  final String? error;
  final String? description;
  final EdgeInsets? scrollPadding;
  final Widget? prefixIcon;

  final bool hasValidateMessage;

  /// [INFO]
  /// Below are keys for widget key :
  static const String _key = 'input_form';
  static const widgetKey = Key(_key);
  static const inputFormLabelKey = Key('${_key}_label');
  static const inputFormTextFormFieldKey = Key('${_key}_text_form_field');

  @override
  State<InputFormWidget> createState() => _InputFormWidgetState();
}

class _InputFormWidgetState extends State<InputFormWidget> {
  final validateState = ValueNotifier<ValidateState>(ValidateState._none);

  @override
  void dispose() {
    validateState.dispose();
    super.dispose();
  }

  TextFormField get _getFormField {
    return TextFormField(
      focusNode: widget.focusNode,
      initialValue: widget.initialValue,
      enableInteractiveSelection: !widget.isIdrFormatted,
      scrollPadding: widget.scrollPadding ?? const EdgeInsets.all(20.0),
      keyboardType: widget.keyboardType,
      cursorColor: BaseColor.neutral.shade40,
      key: InputFormWidget.inputFormTextFormFieldKey,
      validator: (value) {
        final isValid = widget.validator?.call(value);

        if (isValid == null) {
          validateState.value = ValidateState._valid;
        } else {
          validateState.value = ValidateState._notValid;
        }

        safeSetState(() {});

        return widget.hasValidateMessage ? isValid : null;
      },
      style: widget.valueTextStyle ??
          (widget.isInputNumber
              ? BaseTypography.textLRegular
              : BaseTypography.textLRegular),
      enabled: widget.isActive,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      readOnly: widget.readOnly,
      onTap: widget.onBodyTap,
      buildCounter: (
        context, {
        required currentLength,
        required isFocused,
        maxLength,
      }) =>
          maxLength != null
              ? Text(
                  "$currentLength/$maxLength",
                  style: widget.counterTextStyle,
                )
              : null,
      textInputAction: widget.textInputAction,
      inputFormatters: [
        if (widget.isIdrFormatted) ...[
          FilteringTextInputFormatter.digitsOnly,
          ThousandsSeparatorInputFormatter(),
        ],
        ...?widget.inputFormatters,
      ],
      onChanged: (value) {
        if (widget.hasIconState) {
          if (widget.validator?.call(value) != null) {
            validateState.value = ValidateState._notValid;
          } else {
            validateState.value = ValidateState._valid;
          }
        }
        widget.onChanged?.call(value);
      },
      onEditingComplete: widget.onEditingComplete,
      obscureText: widget.isObscure,
      maxLength: widget.maxLength,
      controller: widget.controller,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon ?? _getPrefixIDR(),
        prefixIconConstraints: BoxConstraints(
          minWidth: BaseSize.w56,
        ),
        errorMaxLines: 2,
        errorText: widget.error,
        helperText: widget.helperText,
        helperStyle: BaseTypography.textSRegular.toNeutral60,
        fillColor: Colors.transparent,
        hintText: widget.hintText,
        hintStyle: widget.isInputNumber
            ? BaseTypography.textLRegular.fontColor(BaseColor.neutral.shade50)
            : BaseTypography.textLRegular.fontColor(BaseColor.neutral.shade50),
        enabledBorder: _underlineInputBorder(
          color: BaseColor.neutral.shade20,
        ),
        focusedBorder: _underlineInputBorder(
          color: _getFocusedBorderColor(),
        ),
        border: _underlineInputBorder(
          color: ValidateState._valid == validateState.value
              ? BaseColor.primary3
              : BaseColor.neutral.shade30,
        ),
        errorBorder: _underlineInputBorder(
          color: ValidateState._valid == validateState.value
              ? BaseColor.neutral.shade30
              : BaseColor.error,
        ),
        focusedErrorBorder: _underlineInputBorder(
          color: ValidateState._valid == validateState.value
              ? BaseColor.primary3
              : BaseColor.error,
        ),
        suffixIcon: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.w12,
            vertical: BaseSize.h12,
          ),
          child: widget.suffixIcon ??
              (widget.hasIconState
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // TODO: Revisit this later to improve logic
                        if (widget.isDropdown) ...[
                          Assets.icons.line.chevronDown.svg(),
                          Gap.w8,
                          if (validateState.value == ValidateState._notValid)
                            IconState(validate: validateState),
                        ] else
                          IconState(validate: validateState),
                      ],
                    )
                  : widget.onObscureTap != null
                      ? InkWell(
                          onTap: widget.onObscureTap,
                          child: widget.isObscure
                              ? Assets.icons.line.closedEye.svg(
                                  colorFilter:
                                      BaseColor.neutral.shade50.filterSrcIn)
                              : Assets.icons.line.openedEye.svg(
                                  colorFilter:
                                      BaseColor.neutral.shade50.filterSrcIn),
                        )
                      : widget.isDropdown
                          ? Assets.icons.line.chevronDown.svg()
                          : null),
        ),
      ),
      maxLines: widget.maxLines,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: InputFormWidget.widgetKey,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label.toString(),
                style: BaseTypography.textMRegular
                    .fontColor(BaseColor.neutral.shade60),
              ),
              if (widget.isImportant)
                Text(
                  '*',
                  style: BaseTypography.textLRegular.toRed500,
                ),
            ],
          ),
          Gap.h8,
        ],
        if (widget.description != null) ...[
          Text(
            widget.description.toString(),
            style: widget.descriptionStyle ?? BaseTypography.bodyRegular,
          ),
          Gap.h8,
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.outsidePrefix != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12.3),
                child: Text(
                  widget.outsidePrefix.toString(),
                  style: BaseTypography.textLRegular,
                ),
              ),
              Gap.w12,
            ],
            Expanded(child: _getFormField),
          ],
        ),
      ],
    );
  }

  UnderlineInputBorder? _underlineInputBorder({required Color color}) {
    if (widget.clearBorder) {
      return const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      );
    }
    return UnderlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(
        width: BaseSize.w2,
        color: color,
      ),
    );
  }

  Color _getFocusedBorderColor() {
    return widget.hasBorderState
        ? ValidateState._none == validateState.value
            ? BaseColor.neutral.shade30
            : ValidateState._valid == validateState.value
                ? BaseColor.neutral.shade30
                : BaseColor.error
        : BaseColor.neutral.shade30;
  }

  Widget? _getPrefixIDR() {
    if (widget.prefix != null) {
      return Align(
        alignment: Alignment.centerLeft,
        widthFactor: 0.1,
        child: Padding(
          padding: EdgeInsets.only(
            left: BaseSize.w16,
            bottom: BaseSize.h4 / 2,
          ),
          child: Text(
            widget.prefix ?? "",
            style: BaseTypography.textMRegular,
          ),
        ),
      );
    } else {
      return null;
    }
  }
}

enum ValidateState {
  _none,
  _notValid,
  _valid,
}

class IconState extends StatelessWidget {
  const IconState({super.key, required this.validate});

  final ValueNotifier<ValidateState> validate;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: validate,
      builder: (context, value, child) {
        switch (value) {
          // case ValidateState._none:
          default:
            return const SizedBox();
          // case ValidateState._notValid:
          //   return Assets.icons.exclamationCircle.svg();
          // case ValidateState._valid:
          //   return Assets.icons.checkCircle.svg();
        }
      },
    );
  }
}
