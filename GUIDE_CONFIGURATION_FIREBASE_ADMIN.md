# 🔧 Guide : Configuration Firebase Admin SDK sur Render

## 📋 Vue d'ensemble

Ce guide vous explique comment configurer Firebase Admin SDK sur Render pour activer l'authentification serveur des commandes.

---

## 📝 **Étape 1 : Obtenir les Credentials Firebase**

### 1.1 Accéder à Firebase Console

1. Allez sur [Firebase Console](https://console.firebase.google.com)
2. Sélectionnez votre projet **Gnala Cosmetic** (ou le projet que vous utilisez)

### 1.2 Accéder aux Service Accounts

1. Cliquez sur l'icône ⚙️ **Paramètres du projet** (en haut à gauche)
2. Allez dans l'onglet **"Service accounts"** (Comptes de service)
3. Vous verrez une section **"Firebase Admin SDK"**

### 1.3 Générer une nouvelle clé privée

1. Cliquez sur le bouton **"Générer une nouvelle clé privée"**
2. Une boîte de dialogue apparaît avec un avertissement
3. Cliquez sur **"Générer la clé"**
4. Un fichier JSON sera téléchargé automatiquement (ex: `gnala-cosmetic-firebase-adminsdk-xxxxx.json`)

⚠️ **IMPORTANT** : Ce fichier contient des credentials sensibles. Ne le partagez jamais publiquement !

---

## 📝 **Étape 2 : Préparer le JSON pour Render**

### 2.1 Ouvrir le fichier JSON

1. Ouvrez le fichier JSON téléchargé avec un éditeur de texte (Notepad++, VS Code, etc.)
2. Le contenu ressemble à ceci :

```json
{
  "type": "service_account",
  "project_id": "gnala-cosmetic",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@gnala-cosmetic.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/..."
}
```

### 2.2 Convertir en une seule ligne

Pour Render, vous devez convertir ce JSON en **une seule ligne** :

1. **Option A - Manuellement** :
   - Supprimez tous les retours à la ligne
   - Gardez tous les espaces entre les éléments
   - Le résultat doit être sur une seule ligne

2. **Option B - En ligne** :
   - Utilisez un outil en ligne comme [JSON Minifier](https://jsonformatter.org/json-minify)
   - Collez votre JSON
   - Copiez le résultat minifié

3. **Option C - PowerShell (Windows)** :
   ```powershell
   $json = Get-Content "chemin/vers/votre/fichier.json" -Raw
   $jsonMinified = $json -replace '\s+', ' ' -replace '\s*([{}:,])\s*', '$1'
   $jsonMinified
   ```

**Exemple de résultat** (une seule ligne) :
```json
{"type":"service_account","project_id":"gnala-cosmetic","private_key_id":"abc123...","private_key":"-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----\n","client_email":"firebase-adminsdk-xxxxx@gnala-cosmetic.iam.gserviceaccount.com",...}
```

---

## 📝 **Étape 3 : Configurer sur Render**

### 3.1 Accéder à votre service Render

1. Allez sur [Render Dashboard](https://dashboard.render.com)
2. Connectez-vous avec votre compte
3. Trouvez votre service **"orders-site-gnala"** (ou le nom de votre service)
4. Cliquez dessus pour accéder aux paramètres

### 3.2 Ajouter la variable d'environnement

1. Dans le menu de gauche, cliquez sur **"Environment"** (Environnement)
2. Faites défiler jusqu'à la section **"Environment Variables"** (Variables d'environnement)
3. Cliquez sur **"Add Environment Variable"** (Ajouter une variable d'environnement)

### 3.3 Configurer la variable

1. **Key** (Clé) : `FIREBASE_SERVICE_ACCOUNT_KEY`
2. **Value** (Valeur) : Collez le JSON minifié (une seule ligne) que vous avez préparé à l'étape 2
3. Cliquez sur **"Save Changes"** (Enregistrer les modifications)

⚠️ **IMPORTANT** : 
- Le champ Value peut être très long (plusieurs centaines de caractères)
- Assurez-vous de copier TOUT le JSON, y compris les guillemets au début et à la fin
- Ne laissez pas d'espaces avant ou après le JSON

### 3.4 Redéployer le service

1. Après avoir sauvegardé, Render redéploiera automatiquement votre service
2. Vous pouvez aussi cliquer sur **"Manual Deploy"** → **"Deploy latest commit"** pour forcer un redéploiement
3. Attendez que le déploiement soit terminé (environ 2-3 minutes)

---

## 📝 **Étape 4 : Vérifier la Configuration**

### 4.1 Vérifier les logs Render

1. Dans Render Dashboard, allez dans l'onglet **"Logs"** de votre service
2. Cherchez le message suivant :
   ```
   ✅ Firebase Admin SDK initialisé avec service account
   ```
3. Si vous voyez ce message, la configuration est réussie ! ✅

### 4.2 Si vous voyez une erreur

Si vous voyez :
```
❌ Erreur initialisation Firebase Admin avec service account: ...
```

**Causes possibles** :
- Le JSON n'est pas valide (vérifiez la syntaxe)
- Le JSON n'est pas sur une seule ligne
- Des caractères spéciaux ont été mal encodés
- La variable d'environnement n'a pas été sauvegardée correctement

**Solution** :
1. Vérifiez que le JSON est bien sur une seule ligne
2. Réessayez avec un JSON minifié depuis un outil en ligne
3. Vérifiez qu'il n'y a pas d'espaces avant/après le JSON dans Render

### 4.3 Tester l'authentification

1. Essayez de passer une commande depuis l'application Flutter
2. Si l'authentification fonctionne, la commande devrait être acceptée
3. Si vous voyez une erreur `401 Unauthorized`, vérifiez que :
   - L'app Flutter envoie bien le token Firebase (vérifiez `order_service.dart`)
   - Le token n'est pas expiré (reconnectez-vous dans l'app)

---

## 🔍 **Dépannage**

### Problème : "Firebase Admin SDK non initialisé"

**Solution** :
1. Vérifiez que la variable `FIREBASE_SERVICE_ACCOUNT_KEY` existe bien sur Render
2. Vérifiez que le JSON est valide (utilisez un validateur JSON en ligne)
3. Redéployez le service après avoir corrigé la variable

### Problème : "Token invalide ou expiré"

**Solution** :
1. Dans l'app Flutter, déconnectez-vous et reconnectez-vous
2. Vérifiez que `order_service.dart` envoie bien le token dans les headers
3. Vérifiez les logs Render pour voir l'erreur exacte

### Problème : "Erreur de parsing JSON"

**Solution** :
1. Le JSON doit être sur une seule ligne
2. Utilisez un outil de minification JSON
3. Vérifiez qu'il n'y a pas de caractères invisibles

---

## ✅ **Vérification Finale**

Une fois configuré, vous devriez voir dans les logs Render :

```
✅ Firebase Admin SDK initialisé avec service account
✅ Connecté à MongoDB
Serveur orders_site démarré sur le port 3000
```

Et lors d'une commande :

```
[SECURITY] ... - ORDER_SUCCESS: {...}
✅ Nouvelle commande reçue: {...}
```

---

## 📚 **Ressources Utiles**

- [Firebase Admin SDK Documentation](https://firebase.google.com/docs/admin/setup)
- [Render Environment Variables](https://render.com/docs/environment-variables)
- [JSON Minifier](https://jsonformatter.org/json-minify)

---

## 🔒 **Sécurité**

⚠️ **IMPORTANT** :
- Ne partagez jamais votre fichier JSON de service account
- Ne le commitez jamais dans Git
- Si vous l'avez accidentellement partagé, régénérez immédiatement une nouvelle clé dans Firebase Console
- La variable d'environnement sur Render est chiffrée et sécurisée

---

**Date de création** : $(date)
**Version** : 1.0.0

