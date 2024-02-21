import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class PaymentMethodSelectionCardWidget<T> extends StatelessWidget {
  const PaymentMethodSelectionCardWidget({
    super.key,
    required this.onChangedValue,
    required this.radioIdentifierValue,
    required this.groupValue,
    required this.title,
    this.useCardWidget = false,
    required this.image,
  });

  final void Function(T value) onChangedValue;

  final T radioIdentifierValue;
  final T groupValue;

  final String title;

  final bool useCardWidget;

  final AssetGenImage image;

  @override
  Widget build(BuildContext context) {
    final Widget content = Row(
      children: [
        image.image(
          width: BaseSize.customWidth(40),
          fit: BoxFit.fitWidth,
        ),
        Gap.w16,
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TypographyTheme.textMRegular.toNeutral60,
              ),
              RadioWidget<T>.primary(
                value: radioIdentifierValue,
                groupValue: groupValue,
                onChanged: onChangedValue,
              ),
            ],
          ),
        ),
      ],
    );

    return useCardWidget
        ? CardWidget(
      onTap: () => onChangedValue(radioIdentifierValue),
      content: [content],
    )
        : InkWell(
      onTap: () => onChangedValue(radioIdentifierValue),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: BaseSize.h12,
        ),
        child: content,
      ),
    );
  }
}
