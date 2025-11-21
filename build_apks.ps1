# Script pour builder les APK pour différentes versions Android
# V7-V8: Android 7.0 (API 24) à Android 8.1 (API 27)
# V8-V15: Android 8.0 (API 26) à Android 15 (API 35)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Build des APK Gnala Cosmetic" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Vérifier que Flutter est installé
$flutterCheck = flutter --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter n'est pas installé ou n'est pas dans le PATH" -ForegroundColor Red
    exit 1
}

# Nettoyer les builds précédents
Write-Host "`n🧹 Nettoyage des builds précédents..." -ForegroundColor Yellow
flutter clean

# Récupérer les dépendances
Write-Host "`n📦 Récupération des dépendances..." -ForegroundColor Yellow
flutter pub get

# Créer le dossier releases s'il n'existe pas
if (-not (Test-Path "releases")) {
    New-Item -ItemType Directory -Path "releases" | Out-Null
}

# Sauvegarder la configuration originale
$buildGradle = Get-Content "android/app/build.gradle.kts" -Raw

# Build APK V7-V8 (API 24-27)
Write-Host "`n🔨 Build APK V7-V8 (Android 7.0 - 8.1, API 24-27)..." -ForegroundColor Green
Write-Host "   Configuration: minSdk=24, targetSdk=27" -ForegroundColor Gray

# Modifier temporairement le build.gradle.kts pour V7-V8
$buildGradleV7V8 = $buildGradle -replace 'minSdk = 24\s*//.*', 'minSdk = 24  // Android 7.0 (Nougat) - V7-V8' -replace 'targetSdk = 35\s*//.*', 'targetSdk = 27  // Android 8.1 (Oreo) - V7-V8'
$buildGradleV7V8 | Set-Content "android/app/build.gradle.kts"

# Build release V7-V8
flutter build apk --release
if ($LASTEXITCODE -eq 0) {
    $apkPath = "build/app/outputs/flutter-apk/app-release.apk"
    if (Test-Path $apkPath) {
        Copy-Item $apkPath "releases/gnala-cosmetic-v7v8-release.apk" -Force
        Write-Host "✅ APK V7-V8 créé avec succès!" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Build V7-V8 échoué" -ForegroundColor Red
}

# Restaurer la configuration originale
$buildGradle | Set-Content "android/app/build.gradle.kts"

# Build APK V8-V15 (API 26-35)
Write-Host "`n🔨 Build APK V8-V15 (Android 8.0 - 15, API 26-35)..." -ForegroundColor Green
Write-Host "   Configuration: minSdk=26, targetSdk=35" -ForegroundColor Gray

# Modifier temporairement le build.gradle.kts pour V8-V15
$buildGradleV8V15 = $buildGradle -replace 'minSdk = 24\s*//.*', 'minSdk = 26  // Android 8.0 (Oreo) - V8-V15' -replace 'targetSdk = 35\s*//.*', 'targetSdk = 35  // Android 15 - V8-V15'
$buildGradleV8V15 | Set-Content "android/app/build.gradle.kts"

# Build release V8-V15
flutter build apk --release
if ($LASTEXITCODE -eq 0) {
    $apkPath = "build/app/outputs/flutter-apk/app-release.apk"
    if (Test-Path $apkPath) {
        Copy-Item $apkPath "releases/gnala-cosmetic-v8v15-release.apk" -Force
        Write-Host "✅ APK V8-V15 créé avec succès!" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Build V8-V15 échoué" -ForegroundColor Red
}

# Restaurer la configuration originale
$buildGradle | Set-Content "android/app/build.gradle.kts"

# Résumé
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Résumé des builds" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if (Test-Path "releases/gnala-cosmetic-v7v8-release.apk") {
    $size = (Get-Item "releases/gnala-cosmetic-v7v8-release.apk").Length / 1MB
    Write-Host "✅ APK V7-V8: releases/gnala-cosmetic-v7v8-release.apk ($([math]::Round($size, 2)) MB)" -ForegroundColor Green
} else {
    Write-Host "❌ APK V7-V8: Non créé" -ForegroundColor Red
}

if (Test-Path "releases/gnala-cosmetic-v8v15-release.apk") {
    $size = (Get-Item "releases/gnala-cosmetic-v8v15-release.apk").Length / 1MB
    Write-Host "✅ APK V8-V15: releases/gnala-cosmetic-v8v15-release.apk ($([math]::Round($size, 2)) MB)" -ForegroundColor Green
} else {
    Write-Host "❌ APK V8-V15: Non créé" -ForegroundColor Red
}

Write-Host "`n✨ Terminé!" -ForegroundColor Cyan

