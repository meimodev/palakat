import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'appointment_list_request.g.dart';

@JsonSerializable(includeIfNull: false)
class AppointmentListRequest extends PaginationRequest {
  final String? state;
  @ParamListConverter()
  final List<String>? types;
  @ParamListConverter()
  final List<String>? doctorSerial;
  @ParamListConverter()
  final List<String>? specialistSerial;
  @ParamListConverter()
  final List<String>? hospitalSerial;
  @ParamListConverter()
  final List<String>? patientSerial;

  const AppointmentListRequest({
    required int page,
    required int pageSize,
    String? sortType,
    String? sortBy,
    String? search,
    this.state,
    this.types,
    this.doctorSerial,
    this.specialistSerial,
    this.hospitalSerial,
    this.patientSerial,
  }) : super(
          page: page,
          pageSize: pageSize,
          sortType: sortType,
          sortBy: sortBy,
          search: search,
        );

  @override
  factory AppointmentListRequest.fromJson(Map<String, dynamic> json) =>
      _$AppointmentListRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AppointmentListRequestToJson(this);
}
