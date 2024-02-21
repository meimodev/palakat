import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/keys/route_param_key.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/features/presentation.dart';

class SelfCheckInConsultationPaymentSummaryController
    extends StateNotifier<SelfCheckInConsultationPaymentSummaryState> {
  final BuildContext context;
  SelfCheckInConsultationPaymentSummaryController(this.context)
      : super(const SelfCheckInConsultationPaymentSummaryState());

  final otherServicesData = [
    {
      "service_name": "Blood Sugar 2 Hours After Eating",
      "type": "Laboratory",
      "price": "Rp 285.000",
      "include_doctor": false,
      "ischecked": true,
    },
    {
      "service_name":
          "Transcutaneous Electrical Nerve Stimulation (TENS) Therapy ",
      "type": "Physiotherapy",
      "price": "Rp 265.000",
      "include_doctor": true,
      "ischecked": true,
    },
  ];

  final paymentSummaryData = [
    {
      "type": "Consultation",
      "price": "Rp 300.000",
    },
    {
      "type": "Medication",
      "price": "Rp 150.000",
    },
    {
      "type": "Other Service",
      "price": "Rp 260.000",
    },
    {
      "type": "Service Fee",
      "price": "Rp 1.000",
    },
  ];

  final prescriptionData = [
    {
      "item_name": "ESOFER 40MG INJ ESOFER 40MG INJ",
      "qty": "100",
      "dosage": "2 times per day",
      "instructions": "Before Meal",
      "time": "Morning, Evening",
      "notes": "Consumed on an empty stomach",
      "price": "Rp 25.000",
      "uom": "Strip",
    },
    {
      "item_name": "ESOFER 40MG INJ ESOFER 40MG INJ",
      "qty": "50",
      "dosage": "2 times per day",
      "instructions": "Before Meal",
      "time": "Morning, Evening",
      "notes": "Consumed on an empty stomach",
      "price": "Rp 25.000",
      "uom": "Strip",
    },
    {
      "item_name": "ESOFER 40MG INJ ESOFER 40MG INJ",
      "qty": "100",
      "dosage": "2 times per day",
      "instructions": "Before Meal",
      "time": "Morning, Evening",
      "notes": "Consumed on an empty stomach",
      "price": "Rp 250.000",
      "uom": "Strip",
    },
    {
      "item_name": "ESOFER 40MG INJ ESOFER 40MG INJ",
      "qty": "70",
      "dosage": "2 times per day",
      "instructions": "Before Meal",
      "time": "Morning, Evening",
      "notes": "Consumed on an empty stomach",
      "price": "Rp 25.000",
      "uom": "Strip",
    },
  ];

  void handleOtherServiceCheckboxChanged(int index, bool newValue) {
    final List<Map<String, dynamic>> updatedOtherServices = otherServicesData;
    updatedOtherServices[index]['ischecked'] = newValue;

    state = state.copyWith(otherServices: updatedOtherServices);
  }

  void handleOnTapChoosePickUpMethod() async {
    var params = {
      RouteParamKey.name: state.selectedName,
      RouteParamKey.address: state.selectedAddress,
      RouteParamKey.selectedOption: state.selectedOption
    };

    var selected = await context.pushNamed<Map<String, dynamic>>(
      AppRoute.selfCheckInPickUpMethod,
      extra: RouteParam(params: params),
    );

    if (selected != null) {
      state = state.copyWith(
        selectedName: selected[RouteParamKey.name],
        selectedAddress: selected[RouteParamKey.address],
        selectedOption: selected[RouteParamKey.selectedOption],
      );
    }
  }
}

final selfCheckInConsultationPaymentSummaryControllerProvider =
    StateNotifierProvider.family<
        SelfCheckInConsultationPaymentSummaryController,
        SelfCheckInConsultationPaymentSummaryState,
        BuildContext>((ref, context) {
  return SelfCheckInConsultationPaymentSummaryController(context);
});
