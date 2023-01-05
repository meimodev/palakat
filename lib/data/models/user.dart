import 'package:palakat/data/models/membership.dart';

class User {
  final String id;
  final String phone;
  final String name;
  final String dob;
  final String maritalStatus;
  final Membership membership;
  List<String> eventIds;

  User({
    required this.dob,
    required this.phone,
    required this.id,
    required this.name,
    required this.maritalStatus,
    required this.membership,
    this.eventIds = const [],
  });
}