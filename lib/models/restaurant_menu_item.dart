class RestaurantMenuItem {
  final int itemId;
  final String itemName;
  final double itemPrice;
  final String itemImageUrl;
  final String itemDescription;
  final String itemDietaryDetails;

  RestaurantMenuItem({
    required this.itemId,
    required this.itemName,
    required this.itemPrice,
    required this.itemImageUrl,
    required this.itemDescription,
    required this.itemDietaryDetails,
  });

  // Factory method to create a RestaurantMenuItem object from a JSON map
  factory RestaurantMenuItem.fromJson(Map<String, dynamic> json) {
    return RestaurantMenuItem(
      itemId: json['itemId'],
      itemName: json['itemName'],
      itemPrice: json['itemPrice'].toDouble(),
      itemImageUrl: json['itemImageUrl'],
      itemDescription: json['itemDescription'],
      itemDietaryDetails: json['itemDietaryDetails'],
    );
  }

  // Method to convert a RestaurantMenuItem object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'itemPrice': itemPrice,
      'itemImageUrl': itemImageUrl,
      'itemDescription': itemDescription,
      'itemDietaryDetails': itemDietaryDetails,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RestaurantMenuItem && other.itemId == itemId;
  }
}

List<RestaurantMenuItem> getMenuItems() {
  // Common dishes in Cameroon and Nigeria
  final menuItemsJson = [
    {
      "itemId": 1,
      "itemName": "Kwacoco",
      "itemPrice": 30.262986935831023,
      "itemImageUrl":
          "https://img.restaurantguru.com/c6a0-Restaurant-Yvettes-237-Kitchen-food.jpg",
      "itemDescription": "Delicious dish from Cameroon",
      "itemDietaryDetails": "Contains meat, fish, and vegetables"
    },
    {
      "itemId": 2,
      "itemName": "Sanga",
      "itemPrice": 23.195719017390147,
      "itemImageUrl":
          "https://img.restaurantguru.com/c6a0-Restaurant-Yvettes-237-Kitchen-food.jpg",
      "itemDescription": "Delicious dish from Cameroon",
      "itemDietaryDetails": "Contains meat, fish, and vegetables"
    },
    {
      "itemId": 3,
      "itemName": "Kwacoco",
      "itemPrice": 27.4333015212774116,
      "itemImageUrl":
          "https://img.restaurantguru.com/c6a0-Restaurant-Yvettes-237-Kitchen-food.jpg",
      "itemDescription": "Delicious dish from Cameroon",
      "itemDietaryDetails": "Contains meat, fish, and vegetables"
    },
    {
      "itemId": 4,
      "itemName": "Afang Soup",
      "itemPrice": 16.103416744391712,
      "itemImageUrl":
          "https://img.restaurantguru.com/c6a0-Restaurant-Yvettes-237-Kitchen-food.jpg",
      "itemDescription": "Delicious dish from Cameroon",
      "itemDietaryDetails": "Contains meat, fish, and vegetables"
    },
    {
      "itemId": 5,
      "itemName": "Sanga",
      "itemPrice": 21.19768015491924,
      "itemImageUrl":
          "https://img.restaurantguru.com/c6a0-Restaurant-Yvettes-237-Kitchen-food.jpg",
      "itemDescription": "Delicious dish from Cameroon",
      "itemDietaryDetails": "Contains meat, fish, and vegetables"
    },
    {
      "itemId": 6,
      "itemName": "Pounded Yam",
      "itemPrice": 37.79152132329663,
      "itemImageUrl":
          "https://img.restaurantguru.com/c6a0-Restaurant-Yvettes-237-Kitchen-food.jpg",
      "itemDescription": "Tasty dish from Nigeria",
      "itemDietaryDetails": "Contains various ingredients"
    },
    {
      "itemId": 7,
      "itemName": "Mbanga Soup",
      "itemPrice": 30.881704169049492,
      "itemImageUrl":
          "https://img.restaurantguru.com/c6a0-Restaurant-Yvettes-237-Kitchen-food.jpg",
      "itemDescription": "Delicious dish from Cameroon",
      "itemDietaryDetails": "Contains meat, fish, and vegetables"
    }
  ];

  // Convert restaurant menu items to JSON
  return menuItemsJson
      .map((json) => RestaurantMenuItem.fromJson(json))
      .toList();
}
