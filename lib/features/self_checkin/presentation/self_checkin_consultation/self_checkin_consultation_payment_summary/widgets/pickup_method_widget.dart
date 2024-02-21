import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/presentation.dart';

class PickUpMethodWidget extends StatelessWidget {
  const PickUpMethodWidget({
    super.key,
    this.selectedName,
    this.selectedAddress,
    this.selectedType,
    required this.controller,
  });

  final String? selectedName;
  final String? selectedAddress;
  final String? selectedType;
  final SelfCheckInConsultationPaymentSummaryController controller;

  final String queue = "4";

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        controller.handleOnTapChoosePickUpMethod();
        // context.pushNamed(AppRoute.selfCheckInConsultationPickupMethod);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: BaseSize.h4),
        decoration: BoxDecoration(
          border: Border.all(color: BaseColor.neutral.shade20, width: 1),
          borderRadius: BorderRadius.circular(BaseSize.radiusLg),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              selectedType == "pickup"
                  ? _buildPickup(queue)
                  : selectedType == "delivery"
                      ? _buildDelivery(selectedName, selectedAddress)
                      : _buildNoPickupMethod(),
              Assets.icons.line.chevronRight.svg(
                height: BaseSize.h24,
                width: BaseSize.w24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildNoPickupMethod() {
    return Row(
      children: [
        Assets.icons.line.pickup.svg(
            height: BaseSize.customHeight(20),
            width: BaseSize.customHeight(20),
            colorFilter: BaseColor.primary3.filterSrcIn),
        Gap.w8,
        Text(
          LocaleKeys.text_choosePickupMethod.tr(),
          style:
              TypographyTheme.textLSemiBold.toNeutral60,
        ),
        Gap.w4,
      ],
    );
  }

  _buildDelivery(name, address) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style:
                TypographyTheme.textSBold.toNeutral80,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            address,
            style: TypographyTheme.textSRegular.toNeutral60,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  _buildPickup(queue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.text_pickup.tr(),
          style:
              TypographyTheme.textLRegular.toNeutral80,
        ),
        Text(
          "$queue ${LocaleKeys.text_peopleAhead.tr()}",
          style: TypographyTheme.textXSSemiBold.toPrimary,
        ),
        Text(
          LocaleKeys.text_yourNumberMightBeCalledSooner.tr(),
          style:
              TypographyTheme.textXSRegular.toNeutral50,
        ),
      ],
    );
  }
}
