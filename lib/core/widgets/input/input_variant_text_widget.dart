import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';

class InputVariantTextWidget extends StatelessWidget {
  const InputVariantTextWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.maxLines,
    this.hint,
    this.endIcon,
  });

  final TextEditingController? controller;
  final void Function(String value)? onChanged;
  final int? maxLines;
  final String? hint;
  final SvgGenImage? endIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
      decoration: BoxDecoration(
        color: BaseColor.cardBackground1,
        borderRadius: BorderRadius.circular(
          BaseSize.radiusMd,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _buildTextFormFiled()),
          _buildEndIcon(),
        ],
      ),
    );
  }

  Widget _buildTextFormFiled() {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        fillColor: BaseColor.cardBackground1,
      ),
    );
  }

  Widget _buildEndIcon() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Gap.w12,
        (endIcon ?? Assets.icons.line.chevronDownOutline).svg(
          width: BaseSize.w12,
          height: BaseSize.w12,
        ),
      ],
    );
  }
}
