# Gnala Cosmetic - Application Flutter

Application de cosmétiques développée avec Flutter et Firebase.

## Configuration Firebase

### 1. Créer un projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com)
2. Cliquez sur "Créer un projet"
3. Nommez votre projet "Gnala Cosmetic"
4. Suivez les étapes de configuration

### 2. Configuration Android

1. Dans la console Firebase, ajoutez une application Android
2. Utilisez le package name : `com.example.gnala_cosmetic`
3. Téléchargez le fichier `google-services.json`
4. Remplacez le fichier `android/app/google-services.json` par le vôtre

### 3. Configuration iOS

1. Dans la console Firebase, ajoutez une application iOS
2. Utilisez le bundle ID : `com.example.gnalaCosmetic`
3. Téléchargez le fichier `GoogleService-Info.plist`
4. Remplacez le fichier `ios/Runner/GoogleService-Info.plist` par le vôtre

### 4. Activer les services Firebase

#### Authentication
1. Allez dans "Authentication" > "Sign-in method"
2. Activez "Email/Password" ou "Phone"
3. Configurez selon vos besoins

#### Cloud Firestore
1. Allez dans "Firestore Database"
2. Créez une base de données
3. Choisissez le mode de sécurité (test ou production)

#### Firebase Storage
1. Allez dans "Storage"
2. Créez un bucket de stockage
3. Configurez les règles de sécurité

### 5. Mettre à jour les fichiers de configuration

Après avoir téléchargé vos fichiers de configuration Firebase, mettez à jour :

- `lib/firebase_options.dart` avec vos vraies clés API
- `android/app/google-services.json` avec votre fichier téléchargé
- `ios/Runner/GoogleService-Info.plist` avec votre fichier téléchargé

## Dépendances installées

- `firebase_core` : Configuration Firebase
- `firebase_auth` : Authentification
- `cloud_firestore` : Base de données
- `firebase_storage` : Stockage de fichiers
- `provider` : Gestion d'état
- `fluttertoast` : Notifications toast
- `image_picker` : Sélection d'images
- `intl` : Internationalisation

## Installation

```bash
flutter pub get
```

## Exécution

```bash
flutter run
```

## Structure du projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── firebase_options.dart     # Configuration Firebase
└── ...
```

## Notes importantes

- Les fichiers de configuration Firebase actuels sont des exemples
- Vous devez les remplacer par vos vrais fichiers de configuration
- Assurez-vous d'activer les services Firebase nécessaires dans la console
- Configurez les règles de sécurité appropriées pour la production