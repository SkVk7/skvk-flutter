<!-- 808f8f1f-27ef-49ab-9c95-5788703788e3 c195d8b9-cabd-43b8-91e9-de44f0c55601 -->
# Swiss Ephemeris Production Licensing Implementation

## License Requirement

**Your app requires a Professional/Commercial License** because:

- Advertisement monetization = commercial use
- Future paid features (AI chatbot)
- Closed-source distribution
- Multi-platform commercial deployment

**Cost:** €750-1,500 (one-time fee)

## Phase 1: License Acquisition

### Contact Astrodienst AG

- **Website:** https://www.astro.com/swisseph/
- **Email:** swiss@astro.ch
- **Request:** Professional license for commercial Flutter/mobile application
- **Provide:** App name, description, platforms (Android/iOS/Web), monetization model

### What to Expect

- License agreement document
- Invoice for payment
- License certificate with your app details
- Usage guidelines and attribution requirements

## Phase 2: Legal Compliance Implementation

### 1. Add License Documentation

Create `/licenses/SWISS_EPHEMERIS_LICENSE.txt` with:

- Your license certificate details
- License number and validity
- Permitted usage terms
- Attribution requirements

### 2. Update App Legal Files

- Add Swiss Ephemeris attribution to About screen
- Include license info in Settings > Legal/Licenses
- Update Terms of Service
- Add to Privacy Policy (if collecting astronomical data)

### 3. Source Code Attribution

Add copyright notices to Swiss Ephemeris related files:

- `lib/services/swiss_ephemeris_service.dart`
- `lib/engine/enhanced_astro_core.dart`
- `android/app/src/main/cpp/swisseph_wrapper.cpp`
- `android/app/src/main/kotlin/.../SwissEphemerisPlugin.kt`

## Phase 3: App Integration

### 1. Create Attribution Screen

Add "About > Third-Party Licenses" showing:

```
Swiss Ephemeris
© Astrodienst AG, Zurich, Switzerland
Professional License #[YOUR_LICENSE_NUMBER]
https://www.astro.com/swisseph/
```

### 2. Add to Settings Screen

Path: Settings > About > Licenses

- Display all third-party libraries
- Prominent Swiss Ephemeris attribution
- Link to full license text

### 3. Update App Store Listings

**Google Play & App Store:**

- Mention Swiss Ephemeris in description (optional but recommended)
- Add to "What's New" for transparency
- Include in app screenshots if showing accuracy features

## Phase 4: Build Configuration

### 1. Update ProGuard Rules

Ensure Swiss Ephemeris classes are preserved:

```kotlin
-keep class com.supernova.skvk_application.SwissEphemeris** { *; }
-keep class swisseph.** { *; }
```

### 2. Add Build Metadata

Update `android/app/build.gradle.kts`:

```kotlin
buildConfigField("String", "SWISS_EPH_LICENSE", "\"[LICENSE_NUMBER]\"")
```

### 3. Verify Native Libraries

Ensure Swiss Ephemeris `.so` files are included in release builds:

- `android/app/src/main/jniLibs/arm64-v8a/libswisseph.so`
- iOS framework if applicable

## Phase 5: Alternative Plan (If Budget Constrained)

### Option A: Remove Swiss Ephemeris Temporarily

1. Disable Swiss Ephemeris initialization in `enhanced_astro_core.dart`
2. Use fallback mathematical calculations (already implemented)
3. Update accuracy claims in app description
4. Add Swiss Ephemeris later when revenue permits

### Option B: Use Free Alternatives

1. Implement VSOP87 theory (free for commercial use)
2. Use NASA JPL ephemeris (public domain)
3. Trade-off: Slightly less accurate (arcseconds vs sub-arcseconds)

## Key Files to Modify

1. **Legal/Attribution:**

   - `lib/screens/about_screen.dart` (create if not exists)
   - `lib/screens/licenses_screen.dart` (create)
   - `android/app/src/main/res/raw/licenses.txt`

2. **Configuration:**

   - `android/app/build.gradle.kts` (ProGuard rules)
   - `android/app/proguard-rules.pro`
   - `lib/config/app_config.dart` (license info)

3. **Documentation:**

   - `README.md` (update with license info)
   - `LICENSE` (your app license)
   - `licenses/SWISS_EPHEMERIS_LICENSE.txt` (new file)

## Compliance Checklist

- [ ] Purchase professional license from Astrodienst AG
- [ ] Receive and store license certificate
- [ ] Add license documentation to project
- [ ] Implement attribution in app UI
- [ ] Update source code copyright notices
- [ ] Configure build system for license compliance
- [ ] Update app store listings
- [ ] Test license display in production build
- [ ] Keep license documentation for audits

## Important Notes

1. **Do not release to production without proper licensing** - This could result in legal issues
2. **Keep license certificate secure** - Store in private repository or secure location
3. **Annual renewal may be required** - Check license terms
4. **Attribution is mandatory** - Even with paid license, attribution is typically required
5. **Document everything** - Keep all correspondence with Astrodienst AG

## Timeline Estimate

- License acquisition: 1-2 weeks (includes communication and payment)
- Implementation: 2-3 days
- Testing and verification: 1 day
- **Total:** ~3 weeks from start to production-ready

## Cost Summary

- Swiss Ephemeris Professional License: €750-1,500 (one-time)
- Implementation time: ~3 days development
- No recurring costs (unless license requires renewal)

## Next Steps

1. **Immediate:** Contact Astrodienst AG to initiate license purchase
2. **While waiting:** Implement attribution screens and documentation structure
3. **After license received:** Add license details and deploy to production
4. **Alternative:** If budget is issue, disable Swiss Ephemeris and use fallback calculations

### To-dos

- [ ] Contact Astrodienst AG (swiss@astro.ch) to purchase professional Swiss Ephemeris license for commercial app
- [ ] Create licenses directory and documentation structure for Swiss Ephemeris license certificate
- [ ] Create About/Licenses screens in app to display Swiss Ephemeris attribution and license info
- [ ] Add copyright notices to all Swiss Ephemeris related source files (Dart, Kotlin, C++)
- [ ] Update ProGuard rules and build configuration to preserve Swiss Ephemeris classes and add license metadata
- [ ] Update Google Play and App Store descriptions to include Swiss Ephemeris attribution
- [ ] Test production build to ensure all license attributions are visible and properly displayed