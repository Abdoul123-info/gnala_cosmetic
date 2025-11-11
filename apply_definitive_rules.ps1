# Script pour appliquer les regles Firestore definitives
# Gnala Cosmetic - Regles de securite securisees

Write-Host "Application des regles Firestore definitives pour Gnala Cosmetic" -ForegroundColor Cyan
Write-Host ""

# Verifier que le fichier de regles existe
$rulesFile = "firestore.rules"
if (-not (Test-Path $rulesFile)) {
    Write-Host "Erreur: Le fichier $rulesFile n'existe pas!" -ForegroundColor Red
    Write-Host "Assurez-vous d'etre dans le bon repertoire." -ForegroundColor Yellow
    exit 1
}

Write-Host "Fichier de regles trouve: $rulesFile" -ForegroundColor Green
Write-Host ""

# Afficher le contenu des regles
Write-Host "Contenu des regles a appliquer:" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow
Get-Content $rulesFile | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
Write-Host "=================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "Instructions pour appliquer ces regles:" -ForegroundColor Cyan
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
Write-Host "5. Remplacez le contenu actuel par le contenu du fichier firestore.rules" -ForegroundColor White
Write-Host ""
Write-Host "6. Cliquez sur 'Publier' pour appliquer les regles" -ForegroundColor White
Write-Host ""

# Proposer d'ouvrir le fichier de regles
$openFile = Read-Host "Voulez-vous ouvrir le fichier firestore.rules pour copier le contenu? (o/n)"
if ($openFile -eq "o" -or $openFile -eq "O") {
    Write-Host "Ouverture du fichier de regles..." -ForegroundColor Green
    notepad $rulesFile
}

Write-Host ""
Write-Host "IMPORTANT: Ces regles sont securisees!" -ForegroundColor Yellow
Write-Host "   - Seuls les admins peuvent creer/modifier des produits" -ForegroundColor White
Write-Host "   - Chaque utilisateur ne peut acceder qu'a ses propres donnees" -ForegroundColor White
Write-Host "   - Tous les acces non specifies sont refuses" -ForegroundColor White
Write-Host ""

Write-Host "Une fois les regles appliquees, redemarrez l'application pour tester!" -ForegroundColor Green
Write-Host ""
Write-Host "Appuyez sur Entree pour continuer..." -ForegroundColor Gray
Read-Host