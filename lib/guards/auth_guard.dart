import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../services/connectivity_service.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';
import '../pages/admin_dashboard.dart';
import '../widgets/splash_screen.dart';
import '../widgets/no_internet_widget.dart';

/// AuthWrapper observe l'état d'auth Firebase et oriente vers la bonne page
/// (Login, Home, Admin) en se basant sur le rôle Firestore.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  StreamSubscription<User?>? _authSub;
  bool _checking = true;
  bool _hasInternet = true;
  Widget? _current;
  DateTime? _startTime;
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _wasInBackground = false;
  bool _isInitialLoad = true; // Flag pour distinguer le chargement initial

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTime = DateTime.now();
    _checkInternetAndListenAuth();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Quand l'app passe en arrière-plan
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _wasInBackground = true;
    }
    
    // Quand l'app revient au premier plan
    if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      // Déconnecter automatiquement l'utilisateur pour la sécurité
      _signOutAutomatically();
    }
  }

  Future<void> _signOutAutomatically() async {
    try {
      final auth = FirebaseService.instance.auth;
      if (auth.currentUser != null) {
        await auth.signOut();
        if (mounted) {
          setState(() {
            _current = const LoginPage();
            _checking = false;
            _isInitialLoad = false; // Ne pas réafficher le splash après déconnexion
          });
        }
      }
    } catch (e) {
      // En cas d'erreur, forcer la déconnexion
      if (mounted) {
        setState(() {
          _current = const LoginPage();
          _checking = false;
          _isInitialLoad = false; // Ne pas réafficher le splash après déconnexion
        });
      }
    }
  }

  Future<void> _checkInternetAndListenAuth() async {
    // Vérifier la connexion internet d'abord
    final hasInternet = await _connectivityService.hasInternetConnection();
    
    if (!mounted) return;
    
    setState(() {
      _hasInternet = hasInternet;
    });

    // Si pas de connexion, ne pas continuer
    if (!hasInternet) {
      setState(() {
        _checking = false;
      });
      return;
    }

    // Si connexion OK, continuer avec l'authentification
    _listenAuth();
  }

  Future<void> _ensureMinimumSplashDuration() async {
    if (_startTime != null) {
      final elapsed = DateTime.now().difference(_startTime!);
      const minimumDuration = Duration(milliseconds: 2000); // Minimum 2 secondes
      if (elapsed < minimumDuration) {
        await Future.delayed(minimumDuration - elapsed);
      }
    }
  }

  void _listenAuth() {
    final auth = FirebaseService.instance.auth;
    _authSub = auth.authStateChanges().listen((user) async {
      if (!mounted) return;
      
      // Afficher le splash screen seulement lors du chargement initial
      if (_isInitialLoad) {
        setState(() {
          _checking = true;
        });
        // Attendre le délai minimum pour l'animation seulement au premier chargement
        await _ensureMinimumSplashDuration();
        _isInitialLoad = false; // Marquer que le chargement initial est terminé
      }

      // Vérifier à nouveau la connexion avant de continuer
      final hasInternet = await _connectivityService.hasInternetConnection();
      if (!hasInternet) {
        if (!mounted) return;
        setState(() {
          _hasInternet = false;
          _checking = false;
        });
        return;
      }

      if (user == null) {
        if (!mounted) return;
        setState(() {
          _current = const LoginPage();
          _checking = false;
        });
        return;
      }

      // Utilisateur connecté → charger rôle depuis Firestore
      try {
        final doc = await FirebaseService.instance.firestore
            .collection('users')
            .doc(user.uid)
            .get();

        String role = 'user';
        if (doc.exists) {
          final data = doc.data();
          final rawRole = (data?['role'] ?? data?['profil'] ?? data?['type']) as String?;
          if (rawRole != null && rawRole.trim().isNotEmpty) {
            role = rawRole.trim().toLowerCase();
          }
        }

        // Fallback: si le compte email est explicitement l'admin connu, forcer admin
        final email = user.email?.toLowerCase();
        if (email == 'admin@gnala.com') {
          role = 'admin';
        }

        final next = role == 'admin' ? const AdminDashboard() : const HomePage();
        if (!mounted) return;
        setState(() {
          _current = next;
          _checking = false;
        });
      } on FirebaseException catch (_) {
        if (!mounted) return;
        setState(() {
          _current = const HomePage();
          _checking = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _current = const HomePage();
          _checking = false;
        });
      }
    });
  }

  Future<void> _retryConnection() async {
    setState(() {
      _checking = false; // Ne pas afficher le splash lors du retry
      _startTime = DateTime.now();
    });
    await _checkInternetAndListenAuth();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSub?.cancel();
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si pas de connexion internet, afficher le widget d'erreur
    if (!_hasInternet) {
      return NoInternetWidget(onRetry: _retryConnection);
    }
    
    // Si en cours de vérification, afficher le splash screen
    if (_checking) {
      return const SplashScreen();
    }
    
    // Sinon, afficher la page appropriée
    return _current ?? const LoginPage();
  }
}


