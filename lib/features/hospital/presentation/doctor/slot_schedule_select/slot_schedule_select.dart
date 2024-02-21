import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

Future showSlotScheduleSelect(
  BuildContext context, {
  required String header,
  required Function(String selectedTime) onSelectedAvailableTime,
  required DateTime dateTime,
  required String doctorSerial,
  required String hospitalSerial,
  required String specialistSerial,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(BaseSize.customRadius(16)),
      ),
    ),
    builder: (context) {
      return SlotScheduleSelectContent(
        header: header,
        onSelectedAvailableTime: onSelectedAvailableTime,
        dateTime: dateTime,
        doctorSerial: doctorSerial,
        hospitalSerial: hospitalSerial,
        specialistSerial: specialistSerial,
      );
    },
  );
}

class SlotScheduleSelectContent extends ConsumerStatefulWidget {
  const SlotScheduleSelectContent({
    super.key,
    required this.header,
    required this.onSelectedAvailableTime,
    required this.dateTime,
    required this.doctorSerial,
    required this.hospitalSerial,
    required this.specialistSerial,
  });

  final String header;
  final DateTime dateTime;
  final String doctorSerial;
  final String hospitalSerial;
  final String specialistSerial;
  final void Function(String selectedTime) onSelectedAvailableTime;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SlotScheduleSelectContentState();
}

class _SlotScheduleSelectContentState
    extends ConsumerState<SlotScheduleSelectContent> {
  SlotScheduleSelectController get controller =>
      ref.read(slotScheduleSelectControllerProvider.notifier);

  @override
  void initState() {
    safeRebuild(
      () => controller.init(
        widget.dateTime,
        widget.doctorSerial,
        widget.hospitalSerial,
        widget.specialistSerial,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(slotScheduleSelectControllerProvider);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w24,
        vertical: BaseSize.h12,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.35,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
              child: Center(
                child: Assets.icons.fill.slidePanel.svg(),
              ),
            ),
            Gap.h12,
            Text(
              widget.header,
              style: TypographyTheme.bodySemiBold.toNeutral80,
            ),
            Gap.h20,
            Expanded(
              child: !state.isLoading
                  ? ListBuilderWidget(
                      data: state.times,
                      itemBuilder: (context, index, item) {
                        return SlotScheduleSelectContentTimeItem(
                          time: item,
                          isSelected: state.selectedIndex == index,
                          onTap: () {
                            controller.setSelectedIndex(index);
                          },
                        );
                      },
                    )
                  : Center(
                      child: LoadingWrapper(
                        value: state.isLoading,
                        child: const SizedBox(),
                      ),
                    ),
            ),
            Gap.h12,
            ButtonWidget.primary(
              buttonSize: ButtonSize.medium,
              text: LocaleKeys.text_next.tr(),
              isEnabled: state.selectedIndex >= 0,
              onTap: () => widget.onSelectedAvailableTime(
                state.times[state.selectedIndex],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SlotScheduleSelectContentTimeItem extends StatelessWidget {
  const SlotScheduleSelectContentTimeItem({
    super.key,
    required this.time,
    required this.isSelected,
    required this.onTap,
  });

  final String time;
  final bool isSelected;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final TextStyle timeTextStyle = TypographyTheme.heading3Regular.copyWith(
      color: BaseColor.neutral.shade80,
      fontWeight: FontWeight.w500,
    );
    return InkWell(
      onTap: onTap,
      child: Container(
        height: BaseSize.customHeight(60),
        decoration: BoxDecoration(
          color:
              isSelected ? BaseColor.neutral.shade10 : BaseColor.neutral.shade0,
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        ),
        child: Center(
          child: Text(
            time,
            style: timeTextStyle,
          ),
        ),
      ),
    );
  }
}
