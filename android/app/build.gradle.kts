plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Add the Google services Gradle plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.gnala_cosmetic"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.gnala_cosmetic"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Configuration par défaut : support Android 7.0+ (API 24+) jusqu'à Android 15 (API 35)
        // Pour builder des versions spécifiques, utilisez le script build_apks.ps1
        minSdk = 24  // Android 7.0 (Nougat) - minimum pour V7-V8
        targetSdk = 35  // Android 15 - maximum pour V8-V15
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    lint {
        // Désactiver les erreurs fatales pour les builds
        abortOnError = false
        checkReleaseBuilds = false
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
