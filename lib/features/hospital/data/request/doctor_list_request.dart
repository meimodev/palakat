import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'doctor_list_request.g.dart';

@JsonSerializable(includeIfNull: false)
class DoctorListRequest extends PaginationRequest {
  @ParamListConverter()
  final List<String>? serial;
  @ParamListConverter()
  final List<String>? specialistSerial;
  @ParamListConverter()
  final List<String>? hospitalSerial;
  @ParamListConverter()
  final List<String>? day;
  final String? genderSerial;

  const DoctorListRequest({
    required int page,
    required int pageSize,
    String? sortType,
    String? sortBy,
    String? search,
    this.serial,
    this.specialistSerial,
    this.hospitalSerial,
    this.day,
    this.genderSerial,
  }) : super(
          page: page,
          pageSize: pageSize,
          sortType: sortType,
          sortBy: sortBy,
          search: search,
        );

  @override
  factory DoctorListRequest.fromJson(Map<String, dynamic> json) =>
      _$DoctorListRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DoctorListRequestToJson(this);
}
