import '../../../core/constants/enums/list_item_patient_journey_card_status_enum.dart';

class PatientJourney {
  String title;
  String subTitle;
  String time;
  ListItemPatientJourneyCardStatus status;

  PatientJourney({
    this.time = "",
    required this.title,
    required this.subTitle,
    required this.status,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientJourney &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;

  @override
  String toString() {
    return 'PatientJourney{title: $title, subTitle: $subTitle, time: $time, status: $status}';
  }
}
