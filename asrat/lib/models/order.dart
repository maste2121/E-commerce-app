class Order {
  final int id;
  final int? customerId;
  final String customerName;
  final int productId;
  final String productName;
  final double productPrice;
  final int quantity;
  final double totalPrice;
  String status;
  final String orderDate;

  Order({
    required this.id,
    this.customerId,
    required this.customerName,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.orderDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Safe parsing
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    final productPrice = parseDouble(json['product_price']);
    final quantity = parseInt(json['quantity']);
    final totalPrice =
        json['total_price'] != null
            ? parseDouble(json['total_price'])
            : productPrice * quantity;

    return Order(
      id: parseInt(json['id']),
      customerId:
          json['customer_id'] != null ? parseInt(json['customer_id']) : null,
      customerName: json['customer_name']?.toString() ?? '',
      productId: parseInt(json['product_id']),
      productName: json['product_name']?.toString() ?? '',
      productPrice: productPrice,
      quantity: quantity,
      totalPrice: totalPrice,
      status: json['status']?.toString() ?? '',
      orderDate: json['order_date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_name': customerName,
      'product_id': productId,
      'product_name': productName,
      'product_price': productPrice,
      'quantity': quantity,
      'total_price': totalPrice,
      'status': status,
      'order_date': orderDate,
    };
  }
}
