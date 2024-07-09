// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/constants/enums/enums.dart';
import 'package:palakat/core/models/date_time_converter.dart';

part 'account.freezed.dart';

part 'account.g.dart';

@freezed
class Account with _$Account {
  const factory Account({
    required String serial,
    required String phone,
    required String name,
    @DateTimeConverterTimestamp() required DateTime dob,
    required Gender gender,
    @JsonKey(name: "marital_status") required MaritalStatus maritalStatus,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> data) =>
      _$AccountFromJson(data);
}
