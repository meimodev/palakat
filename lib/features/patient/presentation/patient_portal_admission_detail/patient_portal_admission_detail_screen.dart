import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/patient/domain/enum/enum.dart';
import 'package:halo_hermina/features/patient/presentation/patient_portal_list_active_history/widgets/list_item_patient_portal_list_active_admission_card_widget.dart';

import 'widgets/widgets.dart';

final List<Map<String, dynamic>> _listTabs = [
  {
    "date": "02 Jul 2023",
    "type": "laboratory",
  },
  {
    "date": "01 Maret 2023",
    "type": "laboratory",
  },
  {
    "date": "29 Maret 2023",
    "type": "radiology",
  },
];

final List<Map<String, dynamic>> _listLaboratory = [
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
  {
    "title": "Complete Abdomen USG - USG Abdomen",
    "contents": [
      {
        "text": "hepar",
        "value": "Normal",
      },
      {
        "text": "Sistem vena porta",
        "value": "Normal",
      },
      {
        "text": "lien",
        "value": "Normal",
      },
      {
        "text": "Pankreas",
        "value": "Normal",
      },
      {
        "text": "Ginjal Kanan",
        "value": "Normal",
      },
      {
        "text": "ginjal kiri",
        "value": "Normal",
      },
      {
        "text": "Buli-buli",
        "value": "Normal",
      },
    ],
  }
];

const String _admissionId = "IPA12070008";
const String _roomNumber = "926-VIP";
const String _hospital = "RSH Kemayoran";
const String _admissionDate = "12 Jul 2023";
const String _doctorName = "dr Jhon Wick";
const String _diagnose = "Some diagnose";

const String _patientName = "Pricilia Pamella";
const String _gender = "Female";
const String _dateOfBirth = "10 Januari 1980";

class PatientPortalAdmissionDetailScreen extends ConsumerWidget {
  const PatientPortalAdmissionDetailScreen({super.key});

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
                    roomNumber: _roomNumber,
                    hospital: _hospital,
                    admissionDate: _admissionDate,
                    doctorName: _doctorName,
                    diagnose: _diagnose,
                  ),
                ],
              ),
              Gap.h16,
              ButtonWithBorderWidget(
                onTap: () {},
                title: LocaleKeys.text_foodMenuRequest.tr(),
                icon: Assets.icons.line.foodBar,
              ),
              Gap.h16,
              ListDateTabLayoutWidget<
                  PatientPortalAdmissionDetailScreenTabEnum>(
                activeTab: PatientPortalAdmissionDetailScreenTabEnum.laboratory,
                tabOptions: {
                  PatientPortalAdmissionDetailScreenTabEnum.laboratory:
                      LocaleKeys.text_laboratory.tr(),
                  PatientPortalAdmissionDetailScreenTabEnum.radiology:
                      LocaleKeys.text_radiology.tr(),
                },
                lists: _listTabs,
                itemBuilder: (item, type, index) =>
                    ListItemDateActiveHistoryWidget(
                  date: item["date"],
                  hideDivider: index != 0,
                  onTap: () {
                    showCustomDialogWidget(
                      context,
                      isScrollControlled: true,
                      hideLeftButton: true,
                      btnRightText: LocaleKeys.text_back.tr(),
                      title: "${type.name.capitalizeEachWord} "
                          "- ${item["date"]}",
                      onTap: () => context.pop(),
                      content: type ==
                              PatientPortalAdmissionDetailScreenTabEnum
                                  .laboratory
                          ? BottomSheetLaboratoryLayoutWidget(
                              list: _listLaboratory,
                            )
                          : BottomSheetRadiologyLayoutWidget(
                              list: _listRadiology,
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
