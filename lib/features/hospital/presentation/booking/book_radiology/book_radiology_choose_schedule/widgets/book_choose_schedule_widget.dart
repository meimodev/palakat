import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'widgets.dart';

class BookChooseScheduleWidget extends StatelessWidget {
  const BookChooseScheduleWidget({
    super.key,
    required this.onSelectedHospital,
    required this.showCalendarPicker,
    required this.packageName,
    required this.packageCategory,
    required this.packagePrice,
    required this.onSelectedSchedule,
    required this.hospitals,
    required this.availableTimeSpan,
  });

  final String packageName;
  final String packageCategory;
  final String packagePrice;

  final void Function(String hospital) onSelectedHospital;
  final void Function(DateTimeRange schedule) onSelectedSchedule;
  final bool showCalendarPicker;

  final List<String> hospitals;
  final List<DateTimeRange> availableTimeSpan;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.customWidth(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gap.h20,
          PackageInfoLayoutWidget(
            name: packageName,
            category: packageCategory,
            price: packagePrice,
          ),
          Gap.h16,
          HospitalPickerWidget(
            hospitals: hospitals,
            onSelectedHospital: onSelectedHospital,
          ),
          Gap.h16,
          showCalendarPicker
              ? CalendarDatePickerWidget(
                  availableDateTimes: const [],
                  onSelectedDateTime: (dateTime, isAvailable) {},
                )
              : const SizedBox(),
          Gap.h16,
        ],
      ),
    );
  }
}
