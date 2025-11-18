import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/account.dart';

part 'church_request.freezed.dart';
part 'church_request.g.dart';

@freezed
abstract class ChurchRequest with _$ChurchRequest {
  // ignore: invalid_annotation_target
  @JsonSerializable(includeIfNull: false)
  factory ChurchRequest({
    int? id,
    required String churchName,
    required String churchAddress,
    required String contactPerson,
    required String contactPhone,
    @Default(RequestStatus.todo) RequestStatus status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? requesterId,
    Account? requester,
  }) = _ChurchRequest;

  factory ChurchRequest.fromJson(Map<String, dynamic> json) =>
      _$ChurchRequestFromJson(json);
}
