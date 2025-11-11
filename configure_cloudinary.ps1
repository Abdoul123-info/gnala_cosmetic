# Script de configuration Cloudinary pour Gnala Cosmetic
# Configuration du stockage d'images avec Cloudinary + Firebase Storage

Write-Host "Configuration Cloudinary pour Gnala Cosmetic" -ForegroundColor Cyan
Write-Host ""

Write-Host "ETAPES DE CONFIGURATION:" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. CREER UN COMPTE CLOUDINARY:" -ForegroundColor Green
Write-Host "   - Allez sur https://cloudinary.com" -ForegroundColor White
Write-Host "   - Cliquez sur 'Sign Up For Free'" -ForegroundColor White
Write-Host "   - Créez votre compte" -ForegroundColor White
Write-Host ""
Write-Host "2. OBTENIR VOS CLES CLOUDINARY:" -ForegroundColor Green
Write-Host "   - Connectez-vous à votre Dashboard" -ForegroundColor White
Write-Host "   - Copiez votre 'Cloud Name'" -ForegroundColor White
Write-Host "   - Copiez votre 'API Key'" -ForegroundColor White
Write-Host "   - Copiez votre 'API Secret'" -ForegroundColor White
Write-Host ""
Write-Host "3. CONFIGURER LES CLES DANS LE CODE:" -ForegroundColor Green
Write-Host "   - Ouvrez le fichier lib/config/cloudinary_config.dart" -ForegroundColor White
Write-Host "   - Remplacez 'your_cloud_name' par votre Cloud Name" -ForegroundColor White
Write-Host "   - Remplacez 'your_api_key' par votre API Key" -ForegroundColor White
Write-Host "   - Remplacez 'your_api_secret' par votre API Secret" -ForegroundColor White
Write-Host ""

Write-Host "AVANTAGES DE CLOUDINARY:" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Optimisation automatique des images" -ForegroundColor Green
Write-Host "✅ Compression intelligente" -ForegroundColor Green
Write-Host "✅ Transformations d'images en temps réel" -ForegroundColor Green
Write-Host "✅ CDN global pour des performances optimales" -ForegroundColor Green
Write-Host "✅ Formats modernes (WebP, AVIF)" -ForegroundColor Green
Write-Host "✅ Redimensionnement automatique" -ForegroundColor Green
Write-Host "✅ Backup avec Firebase Storage" -ForegroundColor Green
Write-Host ""

Write-Host "CONFIGURATION FIREBASE STORAGE:" -ForegroundColor Yellow
Write-Host "===============================" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Allez sur https://console.firebase.google.com" -ForegroundColor White
Write-Host "2. Selectionnez votre projet 'gnala-cosmetic'" -ForegroundColor White
Write-Host "3. Cliquez sur 'Storage' dans le menu de gauche" -ForegroundColor White
Write-Host "4. Cliquez sur 'Règles'" -ForegroundColor White
Write-Host "5. Remplacez le contenu par les règles du fichier storage.rules" -ForegroundColor White
Write-Host "6. Cliquez sur 'Publier'" -ForegroundColor White
Write-Host ""

Write-Host "INSTALLATION DES DEPENDANCES:" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Les dépendances suivantes ont été ajoutées au pubspec.yaml:" -ForegroundColor White
Write-Host "- cloudinary_flutter: ^1.0.0" -ForegroundColor Blue
Write-Host "- http: ^1.2.2" -ForegroundColor Blue
Write-Host "- cached_network_image: ^3.4.1" -ForegroundColor Blue
Write-Host "- path_provider: ^2.1.4" -ForegroundColor Blue
Write-Host ""
Write-Host "Exécutez: flutter pub get" -ForegroundColor Yellow
Write-Host ""

Write-Host "UTILISATION DANS LE CODE:" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host ""
Write-Host "// Upload d'image de produit (admin seulement)" -ForegroundColor White
Write-Host "final result = await ImageStorageService().uploadProductImage(" -ForegroundColor Blue
Write-Host "  imageFile: imageFile," -ForegroundColor Blue
Write-Host "  productId: 'product_123'," -ForegroundColor Blue
Write-Host "  fileName: 'main_image.jpg'," -ForegroundColor Blue
Write-Host ");" -ForegroundColor Blue
Write-Host ""
Write-Host "// Upload d'image de profil utilisateur" -ForegroundColor White
Write-Host "final result = await ImageStorageService().uploadUserProfileImage(" -ForegroundColor Blue
Write-Host "  imageFile: imageFile," -ForegroundColor Blue
Write-Host "  userId: 'user_123'," -ForegroundColor Blue
Write-Host "  fileName: 'avatar.jpg'," -ForegroundColor Blue
Write-Host ");" -ForegroundColor Blue
Write-Host ""

Write-Host "WIDGETS DISPONIBLES:" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ ImageUploadWidget - Widget générique" -ForegroundColor Green
Write-Host "✅ ProductImageUploadWidget - Pour les produits (admin)" -ForegroundColor Green
Write-Host "✅ UserProfileImageUploadWidget - Pour les profils" -ForegroundColor Green
Write-Host ""

Write-Host "SECURITE:" -ForegroundColor Red
Write-Host "========" -ForegroundColor Red
Write-Host ""
Write-Host "⚠️  Ne partagez JAMAIS vos clés Cloudinary publiquement!" -ForegroundColor Yellow
Write-Host "⚠️  Utilisez des variables d'environnement en production" -ForegroundColor Yellow
Write-Host "⚠️  Limitez les permissions dans votre compte Cloudinary" -ForegroundColor Yellow
Write-Host ""

Write-Host "TEST:" -ForegroundColor Green
Write-Host "====" -ForegroundColor Green
Write-Host ""
Write-Host "1. Configurez vos clés Cloudinary" -ForegroundColor White
Write-Host "2. Installez les dépendances: flutter pub get" -ForegroundColor White
Write-Host "3. Appliquez les règles Firebase Storage" -ForegroundColor White
Write-Host "4. Testez l'upload d'images dans l'application" -ForegroundColor White
Write-Host ""

Write-Host "Appuyez sur Entree pour continuer..." -ForegroundColor Gray
Read-Host
