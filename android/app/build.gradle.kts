import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "my.gov.onegovappstore.perak.tempahkenderaan"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "my.gov.onegovappstore.perak.tempahkenderaan"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ✅ Load keystore properties
   val keystoreProperties = Properties().apply {
    val keystoreFile = File(rootDir.parentFile, "key.properties")

    if (keystoreFile.exists()) {
        println("✅ key.properties dijumpai: " + keystoreFile.absolutePath)
        load(FileInputStream(keystoreFile))
    } else {
        println("❌ key.properties TIDAK dijumpai. Lokasi cuba: " + keystoreFile.absolutePath)
        throw GradleException("❌ File key.properties tidak dijumpai.")
    }
}


    signingConfigs {
        create("release") {
            val storeFilePath = keystoreProperties["storeFile"]?.toString()
            if (storeFilePath.isNullOrBlank()) {
                throw GradleException("❌ 'storeFile' kosong atau tidak dijumpai dalam key.properties")
            }

            storeFile = file(storeFilePath)
            storePassword = keystoreProperties["storePassword"]?.toString()
            keyAlias = keystoreProperties["keyAlias"]?.toString()
            keyPassword = keystoreProperties["keyPassword"]?.toString()
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
