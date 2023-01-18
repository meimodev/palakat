import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:palakat/data/models/membership.dart';

class UserApp {
  final String id;
  final String phone;
  final String name;
  final DateTime dob;
  final String maritalStatus;
  final String membershipId;
  Membership? membership;
  List<String> eventIds;

  UserApp({
    required this.dob,
    required this.phone,
     this.id = "",
    required this.name,
    required this.maritalStatus,
     this.membershipId ="",
    this.membership,
    this.eventIds = const [],
  });

  factory UserApp.fromMap(Map<String, dynamic> data) => UserApp(
        dob: (data['dob'] as Timestamp).toDate(),
        phone: data["phone"],
        id: data["id"],
        name: data["name"],
        maritalStatus: data["marital_status"],
        membershipId: data["membership_id"],
        eventIds: List<String>.from(data["events"]),
      );

  UserApp copyWith({
    DateTime? dob,
    String? phone,
    String? id,
    String? name,
    String? maritalStatus,
    String? membershipId,
    List<String>? eventIds,
    Membership? membership,
  }) =>
      UserApp(
        dob: dob ?? this.dob,
        phone: phone ?? this.phone,
        id: id ?? this.id,
        name: name ?? this.name,
        maritalStatus: maritalStatus ?? this.maritalStatus,
        membershipId: membershipId ?? this.membershipId,
        eventIds: eventIds ?? this.eventIds,
        membership: membership ?? this.membership,
      );

  @override
  String toString() {
    return 'UserApp{id: $id, phone: $phone, name: $name, dob: $dob, maritalStatus: $maritalStatus, membershipId: $membershipId, membership: $membership, eventIds: $eventIds}';
  }

  Map<String, dynamic> get toMap => {
        'dob': Timestamp.fromDate(dob),
        'phone': phone,
        'id': id,
        'name': name,
        'marital_status': maritalStatus,
        'membership_id': membershipId,
        'events': eventIds,
      };
}
