import 'package:palakat/data/models/church.dart';

class Membership {
  final String? id;
  String churchId;
  final String column;
  final bool baptize;
  final bool sidi;
  Church? church;

  Membership({
     this.id,
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

  Map<String, dynamic> toMap() => {
        "id": id,
        "column": column,
        "baptize": baptize,
        "sidi": sidi,
        "church_id": churchId,
      };

  @override
  String toString() {
    return 'Membership{id: $id, churchId: $churchId, '
        'column: $column, baptize: $baptize, sidi: $sidi, church: $church}';
  }

  Membership copyWith({
    String? id,
    String? churchId,
    String? column,
    bool? baptize,
    bool? sidi,
    Church? church,
  }) =>
      Membership(
        id: id ?? this.id,
        column: column ?? this.column,
        baptize: baptize ?? this.baptize,
        sidi: sidi ?? this.sidi,
        churchId: churchId ?? this.churchId,
        church: church ?? this.church,
      );
}
