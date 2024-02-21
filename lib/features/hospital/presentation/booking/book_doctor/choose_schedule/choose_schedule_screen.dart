import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class ChooseScheduleScreen extends ConsumerStatefulWidget {
  const ChooseScheduleScreen({
    super.key,
    required this.doctor,
    required this.hospital,
    required this.specialistSerial,
  });

  final Doctor doctor;
  final Hospital hospital;
  final String specialistSerial;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChooseScheduleScreenState();
}

class _ChooseScheduleScreenState extends ConsumerState<ChooseScheduleScreen> {
  ChooseScheduleController get controller =>
      ref.watch(chooseScheduleControllerProvider.notifier);

  @override
  void initState() {
    safeRebuild(
      () => controller.init(
        widget.doctor,
        widget.hospital,
        widget.specialistSerial,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chooseScheduleControllerProvider);

    Doctor? doctor = state.doctor;
    Hospital? hospital = state.hospital;

    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_chooseSchedule.tr(),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: BaseSize.customWidth(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gap.h20,
            DoctorInfoLayoutWidget(
              imageUrl: doctor?.content?.pictureURL ?? "",
              name: doctor?.name ?? "",
              field: doctor?.specialist?.name ?? "",
              isLoadingPrice: state.isLoadingPrice,
              price: state.doctorPrice,
            ),
            Gap.h16,
            HospitalCardLayoutWidget(
              text: hospital?.name ?? "",
              onTap: () {
                showHospitalSelect(
                  context,
                  selectedValue: hospital,
                  title: LocaleKeys.text_hospital.tr(),
                  onSave: (value) => controller.setHospital(value),
                  showSearch: false,
                  withNearest: true,
                  doctorSerial: doctor?.serial,
                );
              },
            ),
            Gap.h16,
            if (hospital?.serial != null)
              DoctorScheduleCalendar(
                doctorSerial: doctor?.serial ?? "",
                hospitalSerial: hospital?.serial ?? "",
                specialistSerial: state.specialistSerial ?? "",
                onSelectedAvailableDateTime: (selectedDateTime) {
                  context.pop();
                  context.pushNamed(
                    AppRoute.bookDoctorSummary,
                    extra: RouteParam(params: {
                      RouteParamKey.doctor: doctor,
                      RouteParamKey.hospital: hospital,
                      RouteParamKey.dateTime: selectedDateTime,
                      RouteParamKey.specialistSerial: state.specialistSerial,
                    }),
                  );
                },
              ),
            Gap.h24,
          ],
        ),
      ),
    );
  }
}
