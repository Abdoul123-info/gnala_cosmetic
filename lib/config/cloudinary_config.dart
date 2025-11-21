// Configuration Cloudinary pour Gnala Cosmetic
// Vos vraies clés Cloudinary

class CloudinaryConfig {
  // Vos informations Cloudinary
  static const String cloudName = 'dv9ag6pbp'; // Votre cloud name
  static const String apiKey = '784346296632527'; // Votre API key
  static const String apiSecret = 'KYKbXtkPXrPhFo85NbTPpoMMgEg'; // Votre API secret
  
  // Configuration des dossiers
  static const String productsFolder = 'gnala_cosmetic/products';
  static const String usersFolder = 'gnala_cosmetic/users';
  static const String categoriesFolder = 'gnala_cosmetic/categories';
  static const String tempFolder = 'gnala_cosmetic/temp';
  
  // Upload Preset (doit être créé dans Cloudinary Console)
  static const String uploadPreset = 'ml_default'; // Preset unsigned configuré
  
  // Configuration des transformations par défaut
  static const Map<String, dynamic> defaultTransformations = {
    'quality': 'auto',
    'format': 'auto',
    'fetch_format': 'auto',
  };
  
  // Transformations pour les produits
  static const Map<String, dynamic> productTransformations = {
    'width': 800,
    'height': 600,
    'crop': 'limit',
    'quality': 'auto',
    'format': 'auto',
  };
  
  // Transformations pour les miniatures
  static const Map<String, dynamic> thumbnailTransformations = {
    'width': 300,
    'height': 300,
    'crop': 'fill',
    'gravity': 'auto',
    'quality': 'auto',
    'format': 'auto',
  };
  
  // Transformations pour les avatars
  static const Map<String, dynamic> avatarTransformations = {
    'width': 150,
    'height': 150,
    'crop': 'fill',
    'gravity': 'face',
    'quality': 'auto',
    'format': 'auto',
  };
}

// Instructions pour obtenir vos clés Cloudinary :
// 1. Créez un compte sur https://cloudinary.com
// 2. Allez dans votre Dashboard
// 3. Copiez votre Cloud Name, API Key et API Secret
// 4. Remplacez les valeurs ci-dessus par vos vraies clés
// 5. Ne partagez jamais vos clés publiquement !
