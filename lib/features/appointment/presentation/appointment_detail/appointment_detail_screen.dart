import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class AppointmentDetailScreen extends ConsumerStatefulWidget {
  final String serial;
  const AppointmentDetailScreen({
    super.key,
    required this.serial,
  });

  @override
  ConsumerState<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState
    extends ConsumerState<AppointmentDetailScreen> {
  AppointmentDetailController get controller =>
      ref.read(appointmentDetailControllerProvider.notifier);

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentDetailControllerProvider);
    final appointment = state.appointment;

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: LocaleKeys.text_appointmentDetail.tr(),
        actions: [
          if (appointment?.canPrintInvoice ?? false)
            RippleTouch(
              onTap: () {},
              borderRadius: BorderRadius.circular(BaseSize.radiusSm),
              child: Padding(
                padding: EdgeInsets.all(BaseSize.w4),
                child: Row(
                  children: [
                    Assets.icons.line.document.svg(
                      colorFilter: BaseColor.primary3.filterSrcIn,
                      height: BaseSize.h16,
                    ),
                    Gap.w4,
                    Text(
                      LocaleKeys.text_printInvoice.tr(),
                      style: TypographyTheme.textMSemiBold.toPrimary,
                    )
                  ],
                ),
              ),
            )
        ],
      ),
      child: LoadingWrapper(
        value: state.isLoading,
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.getData(withoutLoading: true);
                },
                child: ListView(
                  padding: horizontalPadding.add(EdgeInsets.symmetric(
                    vertical: BaseSize.h12,
                  )),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    CardWidget(
                      icon: Assets.icons.line.treatment,
                      title: LocaleKeys.text_appointmentInformation.tr(),
                      content: [
                        if (appointment?.queueNumber != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ..._labelValue(
                              //   label: LocaleKeys.text_status.tr(),
                              //   widget: ChipsWidget(
                              //     title: "Making Payment",
                              //     color: BaseColor.blue.shade50,
                              //     textColor: BaseColor.blue.shade400,
                              //   ),
                              // ),
                              ..._labelValue(
                                label: LocaleKeys.text_queueNumber.tr(),
                                text: appointment?.queueNumber.toString(),
                              ),
                            ],
                          ),
                        ..._labelValue(
                          label: LocaleKeys.text_dateTime.tr(),
                          text: appointment?.date.eeeDMmmYyyyHhMm,
                        ),
                        ..._labelValue(
                          label: LocaleKeys.text_hospital.tr(),
                          text: appointment?.hospital?.name,
                        ),
                        ..._labelValue(
                          label: LocaleKeys.text_doctor.tr(),
                          text: appointment?.doctor?.name,
                        ),
                        ..._labelValue(
                          label: LocaleKeys.text_specialist.tr(),
                          text: appointment?.specialist?.name,
                        ),
                        ..._labelValue(
                          label: LocaleKeys.text_paymentType.tr(),
                          text: appointment
                              ?.guaranteeType.name.capitalizeSnakeCaseToTitle,
                          withoutSpacing: true,
                        ),
                      ],
                    ),
                    Gap.h16,
                    CardWidget(
                      icon: Assets.icons.line.account,
                      title: LocaleKeys.text_patientInformation.tr(),
                      content: [
                        ..._labelValue(
                          label: LocaleKeys.text_medicalRecordNumber.tr(),
                          text: appointment?.patient?.mrn,
                        ),
                        ..._labelValue(
                          label: LocaleKeys.text_name.tr(),
                          text: appointment?.patient?.name,
                        ),
                        ..._labelValue(
                          label: LocaleKeys.text_dateOfBirth.tr(),
                          text: state
                              .appointment?.patient?.dateOfBirth?.ddMmmmYyyy,
                        ),
                        ..._labelValue(
                          label: LocaleKeys.text_phoneNumber.tr(),
                          text: appointment?.patient?.phone,
                        ),
                        ..._labelValue(
                          label: LocaleKeys.text_email.tr(),
                          text: appointment?.patient?.email,
                          withoutSpacing: true,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            if ((appointment?.canCancel ?? false) ||
                (appointment?.canReschedule ?? false)) ...[
              BottomActionWrapper(
                actionButton: Row(
                  children: [
                    if (appointment?.canCancel ?? false)
                      Expanded(
                        child: ButtonWidget.outlined(
                          text: LocaleKeys.text_cancel.tr(),
                          isShrink: true,
                          onTap: () {
                            showConfirmCancelAppointmentDialog(
                              context: context,
                              controller: controller.cancelReasonController,
                              onTapYes: () {
                                controller.handleCancel(context, ref);
                              },
                            );
                          },
                        ),
                      ),
                    if (appointment?.canReschedule ?? false) ...[
                      Gap.w16,
                      Expanded(
                        child: ButtonWidget.primary(
                          text: LocaleKeys.text_reschedule.tr(),
                          isShrink: true,
                          onTap: () => context.pushNamed(
                            AppRoute.appointmentReschedule,
                            extra: RouteParam(
                              params: {
                                RouteParamKey.appointment: appointment!,
                              },
                            ),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
