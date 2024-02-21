import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/patient/domain/enum/enum.dart';
import 'package:halo_hermina/features/patient/presentation/patient_portal_admission_detail/widgets/widgets.dart';
import 'package:halo_hermina/features/patient/presentation/patient_portal_list_active_history/widgets/list_item_patient_portal_list_active_admission_card_widget.dart';

import 'widgets/widgets.dart';

final List<Map<String, dynamic>> _listPharmacy = [
  {
    "title": "OTSU-NS NACL 0,9% 25 ML",
    "contents": ["1 AMP", "-", "-"],
  },
  {
    "title": "ESOFER 40MG INJ",
    "contents": ["1 AMP", "-", "-"],
  },
  {
    "title": "NARFOZ 4MG/2ML",
    "contents": ["1 VIAL", "-", "-"],
  },
  {
    "title": "ASERING 500ML SOFTBAG",
    "contents": ["1 AMP", "-", "-"],
  },
];

final List<Map<String, dynamic>> _listLaboratory = [
  {
    "title": "Faeces Feme",
    "contents": [
      {
        "title": "CRP (H)",
        "value": "17 mg/dL",
        "reference": "Reference Value 0 - 5",
        "important": true,
      },
    ],
  },
  {
    "title": "Complete Blood Count",
    "contents": [
      {
        "title": "CRP (H)",
        "value": "17 mg/dL",
        "reference": "Reference Value 0 - 5",
        "important": true,
      },
    ],
  },
  {
    "title": "SGOT - SGPT",
    "contents": [
      {
        "title": "Ureum",
        "value": "110 ml",
        "reference": "Reference Value < 50",
        "important": false,
      },
      {
        "title": "Blood Random Glucose",
        "value": "106 ml / dL",
        "reference": "Reference Value < 50",
        "important": false,
      },
    ],
  },
  {
    "title": "Electrolyte (Na, K, Cl)",
    "contents": [
      {
        "title": "CRP (H)",
        "value": "17 mg/dL",
        "reference": "Reference Value 0 - 5",
        "important": true,
      },
    ],
  },
];

final List<Map<String, dynamic>> _listRadiology = [
  // {
  //   "title": "Complete Abdomen USG - USG Abdomen",
  //   "contents": [
  //     {
  //       "text": "hepar",
  //       "value": "Normal",
  //     },
  //     {
  //       "text": "Sistem vena porta",
  //       "value": "Normal",
  //     },
  //     {
  //       "text": "lien",
  //       "value": "Normal",
  //     },
  //     {
  //       "text": "Pankreas",
  //       "value": "Normal",
  //     },
  //     {
  //       "text": "Ginjal Kanan",
  //       "value": "Normal",
  //     },
  //     {
  //       "text": "ginjal kiri",
  //       "value": "Normal",
  //     },
  //     {
  //       "text": "Buli-buli",
  //       "value": "Normal",
  //     },
  //   ],
  // }
];

const String _admissionId = "OPA02070008";
const String _hospital = "RSH Kemayoran";
const String _admissionDate = "12 Jul 2023";
const String _doctorName = "dr Jhon Wick";
const String _diagnose = "Lipoma (Tumor jinak)";

const String _patientName = "Pricilia Pamella";
const String _gender = "Female";
const String _dateOfBirth = "10 Januari 1980";

class PatientPortalOutpatientScreen extends ConsumerWidget {
  const PatientPortalOutpatientScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final state = ref.watch(patientPortalAdmissionDetailControllerProvider);
    // final controller =
    //     ref.watch(patientPortalAdmissionDetailControllerProvider.notifier);

    return ScaffoldWidget(
      appBar: AppBarWidget(
        height: BaseSize.customHeight(70),
        title: _admissionId,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
          child: Column(
            children: [
              Gap.customGapHeight(10),
              const PatientInfoCardWidget(
                patientName: _patientName,
                gender: _gender,
                dateOfBirth: _dateOfBirth,
              ),
              Gap.h16,
              CardWidget(
                title: LocaleKeys.text_hospitalInformation.tr(),
                icon: Assets.icons.line.hospital3,
                content: const [
                  ListItemPatientPortalListActiveAdmissionCard(
                    removePadding: true,
                    disableBorder: true,
                    verticalDisplay: true,
                    hospital: _hospital,
                    admissionDate: _admissionDate,
                    doctorName: _doctorName,
                    diagnose: _diagnose,
                  ),
                ],
              ),
              Gap.h16,
              ButtonWithBorderWidget(
                title: LocaleKeys.text_medicalResume.tr(),
                icon: Assets.icons.line.treatment,
                onTap: () {
                  context.pushNamed(AppRoute.patientPortalMedicalResume);
                },
              ),
              Gap.h16,
              ListOutPatientTabLayoutWidget<
                  PatientPortalOutpatientScreenTabEnum>(
                activeTab: PatientPortalOutpatientScreenTabEnum.laboratory,
                tabOptions: {
                  PatientPortalOutpatientScreenTabEnum.laboratory:
                      LocaleKeys.text_laboratory.tr(),
                  PatientPortalOutpatientScreenTabEnum.pharmacy:
                      LocaleKeys.text_pharmacy.tr(),
                  PatientPortalOutpatientScreenTabEnum.radiology:
                      LocaleKeys.text_radiology.tr(),
                },
                itemBuilder: (activeTab) {
                  switch (activeTab) {
                    case PatientPortalOutpatientScreenTabEnum.laboratory:
                      return BottomSheetLaboratoryLayoutWidget(
                        list: _listLaboratory,
                      );
                    case PatientPortalOutpatientScreenTabEnum.pharmacy:
                      return BottomSheetPharmacyLayoutWidget(
                        list: _listPharmacy,
                      );
                    case PatientPortalOutpatientScreenTabEnum.radiology:
                      return BottomSheetRadiologyLayoutWidget(
                        list: _listRadiology,
                      );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
