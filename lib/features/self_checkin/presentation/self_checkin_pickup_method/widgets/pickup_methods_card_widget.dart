import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class PickUpMethodsCardWidget extends StatelessWidget {
  const PickUpMethodsCardWidget({
    super.key,
    required this.method,
    required this.groupValue,
    required this.onChangedValue,
    this.subTitle,
  });

  final PickUpDeliveryOptionEnum method;
  final PickUpDeliveryOptionEnum groupValue;
  final void Function(PickUpDeliveryOptionEnum value) onChangedValue;

  final Widget? subTitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      overlayColor: MaterialStateColor.resolveWith(
        (states) => Colors.transparent,
      ),
      onTap: () => onChangedValue(method),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                method == PickUpDeliveryOptionEnum.pickup ? "Pickup" : "Delivery",
                style: TypographyTheme.textLRegular.toNeutral80,
              ),
              RadioWidget<PickUpDeliveryOptionEnum>.primary(
                value: method,
                onChanged: (value) {
                  onChangedValue(value);
                },
                size: RadioSize.small,
                groupValue: groupValue,
              ),
            ],
          ),
          Gap.customGapHeight(6),
          subTitle ?? const SizedBox(),
        ],
      ),
    );
  }
}
