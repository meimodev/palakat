import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';


const String _printedTime = "17 Agustus 2023 17:11";
const String _doctor = "dr Antoine Luc, SpB";

const String _chiefComplaints = "selama 3 menit, kurang lebih 1 jam yang lalu, tetap sadar setelah kejang. Demam tidak ada. Riwayat kejang sebelumnya disangkal";
const String _pregnant = "Usia kehamilan 32 minggu, janin lebh kecil dari usia kehamilan";
const String _breastfeeding = "No";
const String _physicalExamination = "No Data Available";
const String _workingDiagnosis = "J06.9 Acute upper respiratory infection & unspecified Primary";

class PatientPortalMedicalResumeScreen extends ConsumerWidget {
  const PatientPortalMedicalResumeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScaffoldWidget(
      appBar: AppBarWidget(
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_medicalResume.tr(),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
          child: Column(
            children: [
              Gap.h16,
              CardWidget(
                title: LocaleKeys.text_information.tr(),
                icon: Assets.icons.line.hospital3,
                content: [
                  Column(
                    children: [
                      _buildRow(
                        title: LocaleKeys.text_printedTime.tr(),
                        value: _printedTime,
                      ),
                      Gap.h20,
                      _buildRow(
                        title: LocaleKeys.text_doctor.tr(),
                        value: _doctor,
                      ),
                    ],
                  ),
                ],
              ),
              Gap.h16,
              CardWidget(
                title: LocaleKeys.text_summary.tr(),
                icon: Assets.icons.line.treatment,
                content: [
                  _buildColumn(
                    text: LocaleKeys.text_chiefComplaints.tr(),
                    value: _chiefComplaints,
                  ),
                  _buildColumn(
                    text: LocaleKeys.text_pregnant.tr(),
                    value: _pregnant,
                  ),
                  _buildColumn(
                    text: LocaleKeys.text_breastFeeding.tr(),
                    value: _breastfeeding,
                  ),
                  _buildColumn(
                    text: LocaleKeys.text_physicalExamination.tr(),
                    value: _physicalExamination,
                  ),
                  _buildColumn(
                    text: LocaleKeys.text_workingDiagnosis.tr(),
                    value: _workingDiagnosis,
                  ),
                ],
              ),
              Gap.h16,
            ],
          ),
        ),
      ),
    );
  }

  Column _buildColumn({
    required String text,
    required String value,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text,
            style: TypographyTheme.textMRegular.toNeutral60,
          ),
          Gap.customGapHeight(10),
          Text(
            value,
            style: TypographyTheme.textLRegular.toNeutral80,
          ),
          Gap.h20,
        ],
      );

  Row _buildRow({
    required String title,
    required String value,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: TypographyTheme.textXSRegular.toNeutral60,
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TypographyTheme.textMSemiBold.toNeutral70,
            ),
          ),
        ],
      );
}
