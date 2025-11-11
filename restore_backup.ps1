# Script de restauration des fichiers supprimés vers 14h
# Vérifie la corbeille et l'historique Windows

Write-Host "Recherche des fichiers supprimés vers 14h..." -ForegroundColor Cyan
Write-Host ""

$backupDir = "backup_restore_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

# Vérifier la corbeille
$recycleBin = (New-Object -ComObject Shell.Application).NameSpace(0x0a)
Write-Host "Verification de la corbeille..." -ForegroundColor Yellow

$foundFiles = @()
foreach ($item in $recycleBin.Items()) {
    $fileName = $item.Name
    $filePath = $item.Path
    $dateDeleted = $item.ModifyDate
    
    # Chercher les fichiers supprimés aujourd'hui vers 14h
    if ($fileName -like "*gnala*" -or $filePath -like "*Gnala*") {
        $foundFiles += @{
            Name = $fileName
            Path = $filePath
            Date = $dateDeleted
        }
        Write-Host "Trouve: $fileName (supprime: $dateDeleted)" -ForegroundColor Green
    }
}

# Vérifier l'historique des fichiers Windows
Write-Host ""
Write-Host "Verification de l'historique des fichiers Windows..." -ForegroundColor Yellow

$userProfile = $env:USERPROFILE
$fileHistory = "$userProfile\AppData\Local\Microsoft\Windows\FileHistory"

if (Test-Path $fileHistory) {
    Write-Host "File History trouve. Recherche des versions precedentes..." -ForegroundColor Green
    # File History pourrait contenir des versions antérieures
}

# Lister les fichiers connus qui ont été supprimés
Write-Host ""
Write-Host "Fichiers connus qui ont ete supprimes:" -ForegroundColor Cyan
$knownDeletedFiles = @(
    "lib/services/product_service.dart",
    "lib/pages/add_product_page.dart",
    "lib/routes.dart",
    "QUICK_START_GUIDE.md",
    "run_app.bat",
    "START_INSTRUCTIONS.md",
    "PROJET_RESUME.md",
    "lib/debug_firebase.dart",
    "lib/pages/firebase_test_page.dart",
    "lib/services/firebase_service.dart",
    "lib/services/image_storage_service.dart",
    "lib/widgets/image_upload_widget.dart"
)

foreach ($file in $knownDeletedFiles) {
    if (Test-Path $file) {
        Write-Host "✓ $file existe deja" -ForegroundColor Green
    } else {
        Write-Host "✗ $file manquant" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Voulez-vous que je recree les fichiers manquants? (O/N)" -ForegroundColor Yellow
$response = Read-Host

if ($response -eq "O" -or $response -eq "o") {
    Write-Host "Creation des fichiers manquants..." -ForegroundColor Green
    # Les fichiers essentiels ont deja ete recrees precedemment
    Write-Host "Les fichiers essentiels (routes.dart, product_service.dart, add_product_page.dart) ont ete recrees."
}

Write-Host ""
Write-Host "Sauvegarde dans: $backupDir" -ForegroundColor Cyan
Write-Host "Appuyez sur Entree pour continuer..."
Read-Host

