# Design System - Gnala Cosmetic

## Palette de couleurs

### Couleur principale
- **Rose pastel** : `#FFC0CB` (Color(0xFFFFC0CB))
- **Rose pastel foncé** : `#FFB6C1` (Color(0xFFFFB6C1))
- **Blanc** : `#FFFFFF` (Colors.white)

### Couleurs d'accent
- **Gris clair** : `#F5F5F5` (Colors.grey[50])
- **Gris moyen** : `#9E9E9E` (Colors.grey[400])
- **Gris foncé** : `#424242` (Colors.grey[600])

## Typographie

### Police principale
- **Famille** : Poppins
- **Poids disponibles** :
  - Regular (400)
  - Medium (500)
  - SemiBold (600)
  - Bold (700)

### Tailles de police
- **Titre principal** : 28px, Bold
- **Titre section** : 20px, Bold
- **Sous-titre** : 18px, Bold
- **Texte normal** : 16px, Regular
- **Texte petit** : 14px, Regular
- **Texte très petit** : 12px, Regular

## Composants

### Boutons

#### ElevatedButton (Principal)
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFFFFC0CB),
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(vertical: 16),
  ),
  child: Text('Texte du bouton'),
)
```

#### OutlinedButton (Secondaire)
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: Color(0xFFFFC0CB),
    side: BorderSide(color: Color(0xFFFFC0CB)),
    padding: EdgeInsets.symmetric(vertical: 16),
  ),
  child: Text('Texte du bouton'),
)
```

#### TextButton (Lien)
```dart
TextButton(
  style: TextButton.styleFrom(
    foregroundColor: Color(0xFFFFC0CB),
  ),
  child: Text('Texte du lien'),
)
```

### Cartes

#### Carte standard
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withValues(alpha: 0.08),
        spreadRadius: 1,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: // Contenu de la carte
)
```

#### Carte avec gradient
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFFFC0CB), Color(0xFFFFB6C1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  child: // Contenu de la carte
)
```

### AppBar
```dart
AppBar(
  backgroundColor: Color(0xFFFFC0CB),
  foregroundColor: Colors.white,
  elevation: 0,
  centerTitle: true,
)
```

## Icônes Material

### Icônes principales
- **Shopping** : `Icons.shopping_bag`
- **Panier** : `Icons.shopping_cart`
- **Ajouter** : `Icons.add`
- **Supprimer** : `Icons.delete`
- **Modifier** : `Icons.edit`
- **Caméra** : `Icons.camera_alt`
- **Galerie** : `Icons.photo_library`

### Icônes d'interface
- **Utilisateur** : `Icons.person`
- **Téléphone** : `Icons.phone`
- **Verrouiller** : `Icons.lock`
- **Déconnexion** : `Icons.logout`
- **Admin** : `Icons.admin_panel_settings`

## Espacement

### Padding standard
- **Petit** : 8px
- **Moyen** : 16px
- **Grand** : 24px
- **Très grand** : 32px

### Marges
- **Petite** : 4px
- **Moyenne** : 8px
- **Grande** : 12px
- **Très grande** : 16px

## Bordures

### Rayon de bordure
- **Standard** : 12px (BorderRadius.circular(12))
- **Petit** : 8px
- **Grand** : 16px

## Ombres

### Ombre douce
```dart
BoxShadow(
  color: Colors.grey.withValues(alpha: 0.08),
  spreadRadius: 1,
  blurRadius: 8,
  offset: Offset(0, 2),
)
```

### Ombre légère
```dart
BoxShadow(
  color: Colors.grey.withValues(alpha: 0.1),
  spreadRadius: 1,
  blurRadius: 4,
  offset: Offset(0, 2),
)
```

## Thème global

### Configuration dans main.dart
```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFFFFC0CB),
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  fontFamily: 'Poppins',
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    shadowColor: Colors.grey.withValues(alpha: 0.1),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFFFFC0CB),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
)
```

## États des composants

### États de chargement
- **Couleur** : Color(0xFFFFC0CB)
- **Taille** : 20px pour les petits indicateurs
- **Animation** : CircularProgressIndicator

### États d'erreur
- **Couleur** : Colors.red
- **Icône** : Icons.error_outline
- **Message** : Toast avec fond rouge

### États de succès
- **Couleur** : Colors.green
- **Message** : Toast avec fond vert

## Responsive Design

### Breakpoints
- **Mobile** : < 768px
- **Tablet** : 768px - 1024px
- **Desktop** : > 1024px

### Grilles
- **Mobile** : 2 colonnes pour les produits
- **Tablet** : 3 colonnes pour les produits
- **Desktop** : 4 colonnes pour les produits

## Accessibilité

### Contraste
- **Texte sur fond blanc** : Contraste élevé
- **Texte sur fond rose** : Blanc pour la lisibilité
- **Liens** : Couleur rose pastel

### Tailles tactiles
- **Boutons** : Minimum 44px x 44px
- **Icônes** : Minimum 24px
- **Espacement** : Minimum 8px entre les éléments

## Animations

### Transitions
- **Durée** : 300ms pour les transitions standard
- **Courbe** : Curves.easeInOut
- **Délai** : 0ms par défaut

### Micro-interactions
- **Hover** : Légère élévation des cartes
- **Focus** : Bordure colorée pour les champs
- **Active** : Réduction légère de l'opacité

## Guidelines d'utilisation

### Couleurs
- Utiliser le rose pastel comme couleur principale
- Éviter les couleurs trop vives ou contrastées
- Maintenir la cohérence dans toute l'application

### Typographie
- Utiliser Poppins pour tous les textes
- Respecter la hiérarchie des tailles
- Maintenir une bonne lisibilité

### Espacement
- Utiliser les espacements standardisés
- Maintenir la cohérence entre les sections
- Éviter les espacements trop serrés

### Composants
- Utiliser les composants standardisés
- Respecter les rayons de bordure
- Appliquer les ombres de manière cohérente












