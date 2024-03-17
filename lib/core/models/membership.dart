import 'package:palakat/core/constants/enums/enums.dart';
import 'package:palakat/core/models/models.dart';

class Membership {
  final String id;
  final Account account;
  final Church church;
  final String columnNumber;
  final bool baptize;
  final bool sidi;
  final Bipra bipra;

  Membership({
    required this.id,
    required this.account,
    required this.church,
    required this.columnNumber,
    required this.baptize,
    required this.sidi,
    required this.bipra,
  });
}

