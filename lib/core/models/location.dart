class Location {
  final double latitude;
  final double longitude;
  final String name;

  Location({
    required this.latitude,
    required this.longitude,
    this.name = "",
  });

  @override
  String toString() {
    return 'Location{latitude: $latitude, longitude: $longitude, name: $name}';
  }
}
