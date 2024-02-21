import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';

class HelpController extends StateNotifier<HelpState> {
  HelpController()
      : super(
          const HelpState(),
        ) {
    setSelectedTag(tags[0]);
  }

  final questions = [
    {
      "header": "What is Appointment?",
      "content":
          "You can reschedule or cancel an appointment directly on tele-consultation platform by providing certain information. Alternatively, you can call a member of our team to help you with the rescheduling or cancellation."
    },
    {
      "header": "What is Appointment?",
      "content":
          "You can reschedule or cancel an appointment directly on tele-consultation platform by providing certain information. Alternatively, you can call a member of our team to help you with the rescheduling or cancellation."
    },
    {
      "header": "What is Appointment?",
      "content":
          "You can reschedule or cancel an appointment directly on tele-consultation platform by providing certain information. Alternatively, you can call a member of our team to help you with the rescheduling or cancellation."
    },
    {
      "header": "What is Appointment?",
      "content":
          "You can reschedule or cancel an appointment directly on tele-consultation platform by providing certain information. Alternatively, you can call a member of our team to help you with the rescheduling or cancellation."
    },
    {
      "header": "What is Appointment?",
      "content":
          "You can reschedule or cancel an appointment directly on tele-consultation platform by providing certain information. Alternatively, you can call a member of our team to help you with the rescheduling or cancellation."
    },
    {
      "header": "What is Appointment?",
      "content":
          "You can reschedule or cancel an appointment directly on tele-consultation platform by providing certain information. Alternatively, you can call a member of our team to help you with the rescheduling or cancellation."
    },
    {
      "header": "What is Appointment?",
      "content":
          "You can reschedule or cancel an appointment directly on tele-consultation platform by providing certain information. Alternatively, you can call a member of our team to help you with the rescheduling or cancellation."
    },
    {
      "header": "What is Appointment?",
      "content":
          "You can reschedule or cancel an appointment directly on tele-consultation platform by providing certain information. Alternatively, you can call a member of our team to help you with the rescheduling or cancellation."
    },
    {
      "header": "What is Appointment?",
      "content":
          "You can reschedule or cancel an appointment directly on tele-consultation platform by providing certain information. Alternatively, you can call a member of our team to help you with the rescheduling or cancellation."
    },
    {
      "header": "What if I want to reschedule or cancel an appointment?",
      "content":
          "You can reschedule or cancel an appointment directly on tele-consultation platform by providing certain information. Alternatively, you can call a member of our team to help you with the rescheduling or cancellation."
    }
  ];
  final tags = [
    "Appointment",
    "Doctor",
    "Hospital",
    "Payment",
    "Booking",
    "Others"
  ];

  void setSelectedTag(String newValue) {
    state = state.copyWith(selectedTag: newValue);
  }
}

final helpControllerProvider =
    StateNotifierProvider.autoDispose<HelpController, HelpState>(
  (ref) {
    return HelpController();
  },
);
