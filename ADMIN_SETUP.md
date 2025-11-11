# Configuration du compte administrateur

## Comment créer un compte administrateur

### Méthode 1 : Via la console Firebase

1. **Connectez-vous à la console Firebase** : https://console.firebase.google.com
2. **Sélectionnez votre projet** "Gnala Cosmetic"
3. **Allez dans Firestore Database**
4. **Créez ou modifiez un document** dans la collection `users`
5. **Ajoutez les champs suivants** :
   ```json
   {
     "uid": "UID_DE_L_UTILISATEUR",
     "name": "Nom de l'admin",
     "phone": "numéro_de_téléphone",
     "role": "admin",
     "createdAt": "timestamp"
   }
   ```

### Méthode 2 : Via l'application (temporaire)

1. **Inscrivez-vous normalement** via l'application
2. **Notez l'UID** de l'utilisateur dans la console Firebase
3. **Modifiez le document** dans Firestore pour changer `role` de `"user"` à `"admin"`

### Méthode 3 : Script de création (pour les développeurs)

Vous pouvez créer un script pour automatiser la création d'un admin :

```dart
// Script à exécuter une seule fois
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createAdminUser() async {
  try {
    // Créer l'utilisateur dans Firebase Auth
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: "admin@gnala.com",
      password: "motdepasseadmin123",
    );

    // Créer le document dans Firestore avec le rôle admin
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'uid': userCredential.user!.uid,
      'name': 'Administrateur Gnala',
      'phone': 'admin@gnala.com',
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('Compte administrateur créé avec succès !');
  } catch (e) {
    print('Erreur lors de la création de l\'admin : $e');
  }
}
```

## Informations importantes

- **Sécurité** : Changez le mot de passe par défaut après la première connexion
- **UID** : L'UID est unique et généré automatiquement par Firebase Auth
- **Rôle** : Seuls les utilisateurs avec `role: "admin"` accèdent au tableau de bord administrateur
- **Permissions** : Les administrateurs peuvent voir tous les utilisateurs et gérer l'application

## Test de l'admin

1. **Connectez-vous** avec le compte admin
2. **Vérifiez** que vous êtes redirigé vers `AdminDashboard`
3. **Vérifiez** que vous pouvez voir la liste des utilisateurs
4. **Vérifiez** que les statistiques s'affichent correctement

## Dépannage

- **Problème de redirection** : Vérifiez que le champ `role` est bien défini sur `"admin"`
- **Erreur de connexion** : Vérifiez que l'utilisateur existe dans Firebase Auth
- **Données manquantes** : Vérifiez que le document existe dans la collection `users`



