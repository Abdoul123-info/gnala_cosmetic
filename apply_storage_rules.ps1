# Script pour appliquer les regles Firebase Storage
# Gnala Cosmetic - Configuration Storage avec Cloudinary

Write-Host "Application des regles Firebase Storage pour Gnala Cosmetic" -ForegroundColor Cyan
Write-Host ""

# Verifier que le fichier de regles existe
$rulesFile = "storage.rules"
if (-not (Test-Path $rulesFile)) {
    Write-Host "Erreur: Le fichier $rulesFile n'existe pas!" -ForegroundColor Red
    exit 1
}

Write-Host "Fichier de regles trouve: $rulesFile" -ForegroundColor Green
Write-Host ""

# Afficher le contenu des regles
Write-Host "REGLES FIREBASE STORAGE:" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Yellow
Get-Content $rulesFile | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
Write-Host "========================" -ForegroundColor Yellow
Write-Host ""

Write-Host "CARACTERISTIQUES DE CES REGLES:" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ IMAGES DE PRODUITS:" -ForegroundColor Green
Write-Host "   - Lecture: Tous les utilisateurs authentifies" -ForegroundColor White
Write-Host "   - Upload/Modification/Suppression: SEULEMENT LES ADMINS" -ForegroundColor Red
Write-Host ""
Write-Host "✅ IMAGES DE PROFIL:" -ForegroundColor Green
Write-Host "   - Lecture: Tous les utilisateurs authentifies" -ForegroundColor White
Write-Host "   - Upload/Modification: Seulement le proprietaire" -ForegroundColor White
Write-Host ""
Write-Host "✅ IMAGES DE CATEGORIES:" -ForegroundColor Green
Write-Host "   - Lecture: Tous les utilisateurs authentifies" -ForegroundColor White
Write-Host "   - Upload/Modification/Suppression: SEULEMENT LES ADMINS" -ForegroundColor Red
Write-Host ""
Write-Host "✅ FICHIERS TEMPORAIRES:" -ForegroundColor Green
Write-Host "   - Lecture/Ecriture: Seulement le proprietaire" -ForegroundColor White
Write-Host ""

Write-Host "INSTRUCTIONS POUR APPLIQUER CES REGLES:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Ouvrez votre navigateur et allez sur:" -ForegroundColor White
Write-Host "   https://console.firebase.google.com" -ForegroundColor Blue
Write-Host ""
Write-Host "2. Selectionnez votre projet 'gnala-cosmetic'" -ForegroundColor White
Write-Host ""
Write-Host "3. Dans le menu de gauche, cliquez sur 'Storage'" -ForegroundColor White
Write-Host ""
Write-Host "4. Cliquez sur l'onglet 'Regles'" -ForegroundColor White
Write-Host ""
Write-Host "5. Remplacez le contenu actuel par le contenu du fichier storage.rules" -ForegroundColor White
Write-Host ""
Write-Host "6. Cliquez sur 'Publier' pour appliquer les regles" -ForegroundColor White
Write-Host ""

Write-Host "CONFIGURATION CLOUDINARY TERMINEE:" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""
Write-Host "✅ Cloud Name: dv9ag6pbp" -ForegroundColor White
Write-Host "✅ API Key: 784346296632527" -ForegroundColor White
Write-Host "✅ API Secret: KYKbXtkPXrPhFo85NbTPpoMMgEg" -ForegroundColor White
Write-Host ""

Write-Host "PROCHAINES ETAPES:" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Appliquez les regles Firebase Storage" -ForegroundColor White
Write-Host "2. Testez l'upload d'images dans l'application" -ForegroundColor White
Write-Host "3. Verifiez que les images sont optimisees par Cloudinary" -ForegroundColor White
Write-Host ""

# Proposer d'ouvrir le fichier de regles
$openFile = Read-Host "Voulez-vous ouvrir le fichier storage.rules pour copier le contenu? (o/n)"
if ($openFile -eq "o" -or $openFile -eq "O") {
    Write-Host "Ouverture du fichier de regles..." -ForegroundColor Green
    notepad $rulesFile
}

Write-Host ""
Write-Host "IMPORTANT: Configuration securisee!" -ForegroundColor Yellow
Write-Host "   - Seuls les admins peuvent uploader des images de produits" -ForegroundColor White
Write-Host "   - Chaque utilisateur ne peut modifier que ses propres images" -ForegroundColor White
Write-Host "   - Backup automatique avec Firebase Storage" -ForegroundColor White
Write-Host ""

Write-Host "Appuyez sur Entree pour continuer..." -ForegroundColor Gray
Read-Host
