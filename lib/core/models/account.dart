import 'package:palakat/core/constants/enums/enums.dart';

class Account {
  final String id;
  final String phone;
  final String name;

  final DateTime dob;
  final Gender gender;
  final MaritalStatus maritalStatus;

  Account({
    required this.id,
    required this.phone,
    required this.name,
    required this.dob,
    required this.gender,
    required this.maritalStatus,
  });
}