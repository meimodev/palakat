import 'package:palakat/data/models/membership.dart';

class UserApp {
  final String id;
  final String phone;
  final String name;
  final String dob;
  final String maritalStatus;
  final String membershipId;
  Membership? membership;
  List<String> eventIds;

  UserApp({
    required this.dob,
    required this.phone,
    required this.id,
    required this.name,
    required this.maritalStatus,
    required this.membershipId,
    this.membership,
    this.eventIds = const [],
  });

  factory UserApp.fromMap(Map<String, dynamic> data) => UserApp(
        dob: data['dob'],
        phone: data["phone"],
        id: data["id"],
        name: data["name"],
        maritalStatus: data["marital_status"],
        membershipId: data["membership_id"],
        eventIds: List<String>.from(data["events"]),
      );

  @override
  String toString() {
    return 'UserApp{id: $id, phone: $phone, name: $name, dob: $dob, maritalStatus: $maritalStatus, membership: $membership, eventIds: $eventIds}';
  }
}
