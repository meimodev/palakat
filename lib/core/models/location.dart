class Location {
  final double latitude;
  final double longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() {
    return 'Location{latitude: $latitude, longitude: $longitude}';
  }
}
