import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class ActiveAppointmentListWidget extends ConsumerStatefulWidget {
  const ActiveAppointmentListWidget({super.key});

  @override
  ConsumerState<ActiveAppointmentListWidget> createState() =>
      _ActiveAppointmentListWidgetState();
}

class _ActiveAppointmentListWidgetState
    extends ConsumerState<ActiveAppointmentListWidget> {
  MainAppointmentController get controller =>
      ref.read(mainAppointmentControllerProvider.notifier);

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
  Widget build(BuildContext parentContext) {
    final state = ref.watch(mainAppointmentControllerProvider);

    if (!state.loadingUpcoming && state.upcomingAppointments.isEmpty) {
      if (state.searching) {
        return const EmptySearchLayoutWidget();
      } else {
        return LayoutBuilder(
          builder: (context, constraints) => RefreshIndicator(
            onRefresh: () async => await controller.handleRefreshUpcomingTab(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: EmptyAppointment(
                  placeholder:
                      LocaleKeys.text_youDontHaveAnyUpcomingAppointment.tr(),
                ),
              ),
            ),
          ),
        );
      }
    }

    return ListBuilderWidget<Appointment>(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: horizontalPadding,
      isLoading: state.loadingUpcoming,
      isLoadingBottom: state.hasMoreUpcomingPage,
      data: state.upcomingAppointments,
      onEdgeBottom: controller.handleGetMoreUpcoming,
      onRefresh: () async => await controller.handleRefreshUpcomingTab(),
      prewidgets: [
        ...state.activeAppointments.map((appointment) {
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
              state.isGpsEnabled,
            ),
            alertType: unableSelfCheckin ? AlertType.danger : AlertType.info,
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
                            isLoading: state.isLoadingSelfCheckin,
                            onTap: () => controller.handleSelfCheckin(
                                appointment.serial, context),
                            buttonSize: ButtonSize.small,
                          ),
                        ),
                        Gap.w12,
                      ],
                      Expanded(
                        child: ButtonWidget.primary(
                          padding: EdgeInsets.symmetric(vertical: BaseSize.h8),
                          color: BaseColor.primary3,
                          text: unableSelfCheckin
                              ? LocaleKeys.text_scanBarcode.tr()
                              : LocaleKeys.text_selfCheckIn.tr(),
                          icon: Assets.icons.line.scan.svg(
                            colorFilter: BaseColor.neutral.shade20.filterSrcIn,
                          ),
                          isLoading: state.isLoadingSelfCheckin,
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
                        padding: EdgeInsets.symmetric(vertical: BaseSize.h8),
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
        }).toList(),
        Gap.h20,
        Text(
          LocaleKeys.text_upcomingAppointment.tr(),
          style: TypographyTheme.textMSemiBold.toNeutral50,
        ),
        Gap.h20,
      ],
      itemBuilder: (_, __, appointment) {
        return Padding(
          padding: EdgeInsets.only(bottom: BaseSize.h12),
          child: AppointmentCard.upcoming(
            name: appointment.patient?.name ?? "",
            number: appointment.queueNumber,
            date: appointment.date.dMmmYyyyHhMm,
            hospital: appointment.hospital?.name ?? "",
            doctor: appointment.doctor?.name ?? "",
            specialist: appointment.specialist?.name ?? "",
            alertMessage: getAlertMessage(appointment, false, false),
            onTap: () {
              context.pushNamed(
                AppRoute.appointmentDetail,
                extra: RouteParam(
                  params: {
                    RouteParamKey.serial: appointment.serial,
                  },
                ),
              );
            },
            onCancel: appointment.canCancel
                ? () {
                    showConfirmCancelAppointmentDialog(
                      context: context,
                      controller: controller.cancelReasonController,
                      onTapYes: () {
                        controller.handleCancel(
                            parentContext, appointment.serial);
                      },
                    );
                  }
                : null,
            onReschedule: appointment.canReschedule
                ? () {
                    context.pushNamed(
                      AppRoute.appointmentReschedule,
                      extra: RouteParam(
                        params: {
                          RouteParamKey.appointment: appointment,
                        },
                      ),
                    );
                  }
                : null,
            onManage: appointment.canManage
                ? () {
                    showSelectSingleWidget<AppointmentSelectItem>(
                      context,
                      title: LocaleKeys.text_manageAppointment.tr(),
                      heightPercentage: 34,
                      getLabel: (val) => val.label,
                      getValue: (val) => val.value.name,
                      getDescription: (val) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: BaseSize.h12),
                          child: Text(
                            val.subLabel,
                            style: TypographyTheme.textMRegular.toNeutral60,
                          ),
                        );
                      },
                      onSave: (val) {
                        controller.handleManage(
                          val.value,
                          appointment.serial,
                          appointment.hospital?.callCenter ?? "",
                        );
                      },
                      options: [
                        AppointmentSelectItem(
                          value: AppointmentManageType.personal,
                          label: LocaleKeys.text_personal.tr(),
                          subLabel:
                              LocaleKeys.text_pleasePayForYourAppointment.tr(),
                        ),
                        AppointmentSelectItem(
                          value: AppointmentManageType.callCenter,
                          label: LocaleKeys.text_callCenter.tr(),
                          subLabel: LocaleKeys
                              .text_pleaseCallNumberForFurtherInformation
                              .tr(
                            namedArgs: {
                              "number": appointment.hospital?.callCenter ?? ""
                            },
                          ),
                        )
                      ],
                    );
                  }
                : null,
          ),
        );
      },
    );
  }
}
