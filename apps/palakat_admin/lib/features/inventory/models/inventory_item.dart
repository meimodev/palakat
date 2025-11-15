import 'package:palakat_admin/constants.dart';

class InventoryItem {
  final String itemName;
  final String location;
  final InventoryCondition condition;
  final int quantity;
  final DateTime lastUpdate;
  final String updatedBy;

  const InventoryItem({
    required this.itemName,
    required this.location,
    required this.condition,
    required this.quantity,
    required this.lastUpdate,
    required this.updatedBy,
  });
}
