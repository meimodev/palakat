import 'package:palakat/core/constants/constants.dart';

class Activity {
  final String id;
  final String title;
  final ActivityType type;
  final Bipra bipra;
  final DateTime publishDate;
  final DateTime activityDate;

  Activity({
    required this.id,
    required this.title,
    required this.type,
    required this.bipra,
    required this.publishDate,
    required this.activityDate,
  });

  @override
  String toString() {
    return 'Activity{id: $id, title: $title, type: $type, bipra: $bipra, publishDate: $publishDate, activityDate: $activityDate}';
  }
}
