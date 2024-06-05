import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

enum InputWidgetVariant {
  text,
  dropdown,
}

class InputWidget extends StatefulWidget {
  const InputWidget.text({
    super.key,
    this.maxLines = 1,
    this.hint,
    this.label,
    this.onChanged,
    this.controller,
  })  : onPressedWithResult = null,
        endIcon = null,
        variant = InputWidgetVariant.text;

  const InputWidget.dropdown({
    super.key,
    this.label,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
    required this.controller,
    required this.onPressedWithResult,
    this.endIcon,
  }) : variant = InputWidgetVariant.dropdown;

  final int? maxLines;
  final String? hint;
  final String? label;
  final InputWidgetVariant variant;

  final TextEditingController? controller;
  final Function(String text)? onChanged;

  final Future<String> Function()? onPressedWithResult;

  final SvgGenImage? endIcon;

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabelWidget(),
        InkWell(
          onTap: () async {
            if (widget.onPressedWithResult != null) {
              final result = await widget.onPressedWithResult!();
              if (widget.controller != null) {
                widget.controller!.text = result;
              }
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
            decoration: BoxDecoration(
              border: Border.all()
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildTextFormFiled()),
                _buildEndIcon(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEndIcon() {
    if (widget.endIcon == null && widget.variant == InputWidgetVariant.text) {
      return const SizedBox();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Gap.w12,
        (widget.endIcon ?? Assets.icons.line.chevronDownOutline).svg(
          width: BaseSize.w12,
          height: BaseSize.w12,
        ),
      ],
    );
  }

  Widget _buildLabelWidget() {
    if (widget.label == null) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: BaseTypography.bodyMedium.toSecondary,
        ),
        Gap.h6,
      ],
    );
  }

  Widget _buildTextFormFiled() {
    return TextFormField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        hintText: widget.hint,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        fillColor: BaseColor.cardBackground1,
      ),
    );
  }
}
