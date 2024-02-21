import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

String _category = "Beauty & Personal Care";
String _name = "Booster Vitamin C + Multivitamin";
String _price = "Rp 285.000";

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

class BookMcuChooseScheduleScreen extends ConsumerWidget {
  const BookMcuChooseScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.watch(bookMcuChooseScheduleControllerProvider.notifier);
    final state = ref.watch(bookMcuChooseScheduleControllerProvider);

    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        height: BaseSize.customHeight(70),
        title:
            "${LocaleKeys.text_choose.tr()} ${LocaleKeys.text_schedule.tr()}",
      ),
      child: BookChooseScheduleWidget(
        packageName: _name,
        packageCategory: _category,
        packagePrice: _price,
        hospitals: _hospitals,
        showCalendarPicker: state.selectedHospital.isNotEmpty,
        availableTimeSpan: _availableTimeSpans,
        onSelectedHospital: (String hospital) {
          controller.selectHospital(hospital);
        },
        onSelectedSchedule: (DateTimeRange schedule) {
          context.pushNamed(AppRoute.bookMcuSummary);
        },
      ),
    );
  }
}
