# 🔍 Explication : Permissions de Lecture dans Firestore

## 📚 Comprendre les Types de Lecture

### 1. **Lecture d'un Document Spécifique** (Sécurisé)
```dart
// L'utilisateur lit SEULEMENT son propre document
FirebaseFirestore.instance
    .collection('users')
    .doc('mon-uid-12345')  // ← Document spécifique
    .get();
```

**Règle actuelle :**
```javascript
allow read: if request.auth != null && request.auth.uid == userId;
```
✅ **Sécurisé** : L'utilisateur ne peut lire QUE son propre document

---

### 2. **Lecture d'une Collection Entière** (Requête `where`)
```dart
// L'application cherche dans TOUS les documents de la collection
FirebaseFirestore.instance
    .collection('users')
    .where('phoneDigits', isEqualTo: '85196143')  // ← Cherche dans TOUTE la collection
    .limit(1)
    .get();
```

**Problème :** Cette requête nécessite de **parcourir tous les documents** de la collection `users` pour trouver ceux qui correspondent.

**Règle nécessaire :**
```javascript
allow read: if request.auth != null;  // ← Permet de lire n'importe quel document
```

---

## 🎯 Pourquoi Cette Permission est Nécessaire

### Le Code d'Inscription
Dans `signup_page.dart`, ligne 61-65 :
```dart
// Vérifier que le numéro n'est pas déjà utilisé
final existingPhone = await FirebaseFirestore.instance
    .collection('users')
    .where('phoneDigits', isEqualTo: digits)  // ← Requête sur toute la collection
    .limit(1)
    .get();
```

**Ce que fait cette requête :**
1. Parcourt **tous les documents** de la collection `users`
2. Vérifie si un document a `phoneDigits == '85196143'`
3. Retourne le premier résultat trouvé

**Sans la permission `allow read: if request.auth != null;` :**
- ❌ Firestore refuse la requête
- ❌ Erreur : `permission-denied`
- ❌ L'inscription échoue

**Avec la permission :**
- ✅ Firestore autorise la recherche
- ✅ La vérification d'unicité fonctionne
- ✅ L'inscription peut continuer

---

## ⚠️ Implications de Sécurité

### Ce que les Utilisateurs Peuvent Maintenant Faire

**✅ AUTORISÉ :**
```dart
// 1. Lire leur propre document
FirebaseFirestore.instance
    .collection('users')
    .doc(monUid)
    .get();  // ✅ OK

// 2. Chercher un numéro de téléphone (pour vérification)
FirebaseFirestore.instance
    .collection('users')
    .where('phoneDigits', isEqualTo: '85196143')
    .get();  // ✅ OK (nécessaire pour l'inscription)

// 3. Lire n'importe quel document utilisateur
FirebaseFirestore.instance
    .collection('users')
    .doc(autreUid)
    .get();  // ✅ OK (mais pas idéal)
```

**❌ TOUJOURS INTERDIT :**
```dart
// Modifier le document d'un autre utilisateur
FirebaseFirestore.instance
    .collection('users')
    .doc(autreUid)
    .update({'name': 'Pirate'});  // ❌ INTERDIT (règle ligne 9)

// Supprimer le document d'un autre utilisateur
FirebaseFirestore.instance
    .collection('users')
    .doc(autreUid)
    .delete();  // ❌ INTERDIT (règle ligne 9)
```

---

## 🔒 Données Exposées

### Ce qu'un Utilisateur Peut Voir d'un Autre Utilisateur

Si un utilisateur lit le document d'un autre utilisateur, il peut voir :
- ✅ `uid` : Identifiant unique
- ✅ `name` : Nom complet
- ✅ `phone` : Numéro de téléphone
- ✅ `phoneDigits` : Numéro sans formatage
- ✅ `email` : Adresse email
- ✅ `createdEmail` : Email utilisé à l'inscription
- ✅ `role` : Rôle (user/admin)
- ✅ `createdAt` : Date de création

**⚠️ Données sensibles exposées :**
- Email personnel
- Numéro de téléphone
- Nom complet

---

## 🛡️ Solutions pour Améliorer la Sécurité

### Option 1 : Collection Séparée pour les Numéros (Recommandé)

**Créer une collection `phone_numbers` :**
```javascript
// firestore.rules
match /phone_numbers/{phoneDigits} {
  // Permettre la lecture pour vérification d'unicité
  allow read: if request.auth != null;
  // Seulement créer lors de l'inscription
  allow create: if request.auth != null;
  // Interdire modification/suppression
  allow update, delete: if false;
}
```

**Structure :**
```
phone_numbers/
  └── 85196143/
      └── { uid: "user-123", createdAt: timestamp }
```

**Avantages :**
- ✅ Les utilisateurs ne peuvent pas lire les profils complets
- ✅ Seulement le numéro et l'UID sont exposés
- ✅ Plus sécurisé

---

### Option 2 : Cloud Function pour Vérification

**Créer une Cloud Function :**
```javascript
exports.checkPhoneExists = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }
  
  const phoneDigits = data.phoneDigits;
  const snapshot = await admin.firestore()
    .collection('users')
    .where('phoneDigits', '==', phoneDigits)
    .limit(1)
    .get();
  
  return { exists: !snapshot.empty };
});
```

**Avantages :**
- ✅ Les règles Firestore restent strictes
- ✅ La vérification se fait côté serveur
- ✅ Aucune donnée utilisateur exposée

---

### Option 3 : Règles Plus Granulaires (Complexe)

**Utiliser `get()` dans les règles :**
```javascript
match /users/{userId} {
  // Permettre la lecture seulement si :
  // 1. C'est son propre document, OU
  // 2. On fait une requête where sur phoneDigits (difficile à détecter)
  allow read: if request.auth != null && (
    request.auth.uid == userId ||
    // Vérifier si c'est une requête de vérification
    // (Cette vérification est complexe et peut ne pas fonctionner)
  );
}
```

**Inconvénients :**
- ❌ Firestore Rules ne peut pas facilement détecter le type de requête
- ❌ Complexe à implémenter
- ❌ Peut ne pas fonctionner comme prévu

---

## 📊 Comparaison des Options

| Option | Sécurité | Complexité | Performance | Recommandation |
|--------|----------|------------|-------------|----------------|
| **Actuel** (Lecture générale) | ⚠️ Moyenne | ✅ Simple | ✅ Rapide | ✅ OK pour MVP |
| **Collection séparée** | ✅ Bonne | ⚠️ Moyenne | ✅ Rapide | ✅ Recommandé |
| **Cloud Function** | ✅ Excellente | ❌ Complexe | ⚠️ Plus lent | ✅ Pour production |
| **Règles granulaires** | ✅ Bonne | ❌ Très complexe | ✅ Rapide | ❌ Non recommandé |

---

## 🎯 Recommandation

### Pour l'Instant (Solution Actuelle)
✅ **Garder les règles actuelles** car :
- L'application fonctionne
- Les utilisateurs ne peuvent toujours pas modifier les données d'autrui
- C'est acceptable pour un MVP/développement

### Pour la Production
✅ **Implémenter Option 1 (Collection séparée)** car :
- Meilleur équilibre sécurité/complexité
- Protège les données personnelles
- Facile à implémenter

---

## 🔍 Vérification des Règles Actuelles

### Règle Ligne 9 (Stricte)
```javascript
allow read, write: if request.auth != null && request.auth.uid == userId;
```
**Effet :** L'utilisateur peut lire/modifier **SEULEMENT** son propre document

### Règle Ligne 13 (Permissive)
```javascript
allow read: if request.auth != null;
```
**Effet :** N'importe quel utilisateur authentifié peut lire **n'importe quel** document

**⚠️ Conflit :** La règle ligne 13 "écrase" la règle ligne 9 pour la lecture, mais pas pour l'écriture.

---

## 💡 Conclusion

**La permission `allow read: if request.auth != null;` permet :**
1. ✅ Les requêtes `where` nécessaires pour l'inscription
2. ⚠️ La lecture de tous les documents utilisateurs (compromis de sécurité)

**C'est un compromis acceptable pour :**
- ✅ Faire fonctionner l'inscription
- ✅ Protéger l'écriture (modification/suppression)
- ✅ Développement et MVP

**Pour améliorer la sécurité plus tard :**
- Créer une collection séparée `phone_numbers`
- Ou utiliser une Cloud Function


