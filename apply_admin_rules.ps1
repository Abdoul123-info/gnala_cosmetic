# Script pour appliquer les regles Firestore avec restriction admin
# Gnala Cosmetic - Seuls les admins peuvent creer/modifier des produits

Write-Host "Application des regles Firestore avec restriction admin" -ForegroundColor Cyan
Write-Host ""

# Verifier que le fichier de regles existe
$rulesFile = "firestore_admin_rules.rules"
if (-not (Test-Path $rulesFile)) {
    Write-Host "Erreur: Le fichier $rulesFile n'existe pas!" -ForegroundColor Red
    exit 1
}

Write-Host "Fichier de regles trouve: $rulesFile" -ForegroundColor Green
Write-Host ""

# Afficher le contenu des regles
Write-Host "NOUVELLES REGLES AVEC RESTRICTION ADMIN:" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow
Get-Content $rulesFile | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
Write-Host "=========================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "CARACTERISTIQUES DE CES REGLES:" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ PRODUITS:" -ForegroundColor Green
Write-Host "   - Lecture: Tous les utilisateurs authentifies" -ForegroundColor White
Write-Host "   - Creation/Modification/Suppression: SEULEMENT LES ADMINS" -ForegroundColor Red
Write-Host ""
Write-Host "✅ UTILISATEURS:" -ForegroundColor Green
Write-Host "   - Chaque utilisateur peut lire/modifier son propre profil" -ForegroundColor White
Write-Host "   - Les admins peuvent lire tous les profils" -ForegroundColor White
Write-Host ""
Write-Host "✅ COMMANDES:" -ForegroundColor Green
Write-Host "   - Chaque utilisateur gere ses propres commandes" -ForegroundColor White
Write-Host "   - Les admins peuvent lire toutes les commandes" -ForegroundColor White
Write-Host ""
Write-Host "✅ PANIERS:" -ForegroundColor Green
Write-Host "   - Chaque utilisateur gere son propre panier" -ForegroundColor White
Write-Host ""
Write-Host "✅ CATEGORIES:" -ForegroundColor Green
Write-Host "   - Lecture: Tous les utilisateurs authentifies" -ForegroundColor White
Write-Host "   - Creation/Modification/Suppression: SEULEMENT LES ADMINS" -ForegroundColor Red
Write-Host ""
Write-Host "✅ AVIS:" -ForegroundColor Green
Write-Host "   - Lecture: Tous les utilisateurs authentifies" -ForegroundColor White
Write-Host "   - Creation/Modification: Chaque utilisateur pour ses propres avis" -ForegroundColor White
Write-Host ""

Write-Host "INSTRUCTIONS POUR APPLIQUER CES REGLES:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Ouvrez votre navigateur et allez sur:" -ForegroundColor White
Write-Host "   https://console.firebase.google.com" -ForegroundColor Blue
Write-Host ""
Write-Host "2. Selectionnez votre projet 'gnala-cosmetic'" -ForegroundColor White
Write-Host ""
Write-Host "3. Dans le menu de gauche, cliquez sur 'Firestore Database'" -ForegroundColor White
Write-Host ""
Write-Host "4. Cliquez sur l'onglet 'Regles'" -ForegroundColor White
Write-Host ""
Write-Host "5. Remplacez le contenu actuel par le contenu du fichier firestore_admin_rules.rules" -ForegroundColor White
Write-Host ""
Write-Host "6. Cliquez sur 'Publier' pour appliquer les regles" -ForegroundColor White
Write-Host ""

# Proposer d'ouvrir le fichier de regles
$openFile = Read-Host "Voulez-vous ouvrir le fichier firestore_admin_rules.rules pour copier le contenu? (o/n)"
if ($openFile -eq "o" -or $openFile -eq "O") {
    Write-Host "Ouverture du fichier de regles..." -ForegroundColor Green
    notepad $rulesFile
}

Write-Host ""
Write-Host "IMPORTANT: Ces regles sont tres securisees!" -ForegroundColor Yellow
Write-Host "   - Seuls les utilisateurs avec role='admin' peuvent creer/modifier des produits" -ForegroundColor White
Write-Host "   - Les utilisateurs normaux ne peuvent que lire les produits" -ForegroundColor White
Write-Host "   - Chaque utilisateur ne peut acceder qu'a ses propres donnees" -ForegroundColor White
Write-Host ""

Write-Host "Une fois les regles appliquees, testez l'application!" -ForegroundColor Green
Write-Host ""
Write-Host "Appuyez sur Entree pour continuer..." -ForegroundColor Gray
Read-Host
