import 'package:palakat/data/models/church.dart';

class Membership {
  final String id;
  Church? church;
  String churchId;
  final String column;
  final bool baptize;
  final bool sidi;

  Membership({
    required this.id,
    required this.column,
    required this.baptize,
    required this.sidi,
    required this.churchId,
    this.church,
  });

  factory Membership.fromMap(Map<String, dynamic> data) => Membership(
        id: data["id"],
        column: data["column"],
        baptize: data["baptize"],
        sidi: data["sidi"],
        churchId: data["church_id"],
      );

  @override
  String toString() {
    return 'Membership{id: $id, church: $church, churchId: $churchId, column: $column, baptize: $baptize, sidi: $sidi}';
  }
}
