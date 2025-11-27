import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';

import '../widgets.dart';

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

  final String? initialValue;
  final TextEditingController? controller;
  final void Function(String value)? onChanged;
  final int? maxLines;
  final String? hint;
  final SvgGenImage? leadIcon;
  final SvgGenImage? endIcon;
  final TextInputType? textInputType;
  final Color? borderColor;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
            decoration: BoxDecoration(
              color: BaseColor.white,
              border: Border.all(
                color: hasFocus
                    ? BaseColor.teal[700]!
                    : (borderColor ?? BaseColor.neutral30),
                width: hasFocus ? 2 : 1.5,
              ),
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              boxShadow: hasFocus
                  ? [
                      BoxShadow(
                        color: BaseColor.teal[200]!.withValues(alpha: 0.3),
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
                leadIcon == null ? const SizedBox() : _buildLeadIcon(),
                Expanded(child: _buildTextFormFiled()),
                endIcon == null ? const SizedBox() : _buildEndIcon(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextFormFiled() {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      keyboardType: textInputType,
      initialValue: initialValue,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: BaseColor.black,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: BaseColor.neutral50,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        fillColor: BaseColor.white,
        contentPadding: EdgeInsets.symmetric(vertical: BaseSize.h12),
      ),
    );
  }

  Widget _buildLeadIcon() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        leadIcon!.svg(width: BaseSize.w12, height: BaseSize.w12),
        Gap.w12,
        DividerWidget(height: BaseSize.h20),
        Gap.w12,
      ],
    );
  }

  Widget _buildEndIcon() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Gap.w12,
        endIcon!.svg(width: BaseSize.w12, height: BaseSize.w12),
      ],
    );
  }
}
