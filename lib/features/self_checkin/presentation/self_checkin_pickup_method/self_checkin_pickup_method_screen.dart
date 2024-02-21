import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

import './widgets/widgets.dart';

int _peopleAhead = 21;
List<String> _locations = [
  "Location A",
  "Location B",
  "Location C",
];

class PickupMethodScreen extends ConsumerWidget {
  const PickupMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(selfCheckInPickUpMethodsController.notifier);
    final state = ref.watch(selfCheckInPickUpMethodsController);

    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        backgroundColor: Colors.transparent,
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_pickupMethods.tr(),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: BaseSize.w20,
              ),
              child: Column(
                children: [
                  Gap.h24,
                  PickUpMethodsCardWidget(
                    method: PickUpDeliveryOptionEnum.pickup,
                    groupValue: state.selectedMethod,
                    subTitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$_peopleAhead ${LocaleKeys.text_peopleAhead.tr()}",
                          style: TypographyTheme.textXSSemiBold.toPrimary,
                        ),
                        Gap.customGapHeight(4),
                        Text(
                          LocaleKeys.text_yourNumberMightBeCalledSooner.tr(),
                          style: TypographyTheme.textXSRegular.toNeutral50,
                        ),
                      ],
                    ),
                    onChangedValue: (PickUpDeliveryOptionEnum value) {
                      controller.setSelectedMethod(value);
                    },
                  ),
                  ...state.selectedMethod == PickUpDeliveryOptionEnum.pickup
                      ? [
                          Gap.h20,
                          PickUpLocationPickerCardWidget(
                            locations: _locations,
                            selectedLocation: state.selectedLocation,
                            onSelectedLocation: (location) {
                              print(location);
                              controller.setSelectedLocation(location);
                            },
                          ),
                        ]
                      : [],
                  Gap.h20,
                  Divider(
                    color: BaseColor.neutral.shade10,
                    thickness: BaseSize.customHeight(2),
                  ),
                  Gap.h20,
                  PickUpMethodsCardWidget(
                    method: PickUpDeliveryOptionEnum.delivery,
                    groupValue: state.selectedMethod,
                    onChangedValue: (PickUpDeliveryOptionEnum value) {
                      controller.setSelectedMethod(value);
                    },
                  ),
                  ...state.selectedMethod == PickUpDeliveryOptionEnum.delivery
                      ? [
                          Gap.h20,
                          DeliveryAddressPickerCardWidget(
                            selectedAddress: state.selectedAddress,
                            onSelectedAddress: (address) {
                              print(address);
                              controller.setSelectedAddress(address);
                            },
                          ),
                        ]
                      : []
                ],
              ),
            ),
          ),
          BottomActionWrapper(
            actionButton: ButtonWidget.primary(
              text: LocaleKeys.text_submit.tr(),
              onTap: state.selectedLocation.isNotEmpty ||
                      state.selectedAddress != null
                  ? () {}
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
