import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';

class HospitalMapper {
  static DoctorHospitalSchedule mapHospitalSchedule(
      DoctorHospitalScheduleResponse response) {
    final json = response.toJson();
    final List<Map<String, dynamic>> schedules = json['schedules'];
    final grouped = schedules.groupBy<int>((schedule) => schedule['day']);

    return DoctorHospitalSchedule(
      serial: response.serial,
      name: response.name,
      schedules: grouped.entries
          .map(
            (entry) => DoctorSchedule(
              day: entry.key,
              times: entry.value
                  .map(
                    (e) => DoctorScheduleTime.fromJson(e),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}
