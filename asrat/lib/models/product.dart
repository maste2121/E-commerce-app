class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final double? oldPrice;
  final String imagUrl;
  final bool isFavorite;
  final String description;
  final int stock;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.oldPrice,
    required this.imagUrl,
    this.isFavorite = false,
    required this.description,
    this.stock = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    double? oldPrice,
    String? imagUrl,
    String? category,
    bool? isFavorite,
    int? stock,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      imagUrl: imagUrl ?? this.imagUrl,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      oldPrice:
          json['oldPrice'] != null
              ? double.tryParse(json['oldPrice'].toString())
              : null,
      imagUrl:
          json['imagUrl'] != null
              ? 'http://10.0.2.2:8080/${json['imagUrl'].replaceAll("\\", "/")}'
              : '',
      isFavorite: (json['isFavorite'] ?? 0) == 1,
      category: json['category'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'oldPrice': oldPrice,
      'imagUrl': imagUrl,
      'isFavorite': isFavorite ? 1 : 0,
      'description': description,
      'stock': stock,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
