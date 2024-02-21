import 'package:flutter/material.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class ToggleableInputTextWidget extends StatefulWidget {
  const ToggleableInputTextWidget({
    super.key,
    this.onChanged,
    this.validator,
    required this.controller,
    required this.mainLabel,
    required this.obscure,
  });

  final TextEditingController controller;
  final String mainLabel;
  final void Function(String value)? onChanged;
  final String? Function(String? value)? validator;

  final bool obscure;

  @override
  State<ToggleableInputTextWidget> createState() => _ToggleableInputTextWidgetState();
}

class _ToggleableInputTextWidgetState extends State<ToggleableInputTextWidget> {
  late bool obscure = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return InputFormWidget.password(
      controller: widget.controller,
      label: widget.mainLabel,
      hintText: "${LocaleKeys.text_enter.tr()} ${widget.mainLabel}",
      onObscureTap: () {
        setState(() {
          obscure = !obscure;
        });
      },
      isObscure: obscure,
      hasBorderState: false,
      onChanged: widget.onChanged,
      validator: widget.validator,
    );
  }
}
