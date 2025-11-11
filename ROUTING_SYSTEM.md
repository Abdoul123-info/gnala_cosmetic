# Système de Routage - Gnala Cosmetic

## Vue d'ensemble

Le système de routage centralisé gère la navigation dans l'application avec une authentification automatique et une redirection basée sur les rôles utilisateur.

## Architecture

### Routes définies

```dart
// Noms des routes
static const String login = '/login';
static const String signup = '/signup';
static const String home = '/home';
static const String admin = '/admin';
static const String cart = '/cart';
```

### Configuration des routes

```dart
static Map<String, WidgetBuilder> get routes {
  return {
    login: (context) => const LoginPage(),
    signup: (context) => const SignupPage(),
    home: (context) => const HomePage(),
    admin: (context) => const AdminDashboard(),
    cart: (context) => const CartPage(),
  };
}
```

## Gestion de l'authentification

### AuthWrapper
- **Vérification automatique** : Écoute des changements d'état d'authentification
- **Redirection intelligente** : Basée sur le statut de connexion
- **Gestion des états** : Loading, connecté, non connecté

### RoleBasedNavigation
- **Chargement du rôle** : Récupération depuis Firestore
- **Création automatique** : Création du document utilisateur si inexistant
- **Redirection basée sur le rôle** :
  - `admin` → AdminDashboard
  - `user` → HomePage

## Méthodes de navigation

### Navigation avec remplacement de pile
```dart
// Navigation complète (efface la pile)
AppRoutes.navigateToLogin(context);
AppRoutes.navigateToHome(context);
AppRoutes.navigateToAdmin(context);
```

### Navigation avec remplacement simple
```dart
// Remplacement de la page actuelle
AppRoutes.replaceWithLogin(context);
AppRoutes.replaceWithSignup(context);
```

### Navigation simple
```dart
// Ajout à la pile de navigation
AppRoutes.goToLogin(context);
AppRoutes.goToSignup(context);
AppRoutes.goToCart(context);
```

### Navigation basée sur le rôle
```dart
// Redirection automatique selon le rôle
AppRoutes.navigateBasedOnRole(context, role);
```

## Workflow d'authentification

### 1. Initialisation de l'application
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### 2. Configuration du routage
```dart
MaterialApp(
  home: const AuthWrapper(),
  routes: AppRoutes.routes,
  // ...
)
```

### 3. Vérification de l'authentification
```dart
StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return RoleBasedNavigation(user: snapshot.data!);
    } else {
      return const LoginPage();
    }
  },
)
```

### 4. Vérification du rôle
```dart
Future<void> _loadUserRole() async {
  DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.user.uid)
      .get();

  if (userDoc.exists) {
    String role = userDoc.get('role') ?? 'user';
    AppRoutes.navigateBasedOnRole(context, role);
  } else {
    // Créer l'utilisateur avec role "user"
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .set({
      'uid': widget.user.uid,
      'name': widget.user.displayName ?? 'Utilisateur',
      'phone': widget.user.email ?? '',
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    AppRoutes.navigateToHome(context);
  }
}
```

## Gestion des états

### États de chargement
- **Initialisation Firebase** : Pendant le démarrage
- **Vérification auth** : Pendant la vérification de connexion
- **Chargement rôle** : Pendant la récupération du rôle utilisateur

### États d'erreur
- **Erreur Firestore** : Redirection vers login
- **Utilisateur inexistant** : Création automatique
- **Rôle manquant** : Attribution du rôle "user" par défaut

## Sécurité

### Protection des routes
- **AuthGuard** : Vérification d'authentification avant accès
- **RoleGuard** : Vérification du rôle pour les pages admin
- **Redirection automatique** : En cas d'accès non autorisé

### Validation des données
- **Vérification UID** : Validation de l'identifiant utilisateur
- **Validation rôle** : Vérification du rôle dans Firestore
- **Sanitisation** : Nettoyage des données utilisateur

## Performance

### Optimisations
- **Lazy loading** : Chargement des pages à la demande
- **Cache des routes** : Mise en cache des configurations
- **StreamBuilder** : Écoute efficace des changements d'état

### Gestion mémoire
- **Dispose automatique** : Nettoyage des contrôleurs
- **Streams optimisés** : Fermeture automatique des streams
- **Widgets légers** : Minimisation des reconstructions

## Tests

### Tests unitaires
- **AppRoutes** : Test des méthodes de navigation
- **AuthGuard** : Test de la logique d'authentification
- **RoleBasedNavigation** : Test de la redirection par rôle

### Tests d'intégration
- **Flux complet** : Test du parcours utilisateur
- **Gestion d'erreurs** : Test des cas d'erreur
- **Persistance** : Test de la conservation de l'état

### Tests UI
- **Navigation** : Test des transitions entre pages
- **États de chargement** : Test des indicateurs
- **Responsive** : Test sur différentes tailles d'écran

## Monitoring

### Métriques
- **Temps de navigation** : Durée des transitions
- **Taux d'erreur** : Fréquence des erreurs de routage
- **Utilisation des routes** : Pages les plus visitées
- **Temps d'authentification** : Durée de vérification

### Logs
- **Navigation** : Enregistrement des changements de page
- **Authentification** : Log des connexions/déconnexions
- **Erreurs** : Enregistrement des erreurs de routage
- **Performance** : Métriques de performance

## Évolutions futures

### Fonctionnalités avancées
- **Deep linking** : Support des liens profonds
- **Navigation conditionnelle** : Basée sur les permissions
- **Cache intelligent** : Mise en cache des pages
- **Préchargement** : Chargement anticipé des pages

### Améliorations techniques
- **Route guards** : Protection granulaire des routes
- **Middleware** : Intercepteurs de navigation
- **Analytics** : Suivi détaillé de la navigation
- **A/B testing** : Tests de différentes navigations

### Interface
- **Animations** : Transitions personnalisées
- **Thèmes** : Navigation adaptée au thème
- **Accessibilité** : Navigation au clavier
- **Gestes** : Navigation par gestes

## Dépannage

### Problèmes courants
- **Route non trouvée** : Vérifier la configuration des routes
- **Boucle de redirection** : Vérifier la logique d'authentification
- **Rôle non reconnu** : Vérifier la structure Firestore
- **Performance lente** : Optimiser les requêtes Firestore

### Solutions
- **Logs détaillés** : Activer les logs de navigation
- **Tests de connectivité** : Vérifier la connexion Firebase
- **Validation des données** : Contrôler la structure des données
- **Optimisation** : Réduire les requêtes inutiles












