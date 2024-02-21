import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class BookChooseScheduleDoctorWidget extends ConsumerWidget {
  const BookChooseScheduleDoctorWidget({
    super.key,
    required this.onSelectedHospital,
    required this.showCalendarPicker,
    required this.packageName,
    required this.packageCategory,
    required this.packagePrice,
    required this.onSelectedSchedule,
    required this.hospitals,
    required this.availableTimeSpan,
    required this.onSelectedDoctor,
    required this.doctors,
  });

  final String packageName;
  final String packageCategory;
  final String packagePrice;

  final void Function(String hospital) onSelectedHospital;
  final void Function(String doctor) onSelectedDoctor;
  final void Function(DateTimeRange schedule) onSelectedSchedule;
  final bool showCalendarPicker;

  final List<String> hospitals;
  final List<Map<String, String>> doctors;
  final List<DateTimeRange> availableTimeSpan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookVaccineChooseScheduleControllerProvider);
    print("selectedHospital: ${state.selectedHospital}");
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
          Container(
            decoration: BoxDecoration(
              color: state.selectedHospital.isEmpty
                  ? BaseColor.neutral.shade20
                  : BaseColor.white,
              borderRadius: BorderRadius.circular(BaseSize.radiusLg),
            ),
            child: AbsorbPointer(
              absorbing: state.selectedHospital.isEmpty,
              child: DoctorPickerWidget(
                doctors: doctors,
                onSelectedDoctor: onSelectedDoctor,
              ),
            ),
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
