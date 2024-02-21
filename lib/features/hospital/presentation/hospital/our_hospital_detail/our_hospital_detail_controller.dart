import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/presentation.dart';

class OurHospitalDetailController
    extends StateNotifier<OurHospitalDetailState> {
  OurHospitalDetailController()
      : super(const OurHospitalDetailState(
          selectedSegment: OurHospitalSegment.profile,
          hospitalLocationMarker: {},
        ));

  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();

  final CameraPosition initialMapsPosition = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<void> init() async {
    await setHospitalLocationMarker(37.42796133580664, -122.085749655962);
  }

  Future<void> setHospitalLocationMarker(
      double latitude, double longitude) async {
    MapsUtil.zoomToMarker(mapController, latitude, longitude);

    var marker = await MapsUtil.createMarker(
        mapController, 'marker-1', latitude, longitude);

    state = state.copyWith(
      hospitalLocationMarker: {marker},
    );
  }

  void changeSegment(OurHospitalSegment? segment) {
    state = state.copyWith(
      selectedSegment: segment,
    );
  }

  Future<void> _disposeController() async {
    final GoogleMapController controller = await mapController.future;
    controller.dispose();
  }

  @override
  void dispose() {
    super.dispose();
    _disposeController();
  }
}

final ourHospitalDetailControllerProvider = StateNotifierProvider.autoDispose<
    OurHospitalDetailController, OurHospitalDetailState>((ref) {
  return OurHospitalDetailController();
});
