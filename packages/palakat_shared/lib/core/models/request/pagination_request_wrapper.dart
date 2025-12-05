import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_request_wrapper.freezed.dart';
part 'pagination_request_wrapper.g.dart';

@Freezed(genericArgumentFactories: true)
abstract class PaginationRequestWrapper<T> with _$PaginationRequestWrapper<T> {
  const PaginationRequestWrapper._();

  const factory PaginationRequestWrapper({
    @Default(1) int page,
    @Default(100) int pageSize,
    String? sortBy,
    String? sortOrder,
    required T data,
  }) = _PaginationRequestWrapper;

  factory PaginationRequestWrapper.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$PaginationRequestWrapperFromJson(json, fromJsonT);

  Map<String, dynamic> toJsonFlat(Object? Function(T) toJsonT) {
    final dataJson = toJsonT(data);
    return {
      'page': page,
      'pageSize': pageSize,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (dataJson is Map<String, dynamic>) ...dataJson,
    };
  }
}
