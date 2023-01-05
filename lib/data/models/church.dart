class Church {
  final String id;
  final String name;
  final String location;

  Church({
    required this.id,
    required this.name,
    required this.location,
  });

  @override
  String toString() {
    return 'Church{id: $id, name: $name, location: $location}';
  }
}