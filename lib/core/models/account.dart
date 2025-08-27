// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/constants/enums/enums.dart';

import 'models.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
abstract class Account with _$Account {
  const factory Account({
    required int id,
    required String phone,
    required String name,
    // @DateTimeConverterTimestamp() DateTime? dob,
    required Gender gender,
    required bool married,
    @DateTimeConverterTimestamp() DateTime? createdAt,
    @DateTimeConverterTimestamp() DateTime? updatedAt,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> data) =>
      _$AccountFromJson(data);
}
