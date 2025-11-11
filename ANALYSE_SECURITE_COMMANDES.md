# 🔒 Analyse de Sécurité - Système de Commandes

## 📋 Vue d'ensemble
Analyse approfondie de la sécurité du système de commande de produits de l'application Gnala Cosmetic.

---

## ✅ **AVANTAGES / POINTS FORTS**

### 1. **Authentification Utilisateur**
- ✅ **Firebase Authentication** : Utilisation de Firebase Auth pour vérifier l'identité de l'utilisateur
- ✅ **Vérification de session** : L'utilisateur doit être connecté pour passer une commande (`FirebaseAuth.instance.currentUser`)
- ✅ **Récupération des données utilisateur** : Les informations proviennent de Firestore, pas de l'input utilisateur

### 2. **Validation Côté Client**
- ✅ **Validation des champs** : Les champs d'adresse et de zone sont validés (non vides)
- ✅ **Formulaire Flutter** : Utilisation de `FormState` pour valider avant soumission
- ✅ **Gestion d'erreurs** : Try-catch avec messages d'erreur appropriés

### 3. **Résilience et Fiabilité**
- ✅ **Retry logic** : 3 tentatives avec backoff exponentiel pour gérer les cold starts
- ✅ **Timeout** : 30 secondes par tentative pour éviter les blocages
- ✅ **Gestion des erreurs réseau** : Messages d'erreur clairs pour l'utilisateur

### 4. **Persistance des Données**
- ✅ **MongoDB Atlas** : Stockage persistant des commandes (pas de perte de données)
- ✅ **Structure flexible** : Schéma MongoDB adaptable pour évoluer
- ✅ **Timestamps** : Enregistrement automatique des dates de création/modification

### 5. **Séparation des Responsabilités**
- ✅ **Service dédié** : `OrderService` séparé de l'UI
- ✅ **Configuration centralisée** : `ServerConfig` pour gérer les URLs
- ✅ **Provider pattern** : Utilisation de `CartProvider` pour la gestion du panier

---

## ⚠️ **INCONVÉNIENTS / VULNÉRABILITÉS**

### 1. **🔴 CRITIQUE : Absence d'Authentification Serveur**

**Problème** :
```javascript
// server.js ligne 53
app.post('/api/orders', async (req, res) => {
  // AUCUNE vérification d'authentification !
  const orderData = req.body; // Accepte n'importe quelle requête
});
```

**Risques** :
- ❌ **Injection de fausses commandes** : N'importe qui peut envoyer des commandes sans être authentifié
- ❌ **Spam de commandes** : Attaque par déni de service (DoS)
- ❌ **Manipulation des données** : Modification des prix, quantités, etc.
- ❌ **Usurpation d'identité** : Un attaquant peut créer des commandes au nom d'autres utilisateurs

**Impact** : 🔴 **TRÈS ÉLEVÉ**

**Solution recommandée** :
```javascript
// Ajouter un middleware d'authentification
const verifyFirebaseToken = async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Token manquant' });
  
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Token invalide' });
  }
};

app.post('/api/orders', verifyFirebaseToken, async (req, res) => {
  // Vérifier que req.user.uid correspond à req.body.userId
  if (req.user.uid !== req.body.userId) {
    return res.status(403).json({ error: 'Non autorisé' });
  }
  // ...
});
```

---

### 2. **🔴 CRITIQUE : Pas de Validation Serveur**

**Problème** :
```javascript
// server.js - Aucune validation des données reçues
app.post('/api/orders', async (req, res) => {
  const orderData = req.body; // Accepte tout sans vérification
  await Order.create({ payload: req.body }); // Stocke directement
});
```

**Risques** :
- ❌ **Injection de données malveillantes** : Données corrompues dans MongoDB
- ❌ **Manipulation des prix** : Un attaquant peut modifier `totalPrice` côté client
- ❌ **Commandes avec quantités négatives** : Pas de validation des quantités
- ❌ **Données manquantes** : Commandes incomplètes acceptées

**Impact** : 🔴 **TRÈS ÉLEVÉ**

**Solution recommandée** :
```javascript
const { body, validationResult } = require('express-validator');

app.post('/api/orders', [
  body('userId').notEmpty().isString(),
  body('userName').notEmpty().isString().trim(),
  body('userPhone').notEmpty().isString(),
  body('address').notEmpty().isString().trim(),
  body('zone').notEmpty().isString().trim(),
  body('items').isArray().notEmpty(),
  body('items.*.quantity').isInt({ min: 1 }),
  body('items.*.price').isFloat({ min: 0 }),
  body('totalPrice').isFloat({ min: 0 }),
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  // ...
});
```

---

### 3. **🟠 MOYEN : Pas de Vérification des Prix**

**Problème** :
```dart
// order_service.dart ligne 64
'totalPrice': cart.totalPrice, // Prix calculé côté client, non vérifié
```

**Risques** :
- ❌ **Manipulation des prix** : Un utilisateur malveillant peut modifier le prix total
- ❌ **Commandes à prix réduit** : Possibilité de payer moins que le prix réel
- ❌ **Incohérence des données** : Prix total ne correspond pas aux items

**Impact** : 🟠 **MOYEN** (si pas de paiement en ligne, moins critique)

**Solution recommandée** :
```javascript
// Recalculer le prix côté serveur
const calculateTotalPrice = (items) => {
  return items.reduce((total, item) => {
    // Vérifier le prix depuis la base de données des produits
    const productPrice = getProductPriceFromDB(item.productId);
    return total + (productPrice * item.quantity);
  }, 0);
};

// Comparer avec le prix envoyé
if (Math.abs(calculatedTotal - req.body.totalPrice) > 0.01) {
  return res.status(400).json({ error: 'Prix total invalide' });
}
```

---

### 4. **🟠 MOYEN : Transmission en HTTP (non HTTPS)**

**Problème** :
```dart
// order_service.dart ligne 80
response = await http.post(uri, ...); // Pas de vérification HTTPS
```

**Risques** :
- ❌ **Man-in-the-Middle** : Interception des données en transit
- ❌ **Données en clair** : Informations personnelles visibles sur le réseau
- ❌ **Modification des requêtes** : Altération des commandes en transit

**Impact** : 🟠 **MOYEN** (si déployé sur Render avec HTTPS, moins critique)

**Solution recommandée** :
- ✅ Utiliser HTTPS uniquement (déjà fait si déployé sur Render)
- ✅ Valider les certificats SSL côté client
- ✅ Utiliser `https://` dans `ServerConfig.ordersApiUrl`

---

### 5. **🟡 FAIBLE : Pas de Rate Limiting**

**Problème** :
```javascript
// server.js - Aucune limitation de requêtes
app.post('/api/orders', async (req, res) => {
  // Accepte un nombre illimité de requêtes
});
```

**Risques** :
- ❌ **Spam de commandes** : Un utilisateur peut envoyer des milliers de commandes
- ❌ **Déni de service** : Surcharge du serveur et de la base de données
- ❌ **Coûts MongoDB** : Augmentation des coûts avec trop de requêtes

**Impact** : 🟡 **FAIBLE** (mais peut devenir critique)

**Solution recommandée** :
```javascript
const rateLimit = require('express-rate-limit');

const orderLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // Maximum 10 commandes par IP
  message: 'Trop de commandes, veuillez réessayer plus tard'
});

app.post('/api/orders', orderLimiter, async (req, res) => {
  // ...
});
```

---

### 6. **🟡 FAIBLE : CORS Trop Permissif**

**Problème** :
```javascript
// server.js ligne 14
app.use(cors()); // Accepte toutes les origines
```

**Risques** :
- ❌ **Requêtes depuis n'importe quel site** : Sites malveillants peuvent envoyer des commandes
- ❌ **Cross-Site Request Forgery (CSRF)** : Attaques depuis d'autres domaines

**Impact** : 🟡 **FAIBLE** (mais peut être amélioré)

**Solution recommandée** :
```javascript
const corsOptions = {
  origin: [
    'https://votre-app-web.com',
    'http://localhost:312', // Pour développement
  ],
  credentials: true,
  optionsSuccessStatus: 200
};
app.use(cors(corsOptions));
```

---

### 7. **🟡 FAIBLE : Pas de Logging de Sécurité**

**Problème** :
```javascript
// Pas de logs pour détecter les tentatives d'attaque
console.log('Nouvelle commande reçue:', ...); // Log basique
```

**Risques** :
- ❌ **Difficile de détecter les attaques** : Pas de traçabilité des tentatives malveillantes
- ❌ **Pas d'alerte** : Aucune notification en cas d'anomalie

**Solution recommandée** :
```javascript
// Logger les tentatives suspectes
if (req.body.totalPrice < 0 || req.body.items.length === 0) {
  console.warn('⚠️ Tentative de commande suspecte:', {
    ip: req.ip,
    userId: req.body.userId,
    timestamp: new Date(),
    data: req.body
  });
  // Envoyer une alerte (email, Slack, etc.)
}
```

---

### 8. **🟡 FAIBLE : Pas de Chiffrement des Données Sensibles**

**Problème** :
```javascript
// Données stockées en clair dans MongoDB
payload: { userPhone: '89831840', address: '...' } // En clair
```

**Risques** :
- ❌ **Accès non autorisé à MongoDB** : Si la base est compromise, toutes les données sont visibles
- ❌ **Conformité RGPD** : Données personnelles non chiffrées

**Impact** : 🟡 **FAIBLE** (mais important pour la conformité)

**Solution recommandée** :
```javascript
const crypto = require('crypto');

const encrypt = (text) => {
  const algorithm = 'aes-256-cbc';
  const key = process.env.ENCRYPTION_KEY; // Clé depuis variable d'environnement
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv(algorithm, key, iv);
  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  return iv.toString('hex') + ':' + encrypted;
};
```

---

## 📊 **RÉSUMÉ DES RISQUES**

| Vulnérabilité | Sévérité | Probabilité | Impact Global |
|---------------|----------|-------------|---------------|
| Pas d'authentification serveur | 🔴 Critique | Élevée | 🔴 **TRÈS ÉLEVÉ** |
| Pas de validation serveur | 🔴 Critique | Élevée | 🔴 **TRÈS ÉLEVÉ** |
| Pas de vérification des prix | 🟠 Moyen | Moyenne | 🟠 **MOYEN** |
| HTTP non sécurisé | 🟠 Moyen | Faible* | 🟠 **MOYEN** |
| Pas de rate limiting | 🟡 Faible | Faible | 🟡 **FAIBLE** |
| CORS trop permissif | 🟡 Faible | Faible | 🟡 **FAIBLE** |
| Pas de logging sécurité | 🟡 Faible | Faible | 🟡 **FAIBLE** |
| Données non chiffrées | 🟡 Faible | Faible | 🟡 **FAIBLE** |

*Si déployé sur Render avec HTTPS, le risque est réduit

---

## 🛡️ **RECOMMANDATIONS PRIORITAIRES**

### **🔴 URGENT (À implémenter immédiatement)**

1. **Authentification serveur avec Firebase Admin SDK**
   - Vérifier le token Firebase côté serveur
   - Valider que `userId` correspond au token

2. **Validation serveur des données**
   - Utiliser `express-validator` ou `joi`
   - Valider tous les champs requis
   - Vérifier les types et formats

3. **Vérification des prix**
   - Recalculer le prix total côté serveur
   - Comparer avec le prix envoyé
   - Rejeter si différence > seuil

### **🟠 IMPORTANT (À implémenter rapidement)**

4. **Rate limiting**
   - Limiter le nombre de commandes par IP/utilisateur
   - Protéger contre le spam

5. **CORS restrictif**
   - Autoriser uniquement les domaines de l'application
   - Bloquer les autres origines

6. **Logging de sécurité**
   - Logger les tentatives suspectes
   - Alertes en cas d'anomalie

### **🟡 AMÉLIORATION (À planifier)**

7. **Chiffrement des données sensibles**
   - Chiffrer les numéros de téléphone et adresses
   - Conformité RGPD

8. **Monitoring et alertes**
   - Surveiller les patterns suspects
   - Notifications automatiques

---

## ✅ **CONCLUSION**

Le système actuel présente **des vulnérabilités critiques** qui permettent à un attaquant de :
- Créer des commandes frauduleuses
- Manipuler les prix
- Spammer le serveur

**Il est URGENT d'implémenter l'authentification et la validation serveur** avant de mettre l'application en production.

Les points forts (authentification client, retry logic, persistance) sont bons, mais **insuffisants sans protection serveur**.

---

**Date d'analyse** : $(date)
**Version analysée** : 1.0.0
**Analysé par** : Expert en développement mobile

