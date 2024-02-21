import 'package:collection/collection.dart';
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

class DoctorDetailScreen extends ConsumerStatefulWidget {
  const DoctorDetailScreen({
    super.key,
    required this.serial,
  });
  final String serial;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends ConsumerState<DoctorDetailScreen> {
  DoctorDetailController get controller =>
      ref.read(doctorDetailControllerProvider.notifier);

  List<Widget> buildSchedule(
    List<DoctorHospitalSchedule> schedules,
    Doctor? doctor,
  ) {
    return schedules.map(
      (hospital) {
        final String? specialistSerial = doctor?.specialist?.serial;
        final Hospital? hospitalEntity = doctor?.hospitals
            .firstWhereOrNull((e) => e.serial == hospital.serial);

        return ExpandableWidget(
          initialExpanded: true,
          withGap: schedules.last != hospital,
          withDivider: schedules.last != hospital,
          header: Text(
            hospital.name,
            style: TypographyTheme.textLSemiBold.toSecondary2,
          ),
          content: Column(
            children: [
              ...hospital.schedules
                  .map(
                    (schedule) => Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: BaseSize.h16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  DateUtil.labelWeekDay(
                                    DateUtil.scheduleDayToWeekDay(
                                      schedule.day,
                                    ),
                                  ),
                                  style:
                                      TypographyTheme.textMRegular.toNeutral60,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: schedule.times
                                    .map(
                                      (time) => Padding(
                                        padding: EdgeInsets.only(
                                          bottom: schedule.times.last != time
                                              ? BaseSize.h8
                                              : 0,
                                        ),
                                        child: Text(
                                          "${time.timeFrom} - ${time.timeTo}",
                                          style: TypographyTheme
                                              .textMRegular.toNeutral60,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        if (hospital.schedules.last != schedule)
                          Divider(
                            height: 1,
                            color: BaseColor.neutral.shade20,
                          )
                      ],
                    ),
                  )
                  .toList(),
              Gap.h8,
              ButtonWidget.primary(
                buttonSize: ButtonSize.medium,
                isEnabled: specialistSerial != null && hospitalEntity != null,
                text: LocaleKeys.text_bookAppointment.tr(),
                onTap: () {
                  context.pushNamed(
                    AppRoute.chooseSchedule,
                    extra: RouteParam(
                      params: {
                        RouteParamKey.doctor: doctor,
                        RouteParamKey.hospital: hospitalEntity,
                        RouteParamKey.specialistSerial: specialistSerial,
                      },
                    ),
                  );
                },
              ),
              Gap.h16,
            ],
          ),
        );
      },
    ).toList();
  }

  @override
  void initState() {
    safeRebuild(() => controller.init(widget.serial));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorDetailControllerProvider);

    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        title: LocaleKeys.text_doctorProfile.tr(),
      ),
      child: LoadingWrapper(
        value: state.isLoading,
        child: RefreshIndicator(
          onRefresh: controller.handleRefresh,
          child: ListView(
            padding: horizontalPadding,
            children: [
              Gap.h20,
              CardWidget(
                content: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.all(
                          Radius.circular(BaseSize.radiusLg),
                        ),
                        child: Stack(
                          children: <Widget>[
                            ImageNetworkWidget(
                              imageUrl: state.doctor?.content?.pictureURL ?? "",
                              fit: BoxFit.cover,
                              width: BaseSize.customWidth(80),
                              height: BaseSize.customWidth(105),
                            ),
                          ],
                        ),
                      ),
                      Gap.w20,
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: BaseSize.h8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.doctor?.name ?? "",
                                style:
                                    TypographyTheme.textLSemiBold.toNeutral70,
                              ),
                              Gap.h8,
                              Text(
                                state.doctor?.specialist?.name ?? "",
                                style: TypographyTheme.textSRegular.toNeutral60,
                              ),
                              Gap.h12,
                              ChipsWidget(
                                size: ChipsSize.small,
                                title: LocaleKeys.text_availableToday.tr(),
                                color: BaseColor.primary1,
                                textColor: BaseColor.primary3,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap.h16,
                  ButtonWidget.outlined(
                    text: LocaleKeys.text_viewProfile.tr(),
                    buttonSize: ButtonSize.small,
                    onTap: () => {
                      context.pushNamed(
                        AppRoute.doctorProfile,
                        extra: RouteParam(
                          params: {
                            RouteParamKey.doctor: state.doctor,
                          },
                        ),
                      )
                    },
                  ),
                ],
              ),
              Gap.h16,
              CardWidget(
                icon: Assets.icons.line.calendar,
                title: LocaleKeys.text_outpatientSchedule.tr(),
                content: [
                  if (state.isLoadingSchedule)
                    SizedBox(
                      height: BaseSize.customHeight(300),
                      child: const LoadingWrapper(
                        value: true,
                        child: SizedBox(),
                      ),
                    ),
                  if (!state.isLoadingSchedule)
                    ...buildSchedule(state.schedules, state.doctor)
                ],
              ),
              Gap.h20,
            ],
          ),
        ),
      ),
    );
  }
}
