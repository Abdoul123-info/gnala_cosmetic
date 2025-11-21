@echo off
echo Lancement de l'application Gnala Cosmetic...
echo.

REM Vérifier si Flutter est installé
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Erreur: Flutter n'est pas installe ou n'est pas dans le PATH
    pause
    exit /b 1
)

REM Aller dans le répertoire du projet
cd /d "%~dp0"

REM Installer les dépendances
echo Installation des dependances...
flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo Erreur lors de l'installation des dependances
    pause
    exit /b 1
)

REM Lancer l'application
echo.
echo Lancement de l'application sur le port 312...
flutter run -d chrome --web-port 312

pause


