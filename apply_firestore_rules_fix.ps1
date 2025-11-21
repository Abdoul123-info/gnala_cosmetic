# Script pour appliquer les regles Firestore corrigees pour l'inscription
# Gnala Cosmetic - Correction des permissions d'inscription

Write-Host "Application des regles Firestore corrigees pour l'inscription" -ForegroundColor Cyan
Write-Host ""

# Verifier que le fichier de regles existe
$rulesFile = "firestore.rules"
if (-not (Test-Path $rulesFile)) {
    Write-Host "Erreur: Le fichier $rulesFile n'existe pas!" -ForegroundColor Red
    Write-Host "Assurez-vous d'etre dans le repertoire gnala_cosmetic." -ForegroundColor Yellow
    exit 1
}

Write-Host "Fichier de regles trouve: $rulesFile" -ForegroundColor Green
Write-Host ""

# Afficher le contenu des regles
Write-Host "NOUVELLES REGLES (corrigees pour l'inscription):" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Yellow
Get-Content $rulesFile | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
Write-Host "================================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "CORRECTIONS APPORTEES:" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ COLLECTION USERS:" -ForegroundColor Green
Write-Host "   - Creation du document utilisateur lors de l'inscription: AUTORISEE" -ForegroundColor White
Write-Host "   - Lecture pour verification unicite telephone: AUTORISEE (utilisateurs authentifies)" -ForegroundColor White
Write-Host "   - Modification: Seulement son propre document" -ForegroundColor White
Write-Host "   - Les admins peuvent lire tous les documents" -ForegroundColor White
Write-Host ""

Write-Host "INSTRUCTIONS POUR APPLIQUER CES REGLES:" -ForegroundColor Cyan
Write-Host ""
Write-Host "METHODE 1: Firebase Console (Recommandee)" -ForegroundColor Yellow
Write-Host "1. Ouvrez votre navigateur et allez sur:" -ForegroundColor White
Write-Host "   https://console.firebase.google.com" -ForegroundColor Blue
Write-Host ""
Write-Host "2. Selectionnez votre projet 'gnala-cosmetic'" -ForegroundColor White
Write-Host ""
Write-Host "3. Dans le menu de gauche, cliquez sur 'Firestore Database'" -ForegroundColor White
Write-Host ""
Write-Host "4. Cliquez sur l'onglet 'Regles'" -ForegroundColor White
Write-Host ""
Write-Host "5. Remplacez le contenu actuel par le contenu du fichier firestore.rules" -ForegroundColor White
Write-Host ""
Write-Host "6. Cliquez sur 'Publier' pour appliquer les regles" -ForegroundColor White
Write-Host ""

Write-Host "METHODE 2: Firebase CLI" -ForegroundColor Yellow
Write-Host "Si vous avez Firebase CLI installe:" -ForegroundColor White
Write-Host "   firebase deploy --only firestore:rules" -ForegroundColor Blue
Write-Host ""

# Proposer d'ouvrir le fichier de regles
$openFile = Read-Host "Voulez-vous ouvrir le fichier firestore.rules pour copier le contenu? (o/n)"
if ($openFile -eq "o" -or $openFile -eq "O" -or $openFile -eq "") {
    Write-Host "Ouverture du fichier de regles..." -ForegroundColor Green
    notepad $rulesFile
}

Write-Host ""
Write-Host "IMPORTANT: Apres avoir applique les regles, testez l'inscription!" -ForegroundColor Yellow
Write-Host "   - L'erreur 'Missing or insufficient permissions' devrait disparaitre" -ForegroundColor White
Write-Host "   - Les utilisateurs peuvent maintenant creer leur compte" -ForegroundColor White
Write-Host ""


