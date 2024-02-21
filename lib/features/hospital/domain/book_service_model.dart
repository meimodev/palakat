// TODO for slicing purposes only
class BookServiceModel {
  String category;
  String name;
  String locations;
  String price;
  String? discountPrice;

  BookServiceModel({
    required this.category,
    required this.name,
    required this.locations,
    required this.price,
    this.discountPrice,
  });

  @override
  String toString() {
    return 'BookServiceModel{category: $category, name: $name, locations: $locations, price: $price, discountPrice: $discountPrice}';
  }
}
