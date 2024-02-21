import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/patient/domain/enum/enum.dart';
import 'package:halo_hermina/features/patient/presentation/patient_portal_list_active_history/widgets/widgets.dart';

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

class AuthorizedLayoutWidget extends StatefulWidget {
  const AuthorizedLayoutWidget({
    super.key,
    required this.patientName,
  });

  final String patientName;

  @override
  State<AuthorizedLayoutWidget> createState() => _AuthorizedLayoutWidgetState();
}

class _AuthorizedLayoutWidgetState extends State<AuthorizedLayoutWidget> {
  var selectedTab = PatientPortalListActiveHistoryTab.active;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      type: ScaffoldType.authGradient,
      appBar: AppBarWidget(
        backgroundColor: Colors.transparent,
        hasLeading: false,
        widgetTitle: Text(
          widget.patientName,
          style: TypographyTheme.heading4SemiBold.copyWith(
            color: BaseColor.primary4,
          ),
        ),
        height: BaseSize.customHeight(70),
        actions: [
          PatientPortalListActiveHistoryFilterWidget(
            onTapSubmitFilter: () {},
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap.h12,
          SegmentedControlWidget<PatientPortalListActiveHistoryTab>(
            value: selectedTab,
            options: {
              PatientPortalListActiveHistoryTab.active:
                  LocaleKeys.text_active.tr(),
              PatientPortalListActiveHistoryTab.past: LocaleKeys.text_past.tr(),
            },
            onValueChanged: (val) {
              setState(() {
                selectedTab = val;
              });
            },
          ),
          Expanded(
            child: selectedTab == PatientPortalListActiveHistoryTab.active
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: BaseSize.w24),
                    child: PatientPortalListActiveLayoutWidget(
                      listAdmission: _admissionList,
                      onPressedAdmissionCard: (int selectedIndex) {
                        context
                            .pushNamed(AppRoute.patientPortalAdmissionDetail);
                      },
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: BaseSize.w24),
                    child: PatientPortalListPastLayoutWidget(
                      listAdmission: _admissionList,
                      onPressedAdmissionCard: (int selectedIndex) {
                        final admission = _admissionList[selectedIndex];
                        if (admission["inpatient"]) {
                          context.pushNamed(AppRoute.patientPortalInpatient);
                          return;
                        }
                        context.pushNamed(AppRoute.patientPortalOutpatient);
                        return;
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
