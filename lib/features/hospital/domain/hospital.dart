import 'package:freezed_annotation/freezed_annotation.dart';

part 'hospital.freezed.dart';
part 'hospital.g.dart';

@freezed
class Hospital with _$Hospital {
  const factory Hospital({
    @Default("") String serial,
    @Default("") String name,
    String? address,
    String? about,
    double? longitude,
    double? latitude,
    String? pictureURL,
    String? phone,
    String? callCenter,
    String? instagram,
    String? email,
  }) = _Hospital;

  @override
  factory Hospital.fromJson(Map<String, dynamic> json) =>
      _$HospitalFromJson(json);
}
