import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class SelfCheckInConsultationPaymentSummaryScreen extends ConsumerWidget {
  const SelfCheckInConsultationPaymentSummaryScreen({Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(
        selfCheckInConsultationPaymentSummaryControllerProvider(context)
            .notifier);
    final state = ref.watch(
        selfCheckInConsultationPaymentSummaryControllerProvider(context));

    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        title: LocaleKeys.text_paymentSummary.tr(),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    DoctorPrescriptionWidget(),
                    Gap.h16,
                    MedicationWidget(prescription: controller.prescriptionData),
                    Gap.h16,
                    OtherServiceWidget(
                      otherService: controller.otherServicesData,
                      onCheckedChanged: (index, newValue) {
                        // setState(() {
                        //   _otherServices[index]['ischecked'] = newValue;
                        // });
                        controller.handleOtherServiceCheckboxChanged(
                            index, newValue);
                      },
                    ),
                    Gap.h16,
                    PickUpMethodWidget(
                      selectedName: state.selectedAddress,
                      selectedAddress: state.selectedName,
                      controller: controller,
                      // selectedType: state.pickupMethod,
                      selectedType: state.selectedOption.toString().replaceAll(
                            "PickupDeliveryOption.",
                            "",
                          ),
                    ),
                    Gap.h16,
                    PaymentSummaryWidget(
                        paymentSummary: controller.paymentSummaryData),
                  ],
                ),
              ),
            ),
          ),
          BottomActionWrapper(
            actionButton: ButtonWidget.primary(
              text: LocaleKeys.text_selectPaymentMethod.tr(),
              onTap: () {
                context.pushNamed(
                  AppRoute.selfCheckInConsultationPaymentMethod,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
