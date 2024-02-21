import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/self_checkin/domain/patient_journey.dart';


class ListItemPatientJourneyCardWidget extends StatelessWidget {
  const ListItemPatientJourneyCardWidget({
    super.key,
    required this.journey,
    this.contentBuilder,
    required this.calculateDotsHeight,
    required this.onPressedButton,
  });

  final PatientJourney journey;

  final double? Function(PatientJourney journey) calculateDotsHeight;
  final Widget? Function(PatientJourney journey)? contentBuilder;
  final void Function(PatientJourney journey) onPressedButton;

  @override
  Widget build(BuildContext context) {
    final icon = journey.status == ListItemPatientJourneyCardStatus.done
        ? Assets.icons.fill.checkCircle
        : Assets.icons.fill.ellipse;

    final color = journey.status == ListItemPatientJourneyCardStatus.done ||
            journey.status == ListItemPatientJourneyCardStatus.notDone ||
            journey.status == ListItemPatientJourneyCardStatus.notDoneEnd
        ? BaseColor.neutral.shade50
        : BaseColor.primary3;

    final double dotsHeight =
        calculateDotsHeight(journey) ?? _calculateDotsHeight();

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                icon.svg(
                  width: 20,
                  height: 20,
                  colorFilter: color.filterSrcIn,
                ),
                Gap.customGapHeight(4),
                journey.status != ListItemPatientJourneyCardStatus.notDoneEnd
                    ? SizedBox(
                        height: BaseSize.customHeight(
                          dotsHeight,
                        ),
                        child: DottedLine(
                          dashColor: color,
                          direction: Axis.vertical,
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
            Gap.customGapWidth(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          journey.title,
                          style: TypographyTheme.textSSemiBold.copyWith(
                            color: journey.status ==
                                    ListItemPatientJourneyCardStatus.done ||
                                journey.status ==
                                    ListItemPatientJourneyCardStatus.notDone
                                ? BaseColor.neutral.shade40
                                : BaseColor.neutral.shade80,
                          ),
                        ),
                      ),
                      journey.time.isNotEmpty
                          ? Gap.customGapWidth(10)
                          : const SizedBox(),
                      journey.time.isNotEmpty &&
                              journey.status ==
                                  ListItemPatientJourneyCardStatus.done
                          ? Text(
                              journey.time,
                              style: TypographyTheme.textSRegular.toNeutral40,
                            )
                          : const SizedBox(),
                    ],
                  ),
                  Gap.customGapHeight(10),
                  if (contentBuilder != null)
                    contentBuilder!(journey) ?? buildContent(context)
                  else
                    buildContent(context),
                ],
              ),
            ),
          ],
        ),
        Gap.customGapHeight(6),
      ],
    );
  }

  Widget buildContent(BuildContext context) {
    Widget? child;
    switch (journey.status) {
      case ListItemPatientJourneyCardStatus.queue:
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Assets.icons.fill.account.svg(
                  width: BaseSize.customWidth(18),
                  height: BaseSize.customHeight(18),
                  colorFilter: BaseColor.primary3.filterSrcIn,
                ),
                Gap.w4,
                Text(
                  journey.subTitle,
                  style: TypographyTheme.textXSSemiBold.toPrimary,
                ),
              ],
            ),
            Gap.h16,
            ButtonWidget.primary(
              text: LocaleKeys.text_viewQueueingList.tr(),
              buttonSize: ButtonSize.small,
              onTap: () => onPressedButton(journey),
            ),
          ],
        );
        break;
      case ListItemPatientJourneyCardStatus.inProgress:
        child = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: BaseSize.customHeight(2),
              ),
              child: Assets.icons.fill.clock.svg(
                width: BaseSize.customWidth(18),
                height: BaseSize.customHeight(18),
                colorFilter: BaseColor.primary3.filterSrcIn,
              ),
            ),
            Gap.w4,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  journey.subTitle.isEmpty
                      ? LocaleKeys.text_inExamination.tr()
                      : journey.subTitle,
                  style: TypographyTheme.textXSSemiBold.toPrimary,
                ),
                Gap.h4,
                Text(
                  LocaleKeys.text_examinationInProgress.tr(),
                  style: TypographyTheme.textXSRegular.toNeutral50,
                ),
              ],
            ),
          ],
        );
        break;
      case ListItemPatientJourneyCardStatus.done:
        return Text(
          journey.subTitle.isEmpty
              ? LocaleKeys.text_done.tr()
              : journey.subTitle,
          style: TypographyTheme.textSRegular.toNeutral40,
        );
    }

    return Container(
      decoration: BoxDecoration(
        color: BaseColor.primary1,
        borderRadius: BorderRadius.circular(
          BaseSize.radiusLg,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.customWidth(10),
        vertical: BaseSize.customHeight(10),
      ),
      child: child,
    );
  }

  double _calculateDotsHeight() {
    return 40.0;
  }
}
