import 'package:palakat/data/models/church.dart';

class Membership {
  final String id;
  final Church church;
  final String column;
  final bool baptize;
  final bool sidi;

  Membership({
    required this.id,
    required this.church,
    required this.column,
    required this.baptize,
    required this.sidi,
  });
}
