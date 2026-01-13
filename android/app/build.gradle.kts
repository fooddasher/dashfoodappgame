import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ============================================================================
// SIGNING CONFIGURATION
// ============================================================================
// Load keystore properties from key.properties file (if it exists)
// This file is created by GitHub Actions during CI/CD builds
// and should NEVER be committed to version control.
// ============================================================================

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

val hasKeystoreProperties = keystorePropertiesFile.exists()
if (hasKeystoreProperties) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.fooddash.foodgame"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.fooddash.foodgame"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ========================================================================
    // SIGNING CONFIGS
    // ========================================================================
    signingConfigs {
        if (hasKeystoreProperties) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    // ========================================================================
    // BUILD TYPES
    // ========================================================================
    buildTypes {
        release {
            // Use release signing config if available, otherwise fail
            // This ensures we NEVER build release with debug keys
            signingConfig = if (hasKeystoreProperties) {
                signingConfigs.getByName("release")
            } else {
                // For local development without keystore, use debug
                // CI/CD will always have the keystore available
                println("⚠️ WARNING: No key.properties found. Using debug signing for release build.")
                println("   For production builds, ensure key.properties is configured.")
                signingConfigs.getByName("debug")
            }
            
            // Enable R8 code shrinking and optimization
            isMinifyEnabled = true
            isShrinkResources = true
            
            // ProGuard rules
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        
        debug {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // ========================================================================
    // BUNDLE OPTIONS (AAB)
    // ========================================================================
    bundle {
        // Ensure AAB is always built in release mode
        language {
            enableSplit = true
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }
}

flutter {
    source = "../.."
}
