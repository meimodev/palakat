import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'hospital_list_request.g.dart';

@JsonSerializable(includeIfNull: false)
class HospitalListRequest extends PaginationRequest {
  final double? longitude;
  final double? latitude;
  final String? doctorSerial;
  @ParamListConverter()
  final List<String>? serial;

  const HospitalListRequest({
    required int page,
    required int pageSize,
    String? sortType,
    String? sortBy,
    String? search,
    this.latitude,
    this.longitude,
    this.doctorSerial,
    this.serial,
  }) : super(
          page: page,
          pageSize: pageSize,
          sortType: sortType,
          sortBy: sortBy,
          search: search,
        );

  @override
  factory HospitalListRequest.fromJson(Map<String, dynamic> json) =>
      _$HospitalListRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HospitalListRequestToJson(this);
}
