/*
 * Swiss Ephemeris JNI Wrapper for Android
 * 
 * LICENSE NOTICE:
 * This application uses Swiss Ephemeris under a professional commercial license.
 * © Astrodienst AG, Zurich, Switzerland
 * License: Professional Commercial License
 * Website: https://www.astro.com/swisseph/
 * Email: swiss@astro.ch
 */

#include <jni.h>
#include <string>
#include <vector>
#include <cmath>
#include "sweph/sweph.h"

/// Swiss Ephemeris JNI Wrapper for Android
/// Provides interface between Kotlin and Swiss Ephemeris C library

extern "C" {

/// JNI function declarations
JNIEXPORT jboolean JNICALL
Java_com_supernova_skvk_1application_SwissEphemerisWrapper_setEphemerisPath(
    JNIEnv* env,
    jobject /* this */,
    jstring path
);

JNIEXPORT jobject JNICALL
Java_com_supernova_skvk_1application_SwissEphemerisWrapper_getPlanetPositionInternal(
    JNIEnv* env,
    jobject /* this */,
    jdouble julianDay,
    jint planet,
    jdouble latitude,
    jdouble longitude,
    jint ayanamsha
);

JNIEXPORT jdouble JNICALL
Java_com_supernova_skvk_1application_SwissEphemerisWrapper_getAyanamshaInternal(
    JNIEnv* env,
    jobject /* this */,
    jdouble julianDay,
    jint ayanamshaType
);

JNIEXPORT jobject JNICALL
Java_com_supernova_skvk_1application_SwissEphemerisWrapper_getHouseCuspsInternal(
    JNIEnv* env,
    jobject /* this */,
    jdouble julianDay,
    jdouble latitude,
    jdouble longitude,
    jint houseSystem
);

JNIEXPORT jobject JNICALL
Java_com_supernova_skvk_1application_SwissEphemerisWrapper_getAscendantDataInternal(
    JNIEnv* env,
    jobject /* this */,
    jdouble julianDay,
    jdouble latitude,
    jdouble longitude,
    jint houseSystem
);

} // extern "C"

/// Set ephemeris path for Swiss Ephemeris
JNIEXPORT jboolean JNICALL
Java_com_supernova_skvk_1application_SwissEphemerisWrapper_setEphemerisPath(
    JNIEnv* env,
    jobject /* this */,
    jstring path
) {
    try {
        const char* pathStr = env->GetStringUTFChars(path, nullptr);
        if (pathStr == nullptr) {
            return JNI_FALSE;
        }

        // Set ephemeris path in Swiss Ephemeris
        swe_set_ephe_path(pathStr);

        env->ReleaseStringUTFChars(path, pathStr);
        return JNI_TRUE;
    } catch (const std::exception& e) {
        return JNI_FALSE;
    }
}

/// Get planet position with full precision
JNIEXPORT jobject JNICALL
Java_com_supernova_skvk_1application_SwissEphemerisWrapper_getPlanetPositionInternal(
    JNIEnv* env,
    jobject /* this */,
    jdouble julianDay,
    jint planet,
    jdouble latitude,
    jdouble longitude,
    jint ayanamsha
) {
    try {
        // Set ayanamsha if specified
        if (ayanamsha >= 0) {
            swe_set_sid_mode(ayanamsha, 0, 0);
        }

        // Calculate planet position
        double xx[6]; // Position array for Swiss Ephemeris
        char serr[AS_MAXCH];

        int result = swe_calc_ut(
            julianDay,           // Julian day in UT
            static_cast<int>(planet), // Planet code
            SEFLG_SIDEREAL | SEFLG_SPEED, // Flags for sidereal and speed
            xx,                  // Result array
            serr                 // Error string
        );

        if (result < 0) {
            // Error in calculation
            return nullptr;
        }

        // Create result map
        jclass mapClass = env->FindClass("java/util/HashMap");
        jmethodID mapInit = env->GetMethodID(mapClass, "<init>", "()V");
        jmethodID mapPut = env->GetMethodID(mapClass, "put",
            "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");

        jobject resultMap = env->NewObject(mapClass, mapInit);

        // Add longitude
        jstring keyLong = env->NewStringUTF("longitude");
        env->CallObjectMethod(resultMap, mapPut, keyLong, xx[0]);
        env->DeleteLocalRef(keyLong);

        // Add latitude
        jstring keyLat = env->NewStringUTF("latitude");
        env->CallObjectMethod(resultMap, mapPut, keyLat, xx[1]);
        env->DeleteLocalRef(keyLat);

        // Add distance
        jstring keyDist = env->NewStringUTF("distance");
        env->CallObjectMethod(resultMap, mapPut, keyDist, xx[2]);
        env->DeleteLocalRef(keyDist);

        // Add speed
        jstring keySpeed = env->NewStringUTF("speed");
        env->CallObjectMethod(resultMap, mapPut, keySpeed, xx[3]);
        env->DeleteLocalRef(keySpeed);

        return resultMap;

    } catch (const std::exception& e) {
        return nullptr;
    }
}

/// Get ayanamsha value
JNIEXPORT jdouble JNICALL
Java_com_supernova_skvk_1application_SwissEphemerisWrapper_getAyanamshaInternal(
    JNIEnv* env,
    jobject /* this */,
    jdouble julianDay,
    jint ayanamshaType
) {
    try {
        double ayanamshaValue = swe_get_ayanamsa_ut(julianDay);
        return ayanamshaValue;
    } catch (const std::exception& e) {
        return 0.0;
    }
}

/// Get house cusps for all 12 houses
JNIEXPORT jobject JNICALL
Java_com_supernova_skvk_1application_SwissEphemerisWrapper_getHouseCuspsInternal(
    JNIEnv* env,
    jobject /* this */,
    jdouble julianDay,
    jdouble latitude,
    jdouble longitude,
    jint houseSystem
) {
    try {
        // House cusps array
        double cusps[13];  // 12 houses + 1 extra
        double ascmc[10];  // Ascendant, MC, etc.

        char serr[AS_MAXCH];

        // Calculate houses
        int result = swe_houses(
            julianDay,           // Julian day
            latitude,            // Geographic latitude
            longitude,           // Geographic longitude
            static_cast<int>(houseSystem), // House system
            cusps,               // House cusps
            ascmc                // Ascendant, MC, etc.
        );

        if (result < 0) {
            return nullptr;
        }

        // Create result list
        jclass arrayListClass = env->FindClass("java/util/ArrayList");
        jmethodID arrayListInit = env->GetMethodID(arrayListClass, "<init>", "()V");
        jmethodID arrayListAdd = env->GetMethodID(arrayListClass, "add",
            "(Ljava/lang/Object;)Z");

        jobject resultList = env->NewObject(arrayListClass, arrayListInit);

        // Add all 12 house cusps
        for (int i = 0; i < 12; i++) {
            env->CallBooleanMethod(resultList, arrayListAdd, cusps[i + 1]); // cusps[0] is ARMC
        }

        return resultList;

    } catch (const std::exception& e) {
        return nullptr;
    }
}

/// Get ascendant and related data
JNIEXPORT jobject JNICALL
Java_com_supernova_skvk_1application_SwissEphemerisWrapper_getAscendantDataInternal(
    JNIEnv* env,
    jobject /* this */,
    jdouble julianDay,
    jdouble latitude,
    jdouble longitude,
    jint houseSystem
) {
    try {
        // House cusps and ascmc data
        double cusps[13];
        double ascmc[10];

        char serr[AS_MAXCH];

        // Calculate houses to get ascendant data
        int result = swe_houses(
            julianDay,
            latitude,
            longitude,
            static_cast<int>(houseSystem),
            cusps,
            ascmc
        );

        if (result < 0) {
            return nullptr;
        }

        // Create result map
        jclass mapClass = env->FindClass("java/util/HashMap");
        jmethodID mapInit = env->GetMethodID(mapClass, "<init>", "()V");
        jmethodID mapPut = env->GetMethodID(mapClass, "put",
            "(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;");

        jobject resultMap = env->NewObject(mapClass, mapInit);

        // Add ascendant
        jstring keyAsc = env->NewStringUTF("ascendant");
        env->CallObjectMethod(resultMap, mapPut, keyAsc, ascmc[0]);
        env->DeleteLocalRef(keyAsc);

        // Add MC (Midheaven)
        jstring keyMC = env->NewStringUTF("midheaven");
        env->CallObjectMethod(resultMap, mapPut, keyMC, ascmc[1]);
        env->DeleteLocalRef(keyMC);

        // Add ARMC (Right Ascension of Meridian)
        jstring keyARMC = env->NewStringUTF("armc");
        env->CallObjectMethod(resultMap, mapPut, keyARMC, ascmc[2]);
        env->DeleteLocalRef(keyARMC);

        // Add vertex
        jstring keyVertex = env->NewStringUTF("vertex");
        env->CallObjectMethod(resultMap, mapPut, keyVertex, ascmc[3]);
        env->DeleteLocalRef(keyVertex);

        // Add equatorial ascendant
        jstring keyEquAsc = env->NewStringUTF("equatorialAscendant");
        env->CallObjectMethod(resultMap, mapPut, keyEquAsc, ascmc[4]);
        env->DeleteLocalRef(keyEquAsc);

        return resultMap;

    } catch (const std::exception& e) {
        return nullptr;
    }
}

/// Initialize Swiss Ephemeris on load
jint JNI_OnLoad(JavaVM* vm, void* reserved) {
    // Set default ephemeris path to internal storage
    swe_set_ephe_path("/data/data/com.supernova.skvk_application/files/ephemeris");

    // Close Swiss Ephemeris message handler to reduce logging
    swe_close();

    return JNI_VERSION_1_6;
}
