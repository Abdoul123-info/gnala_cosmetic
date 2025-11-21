# 🔒 Migration vers la Collection `phone_numbers` - Sécurité Améliorée

## 📋 Résumé des Changements

Une nouvelle collection séparée `phone_numbers` a été créée pour améliorer la sécurité de l'application. Cette collection ne contient que les numéros de téléphone et les UID, sans exposer les données personnelles des utilisateurs.

---

## ✅ Modifications Apportées

### 1. **Nouvelles Règles Firestore**

**Collection `phone_numbers` :**
- ✅ Lecture autorisée pour tous les utilisateurs authentifiés (vérification d'unicité)
- ✅ Création autorisée seulement lors de l'inscription (par le propriétaire)
- ✅ Modification/Suppression autorisées seulement pour le propriétaire
- ✅ Les admins peuvent lire tous les numéros

**Collection `users` :**
- ✅ **Règle permissive retirée** : Les utilisateurs ne peuvent plus lire tous les documents
- ✅ Chaque utilisateur peut lire/modifier **SEULEMENT** son propre document
- ✅ Les admins peuvent toujours lire tous les documents

### 2. **Code Modifié**

**Fichiers mis à jour :**
- ✅ `lib/pages/signup_page.dart` : Utilise `phone_numbers` pour vérification
- ✅ `lib/pages/login_page.dart` : Utilise `phone_numbers` pour trouver l'email
- ✅ `lib/pages/forgot_password_page.dart` : Utilise `phone_numbers` pour trouver l'email

---

## 🏗️ Structure de la Collection `phone_numbers`

### Document Exemple
```
phone_numbers/
  └── 85196143/  (ID = numéro de téléphone sans formatage)
      ├── uid: "user-uid-12345"
      ├── phoneDigits: "85196143"
      └── createdAt: Timestamp
```

### Avantages
- ✅ **Sécurité** : Ne contient pas de données personnelles (nom, email, etc.)
- ✅ **Performance** : Recherche directe par ID (pas de requête `where`)
- ✅ **Unicité** : Un seul document par numéro (garantie par l'ID)

---

## 🔄 Flux d'Inscription (Nouveau)

1. **Vérification d'unicité** :
   ```dart
   // Cherche directement par ID (rapide et sécurisé)
   final phoneDoc = await FirebaseFirestore.instance
       .collection('phone_numbers')
       .doc(digits)
       .get();
   ```

2. **Création du compte** :
   - Création dans Firebase Auth
   - Création du document dans `users`
   - Création du document dans `phone_numbers`

---

## 🔄 Flux de Connexion (Nouveau)

1. **Recherche du numéro** :
   ```dart
   // Obtient l'UID depuis phone_numbers
   final phoneDoc = await FirebaseFirestore.instance
       .collection('phone_numbers')
       .doc(digits)
       .get();
   ```

2. **Récupération de l'email** :
   ```dart
   // Lit le document utilisateur avec l'UID
   final userDoc = await FirebaseFirestore.instance
       .collection('users')
       .doc(uid)
       .get();
   ```

---

## 🔒 Amélioration de Sécurité

### Avant (Ancien Système)
```
❌ Les utilisateurs authentifiés pouvaient lire TOUS les documents users
❌ Exposait : nom, email, téléphone, date de création
❌ Requête where sur toute la collection users
```

### Après (Nouveau Système)
```
✅ Les utilisateurs peuvent lire SEULEMENT leur propre document users
✅ phone_numbers ne contient que : uid, phoneDigits, createdAt
✅ Recherche directe par ID (pas de parcours de collection)
✅ Données personnelles protégées
```

---

## 📊 Comparaison

| Aspect | Avant | Après |
|--------|-------|-------|
| **Lecture users** | Tous les documents | Seulement son propre document |
| **Données exposées** | Nom, email, téléphone | Seulement uid + phoneDigits |
| **Performance** | Requête `where` (lente) | Recherche par ID (rapide) |
| **Sécurité** | ⚠️ Moyenne | ✅ Bonne |

---

## 🚀 Utilisateurs Existants

### Migration Automatique
Les nouveaux utilisateurs seront automatiquement ajoutés à `phone_numbers` lors de l'inscription.

### Utilisateurs Existants
Si vous avez des utilisateurs existants qui se sont inscrits avant cette mise à jour, ils devront :
- Se réinscrire (recommandé pour tester)
- OU vous pouvez créer un script de migration (voir section suivante)

---

## 🔧 Script de Migration (Optionnel)

Si vous avez des utilisateurs existants, vous pouvez créer un script pour migrer leurs numéros vers `phone_numbers` :

```dart
// Script de migration (à exécuter une seule fois)
Future<void> migrateExistingUsers() async {
  final usersSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .get();

  final batch = FirebaseFirestore.instance.batch();
  
  for (var doc in usersSnapshot.docs) {
    final data = doc.data();
    final phoneDigits = data['phoneDigits'] as String?;
    final uid = doc.id;
    
    if (phoneDigits != null && phoneDigits.isNotEmpty) {
      final phoneRef = FirebaseFirestore.instance
          .collection('phone_numbers')
          .doc(phoneDigits);
      
      // Vérifier si le document existe déjà
      final existing = await phoneRef.get();
      if (!existing.exists) {
        batch.set(phoneRef, {
          'uid': uid,
          'phoneDigits': phoneDigits,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }
  
  await batch.commit();
  print('Migration terminée !');
}
```

---

## ✅ Tests à Effectuer

1. **Inscription** :
   - ✅ Créer un nouveau compte avec un numéro de téléphone
   - ✅ Vérifier que le document est créé dans `phone_numbers`
   - ✅ Vérifier que le document est créé dans `users`

2. **Vérification d'unicité** :
   - ✅ Essayer de s'inscrire avec un numéro déjà utilisé
   - ✅ Vérifier que l'erreur "Ce numéro est déjà utilisé" s'affiche

3. **Connexion** :
   - ✅ Se connecter avec un numéro de téléphone
   - ✅ Vérifier que la connexion fonctionne

4. **Récupération de mot de passe** :
   - ✅ Utiliser "Mot de passe oublié" avec un numéro de téléphone
   - ✅ Vérifier que l'email de réinitialisation est envoyé

5. **Sécurité** :
   - ✅ Vérifier qu'un utilisateur ne peut pas lire les documents `users` d'autres utilisateurs
   - ✅ Vérifier qu'un utilisateur peut lire les documents `phone_numbers` (mais seulement uid + phoneDigits)

---

## 📝 Notes Importantes

1. **Compatibilité** : Le champ `phoneDigits` est toujours stocké dans `users` pour compatibilité, mais n'est plus utilisé pour les vérifications.

2. **Performance** : La recherche par ID est beaucoup plus rapide qu'une requête `where`.

3. **Sécurité** : Les données personnelles (nom, email) ne sont plus exposées lors de la vérification d'unicité.

4. **Migration** : Les utilisateurs existants continueront de fonctionner, mais pour une sécurité optimale, ils devraient être migrés vers `phone_numbers`.

---

## 🎯 Prochaines Étapes

1. ✅ **Tester l'inscription** avec un nouveau compte
2. ✅ **Tester la connexion** avec un numéro de téléphone
3. ✅ **Vérifier la sécurité** en essayant de lire les documents d'autres utilisateurs
4. ⚠️ **Optionnel** : Créer et exécuter le script de migration pour les utilisateurs existants

---

**Date de mise à jour** : $(Get-Date -Format "yyyy-MM-dd")
**Version** : 2.0 (Sécurité améliorée)




