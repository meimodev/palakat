import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'location_list_request.g.dart';

@JsonSerializable(includeIfNull: false)
class LocationListRequest extends PaginationRequest {
  final double? longitude;
  final double? latitude;

  const LocationListRequest({
    required int page,
    required int pageSize,
    String? sortType,
    String? sortBy,
    String? search,
    this.latitude,
    this.longitude,
  }) : super(
          page: page,
          pageSize: pageSize,
          sortType: sortType,
          sortBy: sortBy,
          search: search,
        );

  @override
  factory LocationListRequest.fromJson(Map<String, dynamic> json) =>
      _$LocationListRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LocationListRequestToJson(this);
}
