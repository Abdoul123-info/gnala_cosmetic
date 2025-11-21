import 'cart_item.dart';

class Cart {
  final List<CartItem> items;

  Cart({required this.items});

  // Nombre total d'articles dans le panier
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Prix total du panier
  double get totalPrice {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Vérifier si le panier est vide
  bool get isEmpty => items.isEmpty;

  // Vérifier si le panier n'est pas vide
  bool get isNotEmpty => items.isNotEmpty;

  // Obtenir un item par produit
  CartItem? getItemByProductId(String productId) {
    try {
      return items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Créer une copie avec des modifications
  Cart copyWith({List<CartItem>? items}) {
    return Cart(items: items ?? this.items);
  }

  @override
  String toString() {
    return 'Cart{items: ${items.length}, totalItems: $totalItems, totalPrice: $totalPrice}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cart && 
           other.items.length == items.length &&
           _listEquals(other.items, items);
  }

  @override
  int get hashCode => items.hashCode;

  // Fonction helper pour comparer les listes
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}






