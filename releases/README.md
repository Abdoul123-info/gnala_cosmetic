# Releases APK

Ce dossier contient les versions APK de l'application Gnala Cosmetic.

## Comment builder les APK

### Prérequis
1. Installer Flutter SDK
2. Installer Android SDK et configurer `ANDROID_HOME`
3. Accepter les licences Android : `flutter doctor --android-licenses`

### Build APK Debug
```bash
flutter build apk --debug
```
L'APK sera généré dans : `build/app/outputs/flutter-apk/app-debug.apk`

### Build APK Release
```bash
flutter build apk --release
```
L'APK sera généré dans : `build/app/outputs/flutter-apk/app-release.apk`

### Copier les APK dans ce dossier
Après le build, copiez les APK dans ce dossier :
```bash
# Windows PowerShell
Copy-Item build\app\outputs\flutter-apk\app-debug.apk releases\gnala-cosmetic-debug.apk
Copy-Item build\app\outputs\flutter-apk\app-release.apk releases\gnala-cosmetic-release.apk
```

## Versions disponibles
- Debug : Pour le développement et les tests
- Release : Version optimisée pour la production

