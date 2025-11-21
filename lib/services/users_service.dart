import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/server_config.dart';

class UserStats {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool blocked;
  final int ordersCount;
  final int totalRevenue;
  final int deliveredOrdersCount;
  final int pendingOrdersCount;
  final int processingOrdersCount;
  final int confirmedOrdersCount;
  final int shippedOrdersCount;
  final String status;

  UserStats({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.blocked,
    required this.ordersCount,
    required this.totalRevenue,
    required this.deliveredOrdersCount,
    required this.pendingOrdersCount,
    required this.processingOrdersCount,
    required this.confirmedOrdersCount,
    required this.shippedOrdersCount,
    required this.status,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'user',
      blocked: json['blocked'] ?? false,
      ordersCount: json['ordersCount'] ?? 0,
      totalRevenue: json['totalRevenue'] ?? 0,
      deliveredOrdersCount: json['deliveredOrdersCount'] ?? 0,
      pendingOrdersCount: json['pendingOrdersCount'] ?? 0,
      processingOrdersCount: json['processingOrdersCount'] ?? 0,
      confirmedOrdersCount: json['confirmedOrdersCount'] ?? 0,
      shippedOrdersCount: json['shippedOrdersCount'] ?? 0,
      status: json['status'] ?? 'Aucune commande',
    );
  }
}

class UsersService {
  static String get baseUrl => ServerConfig.baseUrl;

  Future<List<UserStats>> fetchUsers() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      String? idToken;
      try {
        idToken = await user.getIdToken();
      } catch (e) {
        print('❌ Erreur récupération token: $e');
        throw Exception('Impossible de récupérer le token utilisateur');
      }

      final uri = Uri.parse('$baseUrl/api/users');
      print('📡 Récupération utilisateurs → $uri');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      };

      final response = await http.get(uri, headers: headers).timeout(
            const Duration(seconds: 30),
          );

      print('📥 Réponse status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map && body['success'] == true && body['users'] is List) {
          final users = (body['users'] as List)
              .map((user) => UserStats.fromJson(Map<String, dynamic>.from(user)))
              .toList();
          print('✅ ${users.length} utilisateur(s) chargé(s)');
          return users;
        } else {
          throw Exception('Format de réponse invalide');
        }
      } else if (response.statusCode == 401) {
        // Token expiré, essayer de le rafraîchir
        try {
          idToken = await user.getIdToken(true);
          final retryResponse = await http.get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
          ).timeout(const Duration(seconds: 30));

          if (retryResponse.statusCode == 200) {
            final body = jsonDecode(retryResponse.body);
            if (body is Map && body['success'] == true && body['users'] is List) {
              final users = (body['users'] as List)
                  .map((user) => UserStats.fromJson(Map<String, dynamic>.from(user)))
                  .toList();
              print('✅ ${users.length} utilisateur(s) chargé(s) (après refresh token)');
              return users;
            }
          }
        } catch (e) {
          print('❌ Erreur refresh token: $e');
        }
        throw Exception('Accès refusé. Vérifiez que vous êtes administrateur.');
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur récupération utilisateurs: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erreur lors de la récupération des utilisateurs: $e');
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      String? idToken;
      try {
        idToken = await user.getIdToken();
      } catch (e) {
        print('❌ Erreur récupération token: $e');
        throw Exception('Impossible de récupérer le token utilisateur');
      }

      final uri = Uri.parse('$baseUrl/api/users/$userId/block');
      print('🔒 Blocage utilisateur → $uri');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      };

      final response = await http.patch(uri, headers: headers).timeout(
            const Duration(seconds: 30),
          );

      print('📥 Réponse status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Utilisateur bloqué avec succès');
      } else if (response.statusCode == 401) {
        // Token expiré, essayer de le rafraîchir
        try {
          idToken = await user.getIdToken(true);
          final retryResponse = await http.patch(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
          ).timeout(const Duration(seconds: 30));

          if (retryResponse.statusCode != 200) {
            throw Exception('Erreur lors du blocage: ${retryResponse.statusCode}');
          }
        } catch (e) {
          print('❌ Erreur refresh token: $e');
          throw Exception('Accès refusé. Vérifiez que vous êtes administrateur.');
        }
      } else {
        final errorBody = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : <String, dynamic>{};
        throw Exception(errorBody['message'] ?? 'Erreur lors du blocage: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur blocage utilisateur: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erreur lors du blocage: $e');
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      String? idToken;
      try {
        idToken = await user.getIdToken();
      } catch (e) {
        print('❌ Erreur récupération token: $e');
        throw Exception('Impossible de récupérer le token utilisateur');
      }

      final uri = Uri.parse('$baseUrl/api/users/$userId/unblock');
      print('🔓 Déblocage utilisateur → $uri');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      };

      final response = await http.patch(uri, headers: headers).timeout(
            const Duration(seconds: 30),
          );

      print('📥 Réponse status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Utilisateur débloqué avec succès');
      } else if (response.statusCode == 401) {
        // Token expiré, essayer de le rafraîchir
        try {
          idToken = await user.getIdToken(true);
          final retryResponse = await http.patch(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
          ).timeout(const Duration(seconds: 30));

          if (retryResponse.statusCode != 200) {
            throw Exception('Erreur lors du déblocage: ${retryResponse.statusCode}');
          }
        } catch (e) {
          print('❌ Erreur refresh token: $e');
          throw Exception('Accès refusé. Vérifiez que vous êtes administrateur.');
        }
      } else {
        final errorBody = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : <String, dynamic>{};
        throw Exception(errorBody['message'] ?? 'Erreur lors du déblocage: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur déblocage utilisateur: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erreur lors du déblocage: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      String? idToken;
      try {
        idToken = await user.getIdToken();
      } catch (e) {
        print('❌ Erreur récupération token: $e');
        throw Exception('Impossible de récupérer le token utilisateur');
      }

      final uri = Uri.parse('$baseUrl/api/users/$userId');
      print('🗑️ Suppression utilisateur → $uri');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      };

      final response = await http.delete(uri, headers: headers).timeout(
            const Duration(seconds: 30),
          );

      print('📥 Réponse status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Utilisateur supprimé avec succès');
      } else if (response.statusCode == 401) {
        // Token expiré, essayer de le rafraîchir
        try {
          idToken = await user.getIdToken(true);
          final retryResponse = await http.delete(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
          ).timeout(const Duration(seconds: 30));

          if (retryResponse.statusCode != 200) {
            final errorBody = retryResponse.body.isNotEmpty
                ? jsonDecode(retryResponse.body)
                : <String, dynamic>{};
            throw Exception(errorBody['message'] ?? 'Erreur lors de la suppression: ${retryResponse.statusCode}');
          }
        } catch (e) {
          print('❌ Erreur refresh token: $e');
          throw Exception('Accès refusé. Vérifiez que vous êtes administrateur.');
        }
      } else {
        final errorBody = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : <String, dynamic>{};
        throw Exception(errorBody['message'] ?? 'Erreur lors de la suppression: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur suppression utilisateur: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erreur lors de la suppression: $e');
    }
  }
}

