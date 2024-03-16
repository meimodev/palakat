import 'models.dart';

class UserApp {
  final int id;
  final String name;
  final String dob;
  final String phone;
  final String column;
  final Church church;

  UserApp({
    required this.dob,
    required this.phone,
    required this.column,
    required this.id,
    required this.name,
    required this.church,
  });
}