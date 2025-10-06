// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/constants/enums/enums.dart';

import 'date_time_converter_iso8601.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
abstract class Account with _$Account {
  const factory Account({
    int? id,
    required String phone,
    required String name,
    @DateTimeConverterIso8601() DateTime? dob,
    required Gender gender,
    required bool married,
    int? membershipId,
    @DateTimeConverterIso8601() DateTime? createdAt,
    @DateTimeConverterIso8601() DateTime? updatedAt,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> data) =>
      _$AccountFromJson(data);
}
