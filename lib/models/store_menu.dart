import 'package:hive_flutter/adapters.dart';

part 'store_menu.g.dart';

@HiveType(typeId: 10)
class StoreMenuItem {
  @HiveField(1)
  late int itemId;
  @HiveField(2)
  late String itemName;
  @HiveField(3)
  late String itemDescription;
  @HiveField(4)
  late double itemPrice;
  @HiveField(5)
  late String image;
  @HiveField(6)
  late num storeId;
  @HiveField(7)
  late int isInStock;
  @HiveField(8)
  late int quantityInStock;
  @HiveField(9)
  late double deliveryPrice;
  StoreMenuItem(
      {required this.itemId,
      required this.itemName,
      required this.itemDescription,
      required this.itemPrice,
      required this.image,
      required this.storeId,
      required this.isInStock,
      required this.quantityInStock,
      required this.deliveryPrice});

  factory StoreMenuItem.fromMap(Map<String, dynamic> json) => StoreMenuItem(
      itemId: json['itemId'] as int,
      itemName: json['itemName'] as String,
      itemDescription: json['itemDescription'] as String,
      itemPrice: json['itemPrice'] as double,
      deliveryPrice: (json['deliveryPrice'] ?? 0.0) as double,
      image: json['image'] as String,
      storeId: json['storeId'] as int,
      isInStock: json['isInStock'] as int,
      quantityInStock: json['quantityInStock'] as int);
  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'itemName': itemName,
        'itemDescription': itemDescription,
        'itemPrice': itemPrice,
        'image': image,
        'storeId': storeId,
        'isInStock': isInStock,
        'quantityInStock': quantityInStock
      };
  bool hasInventory() => isInStock > 0 && quantityInStock > 0;
}
