# Guide de Démarrage Rapide - Gnala Cosmetic

## Prérequis

1. **Flutter** installé (version 3.9.2 ou supérieure)
2. **Firebase** configuré avec votre projet
3. **Cloudinary** configuré (pour l'upload d'images)

## Installation

### 1. Installer les dépendances

```bash
flutter pub get
```

### 2. Configurer Firebase

Assurez-vous que `lib/firebase_options.dart` contient vos clés Firebase.

### 3. Configurer Cloudinary

Éditez `lib/config/cloudinary_config.dart` avec vos clés Cloudinary.

## Lancement de l'application

### Mode Web (recommandé pour le développement)

```bash
flutter run -d chrome --web-port 312
```

### Ou utilisez le script batch

Double-cliquez sur `run_app.bat`

## Comptes de test

### Compte Admin
- **Email**: `admin@gnala.com`
- **Mot de passe**: (configuré dans Firebase)

### Compte Utilisateur
Créez un compte via la page d'inscription avec un numéro de téléphone.

## Structure du projet

```
lib/
├── config/          # Configuration (Cloudinary)
├── guards/          # Guards d'authentification
├── models/          # Modèles de données
├── pages/           # Pages de l'application
├── providers/       # State management (Provider)
├── routes.dart      # Système de routage
└── services/        # Services (Firebase, Products)
```

## Fonctionnalités principales

1. **Authentification**
   - Connexion avec numéro de téléphone
   - Inscription
   - Gestion des rôles (admin/user)

2. **Gestion des produits** (Admin)
   - Ajouter un produit
   - Modifier un produit
   - Supprimer un produit
   - Upload d'images vers Cloudinary

3. **Boutique** (Utilisateur)
   - Voir les produits
   - Ajouter au panier
   - Commander

## Dépannage

### Erreur 400 Firebase
- Vérifiez que les clés Firebase sont correctes
- Assurez-vous que l'authentification Email/Password est activée dans Firebase Console

### Erreur d'upload d'image
- Vérifiez les clés Cloudinary
- Assurez-vous que le preset Cloudinary est configuré

### Port déjà utilisé
Changez le port dans la commande :
```bash
flutter run -d chrome --web-port 313
```


