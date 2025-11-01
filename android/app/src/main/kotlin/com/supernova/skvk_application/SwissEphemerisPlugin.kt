/*
 * Swiss Ephemeris Plugin for Flutter
 * 
 * LICENSE NOTICE:
 * This application uses Swiss Ephemeris under a professional commercial license.
 * © Astrodienst AG, Zurich, Switzerland
 * License: Professional Commercial License
 * Website: https://www.astro.com/swisseph/
 * Email: swiss@astro.ch
 */

package com.supernova.skvk_application

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.util.zip.ZipInputStream
import java.net.URL
import java.io.BufferedInputStream

/// Swiss Ephemeris Plugin for Flutter
/// Provides professional-grade astrological calculations using the Swiss Ephemeris library
class SwissEphemerisPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context
    private var swissEph: SwissEphemerisWrapper? = null
    private val mainScope = CoroutineScope(Dispatchers.Main)

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.supernova.swisseph")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "com.supernova.swisseph/events")
        eventChannel.setStreamHandler(SwissEphemerisStreamHandler())
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        mainScope.launch {
            try {
                when (call.method) {
                    "initialize" -> {
                        val success = initializeSwissEphemeris()
                        result.success(success)
                    }
                    "getPlanetPosition" -> {
                        val planetPosition = getPlanetPosition(call, result)
                        result.success(planetPosition)
                    }
                    "getAyanamsha" -> {
                        val ayanamsha = getAyanamsha(call, result)
                        result.success(ayanamsha)
                    }
                    "getHouseCusps" -> {
                        val houseCusps = getHouseCusps(call, result)
                        result.success(houseCusps)
                    }
                    "getAscendantData" -> {
                        val ascendantData = getAscendantData(call, result)
                        result.success(ascendantData)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            } catch (e: Exception) {
                result.error("SWISS_EPHEMERIS_ERROR", e.message, e.stackTraceToString())
            }
        }
    }

    /// Initialize Swiss Ephemeris library and ephemeris files
    private suspend fun initializeSwissEphemeris(): Boolean {
        return withContext(Dispatchers.IO) {
            try {
                // Initialize Swiss Ephemeris wrapper
                swissEph = SwissEphemerisWrapper()

                // Set ephemeris path to app's internal storage
                val ephemerisDir = File(context.filesDir, "ephemeris")
                if (!ephemerisDir.exists()) {
                    ephemerisDir.mkdirs()
                }

                // Initialize with ephemeris path
                swissEph?.initializeEphemeris(ephemerisDir.absolutePath)

                true
            } catch (e: Exception) {
                println("Swiss Ephemeris initialization error: ${e.message}")
                false
            }
        }
    }

    /// Get planet position using Swiss Ephemeris
    private suspend fun getPlanetPosition(call: MethodCall, result: Result): Map<String, Any>? {
        return withContext(Dispatchers.IO) {
            try {
                val julianDay = call.argument<Double>("julianDay") ?: return@withContext null
                val planet = call.argument<Int>("planet") ?: return@withContext null
                val latitude = call.argument<Double>("latitude") ?: 0.0
                val longitude = call.argument<Double>("longitude") ?: 0.0
                val ayanamsha = call.argument<Int>("ayanamsha") ?: 1

                swissEph?.let { se ->
                    val position = se.getPlanetPosition(julianDay, planet, latitude, longitude, ayanamsha)

                    mapOf(
                        "longitude" to position.longitude,
                        "latitude" to position.latitude,
                        "distance" to position.distance,
                        "speed" to position.speed
                    )
                }
            } catch (e: Exception) {
                println("Error getting planet position: ${e.message}")
                null
            }
        }
    }

    /// Get ayanamsha value
    private suspend fun getAyanamsha(call: MethodCall, result: Result): Double? {
        return withContext(Dispatchers.IO) {
            try {
                val julianDay = call.argument<Double>("julianDay") ?: return@withContext null
                val ayanamshaType = call.argument<Int>("ayanamshaType") ?: 1

                swissEph?.getAyanamsha(julianDay, ayanamshaType)
            } catch (e: Exception) {
                println("Error getting ayanamsha: ${e.message}")
                null
            }
        }
    }

    /// Get house cusps
    private suspend fun getHouseCusps(call: MethodCall, result: Result): List<Double>? {
        return withContext(Dispatchers.IO) {
            try {
                val julianDay = call.argument<Double>("julianDay") ?: return@withContext null
                val latitude = call.argument<Double>("latitude") ?: 0.0
                val longitude = call.argument<Double>("longitude") ?: 0.0
                val houseSystem = call.argument<Int>("houseSystem") ?: 0

                swissEph?.getHouseCusps(julianDay, latitude, longitude, houseSystem)
            } catch (e: Exception) {
                println("Error getting house cusps: ${e.message}")
                null
            }
        }
    }

    /// Get ascendant and related data
    private suspend fun getAscendantData(call: MethodCall, result: Result): Map<String, Double>? {
        return withContext(Dispatchers.IO) {
            try {
                val julianDay = call.argument<Double>("julianDay") ?: return@withContext null
                val latitude = call.argument<Double>("latitude") ?: 0.0
                val longitude = call.argument<Double>("longitude") ?: 0.0
                val houseSystem = call.argument<Int>("houseSystem") ?: 0

                swissEph?.getAscendantData(julianDay, latitude, longitude, houseSystem)
            } catch (e: Exception) {
                println("Error getting ascendant data: ${e.message}")
                null
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        swissEph?.cleanup()
        swissEph = null
    }
}

/// Stream handler for Swiss Ephemeris events
class SwissEphemerisStreamHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private val streamScope = CoroutineScope(Dispatchers.Main)

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun sendEvent(event: Map<String, Any>) {
        streamScope.launch {
            eventSink?.success(event)
        }
    }
}

/// Wrapper class for Swiss Ephemeris C library
class SwissEphemerisWrapper {
    private var isInitialized = false

    /// Initialize Swiss Ephemeris with ephemeris path
    fun initializeEphemeris(ephemerisPath: String): Boolean {
        return try {
            // Set ephemeris path for Swiss Ephemeris
            setEphemerisPath(ephemerisPath)

            // Test basic calculation to ensure initialization
            val testJd = 2451545.0 // J2000.0
            val testResult = getPlanetPositionInternal(testJd, 0, 0.0, 0.0, 1)

            isInitialized = true
            true
        } catch (e: Exception) {
            println("Swiss Ephemeris initialization failed: ${e.message}")
            false
        }
    }

    /// Get planet position with full precision
    fun getPlanetPosition(
        julianDay: Double,
        planet: Int,
        latitude: Double,
        longitude: Double,
        ayanamsha: Int
    ): PlanetPositionResult {
        if (!isInitialized) {
            throw Exception("Swiss Ephemeris not initialized")
        }

        return getPlanetPositionInternal(julianDay, planet, latitude, longitude, ayanamsha)
    }

    /// Get ayanamsha value
    fun getAyanamsha(julianDay: Double, ayanamshaType: Int): Double {
        if (!isInitialized) {
            throw Exception("Swiss Ephemeris not initialized")
        }

        return getAyanamshaInternal(julianDay, ayanamshaType)
    }

    /// Get house cusps for all 12 houses
    fun getHouseCusps(
        julianDay: Double,
        latitude: Double,
        longitude: Double,
        houseSystem: Int
    ): List<Double> {
        if (!isInitialized) {
            throw Exception("Swiss Ephemeris not initialized")
        }

        return getHouseCuspsInternal(julianDay, latitude, longitude, houseSystem)
    }

    /// Get ascendant and related house data
    fun getAscendantData(
        julianDay: Double,
        latitude: Double,
        longitude: Double,
        houseSystem: Int
    ): Map<String, Double> {
        if (!isInitialized) {
            throw Exception("Swiss Ephemeris not initialized")
        }

        return getAscendantDataInternal(julianDay, latitude, longitude, houseSystem)
    }

    /// Clean up resources
    fun cleanup() {
        // Clean up any resources if needed
        isInitialized = false
    }

    /// Native method declarations for Swiss Ephemeris C library
    private external fun setEphemerisPath(path: String): Boolean
    private external fun getPlanetPositionInternal(
        julianDay: Double,
        planet: Int,
        latitude: Double,
        longitude: Double,
        ayanamsha: Int
    ): PlanetPositionResult

    private external fun getAyanamshaInternal(julianDay: Double, ayanamshaType: Int): Double
    private external fun getHouseCuspsInternal(
        julianDay: Double,
        latitude: Double,
        longitude: Double,
        houseSystem: Int
    ): List<Double>

    private external fun getAscendantDataInternal(
        julianDay: Double,
        latitude: Double,
        longitude: Double,
        houseSystem: Int
    ): Map<String, Double>

    companion object {
        init {
            // Load the Swiss Ephemeris native library
            System.loadLibrary("swisseph")
        }
    }
}

/// Data class for planet position results
data class PlanetPositionResult(
    val longitude: Double,
    val latitude: Double,
    val distance: Double,
    val speed: Double
)
