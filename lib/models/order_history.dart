class OrderHistoryProduct {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final double totalPrice;

  OrderHistoryProduct({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  factory OrderHistoryProduct.fromJson(Map<String, dynamic> json) {
    return OrderHistoryProduct(
      productId: (json['productId'] ?? '').toString(),
      name: (json['productName'] ?? '').toString(),
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity'].toString()) ?? 0,
      price: _toDouble(json['price']),
      totalPrice: _toDouble(json['totalPrice']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}

class OrderHistoryEntry {
  final String id;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double totalPrice;
  final int totalItems;
  final String address;
  final String zone;
  final String deliveryType;
  final List<OrderHistoryProduct> products;

  OrderHistoryEntry({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.totalPrice,
    required this.totalItems,
    required this.address,
    required this.zone,
    required this.deliveryType,
    required this.products,
  });

  factory OrderHistoryEntry.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? []);
    final items = rawItems.map((item) {
      if (item is OrderHistoryProduct) return item;
      final map = item is Map<String, dynamic>
          ? item
          : Map<String, dynamic>.from(item as Map);
      return OrderHistoryProduct.fromJson(map);
    }).toList();

    return OrderHistoryEntry(
      id: (json['id'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      createdAt: _parseDate(json['createdAt'] ?? json['receivedAt']),
      updatedAt: _parseDate(json['updatedAt']),
      totalPrice: OrderHistoryProduct._toDouble(json['totalPrice']),
      totalItems: json['totalItems'] is int
          ? json['totalItems'] as int
          : int.tryParse(json['totalItems']?.toString() ?? '') ?? items.length,
      address: (json['address'] ?? '').toString(),
      zone: (json['zone'] ?? '').toString(),
      deliveryType: (json['deliveryType'] ?? 'simple').toString(),
      products: items,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) {
      return value.toLocal();
    }
    return DateTime.tryParse(value.toString());
  }
}

