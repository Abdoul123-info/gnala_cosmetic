import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Récupérer la collection des favoris de l'utilisateur
  CollectionReference _getFavoritesCollection() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    return _firestore.collection('users').doc(user.uid).collection('favorites');
  }

  // Vérifier si un produit est dans les favoris
  Future<bool> isFavorite(String productId) async {
    try {
      final doc = await _getFavoritesCollection().doc(productId).get();
      return doc.exists;
    } catch (e) {
      print('Erreur vérification favori: $e');
      return false;
    }
  }

  // Stream pour écouter les changements de favoris
  Stream<List<String>> getFavoriteIds() {
    try {
      return _getFavoritesCollection().snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      print('Erreur stream favoris: $e');
      return Stream.value([]);
    }
  }

  // Récupérer tous les produits favoris
  Stream<List<Product>> getFavoriteProducts() {
    try {
      return getFavoriteIds().asyncMap((favoriteIds) async {
        if (favoriteIds.isEmpty) return [];

        // Récupérer les produits depuis Firestore
        final productsSnapshot = await _firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: favoriteIds)
            .get();

        return productsSnapshot.docs
            .map((doc) => Product.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Erreur récupération produits favoris: $e');
      return Stream.value([]);
    }
  }

  // Ajouter un produit aux favoris
  Future<void> addFavorite(String productId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      await _getFavoritesCollection().doc(productId).set({
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur ajout favori: $e');
      rethrow;
    }
  }

  // Retirer un produit des favoris
  Future<void> removeFavorite(String productId) async {
    try {
      await _getFavoritesCollection().doc(productId).delete();
    } catch (e) {
      print('Erreur suppression favori: $e');
      rethrow;
    }
  }

  // Toggle favori (ajouter si absent, retirer si présent)
  Future<void> toggleFavorite(String productId) async {
    try {
      final isFav = await isFavorite(productId);
      if (isFav) {
        await removeFavorite(productId);
      } else {
        await addFavorite(productId);
      }
    } catch (e) {
      print('Erreur toggle favori: $e');
      rethrow;
    }
  }
}

