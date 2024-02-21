import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class TodayAppointmentsWidget extends ConsumerWidget {
  const TodayAppointmentsWidget({
    super.key,
    required this.isLoadingAppointment,
    required this.isLoadingSelfCheckin,
    required this.isGpsEnabled,
    required this.appointments,
  });
  final bool isLoadingAppointment;
  final bool isLoadingSelfCheckin;
  final bool isGpsEnabled;
  final List<Appointment> appointments;

  String? getAlertMessage(
    Appointment appointment,
    bool unableSelfCheckin,
    bool isGpsEnabled,
  ) {
    if (appointment.canSelfCheckin) {
      if (!unableSelfCheckin) {
        return LocaleKeys
            .text_youAreAlreadyInTheRadiusPleaseDoASelfCheckInImmediately
            .tr();
      } else {
        return "${!isGpsEnabled ? LocaleKeys.text_yourGpsIsDisabled.tr() : LocaleKeys.text_yourGpsConnectionIsLow.tr()}, ${LocaleKeys.text_soYouNeedToScanBarcodeToSelfCheckIn.tr()}";
      }
    }

    if (appointment.insuranceStatus == AppointmentInsuranceStatus.pending) {
      return '${LocaleKeys.text_yourDataIsUnderReview.tr()} ${LocaleKeys.text_pleaseVisitOrContactOurFrontOfficeForFurtherInformation.tr()}';
    } else if (appointment.status == AppointmentStatus.doctorNotAvailable) {
      return LocaleKeys.text_theDoctorIsUnableToAttend.tr();
    } else if (appointment.insuranceStatus ==
        AppointmentInsuranceStatus.rejected) {
      return LocaleKeys.text_yourInsuranceIsRejected.tr();
    } else if (appointment.status == AppointmentStatus.slotTaken) {
      return LocaleKeys.text_yourInsuranceIsApprovedButYourSlotHasBeenTaken
          .tr();
    }

    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(homeControllerProvider.notifier);

    if (!isLoadingAppointment && appointments.isEmpty) {
      return const SizedBox();
    }

    return LoadingWrapper(
      value: isLoadingAppointment,
      height: BaseSize.customHeight(400),
      child: Column(
        children: [
          Gap.h20,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.text_todaysAppointment.tr(),
                style: TypographyTheme.textLSemiBold,
              ),
              GestureDetector(
                onTap: () => {},
                child: Text(
                  LocaleKeys.text_viewAll.tr(),
                  style: TypographyTheme.textSSemiBold.toPrimary,
                ),
              ),
            ],
          ),
          Gap.h20,
          CarouselSliderWidget<Appointment>(
            items: appointments,
            itemBuilder: (_, __, appointment) {
              bool inRadius = controller.checkInRadius(appointment);
              bool unableSelfCheckin = controller.errorGps || !inRadius;

              return FeaturingAppointmentWidget(
                variety: appointment.type.name.capitalizeSnakeCaseToTitle,
                date: appointment.date.dMmmYyyyHhMm,
                doctorName: appointment.doctor?.name ?? "",
                hospital: appointment.hospital?.name ?? "",
                journey: appointment.currentJourney,
                name: appointment.patient?.name ?? "",
                number: appointment.queueNumber,
                alertMessage: getAlertMessage(
                  appointment,
                  unableSelfCheckin,
                  isGpsEnabled,
                ),
                alertType:
                    unableSelfCheckin ? AlertType.danger : AlertType.info,
                action: appointment.canSelfCheckin
                    ? Row(
                        children: [
                          if (unableSelfCheckin) ...[
                            Expanded(
                              child: ButtonWidget.outlined(
                                padding:
                                    EdgeInsets.symmetric(vertical: BaseSize.h8),
                                textColor: BaseColor.primary3,
                                text: LocaleKeys.text_selfCheckIn.tr(),
                                isLoading: isLoadingSelfCheckin,
                                onTap: () => controller.handleSelfCheckin(
                                    appointment.serial, context),
                                buttonSize: ButtonSize.small,
                              ),
                            ),
                            Gap.w12,
                          ],
                          Expanded(
                            child: ButtonWidget.primary(
                              padding:
                                  EdgeInsets.symmetric(vertical: BaseSize.h8),
                              color: BaseColor.primary3,
                              text: unableSelfCheckin
                                  ? LocaleKeys.text_scanBarcode.tr()
                                  : LocaleKeys.text_selfCheckIn.tr(),
                              icon: Assets.icons.line.scan.svg(
                                colorFilter:
                                    BaseColor.neutral.shade20.filterSrcIn,
                              ),
                              isLoading: isLoadingSelfCheckin,
                              onTap: () {
                                if (unableSelfCheckin) {
                                  context.pushNamed(
                                    AppRoute.scanQuickResponseCode,
                                    extra: RouteParam(
                                      params: {
                                        RouteParamKey.appointmentSerial:
                                            appointment.serial,
                                      },
                                    ),
                                  );
                                } else {
                                  controller.handleSelfCheckin(
                                      appointment.serial, context);
                                }
                              },
                              buttonSize: ButtonSize.small,
                            ),
                          ),
                        ],
                      )
                    : (appointment.status == AppointmentStatus.selfCheckin
                        ? ButtonWidget.outlined(
                            padding:
                                EdgeInsets.symmetric(vertical: BaseSize.h8),
                            textColor: BaseColor.primary3,
                            text: LocaleKeys.text_virtualQueue.tr(),
                            onTap: () {
                              context.pushNamed(
                                AppRoute.selfCheckInConsultationVirtualQueue,
                              );
                            },
                            buttonSize: ButtonSize.small,
                          )
                        : null),
              );
            },
          ),
        ],
      ),
    );
  }
}
