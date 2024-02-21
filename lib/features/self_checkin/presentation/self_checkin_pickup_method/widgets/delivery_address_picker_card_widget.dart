import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';

class DeliveryAddressPickerCardWidget extends StatefulWidget {
  const DeliveryAddressPickerCardWidget({
    super.key,
    required this.onSelectedAddress,
    this.selectedAddress,
  });

  final void Function(UserAddress userAddress) onSelectedAddress;
  final UserAddress? selectedAddress;

  @override
  State<DeliveryAddressPickerCardWidget> createState() =>
      _DeliveryAddressPickerCardWidgetState();
}

class _DeliveryAddressPickerCardWidgetState
    extends State<DeliveryAddressPickerCardWidget> {
  late UserAddress? selectedAddress = widget.selectedAddress;


  void onPressedCard() async {
    final result = await context.pushNamed(
      AppRoute.addressList,
      extra: const RouteParam(
        params: {
          RouteParamKey.addressOperationType: AddressListType.selection,
        },
      ),
    );

    if (result != null) {
      final res = result as UserAddress;
      widget.onSelectedAddress(res);
      setState(() {
        selectedAddress = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      onTap: onPressedCard,
      content: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedAddress?.name ??
                      LocaleKeys.text_chooseYourAddress.tr(),
                  style: TypographyTheme.textMSemiBold.toNeutral80,
                ),
                Gap.customGapHeight(6),
                Text(
                  selectedAddress?.address ??
                      LocaleKeys.text_makeSureYourAddressIsCorrect.tr(),
                  style: TypographyTheme.textSRegular.toNeutral60,
                ),
              ],
            ),
            Assets.icons.line.chevronRight.svg(
              width: BaseSize.w24,
              height: BaseSize.h24,
            ),
          ],
        ),
      ],
    );
  }
}
