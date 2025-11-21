# 🔒 Règles de Sécurité Firestore - Gnala Cosmetic

## 📋 Vue d'ensemble
Ce fichier contient les règles de sécurité Firestore pour l'application Gnala Cosmetic. Ces règles garantissent que :
- Les utilisateurs peuvent seulement accéder aux données qu'ils sont autorisés à voir
- Seuls les administrateurs peuvent gérer les produits
- La sécurité des données est maintenue

## 🛡️ Règles Implémentées

### 1. **Collection Users** (`/users/{userId}`)
- ✅ **Lecture/Écriture** : Un utilisateur peut lire et modifier son propre profil
- ✅ **Lecture Admin** : Les admins peuvent lire tous les profils utilisateurs
- ❌ **Écriture Admin** : Les admins ne peuvent pas modifier les profils d'autres utilisateurs (sécurité)

### 2. **Collection Products** (`/products/{productId}`)
- ✅ **Lecture** : Tous les utilisateurs authentifiés peuvent lire les produits
- ✅ **Écriture** : Seuls les admins peuvent créer, modifier ou supprimer des produits
- 🔒 **Protection** : Empêche les utilisateurs normaux de modifier le catalogue

### 3. **Collection Orders** (`/orders/{orderId}`) - Optionnel
- ✅ **Lecture/Écriture** : Un utilisateur peut gérer ses propres commandes
- ✅ **Lecture Admin** : Les admins peuvent voir toutes les commandes
- 📊 **Analytics** : Permet aux admins de suivre les ventes

### 4. **Collection Carts** (`/carts/{cartId}`) - Optionnel
- ✅ **Lecture/Écriture** : Un utilisateur peut gérer son propre panier
- 🔒 **Isolation** : Chaque utilisateur ne voit que son panier

## 🚀 Comment Appliquer ces Règles

### Méthode 1 : Firebase Console (Recommandée)
1. Allez sur [Firebase Console](https://console.firebase.google.com)
2. Sélectionnez votre projet "Gnala Cosmetic"
3. Dans le menu de gauche, cliquez sur **"Firestore Database"**
4. Cliquez sur l'onglet **"Règles"**
5. Copiez le contenu du fichier `firestore.rules`
6. Collez-le dans l'éditeur de règles
7. Cliquez sur **"Publier"**

### Méthode 2 : Firebase CLI
```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Se connecter à Firebase
firebase login

# Initialiser le projet
firebase init firestore

# Déployer les règles
firebase deploy --only firestore:rules
```

## 🔍 Explication des Règles

### Structure de Base
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Vos règles ici
  }
}
```

### Vérification du Rôle Admin
```javascript
get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin"
```
Cette ligne :
1. Récupère le document utilisateur de l'utilisateur connecté
2. Vérifie que le champ `role` est égal à "admin"
3. Permet l'action seulement si la condition est vraie

### Protection des Données Utilisateur
```javascript
request.auth.uid == userId
```
Garantit qu'un utilisateur ne peut accéder qu'à ses propres données.

## ⚠️ Points Importants

### 1. **Performance**
- Les règles `get()` peuvent impacter les performances
- Utilisez-les avec parcimonie
- Considérez le cache des règles

### 2. **Sécurité**
- Testez toujours vos règles avant le déploiement
- Utilisez le simulateur Firestore dans Firebase Console
- Vérifiez que les utilisateurs ne peuvent pas contourner les règles

### 3. **Maintenance**
- Documentez toute modification des règles
- Testez les nouvelles règles en mode développement
- Surveillez les logs d'accès refusés

## 🧪 Tests des Règles

### Test 1 : Utilisateur Normal
```javascript
// Devrait réussir
- Lire ses propres données utilisateur ✅
- Lire les produits ✅
- Créer une commande ✅

// Devrait échouer
- Modifier un produit ❌
- Lire les données d'un autre utilisateur ❌
- Supprimer un produit ❌
```

### Test 2 : Administrateur
```javascript
// Devrait réussir
- Lire tous les utilisateurs ✅
- Créer/modifier/supprimer des produits ✅
- Lire toutes les commandes ✅

// Devrait échouer
- Modifier les profils d'autres utilisateurs ❌
```

## 🔧 Personnalisation

### Ajouter de Nouvelles Collections
Pour ajouter des règles pour une nouvelle collection, suivez ce modèle :
```javascript
match /nouvelleCollection/{docId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && 
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin";
}
```

### Modifier les Permissions
- **Lecture publique** : `allow read: if true;`
- **Lecture authentifiée** : `allow read: if request.auth != null;`
- **Écriture admin** : Ajoutez la vérification du rôle admin

## 📞 Support
Si vous rencontrez des problèmes avec les règles :
1. Vérifiez les logs dans Firebase Console
2. Utilisez le simulateur de règles
3. Testez avec différents utilisateurs et rôles
4. Consultez la [documentation Firestore](https://firebase.google.com/docs/firestore/security/get-started)

---

**Note** : Ces règles sont optimisées pour l'application Gnala Cosmetic. Adaptez-les selon vos besoins spécifiques.























