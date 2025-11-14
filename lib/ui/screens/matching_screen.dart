import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skvk_application/core/design_system/theme/background_gradients.dart'; // For BackgroundGradients
import 'package:skvk_application/core/features/matching/providers/matching_provider.dart';
import 'package:skvk_application/core/features/matching/repositories/matching_repository.dart';
import 'package:skvk_application/core/features/user/providers/user_provider.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/models/user/user_model.dart';
import 'package:skvk_application/core/services/language/translation_service.dart';
import 'package:skvk_application/core/services/location/simple_location_service.dart';
import 'package:skvk_application/core/services/storage/matching_form_storage_service.dart';
import 'package:skvk_application/ui/components/app_bar/index.dart';
import 'package:skvk_application/ui/components/common/index.dart';
import 'package:skvk_application/ui/components/matching/index.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/screen_handlers.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

class MatchingScreen extends ConsumerStatefulWidget {
  const MatchingScreen({super.key});

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _resultsAnimationController;

  // Groom details
  final TextEditingController _groomNameController = TextEditingController();
  DateTime _groomDob = DateTime.now()
      .subtract(const Duration(days: 25 * 365)); // Current date - 25 years
  TimeOfDay _groomTob = TimeOfDay.now(); // Current time
  String _groomPob = 'New Delhi';
  double _groomLatitude = 28.6139; // New Delhi coordinates
  double _groomLongitude = 77.2090;

  // Bride details
  final TextEditingController _brideNameController = TextEditingController();
  DateTime _brideDob = DateTime.now()
      .subtract(const Duration(days: 25 * 365)); // Current date - 25 years
  TimeOfDay _brideTob = TimeOfDay.now(); // Current time
  String _bridePob = 'New Delhi';
  double _brideLatitude = 28.6139; // New Delhi coordinates
  double _brideLongitude = 77.2090;

  // Groom location search state
  final TextEditingController _groomLocationSearchController =
      TextEditingController();
  List<Map<String, dynamic>> _groomLocationSuggestions = [];
  bool _isSearchingGroomLocation = false;
  bool _showGroomLocationSuggestions = false;
  Timer? _groomSearchDebounceTimer;
  String? _groomLocationError;

  // Bride location search state
  final TextEditingController _brideLocationSearchController =
      TextEditingController();
  List<Map<String, dynamic>> _brideLocationSuggestions = [];
  bool _isSearchingBrideLocation = false;
  bool _showBrideLocationSuggestions = false;
  Timer? _brideSearchDebounceTimer;
  String? _brideLocationError;

  // Ayanamsha and house system selection for matching calculations
  String _selectedAyanamsha = 'lahiri';
  String _selectedHouseSystem = 'placidus';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _resultsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Start initial animation
    _animationController.forward();

    // Reset matching state to ensure we start with input screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchingProvider.notifier).resetState();
    });

    _initializeDataBasedOnGender();
    _loadStoredFormData();
  }

  /// Initialize data based on user gender for smart pre-population
  void _initializeDataBasedOnGender() {
    final currentUser = ref.read(userServiceProvider);

    if (currentUser != null) {
      if (currentUser.sex == 'Male') {
        // Male user - pre-populate groom data
        _groomNameController.text = currentUser.name;
        _groomDob = currentUser.dateOfBirth;
        _groomTob = currentUser.timeOfBirth is TimeOfDay
            ? currentUser.timeOfBirth as TimeOfDay
            : const TimeOfDay(hour: 12, minute: 0);
        _groomPob = currentUser.placeOfBirth;
        _groomLatitude = currentUser.latitude;
        _groomLongitude = currentUser.longitude;
        _groomLocationSearchController.text = _groomPob;

        _brideNameController.text = '';
        _brideDob = DateTime.now().subtract(const Duration(days: 25 * 365));
        _brideTob = TimeOfDay.now();
        _bridePob = 'New Delhi';
        _brideLatitude = 28.6139; // New Delhi coordinates
        _brideLongitude = 77.2090;
        _brideLocationSearchController.text = _bridePob;
      } else if (currentUser.sex == 'Female') {
        // Female user - pre-populate bride data
        _brideNameController.text = currentUser.name;
        _brideDob = currentUser.dateOfBirth;
        _brideTob = currentUser.timeOfBirth is TimeOfDay
            ? currentUser.timeOfBirth as TimeOfDay
            : const TimeOfDay(hour: 12, minute: 0);
        _bridePob = currentUser.placeOfBirth;
        _brideLatitude = currentUser.latitude;
        _brideLongitude = currentUser.longitude;
        _brideLocationSearchController.text = _bridePob;

        _groomNameController.text = '';
        _groomDob = DateTime.now().subtract(const Duration(days: 25 * 365));
        _groomTob = TimeOfDay.now();
        _groomPob = 'New Delhi';
        _groomLatitude = 28.6139; // New Delhi coordinates
        _groomLongitude = 77.2090;
        _groomLocationSearchController.text = _groomPob;
      }
    } else {
      // No user profile - use empty values
      _groomLocationSearchController.text = _groomPob;
      _brideLocationSearchController.text = _bridePob;
    }
  }

  /// Load stored form data from previous sessions
  Future<void> _loadStoredFormData() async {
    try {
      final storageService = MatchingFormStorageService.instance();
      await storageService.initialize();

      final groomData = await storageService.getGroomData();
      if (groomData != null) {
        setState(() {
          _groomNameController.text = groomData['name'] ?? '';
          _groomDob = DateTime.tryParse(groomData['dateOfBirth'] ?? '') ??
              DateTime.now().subtract(const Duration(days: 25 * 365));
          _groomTob = _parseTimeOfDay(groomData['timeOfBirth'] ?? '12:00');
          _groomPob = groomData['placeOfBirth'] ?? 'New Delhi';
          _groomLatitude =
              ((groomData['latitude'] as num?) ?? 28.6139).toDouble();
          _groomLongitude =
              ((groomData['longitude'] as num?) ?? 77.2090).toDouble();
          _groomLocationSearchController.text = _groomPob;
        });
      }

      final brideData = await storageService.getBrideData();
      if (brideData != null) {
        setState(() {
          _brideNameController.text = brideData['name'] ?? '';
          _brideDob = DateTime.tryParse(brideData['dateOfBirth'] ?? '') ??
              DateTime.now().subtract(const Duration(days: 25 * 365));
          _brideTob = _parseTimeOfDay(brideData['timeOfBirth'] ?? '12:00');
          _bridePob = brideData['placeOfBirth'] ?? 'New Delhi';
          _brideLatitude =
              ((brideData['latitude'] as num?) ?? 28.6139).toDouble();
          _brideLongitude =
              ((brideData['longitude'] as num?) ?? 77.2090).toDouble();
          _brideLocationSearchController.text = _bridePob;
        });
      }

      final ayanamsha = await storageService.getAyanamsha();
      if (ayanamsha != null) {
        setState(() {
          _selectedAyanamsha = ayanamsha.toLowerCase();
        });
      }

      final houseSystem = await storageService.getHouseSystem();
      if (houseSystem != null) {
        setState(() {
          _selectedHouseSystem = houseSystem.toLowerCase();
        });
      }

      await LoggingHelper.logInfo('Stored form data loaded successfully');
    } on Exception catch (e) {
      await LoggingHelper.logError('Failed to load stored form data: $e');
    }
  }

  /// Parse time string to TimeOfDay
  TimeOfDay _parseTimeOfDay(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 12;
        final minute = int.tryParse(parts[1]) ?? 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
    } on Exception {
      // Fallback to default time
    }
    return const TimeOfDay(hour: 12, minute: 0);
  }

  /// Save current form data for future sessions
  Future<void> _saveFormData() async {
    try {
      final storageService = MatchingFormStorageService.instance();
      await storageService.initialize();

      await storageService.saveGroomData(
        name: _groomNameController.text.trim(),
        dateOfBirth: _groomDob,
        timeOfBirth:
            '${_groomTob.hour.toString().padLeft(2, '0')}:${_groomTob.minute.toString().padLeft(2, '0')}',
        placeOfBirth: _groomPob,
        latitude: _groomLatitude,
        longitude: _groomLongitude,
      );

      await storageService.saveBrideData(
        name: _brideNameController.text.trim(),
        dateOfBirth: _brideDob,
        timeOfBirth:
            '${_brideTob.hour.toString().padLeft(2, '0')}:${_brideTob.minute.toString().padLeft(2, '0')}',
        placeOfBirth: _bridePob,
        latitude: _brideLatitude,
        longitude: _brideLongitude,
      );

      await storageService.saveAyanamsha(_selectedAyanamsha);

      await storageService.saveHouseSystem(_selectedHouseSystem);

      await LoggingHelper.logInfo('Form data saved successfully');
    } on Exception catch (e) {
      await LoggingHelper.logError('Failed to save form data: $e');
    }
  }

  /// Handle groom location search text changes with debouncing
  void _onGroomLocationSearchChanged(String query) {
    // Cancel previous timer if it exists
    _groomSearchDebounceTimer?.cancel();

    if (query.length >= 3) {
      _groomSearchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
        _searchGroomLocations(query);
      });
    } else {
      setState(() {
        _groomLocationSuggestions = [];
        _showGroomLocationSuggestions = false;
        _isSearchingGroomLocation = false;
        _groomLocationError = null;
      });
    }
  }

  /// Handle bride location search text changes with debouncing
  void _onBrideLocationSearchChanged(String query) {
    // Cancel previous timer if it exists
    _brideSearchDebounceTimer?.cancel();

    if (query.length >= 3) {
      _brideSearchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
        _searchBrideLocations(query);
      });
    } else {
      setState(() {
        _brideLocationSuggestions = [];
        _showBrideLocationSuggestions = false;
        _isSearchingBrideLocation = false;
        _brideLocationError = null;
      });
    }
  }

  /// Search for groom locations
  Future<void> _searchGroomLocations(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearchingGroomLocation = true;
      _groomLocationError = null;
    });

    try {
      final locationService = SimpleLocationService();
      final results = await locationService.searchPlaces(query);

      if (mounted) {
        final suggestions = results
            .map(
              (result) => {
                'name': result.placeName ?? 'Unknown Location',
                'latitude': result.latitude,
                'longitude': result.longitude,
              },
            )
            .toList();

        setState(() {
          _groomLocationSuggestions = suggestions;
          _showGroomLocationSuggestions = suggestions.isNotEmpty;
          _isSearchingGroomLocation = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _groomLocationError = 'Failed to search locations: $e';
          _isSearchingGroomLocation = false;
          _showGroomLocationSuggestions = false;
        });
      }
    }
  }

  /// Search for bride locations
  Future<void> _searchBrideLocations(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearchingBrideLocation = true;
      _brideLocationError = null;
    });

    try {
      final locationService = SimpleLocationService();
      final results = await locationService.searchPlaces(query);

      if (mounted) {
        final suggestions = results
            .map(
              (result) => {
                'name': result.placeName ?? 'Unknown Location',
                'latitude': result.latitude,
                'longitude': result.longitude,
              },
            )
            .toList();

        setState(() {
          _brideLocationSuggestions = suggestions;
          _showBrideLocationSuggestions = suggestions.isNotEmpty;
          _isSearchingBrideLocation = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _brideLocationError = 'Failed to search locations: $e';
          _isSearchingBrideLocation = false;
          _showBrideLocationSuggestions = false;
        });
      }
    }
  }

  /// Select Groom location suggestion
  void _selectGroomLocationSuggestion(Map<String, dynamic> location) {
    setState(() {
      _groomPob = location['name'] ?? '';
      _groomLatitude = location['latitude'] ?? 0.0;
      _groomLongitude = location['longitude'] ?? 0.0;
      _groomLocationSearchController.text = _groomPob;
      _showGroomLocationSuggestions = false;
      _groomLocationError = null;
    });
  }

  /// Select Bride location suggestion
  void _selectBrideLocationSuggestion(Map<String, dynamic> location) {
    setState(() {
      _bridePob = location['name'] ?? '';
      _brideLatitude = location['latitude'] ?? 0.0;
      _brideLongitude = location['longitude'] ?? 0.0;
      _brideLocationSearchController.text = _bridePob;
      _showBrideLocationSuggestions = false;
      _brideLocationError = null;
    });
  }

  // have been replaced with reusable LocationSearchField component

  @override
  void dispose() {
    _animationController.dispose();
    _resultsAnimationController.dispose();
    _groomNameController.dispose();
    _brideNameController.dispose();
    _groomLocationSearchController.dispose();
    _brideLocationSearchController.dispose();
    _groomSearchDebounceTimer?.cancel();
    _brideSearchDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _performMatching() async {
    await LoggingHelper.logInfo('Perform Matching button pressed!',
        source: 'MatchingScreen',);

    if (_groomNameController.text.trim().isEmpty ||
        _brideNameController.text.trim().isEmpty) {
      await LoggingHelper.logWarning(
          'Matching validation failed: Missing names',
          source: 'MatchingScreen',);
      _showErrorDialog('Please enter names for both groom and bride');
      return;
    }

    await LoggingHelper.logDebug('Validation passed, proceeding with matching',
        source: 'MatchingScreen',);

    try {
      await LoggingHelper.logInfo(
          'Starting kundali matching process - groom: ${_groomNameController.text.trim()}, bride: ${_brideNameController.text.trim()}',);

      final groomLocalDateTime = DateTime(
        _groomDob.year,
        _groomDob.month,
        _groomDob.day,
        _groomTob.hour,
        _groomTob.minute,
      );

      final brideLocalDateTime = DateTime(
        _brideDob.year,
        _brideDob.month,
        _brideDob.day,
        _brideTob.hour,
        _brideTob.minute,
      );

      await LoggingHelper.logInfo(
          'Birth data prepared for astrology calculations - groomLocal: ${groomLocalDateTime.toIso8601String()}, brideLocal: ${brideLocalDateTime.toIso8601String()}',);

      // No need to fetch separately - this reduces API calls from 3 to 1

      final currentUser = ref.read(userServiceProvider);

      final isGroomUser = currentUser != null &&
          _isUserBirthData(
            groomLocalDateTime,
            _groomLatitude,
            _groomLongitude,
            currentUser,
          );

      final isBrideUser = currentUser != null &&
          _isUserBirthData(
            brideLocalDateTime,
            _brideLatitude,
            _brideLongitude,
            currentUser,
          );

      // Timezone conversion will be handled by AstrologyServiceBridge
      final groomData = PartnerData(
        name: _groomNameController.text.trim(),
        dateOfBirth: groomLocalDateTime,
        timeOfBirth: TimeOfDay.fromDateTime(groomLocalDateTime),
        placeOfBirth: _groomPob,
        latitude: _groomLatitude,
        longitude: _groomLongitude,
        currentUser: isGroomUser ? currentUser : null,
      );

      final brideData = PartnerData(
        name: _brideNameController.text.trim(),
        dateOfBirth: brideLocalDateTime,
        timeOfBirth: TimeOfDay.fromDateTime(brideLocalDateTime),
        placeOfBirth: _bridePob,
        latitude: _brideLatitude,
        longitude: _brideLongitude,
        currentUser: isBrideUser ? currentUser : null,
      );

      // Perform matching through the use case with both persons
      await LoggingHelper.logInfo(
        'Performing kundali matching calculations - groom: ${groomData.name}, bride: ${brideData.name}',
        source: 'MatchingScreen',
      );

      // Pass current user to optimize cache usage
      await ref.read(matchingProvider.notifier).performMatching(
            groomData,
            brideData,
            ayanamsha: _selectedAyanamsha,
            houseSystem: _selectedHouseSystem,
          );

      await LoggingHelper.logInfo('Kundali matching completed successfully',
          source: 'MatchingScreen',);

      await _saveFormData();

      // Start results animation when matching is complete
      unawaited(_resultsAnimationController.forward());
    } on Exception catch (e) {
      await LoggingHelper.logError('Kundali matching failed: $e');
      // Error is already handled by the provider - it will set errorMessage
      // The error screen will be displayed automatically via the build method
    }
  }

  /// Check if birth data matches current user
  bool _isUserBirthData(
    DateTime localBirthDateTime,
    double latitude,
    double longitude,
    UserModel user,
  ) {
    // Compare birth date/time (within 1 minute tolerance)
    final userBirthDateTime = user.localBirthDateTime;
    final timeDiff = localBirthDateTime.difference(userBirthDateTime).abs();
    if (timeDiff.inMinutes > 1) {
      return false;
    }

    // Compare location (within 0.01 degree tolerance ~ 1km)
    final latDiff = (latitude - user.latitude).abs();
    final lonDiff = (longitude - user.longitude).abs();
    if (latDiff > 0.01 || lonDiff > 0.01) {
      return false;
    }

    return true;
  }

  /// Show error dialog with retry option
  void _showErrorDialog(String message, {bool showRetry = true}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: ThemeHelpers.getErrorColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 24),
            ),
            ResponsiveSystem.sizedBox(
              context,
              width: ResponsiveSystem.spacing(context, baseSpacing: 12),
            ),
            Expanded(
              child: Text(
                'Error',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                  fontWeight: FontWeight.bold,
                  color: ThemeHelpers.getPrimaryTextColor(context),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
            color: ThemeHelpers.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          if (showRetry) ...[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: ThemeHelpers.getSecondaryTextColor(context),
                ),
              ),
            ),
            ModernButton(
              text: 'Retry',
              icon: LucideIcons.refreshCw,
              onPressed: () {
                Navigator.of(context).pop();
                _performMatching();
              },
              width: ResponsiveSystem.screenWidth(context) * 0.25,
            ),
          ] else ...[
            ModernButton(
              text: 'OK',
              onPressed: () => Navigator.of(context).pop(),
              width: ResponsiveSystem.screenWidth(context) * 0.2,
            ),
          ],
        ],
      ),
    );
  }

  /// Build partner details section
  List<Widget> _buildPartnerDetailsSection(
    TranslationService translationService,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return [
      SectionTitle(
        title: translationService.translateHeader(
          'compatibility_details',
          fallback: 'Compatibility Details',
        ),
      ),

      // Responsive layout: Row on larger screens, Column on small screens
      if (isSmallScreen)
        Column(
          children: [
            // Groom Name
            NameField(
              controller: _groomNameController,
              label: 'Groom Name',
              icon: LucideIcons.user,
              hintText: 'Enter groom name',
              onChanged: (value) => setState(() {}),
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),
            // Bride Name
            NameField(
              controller: _brideNameController,
              label: 'Bride Name',
              icon: LucideIcons.user,
              hintText: 'Enter bride name',
              onChanged: (value) => setState(() {}),
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),
            // Groom Date of Birth
            DateField(
              label: 'Groom Date of Birth',
              selectedDate: _groomDob,
              onDateChanged: (date) {
                setState(() {
                  _groomDob = date;
                });
              },
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),
            // Bride Date of Birth
            DateField(
              label: 'Bride Date of Birth',
              selectedDate: _brideDob,
              onDateChanged: (date) {
                setState(() {
                  _brideDob = date;
                });
              },
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),
            // Groom Time of Birth
            TimeField(
              label: 'Groom Time of Birth',
              selectedTime: _groomTob,
              onTimeChanged: (time) {
                setState(() {
                  _groomTob = time;
                });
              },
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),
            // Bride Time of Birth
            TimeField(
              label: 'Bride Time of Birth',
              selectedTime: _brideTob,
              onTimeChanged: (time) {
                setState(() {
                  _brideTob = time;
                });
              },
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),
            // Groom Place of Birth
            LocationSearchField(
              controller: _groomLocationSearchController,
              label: "Groom's Place of Birth",
              hintText: "Type to search for groom's birth location",
              onChanged: _onGroomLocationSearchChanged,
              onTap: () {
                setState(() {
                  _groomLocationError = null;
                  _showGroomLocationSuggestions =
                      _groomLocationSuggestions.isNotEmpty;
                });
              },
              suggestions: _groomLocationSuggestions,
              showSuggestions: _showGroomLocationSuggestions,
              isSearching: _isSearchingGroomLocation,
              error: _groomLocationError,
              onSuggestionSelected: _selectGroomLocationSuggestion,
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),
            // Bride Place of Birth
            LocationSearchField(
              controller: _brideLocationSearchController,
              label: "Bride's Place of Birth",
              hintText: "Type to search for bride's birth location",
              onChanged: _onBrideLocationSearchChanged,
              onTap: () {
                setState(() {
                  _brideLocationError = null;
                  _showBrideLocationSuggestions =
                      _brideLocationSuggestions.isNotEmpty;
                });
              },
              suggestions: _brideLocationSuggestions,
              showSuggestions: _showBrideLocationSuggestions,
              isSearching: _isSearchingBrideLocation,
              error: _brideLocationError,
              onSuggestionSelected: _selectBrideLocationSuggestion,
            ),
          ],
        )
      else
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: NameField(
                    controller: _groomNameController,
                    label: 'Groom Name',
                    icon: LucideIcons.user,
                    hintText: 'Enter groom name',
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 16),
                ),
                Expanded(
                  child: NameField(
                    controller: _brideNameController,
                    label: 'Bride Name',
                    icon: LucideIcons.user,
                    hintText: 'Enter bride name',
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ],
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),

            // Second Row: Date of Birth
            Row(
              children: [
                Expanded(
                  child: DateField(
                    label: 'Groom Date of Birth',
                    selectedDate: _groomDob,
                    onDateChanged: (date) {
                      setState(() {
                        _groomDob = date;
                      });
                    },
                  ),
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 16),
                ),
                Expanded(
                  child: DateField(
                    label: 'Bride Date of Birth',
                    selectedDate: _brideDob,
                    onDateChanged: (date) {
                      setState(() {
                        _brideDob = date;
                      });
                    },
                  ),
                ),
              ],
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),

            // Third Row: Time of Birth
            Row(
              children: [
                Expanded(
                  child: TimeField(
                    label: 'Groom Time of Birth',
                    selectedTime: _groomTob,
                    onTimeChanged: (time) {
                      setState(() {
                        _groomTob = time;
                      });
                    },
                  ),
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 16),
                ),
                Expanded(
                  child: TimeField(
                    label: 'Bride Time of Birth',
                    selectedTime: _brideTob,
                    onTimeChanged: (time) {
                      setState(() {
                        _brideTob = time;
                      });
                    },
                  ),
                ),
              ],
            ),
            ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 16),
            ),

            // Fourth Row: Place of Birth
            Row(
              children: [
                Expanded(
                  child: LocationSearchField(
                    controller: _groomLocationSearchController,
                    label: "Groom's Place of Birth",
                    hintText: "Type to search for groom's birth location",
                    onChanged: _onGroomLocationSearchChanged,
                    onTap: () {
                      setState(() {
                        _groomLocationError = null;
                        _showGroomLocationSuggestions =
                            _groomLocationSuggestions.isNotEmpty;
                      });
                    },
                    suggestions: _groomLocationSuggestions,
                    showSuggestions: _showGroomLocationSuggestions,
                    isSearching: _isSearchingGroomLocation,
                    error: _groomLocationError,
                    onSuggestionSelected: _selectGroomLocationSuggestion,
                  ),
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 16),
                ),
                Expanded(
                  child: LocationSearchField(
                    controller: _brideLocationSearchController,
                    label: "Bride's Place of Birth",
                    hintText: "Type to search for bride's birth location",
                    onChanged: _onBrideLocationSearchChanged,
                    onTap: () {
                      setState(() {
                        _brideLocationError = null;
                        _showBrideLocationSuggestions =
                            _brideLocationSuggestions.isNotEmpty;
                      });
                    },
                    suggestions: _brideLocationSuggestions,
                    showSuggestions: _showBrideLocationSuggestions,
                    isSearching: _isSearchingBrideLocation,
                    error: _brideLocationError,
                    onSuggestionSelected: _selectBrideLocationSuggestion,
                  ),
                ),
              ],
            ),
          ],
        ),
    ];
  }

  /// Build entire content section
  List<Widget> _buildContentSection(
    TranslationService translationService,
    MatchingState matchingState,
  ) {
    return [
      ..._buildPartnerDetailsSection(translationService),
      ..._buildCalculationSection(translationService, matchingState),
    ];
  }

  /// Build calculation and matching section
  List<Widget> _buildCalculationSection(
    TranslationService translationService,
    MatchingState matchingState,
  ) {
    return [
      ResponsiveSystem.sizedBox(
        context,
        height: ResponsiveSystem.spacing(context, baseSpacing: 24),
      ),

      // Calculation System Selection (Ayanamsha and House System)
      CalculationSystemSelector(
        selectedAyanamsha: _selectedAyanamsha,
        selectedHouseSystem: _selectedHouseSystem,
        onAyanamshaChanged: (value) {
          setState(() {
            _selectedAyanamsha = value;
          });
          MatchingFormStorageService.instance().saveAyanamsha(value);
        },
        onHouseSystemChanged: (value) {
          setState(() {
            _selectedHouseSystem = value;
          });
          MatchingFormStorageService.instance().saveHouseSystem(value);
        },
      ),
      ResponsiveSystem.sizedBox(
        context,
        height: ResponsiveSystem.spacing(context, baseSpacing: 24),
      ),

      MatchButton(
        onPressed: () async {
          if (!matchingState.isLoading) {
            await LoggingHelper.logInfo(
                'Button pressed! Calling _performMatching...',);
            unawaited(_performMatching());
          }
        },
        isLoading: matchingState.isLoading,
        text: translationService.translateContent(
          'perform_matching',
          fallback: 'Perform Matching',
        ),
        icon: LucideIcons.heart,
      ),
    ];
  }

  // have been replaced with CalculationSystemSelector component

  @override
  Widget build(BuildContext context) {
    final matchingState = ref.watch(matchingProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: BackgroundGradients.getBackgroundGradient(
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        child: matchingState.isLoading
            ? const MatchingLoadingScreen()
            : matchingState.hasError
                ? MatchingErrorScreen(
                    errorMessage: matchingState.errorMessage,
                    onRetry: _performMatching,
                    onGoBack: () {
                      ref.read(matchingProvider.notifier).editPartnerDetails();
                    },
                  )
                : matchingState.showResults
                    ? AnimatedOpacity(
                        opacity: 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _buildResultsScreen(matchingState),
                      )
                    : _buildInputScreen(context),
      ),
    );
  }

  Widget _buildInputScreen(BuildContext context) {
    final matchingState = ref.watch(matchingProvider);
    final translationService = ref.watch(translationServiceProvider);

    return CustomScrollView(
      slivers: [
        // Collapsible Hero Section using SliverAppBar
        SliverAppBarWithHero(
          title: translationService.translateHeader(
            'kundali_matching',
            fallback: 'Kundali Matching',
          ),
          heroBackground:
              MatchingHeroSection(translationService: translationService),
          expandedHeight: ResponsiveSystem.spacing(context, baseSpacing: 250),
          leadingIcon: LucideIcons.house,
          onLeadingTap: () => Navigator.of(context).pop(),
          onProfileTap: () =>
              ScreenHandlers.handleProfileTap(context, ref, translationService),
          onLanguageChanged: (value) =>
              ScreenHandlers.handleLanguageChange(ref, value),
          onThemeChanged: (value) =>
              ScreenHandlers.handleThemeChange(ref, value),
        ),

        // Content
        SliverPadding(
          padding: ResponsiveSystem.all(context, baseSpacing: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              _buildContentSection(translationService, matchingState),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsScreen(MatchingState matchingState) {
    final translationService = ref.watch(translationServiceProvider);

    return Scaffold(
      backgroundColor: ThemeHelpers.getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          // SliverAppBar for consistency
          SliverAppBarWithHero(
            title: translationService.translateHeader(
              'kundali_matching',
              fallback: 'Kundali Matching',
            ),
            expandedHeight: ResponsiveSystem.spacing(context, baseSpacing: 60),
            floating: false,
            snap: false,
            leadingIcon: LucideIcons.house,
            onLeadingTap: () => Navigator.of(context).pop(),
            onProfileTap: () => ScreenHandlers.handleProfileTap(
                context, ref, translationService,),
            onLanguageChanged: (value) =>
                ScreenHandlers.handleLanguageChange(ref, value),
            onThemeChanged: (value) =>
                ScreenHandlers.handleThemeChange(ref, value),
          ),

          // Hero Section
          SliverToBoxAdapter(
            child: MatchingResultsHeroSection(
                compatibilityScore: matchingState.compatibilityScore,),
          ),

          // Spacing between hero and content
          SliverToBoxAdapter(
            child: ResponsiveSystem.sizedBox(
              context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 40),
            ),
          ),

          // Content
          SliverPadding(
            padding: ResponsiveSystem.all(context, baseSpacing: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Responsive layout: Row on larger screens, Column on small screens
                Builder(
                  builder: (context) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isSmallScreen = screenWidth < 600;

                    if (isSmallScreen) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Groom Details
                          PartnerDetailsCard(
                            name: _groomNameController.text,
                            dateOfBirth: _groomDob,
                            timeOfBirth: _groomTob,
                            placeOfBirth: _groomPob,
                            nakshatram: matchingState
                                .kootaDetails?['person1Nakshatram'],
                            raasi: matchingState.kootaDetails?['person1Raasi'],
                            pada: matchingState.kootaDetails?['person1Pada'],
                            title: 'Groom Details',
                          ),
                          ResponsiveSystem.sizedBox(
                            context,
                            height: ResponsiveSystem.spacing(
                              context,
                              baseSpacing: 16,
                            ),
                          ),
                          // Bride Details
                          PartnerDetailsCard(
                            name: _brideNameController.text,
                            dateOfBirth: _brideDob,
                            timeOfBirth: _brideTob,
                            placeOfBirth: _bridePob,
                            nakshatram: matchingState
                                .kootaDetails?['person2Nakshatram'],
                            raasi: matchingState.kootaDetails?['person2Raasi'],
                            pada: matchingState.kootaDetails?['person2Pada'],
                            title: 'Bride Details',
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Groom Details
                          Expanded(
                            child: PartnerDetailsCard(
                              name: _groomNameController.text,
                              dateOfBirth: _groomDob,
                              timeOfBirth: _groomTob,
                              placeOfBirth: _groomPob,
                              nakshatram: matchingState
                                  .kootaDetails?['person1Nakshatram'],
                              raasi:
                                  matchingState.kootaDetails?['person1Raasi'],
                              pada: matchingState.kootaDetails?['person1Pada'],
                              title: 'Groom Details',
                            ),
                          ),
                          ResponsiveSystem.sizedBox(
                            context,
                            width: ResponsiveSystem.spacing(
                              context,
                              baseSpacing: 16,
                            ),
                          ),
                          // Bride Details
                          Expanded(
                            child: PartnerDetailsCard(
                              name: _brideNameController.text,
                              dateOfBirth: _brideDob,
                              timeOfBirth: _brideTob,
                              placeOfBirth: _bridePob,
                              nakshatram: matchingState
                                  .kootaDetails?['person2Nakshatram'],
                              raasi:
                                  matchingState.kootaDetails?['person2Raasi'],
                              pada: matchingState.kootaDetails?['person2Pada'],
                              title: 'Bride Details',
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  height: ResponsiveSystem.spacing(context, baseSpacing: 24),
                ),
                // Large score display similar to Pradakshana counter
                Container(
                  width: double.infinity,
                  padding: ResponsiveSystem.all(context, baseSpacing: 32),
                  child: CompatibilityScoreDisplay(
                    score: matchingState.compatibilityScore,
                    totalPoints: matchingState.totalScore ??
                        MatchingInsightsHelper.getTotalScore(matchingState),
                    maxPoints: 36,
                    scaleAnimation: Tween<double>(
                      begin: 1,
                      end: 1.1,
                    ).animate(
                      CurvedAnimation(
                        parent: _resultsAnimationController,
                        curve: Curves.elasticOut,
                      ),
                    ),
                  ),
                ),
                ResponsiveSystem.sizedBox(
                  context,
                  height: ResponsiveSystem.spacing(context, baseSpacing: 16),
                ),
                _buildSmallCompatibilityButton(),
                ResponsiveSystem.sizedBox(
                  context,
                  height: ResponsiveSystem.spacing(context, baseSpacing: 24),
                ),
                _buildDetailedKootaAnalysis(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedKootaAnalysis() {
    final matchingState = ref.watch(matchingProvider);

    final kootaEntries = (matchingState.kootaDetails ?? {})
        .entries
        .where(
          (entry) =>
              KootaInfoHelper.isKootaScore(entry.key) &&
              entry.key != 'totalPoints',
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Detailed Guna Milan Analysis'),
        ResponsiveSystem.sizedBox(
          context,
          height: ResponsiveSystem.spacing(context, baseSpacing: 16),
        ),

        // Two-column layout for koota cards
        KootaGridLayout(kootaEntries: kootaEntries),

        ResponsiveSystem.sizedBox(
          context,
          height: ResponsiveSystem.spacing(context, baseSpacing: 16),
        ),
        ScoreSummaryCard(matchingState: matchingState),
        ResponsiveSystem.sizedBox(
          context,
          height: ResponsiveSystem.spacing(context, baseSpacing: 24),
        ),
        CompatibilityInsightsCard(matchingState: matchingState),
        ResponsiveSystem.sizedBox(
          context,
          height: ResponsiveSystem.spacing(context, baseSpacing: 24),
        ),
        const CalculationInfoCard(),
      ],
    );
  }

  // have been moved to MatchingInsightsHelper, ScoreSummaryCard, CompatibilityInsightsCard, and CalculationInfoCard

  /// Build small compatibility button for top of results
  Widget _buildSmallCompatibilityButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InfoCard(
          child: ModernButton(
            text: 'Modify Details',
            icon: LucideIcons.pencil,
            onPressed: () async {
              // Reset the matching state to go back to input screen
              ref.read(matchingProvider.notifier).resetState();

              // Keep all existing form data - don't reset values
              await LoggingHelper.logInfo(
                  'Check Different Compatibility - keeping existing form data',);
            },
            width: ResponsiveSystem.screenWidth(context) * 0.4,
            height: ResponsiveSystem.buttonHeight(context, baseHeight: 40),
          ),
        ),
      ],
    );
  }
}
