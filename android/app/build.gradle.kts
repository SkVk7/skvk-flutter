import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

android {
    namespace = "com.vedicastrology.pro"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        applicationId = "com.vedicastrology.pro"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            isDebuggable = false
            isZipAlignEnabled = true
            isJniDebuggable = false
            isRenderscriptDebuggable = false
            isPseudoLocalesEnabled = false
            isCrunchPngs = true
            isDefault = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            ndk {
                abiFilters += listOf("arm64-v8a") // Only 64-bit for maximum compression
            }
            // Swiss Ephemeris License Information
            buildConfigField("String", "SWISS_EPH_LICENSE", "\"Professional Commercial License\"")
            buildConfigField("String", "SWISS_EPH_COPYRIGHT", "\"© Astrodienst AG, Zurich, Switzerland\"")
            buildConfigField("String", "SWISS_EPH_WEBSITE", "\"https://www.astro.com/swisseph/\"")
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
            ndk {
                abiFilters += listOf("arm64-v8a")
            }
        }
    }

    buildFeatures {
        buildConfig = true
    }

    packaging {
        resources {
            pickFirsts += listOf("**/libc++_shared.so", "**/libjsc.so")
            excludes += listOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/ASL2.0",
                "META-INF/*.kotlin_module",
                "**/kotlin/**",
                "**/*.kotlin_metadata",
                "**/*.kotlin_builtins",
                "**/META-INF/gradle/incremental.annotation.processors",
                "**/DebugProbesKt.bin",
                "**/kotlin/**",
                "**/*.kotlin_metadata",
                "**/*.kotlin_builtins",
                "**/META-INF/gradle/incremental.annotation.processors",
                "**/META-INF/com.android.tools/**",
                "**/META-INF/androidx.**",
                "**/META-INF/services/**",
                "**/META-INF/versions/**"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.10")
    implementation("androidx.multidex:multidex:2.0.1")
}