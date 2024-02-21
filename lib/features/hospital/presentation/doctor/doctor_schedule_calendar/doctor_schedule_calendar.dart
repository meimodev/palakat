import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class DoctorScheduleCalendar extends ConsumerStatefulWidget {
  const DoctorScheduleCalendar({
    super.key,
    required this.onSelectedAvailableDateTime,
    required this.doctorSerial,
    required this.hospitalSerial,
    required this.specialistSerial,
  });

  final Function(DateTime selectedDateTime) onSelectedAvailableDateTime;
  final String doctorSerial;
  final String hospitalSerial;
  final String specialistSerial;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DoctorScheduleCalendarState();
}

class _DoctorScheduleCalendarState
    extends ConsumerState<DoctorScheduleCalendar> {
  DoctorScheduleCalendarController get controller =>
      ref.read(doctorScheduleCalendarControllerProvider.notifier);

  @override
  void initState() {
    safeRebuild(
      () => controller.init(
        widget.doctorSerial,
        widget.hospitalSerial,
      ),
    );
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DoctorScheduleCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    safeRebuild(() {
      if (oldWidget.doctorSerial != widget.doctorSerial) {
        controller.setDoctorSerial(widget.doctorSerial);
      } else if (oldWidget.hospitalSerial != widget.hospitalSerial) {
        controller.setHospitalSerial(widget.hospitalSerial);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorScheduleCalendarControllerProvider);

    return LoadingWrapper(
      value: state.isLoading,
      height: BaseSize.customHeight(300),
      child: CalendarDatePickerWidget(
        availableDateTimes: state.schedules,
        onSelectedDateTime: (dateTime, isAvailable) {
          if (isAvailable) {
            showSlotScheduleSelect(
              context,
              header: dateTime.eeeeDMmmYyyy,
              onSelectedAvailableTime: (selectedTime) {
                widget.onSelectedAvailableDateTime(
                  dateTime.setTime(selectedTime),
                );
              },
              dateTime: dateTime,
              doctorSerial: state.doctorSerial!,
              hospitalSerial: state.hospitalSerial!,
              specialistSerial: widget.specialistSerial,
            );
          }
        },
      ),
    );
  }
}
