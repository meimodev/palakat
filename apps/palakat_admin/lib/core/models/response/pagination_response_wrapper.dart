import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_response_wrapper.freezed.dart';

part 'pagination_response_wrapper.g.dart';

@Freezed(genericArgumentFactories: true)
abstract class PaginationResponseWrapper<T> with _$PaginationResponseWrapper<T> {
  const factory PaginationResponseWrapper({
    required String message,
    required PaginationResponseWrapperResponse pagination,
    required List<T> data,
  }) = _PaginationResponseWrapper;

  factory PaginationResponseWrapper.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$PaginationResponseWrapperFromJson(json, fromJsonT);
}

@freezed
abstract class PaginationResponseWrapperResponse
    with _$PaginationResponseWrapperResponse {
  const factory PaginationResponseWrapperResponse({
    required int page,
    required int pageSize,
    required int total,
    required int totalPages,
    required bool hasNext,
    required bool hasPrev,
  }) = _PaginationResponseWrapperResponse;

  factory PaginationResponseWrapperResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$PaginationResponseWrapperResponseFromJson(json);
}
