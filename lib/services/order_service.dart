import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_history.dart';
import '../providers/cart_provider.dart';
import '../config/server_config.dart';
import 'local_order_storage.dart';

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
        
        // Sauvegarder la nouvelle commande dans le cache local
        // Ne pas réinitialiser le flag - si l'historique a été supprimé, on ajoute seulement la nouvelle commande
        try {
          // Récupérer l'ID de la commande depuis la réponse du serveur
          String orderId = DateTime.now().millisecondsSinceEpoch.toString();
          try {
            final responseBody = jsonDecode(response.body);
            if (responseBody is Map<String, dynamic>) {
              orderId = responseBody['orderId']?.toString() ?? orderId;
            }
          } catch (e) {
            print('⚠️ Erreur parsing réponse serveur pour orderId: $e');
          }
          
          final newOrder = OrderHistoryEntry(
            id: orderId,
            status: 'pending',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            totalPrice: cart.totalPrice,
            totalItems: cart.totalItems,
            address: address,
            zone: zone,
            deliveryType: deliveryType,
            products: cart.items.map((item) => OrderHistoryProduct(
              productId: item.product.id,
              name: item.product.name,
              quantity: item.quantity,
              price: item.product.price,
              totalPrice: item.totalPrice,
            )).toList(),
          );
          
          // Charger les commandes existantes (sera vide si l'historique a été supprimé)
          final existingOrders = await LocalOrderStorage.loadOrders();
          existingOrders.insert(0, newOrder); // Ajouter en premier
          
          // Sauvegarder en forçant l'écriture même si le flag est activé (pour la nouvelle commande uniquement)
          await LocalOrderStorage.saveOrders(existingOrders, forceSave: true);
          print('💾 Nouvelle commande sauvegardée dans le cache local');
        } catch (e) {
          print('⚠️ Erreur sauvegarde locale nouvelle commande: $e');
          // Ne pas faire échouer l'opération si la sauvegarde locale échoue
        }
        
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

  Future<List<OrderHistoryEntry>> fetchOrderHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Vérifier si l'utilisateur a choisi de vider l'historique
      final isHistoryCleared = await LocalOrderStorage.isHistoryCleared();
      print('🔍 Vérification flag historique vidé: $isHistoryCleared');
      if (isHistoryCleared) {
        print('📦 Historique vidé par l\'utilisateur - pas de récupération depuis le serveur');
        return []; // Retourner une liste vide si l'historique a été vidé
      }
      print('✅ Flag historique non vidé - récupération depuis le serveur autorisée');

      String? idToken;
      try {
        idToken = await user.getIdToken();
      } catch (e) {
        print('❌ Erreur récupération token: $e');
        throw Exception('Impossible de récupérer le token utilisateur');
      }

      final uri = Uri.parse('${ServerConfig.baseUrl}/api/my-orders');
      print('📡 Récupération historique → $uri');
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      };

      http.Response response;
      try {
        response = await http.get(uri, headers: headers).timeout(
              const Duration(seconds: 30),
            );
      } catch (e) {
        print('❌ Erreur réseau/timeout: $e');
        if (e.toString().contains('timeout') || e.toString().contains('TimeoutException')) {
          throw Exception('Le serveur met trop de temps à répondre. Vérifiez votre connexion.');
        }
        if (e.toString().contains('Failed host lookup') || e.toString().contains('SocketException')) {
          throw Exception('Impossible de se connecter au serveur. Vérifiez votre connexion internet.');
        }
        throw Exception('Erreur de connexion: ${e.toString()}');
      }

      print('📥 Réponse status: ${response.statusCode}');
      if (response.body.isNotEmpty) {
        final preview = response.body.length > 200 ? response.body.substring(0, 200) : response.body;
        print('📥 Réponse body: $preview');
      } else {
        print('📥 Réponse body: (vide)');
      }

      if (response.statusCode == 200) {
        try {
          final body = jsonDecode(response.body);
          if (body is List) {
            final serverOrders = body
                .map((order) {
                  try {
                    return OrderHistoryEntry.fromJson(Map<String, dynamic>.from(order));
                  } catch (e) {
                    print('⚠️ Erreur parsing commande: $e');
                    print('⚠️ Données commande: $order');
                    return null;
                  }
                })
                .where((order) => order != null)
                .cast<OrderHistoryEntry>()
                .toList();
            
            print('✅ ${serverOrders.length} commande(s) chargée(s) depuis le serveur');
            
            // Vérifier à nouveau si l'historique a été vidé (au cas où il aurait été vidé pendant la requête)
            final isHistoryCleared = await LocalOrderStorage.isHistoryCleared();
            if (isHistoryCleared) {
              print('📦 Historique vidé par l\'utilisateur - pas de sauvegarde des commandes du serveur');
              return []; // Retourner une liste vide si l'historique a été vidé
            }
            
            // Sauvegarder les commandes du serveur dans le cache local
            await LocalOrderStorage.saveOrders(serverOrders);
            
            // Charger les commandes du cache local
            final localOrders = await LocalOrderStorage.loadOrders();
            
            // Fusionner les commandes du serveur avec celles du cache
            // Les commandes supprimées du serveur resteront dans le cache
            final mergedOrders = LocalOrderStorage.mergeOrders(serverOrders, localOrders);
            
            // Sauvegarder la liste fusionnée pour la prochaine fois
            await LocalOrderStorage.saveOrders(mergedOrders);
            
            return mergedOrders;
          }
          throw Exception('Format de données inattendu: attendu une liste, reçu ${body.runtimeType}');
        } catch (e) {
          print('❌ Erreur parsing JSON: $e');
          throw Exception('Erreur lors du traitement des données: ${e.toString()}');
        }
      } else {
        String message = 'Erreur lors de la récupération de l\'historique (code ${response.statusCode})';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['message'] is String) {
            message = body['message'] as String;
          } else if (body is Map && body['error'] is String) {
            message = body['error'] as String;
          }
        } catch (_) {
          // Si le body n'est pas du JSON valide, utiliser le message par défaut
        }
        print('❌ Erreur serveur: $message');
        throw Exception(message);
      }
    } catch (e) {
      print('❌ Erreur fetchOrderHistory: $e');
      
      // Vérifier si l'historique a été vidé avant de charger depuis le cache
      final isHistoryCleared = await LocalOrderStorage.isHistoryCleared();
      if (isHistoryCleared) {
        print('📦 Historique vidé par l\'utilisateur - pas de chargement depuis le cache');
        return []; // Retourner une liste vide si l'historique a été vidé
      }
      
      // En cas d'erreur, essayer de charger depuis le cache local
      print('🔄 Tentative de chargement depuis le cache local...');
      try {
        final localOrders = await LocalOrderStorage.loadOrders();
        if (localOrders.isNotEmpty) {
          print('✅ ${localOrders.length} commande(s) chargée(s) depuis le cache local (mode hors ligne)');
          return localOrders;
        }
      } catch (cacheError) {
        print('❌ Erreur chargement cache: $cacheError');
      }
      
      // Si le cache est vide aussi, relancer l'erreur originale
      rethrow;
    }
  }
}

