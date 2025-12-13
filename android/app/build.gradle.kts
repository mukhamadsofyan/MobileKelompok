plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.kelompok"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ===== PUNYAMU (TETAP) =====
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        // ===== TAMBAHAN WAJIB (DESUGARING) =====
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // ===== PUNYAMU (TETAP) =====
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // ===== PUNYAMU (TETAP) =====
        applicationId = "com.example.kelompok"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ===== PUNYAMU (TETAP) =====
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// ===== TAMBAHAN WAJIB (DEPENDENCY DESUGARING) =====
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
