import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  // Getter pour accéder aux items
  List<CartItem> get items => List.unmodifiable(_items);

  // Nombre total d'articles dans le panier
  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Prix total du panier
  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Vérifier si le panier est vide
  bool get isEmpty => _items.isEmpty;

  // Vérifier si le panier n'est pas vide
  bool get isNotEmpty => _items.isNotEmpty;

  // Obtenir la quantité d'un produit dans le panier
  int getProductQuantity(String productId) {
    final item = _items.where((item) => item.product.id == productId).firstOrNull;
    return item?.quantity ?? 0;
  }

  // Vérifier si un produit est dans le panier
  bool isProductInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // Ajouter un produit au panier
  void addItem(Product product, {int quantity = 1}) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingItemIndex != -1) {
      // Le produit existe déjà, augmenter la quantité
      _items[existingItemIndex].quantity += quantity;
    } else {
      // Nouveau produit, l'ajouter au panier
      _items.add(CartItem(product: product, quantity: quantity));
    }

    notifyListeners();
  }

  // Supprimer un produit du panier
  void removeItem(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  // Supprimer un produit par ID
  void removeItemById(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // Modifier la quantité d'un produit
  void updateQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      removeItem(product);
      return;
    }

    final existingItemIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingItemIndex != -1) {
      _items[existingItemIndex].quantity = quantity;
      notifyListeners();
    }
  }

  // Modifier la quantité par ID
  void updateQuantityById(String productId, int quantity) {
    if (quantity <= 0) {
      removeItemById(productId);
      return;
    }

    final existingItemIndex = _items.indexWhere(
      (item) => item.product.id == productId,
    );

    if (existingItemIndex != -1) {
      _items[existingItemIndex].quantity = quantity;
      notifyListeners();
    }
  }

  // Augmenter la quantité d'un produit
  void incrementQuantity(Product product) {
    addItem(product, quantity: 1);
  }

  // Diminuer la quantité d'un produit
  void decrementQuantity(Product product) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingItemIndex != -1) {
      if (_items[existingItemIndex].quantity > 1) {
        _items[existingItemIndex].quantity--;
      } else {
        _items.removeAt(existingItemIndex);
      }
      notifyListeners();
    }
  }

  // Vider le panier
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Obtenir un item par produit
  CartItem? getItemByProduct(Product product) {
    try {
      return _items.firstWhere((item) => item.product.id == product.id);
    } catch (e) {
      return null;
    }
  }

  // Obtenir un item par ID
  CartItem? getItemById(String productId) {
    try {
      return _items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Calculer le nombre d'articles uniques
  int get uniqueItemsCount => _items.length;

  // Obtenir un résumé du panier
  Map<String, dynamic> get cartSummary => {
    'totalItems': totalItems,
    'uniqueItems': uniqueItemsCount,
    'totalPrice': totalPrice,
    'isEmpty': isEmpty,
  };

  // Méthode pour déboguer (commentée pour la production)
  void printCart() {
    // print('=== PANIER ===');
    // for (var item in _items) {
    //   print('${item.product.name} x${item.quantity} = ${item.totalPrice} FCFA');
    // }
    // print('Total: $totalPrice FCFA');
    // print('==============');
  }
}
