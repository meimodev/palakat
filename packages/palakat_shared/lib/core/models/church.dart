import 'package:freezed_annotation/freezed_annotation.dart';
import 'column.dart';
import 'church_letterhead.dart';
import 'membership.dart';
import 'member_position.dart';
import 'location.dart';

part 'church.freezed.dart';
part 'church.g.dart';

@freezed
abstract class Church with _$Church {
  const factory Church({
    int? id,
    required String name,
    String? documentAccountNumber,
    String? phoneNumber,
    String? email,
    String? description,
    ChurchLetterhead? letterhead,
    int? locationId,
    Location? location,
    @Default([]) List<Column> columns,
    @Default([]) List<Membership> memberships,
    @Default([]) List<MemberPosition> membershipPositions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Church;

  factory Church.fromJson(Map<String, dynamic> json) => _$ChurchFromJson(json);
}
