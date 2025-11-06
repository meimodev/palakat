import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_admin/core/models/models.dart' hide Column;

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.mapOperationType,
    this.initialLocation,
  });

  final MapOperationType mapOperationType;
  final Location? initialLocation;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> gMapsController =
      Completer<GoogleMapController>();

  Location? selectedLocation;
  Location? initialLocation;

  @override
  void initState() {
    super.initState();
    initialLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    final pinPoint = widget.mapOperationType == MapOperationType.pinPoint;
    return ScaffoldWidget(
      disablePadding: true,
      disableSingleChildScrollView: true,
      child: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                initialLocation?.latitude ?? -6.1448757,
                initialLocation?.longitude ?? 106.8532384,
              ),
              zoom: 15,
            ),
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            indoorViewEnabled: false,
            mapToolbarEnabled: false,
            buildingsEnabled: false,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            scrollGesturesEnabled: pinPoint,
            zoomGesturesEnabled: pinPoint,
            onMapCreated: (GoogleMapController controller) {
              gMapsController.complete(controller);
            },
            onCameraMove: (position) {
              final target = position.target;
              selectedLocation = Location(
                id: 0,
                latitude: target.latitude,
                longitude: target.longitude,
                name: '',
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            top: BaseSize.h48,
            child: ScreenTitleWidget.primary(
              title: pinPoint ? "Choose Location" : "",
              leadIcon: Assets.icons.line.chevronBackOutline,
              leadIconColor: Colors.black,
              onPressedLeadIcon: () => context.pop(),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Container(color: Colors.red, width: 10, height: 10)],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: BaseSize.h48,
            child: pinPoint
                ? Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: BaseSize.customWidth(200),
                      child: ButtonWidget.primary(
                        text: "Choose Location",
                        onTap: () => context.pop<Location?>(selectedLocation),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
