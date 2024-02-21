import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

String _category = "Influenza";
String _name = "Influenza 4 Strain Vaccine";
String _price = "Rp 350.000";

List<String> _hospitals = [
  "RSH Bogor",
  "RSH Daan Mogot",
  "RSH Grand Wisata",
  "RSH Kemayoran",
  "RSH Periuk Tanggerang",
  "RSH Podomoro",
  "RSH Serpong",
  "RSH Tanggerang",
  "RSH Yogya",
];

// List<String> _doctorsx = [
//   "name" : "dr. Leon Gerald, SpPD",
//           specialist: 'Internal Medicine - Internist',
//           image:
//               "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d"
// ];

final _doctors = [
  {
    "name": "dr. Leon Gerald, SpPD",
    "image": "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d",
    "specialist": "Internal Medicine - Internist",
  },
  {
    "name": "dr. Eko, SpOG",
    "image": "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d",
    "specialist": "Spesialis Obstetri dan Ginekologi",
  },
  {
    "name": "dr. Rani, SpA",
    "image": "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d",
    "specialist": "Spesialis Anak",
  },
  {
    "name": "dr. Andi Deris, SpPD",
    "image": "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d",
    "specialist": "Internal Medicine - Internist",
  },
];

DateTime _dateSubs(int day) => DateTime.now().subtract(Duration(days: day));

DateTime _dateAdds(int day) => DateTime.now().add(Duration(days: day));

List<DateTimeRange> _availableTimeSpans = [
  DateTimeRange(
    start: _dateSubs(1).copyWith(hour: 10, minute: 0),
    end: _dateSubs(1).copyWith(hour: 10, minute: 30),
  ),
  DateTimeRange(
    start: _dateSubs(2).copyWith(hour: 10, minute: 0),
    end: _dateSubs(2).copyWith(hour: 10, minute: 30),
  ),
  DateTimeRange(
    start: _dateAdds(1).copyWith(hour: 10, minute: 0),
    end: _dateAdds(1).copyWith(hour: 10, minute: 30),
  ),
  DateTimeRange(
    start: _dateAdds(1).copyWith(hour: 11, minute: 0),
    end: _dateAdds(1).copyWith(hour: 12, minute: 30),
  ),
  DateTimeRange(
    start: _dateAdds(2).copyWith(hour: 10, minute: 0),
    end: _dateAdds(2).copyWith(hour: 10, minute: 30),
  ),
];

class BookVaccineChooseScheduleScreen extends ConsumerWidget {
  const BookVaccineChooseScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.watch(bookVaccineChooseScheduleControllerProvider.notifier);
    final state = ref.watch(bookVaccineChooseScheduleControllerProvider);

    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        height: BaseSize.customHeight(70),
        title:
            "${LocaleKeys.text_choose.tr()} ${LocaleKeys.text_schedule.tr()}",
      ),
      child: BookChooseScheduleDoctorWidget(
        packageName: _name,
        packageCategory: _category,
        packagePrice: _price,
        hospitals: _hospitals,
        doctors: _doctors,
        showCalendarPicker: state.selectedDoctor.isNotEmpty,
        availableTimeSpan: _availableTimeSpans,
        onSelectedHospital: (String hospital) {
          controller.selectHospital(hospital);
        },
        onSelectedSchedule: (DateTimeRange schedule) {
          context.pushNamed(AppRoute.bookVaccineSummary);
        },
        onSelectedDoctor: (String doctor) {
          controller.selectDoctor(doctor);
        },
      ),
    );
  }
}
