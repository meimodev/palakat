import 'package:flutter/material.dart';
import 'package:palakat/shared/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextFieldWrapper extends StatelessWidget {
  const TextFieldWrapper({
    Key? key,
    required this.textEditingController,
    required this.labelText,
    this.description,
    this.textInputType,
    this.endIconData,
    this.enabled = true,
    this.readOnly = false,
    this.onPressed,
    this.startIconData, this.fontColor, this.onChangeText, this.maxLength, this.hintText,
  }) : super(key: key);

  final TextEditingController textEditingController;
  final String labelText;
  final String? description;
  final TextInputType? textInputType;
  final IconData? endIconData;
  final IconData? startIconData;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onPressed;
  final int? maxLength;
  final String? hintText;

  final void Function(String text)? onChangeText;

  final Color? fontColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        description != null
            ? Text(
                description!,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w300,
                  fontSize: 11.sp,
                ),
              )
            : const SizedBox(),
        description != null
            ? SizedBox(height: Insets.small.h * .5)
            : const SizedBox(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Insets.small.w,
            vertical: Insets.small.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: Palette.cardBackground,
          ),
          child: Row(
            children: [
              startIconData != null
                  ? Icon(
                      startIconData!,
                      size: 15.sp,
                      color: fontColor ?? Palette.primary,
                    )
                  : const SizedBox(),
              startIconData != null
                  ? const SizedBox(width: 12)
                  : const SizedBox(),
              Expanded(
                child: TextField(
                  onTap: onPressed,
                  controller: textEditingController,
                  enableSuggestions: false,
                  autocorrect: false,
                  maxLines: 1,
                  enabled: enabled,
                  readOnly: readOnly,
                  cursorColor: Palette.primary,
                  keyboardType: textInputType,
                  onChanged: onChangeText,
                  // maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  // maxLength: maxLength,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontSize: 14.sp,
                    color: Palette.primary,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    contentPadding: EdgeInsets.all(0.sp),
                    isDense: true,
                    border: InputBorder.none,
                    labelText: labelText,
                    labelStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontSize: 14.sp,
                      color: fontColor ?? Palette.primary,
                    ),
                  ),
                ),
              ),
              endIconData != null ? const SizedBox(width: 12) : const SizedBox(),
              endIconData != null
                  ? Icon(
                      endIconData!,
                      size: 15.sp,
                      color: Palette.primary,
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }
}
