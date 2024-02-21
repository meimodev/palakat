import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientDetailScreen extends ConsumerStatefulWidget {
  const PatientDetailScreen({super.key, required this.serial});
  final String serial;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen> {
  PatientDetailController get controller =>
      ref.read(patientDetailControllerProvider(context).notifier);

  @override
  void initState() {
    safeRebuild(() => controller.init(widget.serial));
    super.initState();
  }

  List<Widget> _labelValue({
    required String label,
    String? text,
    Widget? widget,
    bool withoutSpacing = false,
  }) {
    return [
      LabelValueWidget(
        label: label,
        text: text ?? "",
        widget: widget,
      ),
      if (!withoutSpacing) Gap.h24,
    ];
  }

  Widget _imageThumbnail(String? url) {
    return SizedBox(
      height: BaseSize.customHeight(200),
      width: double.infinity,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        ),
        child: ImageNetworkWidget(
          imageUrl: url ?? "",
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patientDetailControllerProvider(context));
    final patient = state.patient;

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: LocaleKeys.text_patientDetail.tr(),
      ),
      child: LoadingWrapper(
        value: state.isLoading,
        child: RefreshIndicator(
          onRefresh: () async => await controller.handleRefresh(),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: horizontalPadding.add(EdgeInsets.symmetric(
              vertical: BaseSize.h12,
            )),
            children: [
              CardWidget(
                title: LocaleKeys.text_personalInformation.tr(),
                content: [
                  ..._labelValue(
                    label: LocaleKeys.text_status.tr(),
                    widget: PatientStatusChipWidget(
                      status: patient?.status ?? PatientStatus.unverified,
                    ),
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_firstName.tr(),
                    text: patient?.firstName,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_lastName.tr(),
                    text: patient?.lastName,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_dateOfBirth.tr(),
                    text: patient?.dateOfBirth?.ddMmmmYyyy,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_phoneNumber.tr(),
                    text: patient?.phone,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_email.tr(),
                    text: patient?.email,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_title.tr(),
                    text: patient?.title?.value,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_placeOfBirth.tr(),
                    text: patient?.placeOfBirth,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_identityCard.tr(),
                    text: patient?.identityType?.label,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_identityCardNumber.tr(),
                    text: patient?.passportNumber ?? patient?.ktpNumber,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_gender.tr(),
                    text: patient?.gender?.value,
                    withoutSpacing: true,
                  ),
                ],
              ),
              Gap.h20,
              CardWidget(
                title: LocaleKeys.text_addressInformation.tr(),
                content: [
                  ..._labelValue(
                    label: LocaleKeys.text_address.tr(),
                    text: patient?.address,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: LabelValueWidget(
                          label: LocaleKeys.text_rt.tr(),
                          text: patient?.rtNumber,
                        ),
                      ),
                      Expanded(
                        child: LabelValueWidget(
                          label: LocaleKeys.text_rw.tr(),
                          text: patient?.rwNumber,
                        ),
                      ),
                    ],
                  ),
                  Gap.h20,
                  ..._labelValue(
                    label: LocaleKeys.text_province.tr(),
                    text: patient?.province?.value,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_city.tr(),
                    text: patient?.city?.value,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_district.tr(),
                    text: patient?.district?.value,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_village.tr(),
                    text: patient?.village?.value,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_postalCode.tr(),
                    text: patient?.postalCode,
                    withoutSpacing: true,
                  ),
                ],
              ),
              Gap.h20,
              CardWidget(
                title: LocaleKeys.text_additionalInformation.tr(),
                content: [
                  ..._labelValue(
                    label: LocaleKeys.text_religion.tr(),
                    text: patient?.religion?.value,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_maritalStatus.tr(),
                    text: patient?.marital?.value,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_education.tr(),
                    text: patient?.education?.value,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_jobTitle.tr(),
                    text: patient?.occupation?.value,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_citizenship.tr(),
                    text: patient?.citizenship?.value,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_ethnicity.tr(),
                    text: patient?.ethnic?.value,
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_identityCardPhoto.tr(),
                    widget: _imageThumbnail(patient?.identityCardURL),
                  ),
                  ..._labelValue(
                    label: LocaleKeys.text_photoOfYouWithYourIDCard.tr(),
                    widget: _imageThumbnail(patient?.photoURL),
                    withoutSpacing: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
