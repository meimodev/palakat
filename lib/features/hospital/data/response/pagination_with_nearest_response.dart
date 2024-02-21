import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_with_nearest_response.freezed.dart';
part 'pagination_with_nearest_response.g.dart';

@Freezed(genericArgumentFactories: true)
class PaginationWithNearestResponse<T> with _$PaginationWithNearestResponse<T> {
  const factory PaginationWithNearestResponse({
    @Default(0) int total,
    @Default(0) int currentPage,
    @Default(0) int totalPage,
    @Default([]) List<T> nearest,
    @Default([]) List<T> data,
  }) = _PaginationWithNearestResponse;

  factory PaginationWithNearestResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$PaginationWithNearestResponseFromJson(
        json,
        fromJsonT,
      );
}
