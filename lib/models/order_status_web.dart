// ignore_for_file: constant_identifier_names

class OrderStatusWeb {
  static const String ORDER_PLACED = 'Order Placed';
  static const String ORDER_ACCEPTED = 'Order Accepted';
  static const String ORDER_CANCELLED = 'Order Cancelled';
  static const String READY_FOR_PICKUP = 'Ready for Pickup';
  static const String ORDER_DELIVERED = 'Order Delivered';

  static List<String> get values => [
        ORDER_PLACED,
        ORDER_ACCEPTED,
        ORDER_CANCELLED,
        READY_FOR_PICKUP,
        ORDER_DELIVERED,
      ];
}
