import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/radio/radio_widget.dart';
import 'package:halo_hermina/core/widgets/ripple_touch/ripple_touch_widget.dart';

class LanguageRadioTileWidget<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final String label;
  final Function(T newValue) onTap;

  const LanguageRadioTileWidget({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: BaseSize.h12),
      child: RippleTouch(
        borderRadius: BorderRadius.circular(BaseSize.w8),
        onTap: () {
          onTap(value);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BaseSize.w8),
            border: Border.all(
              width: 1,
              color: BaseColor.neutral.shade30,
            ),
          ),
          padding: EdgeInsets.all(BaseSize.w16),
          child: RadioWidget<T>.primary(
            value: value,
            groupValue: groupValue,
            onChanged: (T value) {
              onTap(value);
            },
            labelSpacing: Gap.w12,
            label: label,
            labelStyle: TypographyTheme.bodySemiBold.w500,
          ),
        ),
      ),
    );
  }
}
