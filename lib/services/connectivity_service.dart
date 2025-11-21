import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Service pour vérifier la connexion internet
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _connectionChecker = InternetConnectionChecker.createInstance();
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _hasInternet = true;

  /// Vérifie si l'appareil a une connexion internet active
  Future<bool> hasInternetConnection() async {
    try {
      // Vérifier d'abord la connectivité réseau
      final connectivityResult = await _connectivity.checkConnectivity();
      
      // Si pas de connexion réseau du tout, retourner false immédiatement
      if (connectivityResult.contains(ConnectivityResult.none)) {
        _hasInternet = false;
        return false;
      }

      // Vérifier l'accès réel à internet (ping)
      final hasConnection = await _connectionChecker.hasConnection;
      _hasInternet = hasConnection;
      return hasConnection;
    } catch (e) {
      // En cas d'erreur, supposer qu'il n'y a pas de connexion
      _hasInternet = false;
      return false;
    }
  }

  /// Écoute les changements de connexion
  Stream<bool> get onConnectivityChanged {
    final controller = StreamController<bool>.broadcast();
    
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        if (results.contains(ConnectivityResult.none)) {
          controller.add(false);
          _hasInternet = false;
        } else {
          // Vérifier l'accès réel à internet
          final hasConnection = await _connectionChecker.hasConnection;
          controller.add(hasConnection);
          _hasInternet = hasConnection;
        }
      },
    );

    return controller.stream;
  }

  /// Dispose les ressources
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Getter pour l'état actuel (cache)
  bool get hasInternet => _hasInternet;
}

