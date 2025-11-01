SKVK Application — Full Production-grade Prototype

What's new in this package:
 - Full 36-point Guna Milan logic implemented in Dart
 - Expanded festival rule engine with sunrise/sunset tie-break hooks
 - Swiss Ephemeris FFI bindings scaffold that call swe_calc_ut; include the native Swiss Ephemeris library per platform to enable high-precision positions
 - Helper scripts to build Swiss Ephemeris (outline), and GitHub Actions CI for dart analyze
 - All calculations are dynamic and rule-driven; no static festival tables required

## Swiss Ephemeris Licensing

**IMPORTANT:** This application uses Swiss Ephemeris under a professional commercial license.

- **License:** Professional Commercial License
- **Copyright:** © Astrodienst AG, Zurich, Switzerland
- **Website:** https://www.astro.com/swisseph/
- **Email:** swiss@astro.ch

This license is required for commercial applications that monetize through advertisements or paid features. The license covers Android, iOS, and Web platforms.

### License Compliance

The application includes proper attribution and license information:
- About screen with Swiss Ephemeris attribution
- Third-party licenses screen with full license details
- Source code copyright notices in all Swiss Ephemeris related files
- Build configuration with license metadata

### For Development

Swiss Ephemeris native libraries are NOT included due to licensing and per-platform binaries. You must build them following the build scripts and place them in the right runtime locations.

Run the app (fallback mode without FFI):
  flutter pub get
  flutter run

To enable high-precision ephemeris (recommended):
  - Build Swiss Ephemeris for your target platform (see build_swisseph.sh and build_swisseph_android.sh)
  - Place the resulting shared library in the runtime path (Android: android/src/main/jniLibs/<abi>/; Linux/macOS: app bundle folder or /usr/local/lib)
  - The app will attempt to load the library at runtime and use FFI. If loading fails it continues with fallback calculations.
