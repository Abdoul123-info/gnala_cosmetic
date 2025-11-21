# Releases APK

Ce dossier contient les versions APK de l'application Gnala Cosmetic.

## Versions disponibles

L'application est disponible en deux versions pour différentes versions Android :

### APK V7-V8
- **Support** : Android 7.0 (API 24) à Android 8.1 (API 27)
- **Fichier** : `gnala-cosmetic-v7v8-release.apk`
- **Compatible avec** : Android Nougat (7.0, 7.1) et Android Oreo (8.0, 8.1)

### APK V8-V15
- **Support** : Android 8.0 (API 26) à Android 15 (API 35)
- **Fichier** : `gnala-cosmetic-v8v15-release.apk`
- **Compatible avec** : Android Oreo (8.0+) jusqu'à Android 15

## Comment builder les APK

### Prérequis
1. Installer Flutter SDK
2. Installer Android SDK et configurer `ANDROID_HOME`
3. Accepter les licences Android : `flutter doctor --android-licenses`

### Build automatique (recommandé)

Utilisez le script PowerShell pour builder les deux versions automatiquement :

```powershell
.\build_apks.ps1
```

Ce script va :
1. Builder l'APK V7-V8 (minSdk=24, targetSdk=27)
2. Builder l'APK V8-V15 (minSdk=26, targetSdk=35)
3. Copier les APK dans le dossier `releases/`

### Build manuel

#### Build APK V7-V8
1. Modifier `android/app/build.gradle.kts` :
   - `minSdk = 24`
   - `targetSdk = 27`
2. Builder : `flutter build apk --release`
3. Copier : `build/app/outputs/flutter-apk/app-release.apk` → `releases/gnala-cosmetic-v7v8-release.apk`

#### Build APK V8-V15
1. Modifier `android/app/build.gradle.kts` :
   - `minSdk = 26`
   - `targetSdk = 35`
2. Builder : `flutter build apk --release`
3. Copier : `build/app/outputs/flutter-apk/app-release.apk` → `releases/gnala-cosmetic-v8v15-release.apk`

## Vérification des APK

Pour vérifier quels APK sont disponibles :
```powershell
Get-ChildItem releases\*.apk
```

Les APK doivent être présents :
- ✅ `gnala-cosmetic-v7v8-release.apk` (pour Android 7.0-8.1)
- ✅ `gnala-cosmetic-v8v15-release.apk` (pour Android 8.0-15)

