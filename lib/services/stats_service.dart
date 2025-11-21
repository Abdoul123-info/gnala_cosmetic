import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/server_config.dart';

class StatsData {
  final bool mongo;
  final int ordersCount;
  final int activeOrdersCount;
  final int cancelledOrdersCount;
  final int deliveredOrdersCount;
  final int totalRevenue;

  StatsData({
    required this.mongo,
    required this.ordersCount,
    required this.activeOrdersCount,
    required this.cancelledOrdersCount,
    required this.deliveredOrdersCount,
    required this.totalRevenue,
  });

  factory StatsData.fromJson(Map<String, dynamic> json) {
    return StatsData(
      mongo: json['mongo'] ?? false,
      ordersCount: json['ordersCount'] ?? 0,
      activeOrdersCount: json['activeOrdersCount'] ?? 0,
      cancelledOrdersCount: json['cancelledOrdersCount'] ?? 0,
      deliveredOrdersCount: json['deliveredOrdersCount'] ?? 0,
      totalRevenue: json['totalRevenue'] ?? 0,
    );
  }
}

class StatsService {
  static String get baseUrl => ServerConfig.baseUrl;

  Future<StatsData> fetchStats() async {
    try {
      final uri = Uri.parse('$baseUrl/api/stats');
      print('📡 Récupération statistiques → $uri');

      final response = await http.get(uri).timeout(
            const Duration(seconds: 30),
          );

      print('📥 Réponse status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final stats = StatsData.fromJson(Map<String, dynamic>.from(body));
        print('✅ Statistiques chargées: ${stats.ordersCount} commandes, ${stats.totalRevenue} FCFA');
        return stats;
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur récupération statistiques: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }
}


