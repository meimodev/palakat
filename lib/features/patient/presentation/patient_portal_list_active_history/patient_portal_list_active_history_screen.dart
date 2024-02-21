import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/patient/domain/enum/enum.dart';
import 'package:halo_hermina/features/presentation.dart';

import 'widgets/widgets.dart';

final _patientList = [
  {
    "name": "First Patient",
    "gender": "female",
    "dob": "10 January 1990",
  },
  {
    "name": "Second Patient",
    "gender": "male",
    "dob": "22 Maret 1992",
  },
];

final List<Map<String, dynamic>> _admissionList = [
  {
    "id": "IPA 1207008",
    "room_number": "926-VIP",
    "hospital": "RSH Kemayoran",
    "doctor_name": "dr. Leon Gerald, SpPD",
    "diagnose": "Diare Akut",
    "admission_date": "12 Januari 2023",
    "name": "First Patient",
    "inpatient": true,
  },
  {
    "id": "IPA 4429014",
    "room_number": "926-VIP",
    "hospital": "RSH Jatinegara",
    "doctor_name": "dr. Jhon Wick, SpPD",
    "admission_date": "12 Desember 2023",
    "diagnose": "Asam Urat",
    "name": "First Patient",
    "inpatient": false,
  },
];

class PatientPortalListActiveHistoryScreen extends ConsumerWidget {
  const PatientPortalListActiveHistoryScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.watch(patientPortalListActiveHistoryControllerProvider.notifier);
    final state = ref.watch(patientPortalListActiveHistoryControllerProvider);

    final filteredAdmissions = ref.watch(
      filteredPatientPortalListActiveHistoryControllerProvider(
        _admissionList,
      ),
    );

    return ScaffoldWidget(
      type: ScaffoldType.authGradient,
      appBar: AppBarWidget(
        backgroundColor: Colors.transparent,
        hasLeading: false,
        widgetTitle: PatientPortalListActiveHistoryPatientDropdownWidget(
          onTapSubmit: (int selectedPatientListIndex) {
            controller.setActivePatient(
              _patientList[selectedPatientListIndex]["name"]!,
            );
          },
          patientList: _patientList,
        ),
        height: BaseSize.customHeight(70),
        actions: [
          PatientPortalListActiveHistoryFilterWidget(
            onTapSubmitFilter: () {},
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap.h12,
            SegmentedControlWidget<PatientPortalListActiveHistoryTab>(
              value: state.activeTab,
              options: {
                PatientPortalListActiveHistoryTab.active:
                    LocaleKeys.text_active.tr(),
                PatientPortalListActiveHistoryTab.past:
                    LocaleKeys.text_past.tr(),
              },
              onValueChanged: (val) {
                controller.setActiveTab(val);
              },
            ),
            Expanded(
              child: state.activeTab == PatientPortalListActiveHistoryTab.active
                  ? PatientPortalListActiveLayoutWidget(
                      listAdmission: filteredAdmissions,
                      onPressedAdmissionCard: (int selectedIndex) {
                        context
                            .pushNamed(AppRoute.patientPortalAdmissionDetail);
                      },
                    )
                  : PatientPortalListPastLayoutWidget(
                      listAdmission: filteredAdmissions,
                      onPressedAdmissionCard: (int selectedIndex) {
                        final admission = filteredAdmissions[selectedIndex];
                        if (admission["inpatient"]) {
                          context.pushNamed(AppRoute.patientPortalInpatient);
                          return;
                        }
                        context.pushNamed(AppRoute.patientPortalOutpatient);
                        return;
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
