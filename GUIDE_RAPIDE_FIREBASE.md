# 🚀 Guide Rapide : Configuration Firebase Admin sur Render

## ⚡ **Méthode Rapide (Recommandée)**

### 1️⃣ Télécharger la clé Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com)
2. Sélectionnez votre projet
3. ⚙️ **Paramètres** → **Service accounts**
4. Cliquez sur **"Générer une nouvelle clé privée"**
5. Téléchargez le fichier JSON (ex: `gnala-cosmetic-xxxxx.json`)

### 2️⃣ Utiliser le script PowerShell (Windows)

1. Placez le fichier JSON téléchargé dans le dossier `orders_site/`
2. Ouvrez PowerShell dans ce dossier
3. Exécutez :
   ```powershell
   .\prepare_firebase_key.ps1 "nom-du-fichier.json"
   ```
4. Copiez le texte affiché

### 3️⃣ Configurer sur Render

1. Allez sur [Render Dashboard](https://dashboard.render.com)
2. Sélectionnez votre service **orders-site-gnala**
3. **Environment** → **Environment Variables**
4. **Add Environment Variable** :
   - **Key** : `FIREBASE_SERVICE_ACCOUNT_KEY`
   - **Value** : Collez le texte copié (très long, une seule ligne)
5. **Save Changes**
6. Attendez le redéploiement (2-3 minutes)

### 4️⃣ Vérifier

Dans les logs Render, vous devriez voir :
```
✅ Firebase Admin SDK initialisé avec service account
```

---

## 🔄 **Méthode Alternative (Variables Individuelles)**

Si la méthode rapide ne fonctionne pas, vous pouvez utiliser des variables séparées :

### Sur Render, ajoutez 3 variables :

1. **FIREBASE_PROJECT_ID**
   - Valeur : L'ID de votre projet Firebase (ex: `gnala-cosmetic`)

2. **FIREBASE_CLIENT_EMAIL**
   - Valeur : L'email du service account (ex: `firebase-adminsdk-xxxxx@gnala-cosmetic.iam.gserviceaccount.com`)
   - Trouvable dans le fichier JSON téléchargé, champ `client_email`

3. **FIREBASE_PRIVATE_KEY**
   - Valeur : La clé privée complète (champ `private_key` du JSON)
   - ⚠️ Incluez les `-----BEGIN PRIVATE KEY-----` et `-----END PRIVATE KEY-----`
   - Gardez les `\n` tels quels dans le JSON

---

## ❓ **Dépannage**

### Erreur : "JSON invalide"
- Vérifiez que le JSON est sur **une seule ligne**
- Utilisez le script PowerShell fourni
- Ou utilisez un outil en ligne : [JSON Minifier](https://jsonformatter.org/json-minify)

### Erreur : "Token invalide"
- Dans l'app Flutter, déconnectez-vous et reconnectez-vous
- Vérifiez que l'app envoie bien le token (vérifiez les logs)

### Erreur : "Firebase Admin non initialisé"
- Vérifiez que la variable existe bien sur Render
- Vérifiez les logs Render pour l'erreur exacte
- Redéployez le service après avoir corrigé

---

## 📞 **Besoin d'aide ?**

Consultez le guide détaillé : `GUIDE_CONFIGURATION_FIREBASE_ADMIN.md`

