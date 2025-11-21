class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category; // Visage, Corps, Cheveux, Nouveautés, Homme, Maquillage, Parfum, Promotions / Meilleures ventes
  final bool isRecommended; // Produit recommandé
  final bool isNew; // Marqué comme nouveauté
  final bool isPromotion; // Promotions / Meilleures ventes
  final bool isAvailable; // Disponibilité du produit
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.category = 'Nouveautés',
    this.isRecommended = false,
    this.isNew = false,
    this.isPromotion = false,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Constructeur pour créer un produit depuis Firestore
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'Nouveautés',
      isRecommended: data['isRecommended'] ?? false,
      isNew: data['isNew'] ?? false,
      isPromotion: data['isPromotion'] ?? false,
      isAvailable: data['isAvailable'] ?? true,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Méthode pour convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isRecommended': isRecommended,
      'isNew': isNew,
      'isPromotion': isPromotion,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Méthode pour créer une copie avec des modifications
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isRecommended,
    bool? isNew,
    bool? isPromotion,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isRecommended: isRecommended ?? this.isRecommended,
      isNew: isNew ?? this.isNew,
      isPromotion: isPromotion ?? this.isPromotion,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, description: $description, price: $price, imageUrl: $imageUrl}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}



