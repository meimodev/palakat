import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_fetch_documents_request.freezed.dart';
part 'get_fetch_documents_request.g.dart';

@freezed
abstract class GetFetchDocumentsRequest with _$GetFetchDocumentsRequest {
// ignore: invalid_annotation_target
@JsonSerializable(includeIfNull: false)
  const factory GetFetchDocumentsRequest({
    int? churchId,
    String? search,
  }) = _GetFetchDocumentsRequest;

  factory GetFetchDocumentsRequest.fromJson(Map<String, dynamic> json) =>
      _$GetFetchDocumentsRequestFromJson(json);
}
