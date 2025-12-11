import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

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
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  Location? _selectedLocation;
  bool _isMapMoving = false;
  bool _isInitialized = false;
  bool _isLoadingLocation = false;

  // Store pending location during drag (no setState)
  LatLng? _pendingLocation;

  // Default location (Manado, North Sulawesi, Indonesia)
  static const _defaultLat = 1.4748;
  static const _defaultLng = 124.8421;

  double get _initialLat => widget.initialLocation?.latitude ?? _defaultLat;
  double get _initialLng => widget.initialLocation?.longitude ?? _defaultLng;

  @override
  void initState() {
    super.initState();
    _selectedLocation = Location(
      id: 0,
      latitude: _initialLat,
      longitude: _initialLng,
      name: _formatCoordinates(_initialLat, _initialLng),
    );

    // Get current location on init if no initial location provided
    if (widget.initialLocation == null && _isPinPointMode) {
      _getCurrentLocationOnInit();
    }
  }

  Future<void> _getCurrentLocationOnInit() async {
    final position = await _determinePosition();
    if (position != null && mounted) {
      setState(() {
        _selectedLocation = Location(
          id: 0,
          latitude: position.latitude,
          longitude: position.longitude,
          name: _formatCoordinates(position.latitude, position.longitude),
        );
      });
      // Animate to current location after map is created
      _mapController.future.then((controller) {
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            17,
          ),
        );
      });
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<void> _goToMyLocation() async {
    setState(() => _isLoadingLocation = true);

    final position = await _determinePosition();

    if (!mounted) return;

    setState(() => _isLoadingLocation = false);

    if (position != null) {
      await _animateToLocation(position.latitude, position.longitude);
    } else {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat mengakses lokasi. Periksa izin lokasi.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatCoordinates(double lat, double lng) {
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }

  bool get _isPinPointMode =>
      widget.mapOperationType == MapOperationType.pinPoint;

  Future<void> _animateToLocation(double lat, double lng) async {
    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 17),
    );
  }

  Future<void> _zoomIn() async {
    final controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    final controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.zoomOut());
  }

  void _onCameraMoveStarted() {
    if (!_isPinPointMode || _isMapMoving) return;
    setState(() {
      _isMapMoving = true;
    });
  }

  void _onCameraMove(CameraPosition position) {
    if (!_isPinPointMode) return;
    // Only store the position, don't trigger rebuild
    _pendingLocation = position.target;
  }

  void _onCameraIdle() {
    if (!_isPinPointMode) return;

    final pending = _pendingLocation;
    setState(() {
      _isMapMoving = false;
      if (pending != null) {
        _selectedLocation = Location(
          id: 0,
          latitude: pending.latitude,
          longitude: pending.longitude,
          name: _formatCoordinates(pending.latitude, pending.longitude),
        );
      }
    });
    _pendingLocation = null;
  }

  void _confirmLocation() {
    context.pop<Location?>(_selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          _buildMap(),

          // Top bar with back button and title
          _buildTopBar(),

          // Center pin marker
          if (_isPinPointMode) _buildCenterPin(),

          // Bottom location card
          if (_isPinPointMode) _buildBottomCard(),

          // Map controls (zoom, my location)
          if (_isPinPointMode) _buildMapControls(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: LatLng(_initialLat, _initialLng),
        zoom: 16,
      ),
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      indoorViewEnabled: false,
      mapToolbarEnabled: false,
      buildingsEnabled: true,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      scrollGesturesEnabled: _isPinPointMode,
      zoomGesturesEnabled: _isPinPointMode,
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
        setState(() => _isInitialized = true);
      },
      onCameraMoveStarted: _onCameraMoveStarted,
      onCameraMove: _onCameraMove,
      onCameraIdle: _onCameraIdle,
      markers: !_isPinPointMode && widget.initialLocation != null
          ? {
              Marker(
                markerId: const MarkerId('location'),
                position: LatLng(_initialLat, _initialLng),
              ),
            }
          : {},
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.w12,
            vertical: BaseSize.h12,
          ),
          child: Row(
            children: [
              // Back button
              _MapIconButton(
                onTap: () => context.pop(),
                child: FaIcon(
                  AppIcons.back,
                  size: BaseSize.w24,
                  color: BaseColor.neutral90,
                ),
              ),
              Gap.w12,
              // Title
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: BaseSize.w16,
                    vertical: BaseSize.h12,
                  ),
                  decoration: BoxDecoration(
                    color: BaseColor.white,
                    borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: BaseColor.shadow.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _isPinPointMode ? 'Pilih Lokasi' : 'Lokasi',
                    style: BaseTypography.titleMedium.toBold.copyWith(
                      color: BaseColor.neutral90,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterPin() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.translationValues(0, _isMapMoving ? -8 : 0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pin icon
                Container(
                  width: BaseSize.w48,
                  height: BaseSize.w48,
                  decoration: BoxDecoration(
                    color: BaseColor.primary3,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BaseColor.primary3.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: FaIcon(
                      AppIcons.mapPin,
                      size: BaseSize.w24,
                      color: BaseColor.white,
                    ),
                  ),
                ),
                // Pin pointer
                CustomPaint(
                  size: Size(BaseSize.w12, BaseSize.h12),
                  painter: _PinPointerPainter(color: BaseColor.primary3),
                ),
                // Shadow dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: _isMapMoving ? BaseSize.w8 : BaseSize.w16,
                  height: BaseSize.h4,
                  decoration: BoxDecoration(
                    color: BaseColor.shadow.withValues(
                      alpha: _isMapMoving ? 0.2 : 0.3,
                    ),
                    borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomCard() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isInitialized ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            color: BaseColor.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(BaseSize.radiusLg),
            ),
            boxShadow: [
              BoxShadow(
                color: BaseColor.shadow.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(BaseSize.w16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: BaseSize.w40,
                      height: BaseSize.h4,
                      decoration: BoxDecoration(
                        color: BaseColor.neutral30,
                        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                      ),
                    ),
                  ),
                  Gap.h16,
                  // Location info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(BaseSize.w10),
                        decoration: BoxDecoration(
                          color: BaseColor.primary.shade50,
                          borderRadius: BorderRadius.circular(
                            BaseSize.radiusMd,
                          ),
                        ),
                        child: FaIcon(
                          AppIcons.mapPin,
                          size: BaseSize.w24,
                          color: BaseColor.primary3,
                        ),
                      ),
                      Gap.w12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lokasi Terpilih',
                              style: BaseTypography.labelSmall.copyWith(
                                color: BaseColor.neutral60,
                              ),
                            ),
                            Gap.h4,
                            Text(
                              _selectedLocation?.name ?? '-',
                              style: BaseTypography.titleMedium.toBold.copyWith(
                                color: BaseColor.neutral90,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap.h20,
                  // Confirm button
                  ButtonWidget.primary(
                    text: 'Konfirmasi Lokasi',
                    onTap: _confirmLocation,
                    isLoading: _isMapMoving,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      right: BaseSize.w12,
      bottom: BaseSize.customHeight(220),
      child: Column(
        children: [
          // Zoom in
          _MapIconButton(
            onTap: _zoomIn,
            child: FaIcon(
              AppIcons.add,
              size: BaseSize.w24,
              color: BaseColor.neutral80,
            ),
          ),
          Gap.h8,
          // Zoom out
          _MapIconButton(
            onTap: _zoomOut,
            child: FaIcon(
              AppIcons.remove,
              size: BaseSize.w24,
              color: BaseColor.neutral80,
            ),
          ),
          Gap.h16,
          // My location
          _MapIconButton(
            onTap: _isLoadingLocation ? () {} : _goToMyLocation,
            child: _isLoadingLocation
                ? SizedBox(
                    width: BaseSize.w22,
                    height: BaseSize.w22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: BaseColor.primary3,
                    ),
                  )
                : FaIcon(
                    AppIcons.gps,
                    size: BaseSize.w22,
                    color: BaseColor.primary3,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Custom icon button for map controls
class _MapIconButton extends StatelessWidget {
  const _MapIconButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BaseColor.white,
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      elevation: 2,
      shadowColor: BaseColor.shadow.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        child: Container(
          width: BaseSize.w48,
          height: BaseSize.w48,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

/// Custom painter for the pin pointer triangle
class _PinPointerPainter extends CustomPainter {
  _PinPointerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
