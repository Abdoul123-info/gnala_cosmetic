import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_history.dart';

/// Service pour stocker les commandes localement
/// Permet de conserver l'historique même si les commandes sont supprimées du serveur
class LocalOrderStorage {
  static const String _ordersKeyPrefix = 'cached_orders_';
  static const String _historyClearedKeyPrefix = 'history_cleared_';

  /// Récupère la clé de stockage pour l'utilisateur actuel
  static String _getStorageKey() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    return '$_ordersKeyPrefix${user.uid}';
  }

  /// Récupère la clé pour le flag de suppression d'historique
  static String _getHistoryClearedKey() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    return '$_historyClearedKeyPrefix${user.uid}';
  }

  /// Récupère la clé pour le timestamp de suppression d'historique (plus fiable)
  static String _getHistoryClearedTimestampKey() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }
    return '${_historyClearedKeyPrefix}timestamp_${user.uid}';
  }

  /// Sauvegarde les commandes localement
  static Future<void> saveOrders(List<OrderHistoryEntry> orders) async {
    try {
      // Vérifier si l'historique a été vidé - ne pas sauvegarder si c'est le cas
      final isCleared = await isHistoryCleared();
      if (isCleared) {
        print('🚫 Historique vidé - sauvegarde des commandes annulée');
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey();
      
      // Convertir les commandes en JSON
      final ordersJson = orders.map((order) => {
        'id': order.id,
        'status': order.status,
        'createdAt': order.createdAt?.toIso8601String(),
        'updatedAt': order.updatedAt?.toIso8601String(),
        'totalPrice': order.totalPrice,
        'totalItems': order.totalItems,
        'address': order.address,
        'zone': order.zone,
        'deliveryType': order.deliveryType,
        'items': order.products.map((product) => {
          'productId': product.productId,
          'productName': product.name,
          'quantity': product.quantity,
          'price': product.price,
          'totalPrice': product.totalPrice,
        }).toList(),
      }).toList();
      
      final jsonString = jsonEncode(ordersJson);
      await prefs.setString(key, jsonString);
      print('💾 ${orders.length} commande(s) sauvegardée(s) localement');
    } catch (e) {
      print('❌ Erreur sauvegarde locale: $e');
      // Ne pas faire échouer l'opération si la sauvegarde locale échoue
    }
  }

  /// Charge les commandes depuis le stockage local
  static Future<List<OrderHistoryEntry>> loadOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey();
      
      final jsonString = prefs.getString(key);
      if (jsonString == null || jsonString.isEmpty) {
        print('📦 Aucune commande en cache');
        return [];
      }
      
      final ordersJson = jsonDecode(jsonString) as List<dynamic>;
      final orders = ordersJson
          .map((order) {
            try {
              return OrderHistoryEntry.fromJson(Map<String, dynamic>.from(order));
            } catch (e) {
              print('⚠️ Erreur parsing commande locale: $e');
              return null;
            }
          })
          .where((order) => order != null)
          .cast<OrderHistoryEntry>()
          .toList();
      
      print('📦 ${orders.length} commande(s) chargée(s) depuis le cache local');
      return orders;
    } catch (e) {
      print('❌ Erreur chargement local: $e');
      return [];
    }
  }

  /// Fusionne les commandes du serveur avec celles du cache local
  /// Les commandes du serveur ont la priorité (statuts à jour)
  /// Les commandes supprimées du serveur restent dans le cache
  static List<OrderHistoryEntry> mergeOrders(
    List<OrderHistoryEntry> serverOrders,
    List<OrderHistoryEntry> localOrders,
  ) {
    // Créer un Map des commandes du serveur par ID pour un accès rapide
    final serverOrdersMap = {
      for (var order in serverOrders) order.id: order
    };
    
    // Commencer avec les commandes du serveur (priorité)
    final merged = <String, OrderHistoryEntry>{};
    merged.addAll(serverOrdersMap);
    
    // Ajouter les commandes locales qui n'existent pas sur le serveur
    for (var localOrder in localOrders) {
      if (!merged.containsKey(localOrder.id)) {
        merged[localOrder.id] = localOrder;
        print('📦 Commande locale ajoutée (supprimée du serveur): ${localOrder.id}');
      }
    }
    
    // Trier par date de création (plus récent en premier)
    final sortedOrders = merged.values.toList()
      ..sort((a, b) {
        final dateA = a.createdAt ?? a.updatedAt;
        final dateB = b.createdAt ?? b.updatedAt;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });
    
    print('🔄 Fusion: ${serverOrders.length} serveur + ${localOrders.length} local = ${sortedOrders.length} total');
    return sortedOrders;
  }

  /// Supprime toutes les commandes en cache pour l'utilisateur actuel
  /// Marque également que l'historique a été vidé pour éviter la récupération automatique
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey();
      final clearedKey = _getHistoryClearedKey();
      
      print('🗑️ Début suppression cache: clé=$key, flagKey=$clearedKey');
      
      // Supprimer le cache des commandes
      await prefs.remove(key);
      print('✅ Cache des commandes supprimé');
      
      // Sauvegarder le flag booléen (ancienne méthode)
      final savedBool = await prefs.setBool(clearedKey, true);
      print('🔍 Tentative sauvegarde flag booléen: $savedBool');
      
      // Sauvegarder le timestamp (nouvelle méthode plus fiable)
      final timestamp = DateTime.now().toIso8601String();
      final timestampKey = _getHistoryClearedTimestampKey();
      final savedTimestamp = await prefs.setString(timestampKey, timestamp);
      print('🔍 Tentative sauvegarde flag timestamp: $savedTimestamp, valeur=$timestamp');
      
      // Vérifier immédiatement après sauvegarde
      final verifyBool = prefs.getBool(clearedKey);
      final verifyTimestamp = prefs.getString(timestampKey);
      print('🔍 Vérification immédiate: bool=$verifyBool, timestamp=$verifyTimestamp');
      
      // Attendre un peu et revérifier (pour le web)
      await Future.delayed(const Duration(milliseconds: 200));
      final verifyBool2 = prefs.getBool(clearedKey);
      final verifyTimestamp2 = prefs.getString(timestampKey);
      print('🔍 Vérification après délai: bool=$verifyBool2, timestamp=$verifyTimestamp2');
      
      // Si aucun des deux n'a été sauvegardé, essayer une dernière fois
      if ((verifyBool2 != true) && (verifyTimestamp2 == null || verifyTimestamp2.isEmpty)) {
        print('⚠️ ATTENTION: Flags non persistés, nouvelle tentative...');
        try {
          await prefs.setBool(clearedKey, true);
          await prefs.setString(timestampKey, timestamp);
          await Future.delayed(const Duration(milliseconds: 100));
          final finalBool = prefs.getBool(clearedKey);
          final finalTimestamp = prefs.getString(timestampKey);
          print('🔍 Tentative finale: bool=$finalBool, timestamp=$finalTimestamp');
        } catch (retryError) {
          print('❌ Erreur lors de la tentative de réessai: $retryError');
        }
      }
      
      if (!savedBool && !savedTimestamp) {
        print('⚠️ ATTENTION: Aucun flag n\'a pu être sauvegardé initialement!');
      }
      
      print('🗑️ Cache local supprimé et flag de suppression activé');
      print('🔍 Flags sauvegardés: bool=$savedBool, timestamp=$savedTimestamp');
    } catch (e) {
      print('❌ Erreur suppression cache: $e');
      rethrow; // Relancer l'erreur pour que l'utilisateur soit informé
    }
  }

  /// Vérifie si l'utilisateur a choisi de vider l'historique
  static Future<bool> isHistoryCleared() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clearedKey = _getHistoryClearedKey();
      final timestampKey = _getHistoryClearedTimestampKey();
      
      // Vérifier le booléen (ancienne méthode)
      final isClearedBool = prefs.getBool(clearedKey) ?? false;
      
      // Vérifier le timestamp (nouvelle méthode plus fiable)
      final clearedTimestamp = prefs.getString(timestampKey);
      final isClearedTimestamp = clearedTimestamp != null && clearedTimestamp.isNotEmpty;
      
      // Utiliser les deux méthodes pour plus de fiabilité
      final isCleared = isClearedBool || isClearedTimestamp;
      
      print('🔍 Lecture flag historique vidé: bool=$isClearedBool, timestamp=$isClearedTimestamp, final=$isCleared');
      print('🔍 Clés: boolKey=$clearedKey, timestampKey=$timestampKey');
      
      return isCleared;
    } catch (e) {
      print('❌ Erreur vérification flag suppression: $e');
      return false;
    }
  }

  /// Réinitialise le flag de suppression (appelé quand une nouvelle commande est passée)
  static Future<void> resetHistoryClearedFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clearedKey = _getHistoryClearedKey();
      final timestampKey = _getHistoryClearedTimestampKey();
      
      // Supprimer les deux flags
      await prefs.remove(clearedKey);
      await prefs.remove(timestampKey);
      print('🔄 Flags de suppression réinitialisés (bool et timestamp)');
    } catch (e) {
      print('❌ Erreur réinitialisation flag: $e');
    }
  }
}

