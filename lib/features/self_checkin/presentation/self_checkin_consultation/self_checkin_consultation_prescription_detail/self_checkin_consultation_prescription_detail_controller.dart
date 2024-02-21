import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/presentation.dart';

class SelfCheckinConsultationPrescriptionController
    extends StateNotifier<SelfCheckinConsultationPrescriptionState> {
  SelfCheckinConsultationPrescriptionController()
      : super(const SelfCheckinConsultationPrescriptionState(
            selectAllMedicine: null));

  selectAllMedicine(bool medicine) {
    state = state.copyWith(
      selectAllMedicine: medicine,
    );
  }
}

final selfCheckinConsultationPrescriptionControllerProvider =
    StateNotifierProvider.autoDispose<
        SelfCheckinConsultationPrescriptionController,
        SelfCheckinConsultationPrescriptionState>((ref) {
  return SelfCheckinConsultationPrescriptionController();
});
