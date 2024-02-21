import 'package:flutter/material.dart';
import 'package:halo_hermina/core/localization/localization.dart';

import 'widgets.dart';

class PatientPortalListPastLayoutWidget extends StatelessWidget {
  const PatientPortalListPastLayoutWidget({
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
        text: LocaleKeys.text_youDontHaveAnyPastAdmission.tr(),
      );
    }

    return ListView.builder(
      itemCount: listAdmission.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final admission = listAdmission[index];
        return ListItemPatientPortalListPastAdmissionCardWidget(
          id: admission["id"],
          hospital: admission["hospital"],
          admissionDate: admission["admission_date"],
          doctorName: admission["doctor_name"],
          inpatient: admission["inpatient"],
          onTap: () => onPressedAdmissionCard(index),
        );
      },
    );
  }
}
