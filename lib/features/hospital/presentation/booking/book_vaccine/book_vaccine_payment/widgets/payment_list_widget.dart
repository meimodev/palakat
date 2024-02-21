import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/radio/radio_widget.dart';

class PaymentListWidget extends StatelessWidget {
  const PaymentListWidget({
    required this.paymentItem,
    required this.index,
    this.selectedValue,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  final dynamic paymentItem;
  final int index;
  final int? selectedValue;
  final Function(int? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            onChanged(index);
          },
          child: Row(
            children: [
              SvgPicture.network(
                paymentItem["imageurl"],
                width: 40,
                fit: BoxFit.fitWidth,
              ),
              Gap.w16,
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      paymentItem["name"],
                      style: TypographyTheme.textLRegular
                          .fontColor(BaseColor.neutral.shade60),
                    ),
                    RadioWidget.primary(
                      value: index,
                      groupValue: selectedValue,
                      onChanged: (int? value) {
                        onChanged(value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// myOnChangedCallback(int? value) {}
