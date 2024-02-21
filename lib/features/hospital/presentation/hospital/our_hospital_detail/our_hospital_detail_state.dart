import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:halo_hermina/features/presentation.dart';

class OurHospitalDetailState {
  final OurHospitalSegment selectedSegment;
  final Set<Marker> hospitalLocationMarker;

  const OurHospitalDetailState({
    required this.selectedSegment,
    required this.hospitalLocationMarker,
  });

  OurHospitalDetailState copyWith({
    OurHospitalSegment? selectedSegment,
    Set<Marker>? hospitalLocationMarker,
  }) {
    return OurHospitalDetailState(
      selectedSegment: selectedSegment ?? this.selectedSegment,
      hospitalLocationMarker:
          hospitalLocationMarker ?? this.hospitalLocationMarker,
    );
  }
}
