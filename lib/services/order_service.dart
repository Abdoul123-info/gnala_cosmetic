import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/cart_provider.dart';
import '../config/server_config.dart';

class OrderService {
  // URL du serveur order_site (détection automatique selon la plateforme)
  static String get orderSiteUrl => ServerConfig.ordersApiUrl;

  Future<bool> submitOrder({
    required CartProvider cart,
    required String address,
    required String zone,
    required String deliveryType,
  }) async {
    try {
      // Récupérer les informations de l'utilisateur connecté
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      String userName = 'Utilisateur';
      String userPhone = '';
      String userEmail = user.email ?? '';

      // Récupérer les données utilisateur depuis Firestore
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          userName = userDoc.get('name') ?? 'Utilisateur';
          userPhone = userDoc.get('phone') ?? user.email ?? '';
        } else {
          userName = 'Utilisateur';
          userPhone = user.email ?? '';
        }
      } catch (e) {
        print('Erreur lors de la récupération des données utilisateur: $e');
        // Continuer avec les valeurs par défaut
      }

      final orderData = {
        'userId': user.uid,
        'userName': userName,
        'userPhone': userPhone,
        'userEmail': userEmail,
        'address': address,
        'zone': zone,
        'deliveryType': deliveryType,
        'items': cart.items.map((item) => {
              'productId': item.product.id,
              'productName': item.product.name,
              'quantity': item.quantity,
              'price': item.product.price,
              'totalPrice': item.totalPrice,
            }).toList(),
        'totalItems': cart.totalItems,
        'totalPrice': cart.totalPrice,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Envoyer la requête vers order_site (avec timeout + retries pour cold start Render)
      final uri = Uri.parse(orderSiteUrl);
      const int maxAttempts = 3;
      const Duration timeoutPerAttempt = Duration(seconds: 30);
      Duration backoff = const Duration(seconds: 1);

      // Récupérer le token Firebase pour l'authentification
      String? idToken;
      try {
        idToken = await user.getIdToken();
      } catch (e) {
        print('Erreur lors de la récupération du token Firebase: $e');
        throw Exception('Impossible de récupérer le token d\'authentification');
      }

      // Préparer les headers avec le token d'authentification
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      };

      http.Response response = http.Response('', 599);
      for (int attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          print('Envoi commande → ${uri.toString()} (tentative $attempt/$maxAttempts)');
          response = await http
              .post(
                uri,
                headers: headers,
                body: jsonEncode(orderData),
              )
              .timeout(timeoutPerAttempt);
          break; // succès requête (même si status != 2xx, on sort la boucle et on gère plus bas)
        } catch (err) {
          print('Tentative $attempt échouée: $err');
          if (attempt == maxAttempts) rethrow;
          await Future.delayed(backoff);
          backoff *= 2;
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Commande envoyée avec succès à order_site');
        return true;
      } else {
        print('Erreur lors de l\'envoi de la commande à order_site: ${response.statusCode}');
        print('Réponse: ${response.body}');
        throw Exception('Échec de l\'envoi de la commande à order_site');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de la commande: $e');
      rethrow;
    }
  }
}

