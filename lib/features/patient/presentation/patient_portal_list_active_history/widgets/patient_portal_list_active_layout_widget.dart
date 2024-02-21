import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';

import 'widgets.dart';

class PatientPortalListActiveLayoutWidget extends StatelessWidget {
  const PatientPortalListActiveLayoutWidget({
    super.key,
    required this.listAdmission,
    required this.onPressedAdmissionCard,
  });

  final List<Map<String, dynamic>> listAdmission;
  final void Function(int selectedIndex) onPressedAdmissionCard;

  @override
  Widget build(BuildContext context) {
    if (listAdmission.isEmpty) {
      return EmptyAdmissionWidget(
        text: LocaleKeys.text_youDontHaveAnyAdmission.tr(),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: BaseSize.h32,
      ),
      itemCount: listAdmission.length,
      itemBuilder: (context, index) {
        final admission = listAdmission[index];
        return ListItemPatientPortalListActiveAdmissionCard(
          id: admission["id"],
          roomNumber: admission["room_number"],
          hospital: admission["hospital"],
          admissionDate: admission["admission_date"],
          doctorName: admission["doctor_name"],
          diagnose: admission["diagnose"],
          onTap: () => onPressedAdmissionCard(index),
        );
      },
    );
  }
}
