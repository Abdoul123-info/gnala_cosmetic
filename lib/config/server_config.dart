// Configuration du serveur orders_site
// Pour les appareils Android physiques, utilisez l'adresse IP locale de votre ordinateur
// Pour trouver votre IP : Windows: ipconfig | findstr IPv4, Mac/Linux: ifconfig | grep inet
// Pour un accès public sur Internet, utilisez une URL publique (ngrok, Railway, Render, etc.)

import 'package:flutter/foundation.dart';

class ServerConfig {
  // OPTION 1: URL publique (recommandé pour production)
  // Si vous avez déployé le serveur sur Railway, Render, Heroku, ou utilisez ngrok
  // Décommentez la ligne suivante et mettez votre URL publique
  // Exemples:
  // - ngrok: 'https://abc123.ngrok.io'
  // - Railway: 'https://orders-site-production.up.railway.app'
  // - Render: 'https://orders-site.onrender.com'
  // static const String? publicServerUrl = 'https://votre-url-publique.com';
  static const String? publicServerUrl = 'https://orders-site-gnala.onrender.com'; // URL publique Render
  
  // OPTION 2: Configuration locale (pour développement)
  // Adresse IP locale de votre ordinateur (utilisé si publicServerUrl est null)
  // Trouvez votre IP avec: ipconfig (Windows) ou ifconfig (Mac/Linux)
  static const String localServerIP = '192.168.1.137';
  static const int serverPort = 3000;
  
  // URL de base du serveur (détection automatique selon la plateforme)
  static String get baseUrl {
    // Si une URL publique est configurée, l'utiliser en priorité
    if (publicServerUrl != null && publicServerUrl!.isNotEmpty) {
      // Retirer le / à la fin si présent
      String url = publicServerUrl!.endsWith('/') 
          ? publicServerUrl!.substring(0, publicServerUrl!.length - 1)
          : publicServerUrl!;
      return url;
    }
    
    // Sinon, utiliser la configuration locale
    // Sur web, utilise localhost
    if (kIsWeb) {
      return 'http://localhost:$serverPort';
    }
    
    // Sur appareil physique Android/iOS, utilise l'IP locale
    return 'http://$localServerIP:$serverPort';
  }
  
  // URL complète pour l'API des commandes
  static String get ordersApiUrl => '$baseUrl/api/orders';
}

// INSTRUCTIONS:
// 1. Pour utiliser une URL publique (ngrok/Railway/Render):
//    - Décommentez et modifiez: static const String? publicServerUrl = 'https://votre-url.com';
//    - Commentez ou ignorez localServerIP
//
// 2. Pour utiliser l'IP locale (développement):
//    - Laissez publicServerUrl = null
//    - Mettez à jour localServerIP avec votre IP actuelle
//
// 3. Pour trouver votre IP locale:
//    - Windows: ipconfig | findstr IPv4
//    - Mac/Linux: ifconfig | grep inet

