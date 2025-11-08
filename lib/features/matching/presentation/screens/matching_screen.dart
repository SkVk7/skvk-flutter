import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/utils/astrology/ayanamsha_info.dart';
import '../../../../core/utils/astrology/house_system_info.dart';
import '../../../../shared/widgets/common/centralized_widgets.dart';
import '../../../../shared/widgets/common/centralized_animations.dart'
    as animations;
import '../../../../core/services/language/translation_service.dart';
import '../../../../core/services/location/simple_location_service.dart';
import '../../../../core/services/shared/centralized_services.dart';
import '../../../../core/services/storage/matching_form_storage_service.dart';
import '../providers/matching_provider.dart';
import '../../domain/repositories/matching_repository.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../../../core/services/language/language_service.dart';
import '../../../../core/design_system/theme/theme_provider.dart';
import '../../../../core/services/user/user_service.dart' as user_service;
import '../../../../core/models/user/user_model.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/validation/profile_completion_checker.dart';
import '../../../../core/logging/logging_helper.dart';
import '../../../../features/user/presentation/screens/user_edit_screen.dart';

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

    // Initialize centralized animation controllers
    _animationController =
        animations.CentralizedAnimationController.createStandard(this);
    _resultsAnimationController =
        animations.CentralizedAnimationController.createSlow(this);

    // Start initial animation
    _animationController.forward();

    // Reset matching state to ensure we start with input screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchingProvider.notifier).resetState();
    });

    // Initialize data based on user gender and load stored form data
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

        // Set bride data to defaults
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

        // Set groom data to defaults
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
      final storageService = MatchingFormStorageService.instance;
      await storageService.initialize();

      // Load groom data
      final groomData = await storageService.getGroomData();
      if (groomData != null) {
        setState(() {
          _groomNameController.text = groomData['name'] ?? '';
          _groomDob = DateTime.tryParse(groomData['dateOfBirth'] ?? '') ??
              DateTime.now().subtract(const Duration(days: 25 * 365));
          _groomTob = _parseTimeOfDay(groomData['timeOfBirth'] ?? '12:00');
          _groomPob = groomData['placeOfBirth'] ?? 'New Delhi';
          _groomLatitude = (groomData['latitude'] ?? 28.6139).toDouble();
          _groomLongitude = (groomData['longitude'] ?? 77.2090).toDouble();
          _groomLocationSearchController.text = _groomPob;
        });
      }

      // Load bride data
      final brideData = await storageService.getBrideData();
      if (brideData != null) {
        setState(() {
          _brideNameController.text = brideData['name'] ?? '';
          _brideDob = DateTime.tryParse(brideData['dateOfBirth'] ?? '') ??
              DateTime.now().subtract(const Duration(days: 25 * 365));
          _brideTob = _parseTimeOfDay(brideData['timeOfBirth'] ?? '12:00');
          _bridePob = brideData['placeOfBirth'] ?? 'New Delhi';
          _brideLatitude = (brideData['latitude'] ?? 28.6139).toDouble();
          _brideLongitude = (brideData['longitude'] ?? 77.2090).toDouble();
          _brideLocationSearchController.text = _bridePob;
        });
      }

      // Load ayanamsha selection
      final ayanamsha = await storageService.getAyanamsha();
      if (ayanamsha != null) {
        setState(() {
          _selectedAyanamsha = ayanamsha.toLowerCase();
        });
      }

      // Load house system selection
      final houseSystem = await storageService.getHouseSystem();
      if (houseSystem != null) {
        setState(() {
          _selectedHouseSystem = houseSystem.toLowerCase();
        });
      }

      CentralizedLoggingService.instance.logInfo(
          'Stored form data loaded successfully',
          tag: 'MatchingScreen');
    } catch (e) {
      CentralizedLoggingService.instance.logError(
          'Failed to load stored form data',
          tag: 'MatchingScreen',
          error: e);
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
    } catch (e) {
      // Fallback to default time
    }
    return const TimeOfDay(hour: 12, minute: 0);
  }

  /// Save current form data for future sessions
  Future<void> _saveFormData() async {
    try {
      final storageService = MatchingFormStorageService.instance;
      await storageService.initialize();

      // Save groom data
      await storageService.saveGroomData(
        name: _groomNameController.text.trim(),
        dateOfBirth: _groomDob,
        timeOfBirth:
            '${_groomTob.hour.toString().padLeft(2, '0')}:${_groomTob.minute.toString().padLeft(2, '0')}',
        placeOfBirth: _groomPob,
        latitude: _groomLatitude,
        longitude: _groomLongitude,
      );

      // Save bride data
      await storageService.saveBrideData(
        name: _brideNameController.text.trim(),
        dateOfBirth: _brideDob,
        timeOfBirth:
            '${_brideTob.hour.toString().padLeft(2, '0')}:${_brideTob.minute.toString().padLeft(2, '0')}',
        placeOfBirth: _bridePob,
        latitude: _brideLatitude,
        longitude: _brideLongitude,
      );

      // Save ayanamsha selection
      await storageService.saveAyanamsha(_selectedAyanamsha);

      // Save house system selection
      await storageService.saveHouseSystem(_selectedHouseSystem);

      CentralizedLoggingService.instance
          .logInfo('Form data saved successfully', tag: 'MatchingScreen');
    } catch (e) {
      CentralizedLoggingService.instance.logError('Failed to save form data',
          tag: 'MatchingScreen', error: e);
    }
  }

  /// Handle groom location search text changes with debouncing
  void _onGroomLocationSearchChanged(String query) {
    // Cancel previous timer if it exists
    _groomSearchDebounceTimer?.cancel();

    if (query.length >= 3) {
      // Set a new timer for 300ms (0.3 seconds)
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
      // Set a new timer for 300ms (0.3 seconds)
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
        // Convert LocationResult objects to Map format for the UI
        final suggestions = results
            .map((result) => {
                  'name': result.placeName ?? 'Unknown Location',
                  'latitude': result.latitude,
                  'longitude': result.longitude,
                })
            .toList();

        setState(() {
          _groomLocationSuggestions = suggestions;
          _showGroomLocationSuggestions = suggestions.isNotEmpty;
          _isSearchingGroomLocation = false;
        });
      }
    } catch (e) {
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
        // Convert LocationResult objects to Map format for the UI
        final suggestions = results
            .map((result) => {
                  'name': result.placeName ?? 'Unknown Location',
                  'latitude': result.latitude,
                  'longitude': result.longitude,
                })
            .toList();

        setState(() {
          _brideLocationSuggestions = suggestions;
          _showBrideLocationSuggestions = suggestions.isNotEmpty;
          _isSearchingBrideLocation = false;
        });
      }
    } catch (e) {
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

  /// Build the groom location search field using robust implementation
  Widget _buildGroomLocationSearchField(TranslationService translationService) {
    return _buildLocationSearchField(
      controller: _groomLocationSearchController,
      label: 'Groom\'s Place of Birth',
      hintText: 'Type to search for groom\'s birth location',
      onChanged: _onGroomLocationSearchChanged,
      onTap: () {
        setState(() {
          _groomLocationError = null;
          _showGroomLocationSuggestions = _groomLocationSuggestions.isNotEmpty;
        });
      },
      suggestions: _groomLocationSuggestions,
      showSuggestions: _showGroomLocationSuggestions,
      isSearching: _isSearchingGroomLocation,
      error: _groomLocationError,
      onSuggestionSelected: _selectGroomLocationSuggestion,
    );
  }

  /// Build the bride location search field using robust implementation
  Widget _buildBrideLocationSearchField(TranslationService translationService) {
    return _buildLocationSearchField(
      controller: _brideLocationSearchController,
      label: 'Bride\'s Place of Birth',
      hintText: 'Type to search for bride\'s birth location',
      onChanged: _onBrideLocationSearchChanged,
      onTap: () {
        setState(() {
          _brideLocationError = null;
          _showBrideLocationSuggestions = _brideLocationSuggestions.isNotEmpty;
        });
      },
      suggestions: _brideLocationSuggestions,
      showSuggestions: _showBrideLocationSuggestions,
      isSearching: _isSearchingBrideLocation,
      error: _brideLocationError,
      onSuggestionSelected: _selectBrideLocationSuggestion,
    );
  }

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
    final logger = CentralizedLoggingService.instance;

    print('🔍 DEBUG: _performMatching called');
    logger.logInfo('Perform Matching button pressed!', tag: 'MatchingScreen');

    // Validate that both persons have required data
    if (_groomNameController.text.trim().isEmpty ||
        _brideNameController.text.trim().isEmpty) {
      print('🔍 DEBUG: Validation failed - missing names');
      logger.logWarning('Matching validation failed: Missing names',
          tag: 'MatchingScreen');
      _showErrorDialog('Please enter names for both groom and bride');
      return;
    }

    print('🔍 DEBUG: Validation passed, proceeding with matching');

    try {
      logger.logInfo('Starting kundali matching process',
          tag: 'MatchingScreen',
          data: {
            'groom': _groomNameController.text.trim(),
            'bride': _brideNameController.text.trim(),
          });

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

      logger.logInfo('Birth data prepared for astrology calculations',
          tag: 'MatchingScreen',
          data: {
            'groomLocal': groomLocalDateTime.toIso8601String(),
            'brideLocal': brideLocalDateTime.toIso8601String(),
          });

      // Note: Birth chart data will be fetched internally by compatibility API
      // No need to fetch separately - this reduces API calls from 3 to 1

      // Get current user for cache optimization
      final currentUser = ref.read(userServiceProvider);

      // Check if groom is the current user
      final isGroomUser = currentUser != null &&
          _isUserBirthData(
            groomLocalDateTime,
            _groomLatitude,
            _groomLongitude,
            currentUser,
          );

      // Check if bride is the current user
      final isBrideUser = currentUser != null &&
          _isUserBirthData(
            brideLocalDateTime,
            _brideLatitude,
            _brideLongitude,
            currentUser,
          );

      // Create PartnerData objects using local times
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
      logger.logInfo('Performing kundali matching calculations',
          tag: 'MatchingScreen');
      print(
          '🔍 DEBUG: Calling matching provider with groom: ${groomData.name}, bride: ${brideData.name}');

      // Pass current user to optimize cache usage
      await ref.read(matchingProvider.notifier).performMatching(
          groomData, brideData,
          ayanamsha: _selectedAyanamsha, houseSystem: _selectedHouseSystem);

      print('🔍 DEBUG: Matching provider call completed');
      logger.logInfo('Kundali matching completed successfully',
          tag: 'MatchingScreen');

      // Save form data for future sessions
      await _saveFormData();

      // Start results animation when matching is complete
      _resultsAnimationController.forward();
    } catch (e) {
      logger.logError('Kundali matching failed',
          tag: 'MatchingScreen', error: e);
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
    final timeDiff = (localBirthDateTime.difference(userBirthDateTime)).abs();
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

  /// Build loading screen
  Widget _buildLoadingScreen() {
    final translationService = ref.watch(translationServiceProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              ThemeProperties.getPrimaryColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 24)),
          Text(
            translationService.translateContent('calculating',
                fallback: 'Calculating Compatibility...'),
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
              fontWeight: FontWeight.w600,
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
          Text(
            translationService.translateContent('please_wait',
                fallback: 'Please wait while we calculate your compatibility'),
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: ThemeProperties.getSecondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build error screen with retry option
  Widget _buildErrorScreen(MatchingState matchingState) {
    final translationService = ref.watch(translationServiceProvider);
    return Center(
      child: Padding(
        padding: ResponsiveSystem.all(context, baseSpacing: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ResponsiveSystem.iconSize(context, baseSize: 64),
              color: ThemeProperties.getErrorColor(context),
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 24)),
            Text(
              translationService.translateContent('error_loading_matching',
                  fallback: 'Unable to Load Matching Results'),
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                fontWeight: FontWeight.bold,
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
            Text(
              matchingState.errorMessage ??
                  translationService.translateContent('unknown_error',
                      fallback: 'An unknown error occurred'),
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeProperties.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 24)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CentralizedModernButton(
                  text: translationService.translateContent('go_back',
                      fallback: 'Go Back'),
                  icon: LucideIcons.arrowLeft,
                  onPressed: () {
                    ref.read(matchingProvider.notifier).editPartnerDetails();
                  },
                  width: ResponsiveSystem.screenWidth(context) * 0.35,
                ),
                ResponsiveSystem.sizedBox(context,
                    width: ResponsiveSystem.spacing(context, baseSpacing: 16)),
                CentralizedModernButton(
                  text: translationService.translateContent('retry',
                      fallback: 'Retry'),
                  icon: LucideIcons.refreshCw,
                  onPressed: () {
                    _performMatching();
                  },
                  width: ResponsiveSystem.screenWidth(context) * 0.35,
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
              color: ThemeProperties.getErrorColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 24),
            ),
            ResponsiveSystem.sizedBox(context,
                width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
            Expanded(
              child: Text(
                'Error',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                  fontWeight: FontWeight.bold,
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
            color: ThemeProperties.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          if (showRetry) ...[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: ThemeProperties.getSecondaryTextColor(context),
                ),
              ),
            ),
            CentralizedModernButton(
              text: 'Retry',
              icon: LucideIcons.refreshCw,
              onPressed: () {
                Navigator.of(context).pop();
                _performMatching();
              },
              width: ResponsiveSystem.screenWidth(context) * 0.25,
            ),
          ] else ...[
            CentralizedModernButton(
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
      TranslationService translationService) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return [
      CentralizedSectionTitle(
          title: translationService.translateHeader('compatibility_details',
              fallback: 'Compatibility Details')),

      // Responsive layout: Row on larger screens, Column on small screens
      isSmallScreen
          ? Column(
              children: [
                // Groom Name
                _buildNameField(
                  controller: _groomNameController,
                  label: 'Groom Name',
                  icon: LucideIcons.user,
                  hintText: 'Enter groom name',
                ),
                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
                // Bride Name
                _buildNameField(
                  controller: _brideNameController,
                  label: 'Bride Name',
                  icon: LucideIcons.user,
                  hintText: 'Enter bride name',
                ),
                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
                // Groom Date of Birth
                _buildDateField(
                  label: 'Groom Date of Birth',
                  selectedDate: _groomDob,
                  onDateChanged: (date) {
                    setState(() {
                      _groomDob = date;
                    });
                  },
                ),
                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
                // Bride Date of Birth
                _buildDateField(
                  label: 'Bride Date of Birth',
                  selectedDate: _brideDob,
                  onDateChanged: (date) {
                    setState(() {
                      _brideDob = date;
                    });
                  },
                ),
                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
                // Groom Time of Birth
                _buildTimeField(
                  label: 'Groom Time of Birth',
                  selectedTime: _groomTob,
                  onTimeChanged: (time) {
                    setState(() {
                      _groomTob = time;
                    });
                  },
                ),
                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
                // Bride Time of Birth
                _buildTimeField(
                  label: 'Bride Time of Birth',
                  selectedTime: _brideTob,
                  onTimeChanged: (time) {
                    setState(() {
                      _brideTob = time;
                    });
                  },
                ),
                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
                // Groom Place of Birth
                _buildGroomLocationSearchField(translationService),
                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
                // Bride Place of Birth
                _buildBrideLocationSearchField(translationService),
              ],
            )
          : Column(
              children: [
                // First Row: Names
                Row(
                  children: [
                    Expanded(
                      child: _buildNameField(
                        controller: _groomNameController,
                        label: 'Groom Name',
                        icon: LucideIcons.user,
                        hintText: 'Enter groom name',
                      ),
                    ),
                    ResponsiveSystem.sizedBox(context,
                        width:
                            ResponsiveSystem.spacing(context, baseSpacing: 16)),
                    Expanded(
                      child: _buildNameField(
                        controller: _brideNameController,
                        label: 'Bride Name',
                        icon: LucideIcons.user,
                        hintText: 'Enter bride name',
                      ),
                    ),
                  ],
                ),
                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

                // Second Row: Date of Birth
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: 'Groom Date of Birth',
                        selectedDate: _groomDob,
                        onDateChanged: (date) {
                          setState(() {
                            _groomDob = date;
                          });
                        },
                      ),
                    ),
                    ResponsiveSystem.sizedBox(context,
                        width:
                            ResponsiveSystem.spacing(context, baseSpacing: 16)),
                    Expanded(
                      child: _buildDateField(
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
                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

                // Third Row: Time of Birth
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeField(
                        label: 'Groom Time of Birth',
                        selectedTime: _groomTob,
                        onTimeChanged: (time) {
                          setState(() {
                            _groomTob = time;
                          });
                        },
                      ),
                    ),
                    ResponsiveSystem.sizedBox(context,
                        width:
                            ResponsiveSystem.spacing(context, baseSpacing: 16)),
                    Expanded(
                      child: _buildTimeField(
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
                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

                // Fourth Row: Place of Birth
                Row(
                  children: [
                    Expanded(
                      child: _buildGroomLocationSearchField(translationService),
                    ),
                    ResponsiveSystem.sizedBox(context,
                        width:
                            ResponsiveSystem.spacing(context, baseSpacing: 16)),
                    Expanded(
                      child: _buildBrideLocationSearchField(translationService),
                    ),
                  ],
                ),
              ],
            ),
    ];
  }

  /// Build name field helper using robust ReusableTextInput
  Widget _buildNameField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
            fontWeight: FontWeight.w500,
            color: ThemeProperties.getPrimaryTextColor(context),
          ),
        ),
        ResponsiveSystem.sizedBox(context, height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(
              icon,
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
              color: ThemeProperties.getSecondaryTextColor(context),
            ),
            border: OutlineInputBorder(
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              borderSide: BorderSide(
                color: ThemeProperties.getBorderColor(context),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              borderSide: BorderSide(
                color: ThemeProperties.getBorderColor(context),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              borderSide: BorderSide(
                color: ThemeProperties.getPrimaryColor(context),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 2),
              ),
            ),
            filled: true,
            fillColor: ThemeProperties.getSurfaceColor(context),
            contentPadding: ResponsiveSystem.all(context, baseSpacing: 16),
          ),
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
            color: ThemeProperties.getPrimaryTextColor(context),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  /// Build location search field using robust implementation
  Widget _buildLocationSearchField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required Function(String) onChanged,
    required VoidCallback onTap,
    required List<Map<String, dynamic>> suggestions,
    required bool showSuggestions,
    required bool isSearching,
    String? error,
    required Function(Map<String, dynamic>) onSuggestionSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
            fontWeight: FontWeight.w500,
            color: ThemeProperties.getPrimaryTextColor(context),
          ),
        ),
        ResponsiveSystem.sizedBox(context, height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(
              LucideIcons.mapPin,
              size: ResponsiveSystem.iconSize(context, baseSize: 20),
              color: ThemeProperties.getSecondaryTextColor(context),
            ),
            border: OutlineInputBorder(
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              borderSide: BorderSide(
                color: ThemeProperties.getBorderColor(context),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              borderSide: BorderSide(
                color: ThemeProperties.getBorderColor(context),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              borderSide: BorderSide(
                color: ThemeProperties.getPrimaryColor(context),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 2),
              ),
            ),
            filled: true,
            fillColor: ThemeProperties.getSurfaceColor(context),
            contentPadding: ResponsiveSystem.all(context, baseSpacing: 16),
          ),
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
            color: ThemeProperties.getPrimaryTextColor(context),
          ),
          onChanged: onChanged,
          onTap: onTap,
        ),

        // Location suggestions dropdown
        if (showSuggestions && suggestions.isNotEmpty) ...[
          ResponsiveSystem.sizedBox(context, height: 8),
          Container(
            decoration: BoxDecoration(
              color: ThemeProperties.getSurfaceColor(context),
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              border: Border.all(
                color: ThemeProperties.getPrimaryColor(context)
                    .withAlpha((0.3 * 255).round()),
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeProperties.getShadowColor(context),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: suggestions.map((suggestion) {
                return ListTile(
                  title: Text(
                    suggestion['name'] ?? 'Unknown Location',
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 14),
                      color: ThemeProperties.getPrimaryTextColor(context),
                    ),
                  ),
                  subtitle: Text(
                    '${suggestion['latitude']?.toStringAsFixed(4) ?? ''}, ${suggestion['longitude']?.toStringAsFixed(4) ?? ''}',
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 12),
                      color: ThemeProperties.getSecondaryTextColor(context),
                    ),
                  ),
                  onTap: () => onSuggestionSelected(suggestion),
                );
              }).toList(),
            ),
          ),
        ],

        // Error message
        if (error != null) ...[
          ResponsiveSystem.sizedBox(context, height: 8),
          Container(
            padding: ResponsiveSystem.all(context, baseSpacing: 12),
            decoration: BoxDecoration(
              color: ThemeProperties.getErrorColor(context)
                  .withAlpha((0.1 * 255).round()),
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              border: Border.all(
                color: ThemeProperties.getErrorColor(context),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: ResponsiveSystem.iconSize(context, baseSize: 16),
                  color: ThemeProperties.getErrorColor(context),
                ),
                ResponsiveSystem.sizedBox(context, width: 8),
                Expanded(
                  child: Text(
                    error,
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 14),
                      color: ThemeProperties.getErrorColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Build custom date field
  Widget _buildDateField({
    required String label,
    required DateTime selectedDate,
    required Function(DateTime) onDateChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
            fontWeight: FontWeight.w500,
            color: ThemeProperties.getPrimaryTextColor(context),
          ),
        ),
        ResponsiveSystem.sizedBox(context, height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: ThemeProperties.getPrimaryColor(context),
                      onPrimary: ThemeProperties.getSurfaceColor(context),
                      surface: ThemeProperties.getSurfaceColor(context),
                      onSurface: ThemeProperties.getPrimaryTextColor(context),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              onDateChanged(date);
            }
          },
          child: Container(
            padding: ResponsiveSystem.all(context, baseSpacing: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: ThemeProperties.getBorderColor(context),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
              ),
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              color: ThemeProperties.getSurfaceColor(context),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                  color: ThemeProperties.getSecondaryTextColor(context),
                ),
                ResponsiveSystem.sizedBox(context, width: 12),
                Expanded(
                  child: Text(
                    DateFormat('dd MMM yyyy').format(selectedDate),
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 16),
                      color: ThemeProperties.getPrimaryTextColor(context),
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.chevronDown,
                  size: ResponsiveSystem.iconSize(context, baseSize: 16),
                  color: ThemeProperties.getSecondaryTextColor(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build custom time field
  Widget _buildTimeField({
    required String label,
    required TimeOfDay selectedTime,
    required Function(TimeOfDay) onTimeChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
            fontWeight: FontWeight.w500,
            color: ThemeProperties.getPrimaryTextColor(context),
          ),
        ),
        ResponsiveSystem.sizedBox(context, height: 8),
        InkWell(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: selectedTime,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: ThemeProperties.getPrimaryColor(context),
                      onPrimary: ThemeProperties.getSurfaceColor(context),
                      surface: ThemeProperties.getSurfaceColor(context),
                      onSurface: ThemeProperties.getPrimaryTextColor(context),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (time != null) {
              onTimeChanged(time);
            }
          },
          child: Container(
            padding: ResponsiveSystem.all(context, baseSpacing: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: ThemeProperties.getBorderColor(context),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
              ),
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              color: ThemeProperties.getSurfaceColor(context),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.clock,
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                  color: ThemeProperties.getSecondaryTextColor(context),
                ),
                ResponsiveSystem.sizedBox(context, width: 12),
                Expanded(
                  child: Text(
                    selectedTime.format(context),
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 16),
                      color: ThemeProperties.getPrimaryTextColor(context),
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.chevronDown,
                  size: ResponsiveSystem.iconSize(context, baseSize: 16),
                  color: ThemeProperties.getSecondaryTextColor(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build entire content section
  List<Widget> _buildContentSection(
      TranslationService translationService, MatchingState matchingState) {
    return [
      ..._buildPartnerDetailsSection(translationService),
      ..._buildCalculationSection(translationService, matchingState),
    ];
  }

  /// Build calculation and matching section
  List<Widget> _buildCalculationSection(
      TranslationService translationService, MatchingState matchingState) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return [
      ResponsiveSystem.sizedBox(context,
          height: ResponsiveSystem.spacing(context, baseSpacing: 24)),

      // Calculation System Selection (Ayanamsha and House System)
      CentralizedSectionTitle(
          title: translationService.translateHeader('calculation_system',
              fallback: 'Calculation System')),
      ResponsiveSystem.sizedBox(context,
          height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
      // Responsive layout: Row on larger screens, Column on small screens
      isSmallScreen
          ? Column(
              children: [
                _buildCompactAyanamshaDropdown(),
                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
                _buildCompactHouseSystemDropdown(),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _buildCompactAyanamshaDropdown(),
                ),
                ResponsiveSystem.sizedBox(context,
                    width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
                Expanded(
                  child: _buildCompactHouseSystemDropdown(),
                ),
              ],
            ),
      ResponsiveSystem.sizedBox(context,
          height: ResponsiveSystem.spacing(context, baseSpacing: 24)),

      Builder(
        builder: (context) {
          print(
              '🔍 DEBUG: Building button with isLoading: ${matchingState.isLoading}');
          return CentralizedModernButton(
            text: matchingState.isLoading
                ? translationService.translateContent('calculating',
                    fallback: 'Calculating...')
                : translationService.translateContent('perform_matching',
                    fallback: 'Perform Matching'),
            icon: LucideIcons.heart,
            onPressed: () {
              print('🔍 DEBUG: Button pressed! Calling _performMatching...');
              print('🔍 DEBUG: Groom name: "${_groomNameController.text}"');
              print('🔍 DEBUG: Bride name: "${_brideNameController.text}"');
              print('🔍 DEBUG: Is loading: ${matchingState.isLoading}');
              print('🔍 DEBUG: Button onPressed called');
              if (!matchingState.isLoading) {
                CentralizedLoggingService.instance.logInfo(
                    'Button pressed! Calling _performMatching...',
                    tag: 'MatchingScreen');
                _performMatching();
              } else {
                print('🔍 DEBUG: Button is disabled due to loading state');
              }
            },
            width: ResponsiveSystem.screenWidth(context),
            height: ResponsiveSystem.buttonHeight(context, baseHeight: 56),
            isLoading: matchingState.isLoading,
          );
        },
      ),
    ];
  }

  /// Build compact ayanamsha dropdown (similar to calendar screen)
  Widget _buildCompactAyanamshaDropdown() {
    final primaryColor = ThemeProperties.getPrimaryColor(context);
    final primaryTextColor = ThemeProperties.getPrimaryTextColor(context);
    final surfaceColor = ThemeProperties.getSurfaceColor(context);

    final allAyanamshaTypes = AyanamshaInfoHelper.getAllAyanamshaTypes();

    return Container(
      height: ResponsiveSystem.spacing(context, baseSpacing: 40),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 6),
        border: Border.all(
          color: primaryColor.withAlpha((0.2 * 255).round()),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAyanamsha,
          isExpanded: true,
          alignment: Alignment.centerLeft,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
            color: primaryTextColor,
            fontWeight: FontWeight.w500,
          ),
          icon: Icon(
            LucideIcons.chevronDown,
            size: ResponsiveSystem.iconSize(context, baseSize: 16),
            color: primaryColor,
          ),
          items: allAyanamshaTypes.map((ayanamsha) {
            final info = AyanamshaInfoHelper.getAyanamshaInfo(ayanamsha);
            return DropdownMenuItem<String>(
              value: ayanamsha,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveSystem.spacing(context, baseSpacing: 8),
                ),
                child: Text(
                  info?.name ?? ayanamsha,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedAyanamsha = newValue;
              });
              // Save immediately
              MatchingFormStorageService.instance.saveAyanamsha(newValue);
            }
          },
        ),
      ),
    );
  }

  /// Build compact house system dropdown (similar to calendar screen)
  Widget _buildCompactHouseSystemDropdown() {
    final primaryColor = ThemeProperties.getPrimaryColor(context);
    final primaryTextColor = ThemeProperties.getPrimaryTextColor(context);
    final surfaceColor = ThemeProperties.getSurfaceColor(context);

    final allHouseSystemTypes = HouseSystemInfoHelper.getAllHouseSystemTypes();

    return Container(
      height: ResponsiveSystem.spacing(context, baseSpacing: 40),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 6),
        border: Border.all(
          color: primaryColor.withAlpha((0.2 * 255).round()),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedHouseSystem,
          isExpanded: true,
          alignment: Alignment.centerLeft,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
            color: primaryTextColor,
            fontWeight: FontWeight.w500,
          ),
          icon: Icon(
            LucideIcons.chevronDown,
            size: ResponsiveSystem.iconSize(context, baseSize: 16),
            color: primaryColor,
          ),
          items: allHouseSystemTypes.map((houseSystem) {
            final info = HouseSystemInfoHelper.getHouseSystemInfo(houseSystem);
            return DropdownMenuItem<String>(
              value: houseSystem,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveSystem.spacing(context, baseSpacing: 8),
                ),
                child: Text(
                  info?.name ?? houseSystem,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedHouseSystem = newValue;
              });
              // Save immediately
              MatchingFormStorageService.instance.saveHouseSystem(newValue);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchingState = ref.watch(matchingProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: BackgroundGradients.getBackgroundGradient(
            isDark: Theme.of(context).brightness == Brightness.dark,
            isEvening: false,
            useSacredFire: false,
          ),
        ),
        child: matchingState.isLoading
            ? _buildLoadingScreen()
            : matchingState.hasError
                ? _buildErrorScreen(matchingState)
                : matchingState.showResults
                    ? animations.CentralizedAnimatedOpacity(
                        opacity: 1.0,
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
        SliverAppBar(
          expandedHeight: ResponsiveSystem.spacing(context, baseSpacing: 250),
          floating: true,
          pinned: true,
          snap: true,
          backgroundColor: ThemeProperties.getTransparentColor(context),
          elevation: 0,
          toolbarHeight: ResponsiveSystem.spacing(context, baseSpacing: 60),
          // Minimal title shown only when collapsed
          title: Text(
            translationService.translateHeader('kundali_matching',
                fallback: 'Kundali Matching'),
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
              fontWeight: FontWeight.bold,
              color: ThemeProperties.getAppBarTextColor(context),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              LucideIcons.house,
              color: ThemeProperties.getAppBarTextColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 24),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            // Language Dropdown Widget
            CentralizedLanguageDropdown(
              onLanguageChanged: (value) {
                LoggingHelper.logInfo('Language changed to: $value');
                _handleLanguageChange(ref, value);
              },
            ),
            // Theme Dropdown Widget
            CentralizedThemeDropdown(
              onThemeChanged: (value) {
                LoggingHelper.logInfo('Theme changed to: $value');
                _handleThemeChange(ref, value);
              },
            ),
            // Profile Photo with Hover Effect
            Padding(
              padding: ResponsiveSystem.only(
                context,
                right: ResponsiveSystem.spacing(context, baseSpacing: 8),
              ),
              child: CentralizedProfilePhotoWithHover(
                key: const ValueKey('profile_icon'),
                onTap: () =>
                    _handleProfileTap(context, ref, translationService),
                tooltip: translationService.translateContent(
                  'my_profile',
                  fallback: 'My Profile',
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            // Title removed - hero section contains the main title
            // This prevents duplicate titles when expanded
            background: _buildHeroSection(translationService),
            collapseMode: CollapseMode.parallax,
            stretchModes: const [StretchMode.zoomBackground],
          ),
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
    // Note: kundali data is now handled by the centralized astrology library
    // This is a simplified display - actual calculations are done in the matching method

    return CustomScrollView(
      slivers: [
        // SliverAppBar for consistency
        SliverAppBar(
          expandedHeight: ResponsiveSystem.spacing(context, baseSpacing: 60),
          floating: false,
          pinned: true,
          backgroundColor: ThemeProperties.getTransparentColor(context),
          elevation: 0,
          toolbarHeight: ResponsiveSystem.spacing(context, baseSpacing: 60),
          // Minimal title shown only when collapsed
          title: Text(
            translationService.translateHeader('kundali_matching',
                fallback: 'Kundali Matching'),
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
              fontWeight: FontWeight.bold,
              color: ThemeProperties.getAppBarTextColor(context),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              LucideIcons.house,
              color: ThemeProperties.getAppBarTextColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 24),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            // Language Dropdown Widget
            CentralizedLanguageDropdown(
              onLanguageChanged: (value) {
                LoggingHelper.logInfo('Language changed to: $value');
                _handleLanguageChange(ref, value);
              },
            ),
            // Theme Dropdown Widget
            CentralizedThemeDropdown(
              onThemeChanged: (value) {
                LoggingHelper.logInfo('Theme changed to: $value');
                _handleThemeChange(ref, value);
              },
            ),
            // Profile Photo with Hover Effect
            Padding(
              padding: ResponsiveSystem.only(
                context,
                right: ResponsiveSystem.spacing(context, baseSpacing: 8),
              ),
              child: CentralizedProfilePhotoWithHover(
                key: const ValueKey('profile_icon'),
                onTap: () =>
                    _handleProfileTap(context, ref, translationService),
                tooltip: translationService.translateContent(
                  'my_profile',
                  fallback: 'My Profile',
                ),
              ),
            ),
          ],
        ),

        // Hero Section
        SliverToBoxAdapter(
          child: _buildResultsHeroSection(),
        ),

        // Spacing between hero and content
        SliverToBoxAdapter(
          child: ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 40)),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CentralizedSectionTitle(title: 'Groom Details'),
                            CentralizedInfoCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CentralizedInfoRow(
                                      label: 'Name',
                                      value: _groomNameController.text),
                                  CentralizedInfoRow(
                                      label: 'DOB',
                                      value: DateFormat('dd-MM-yyyy')
                                          .format(_groomDob)),
                                  CentralizedInfoRow(
                                      label: 'TOB',
                                      value: _groomTob.format(context)),
                                  CentralizedInfoRow(
                                    label: 'Place of Birth',
                                    value: _groomPob,
                                  ),
                                  CentralizedInfoRow(
                                    label: 'Nakshatram',
                                    value: matchingState.kootaDetails?[
                                            'person1Nakshatram'] ??
                                        'Not available',
                                  ),
                                  CentralizedInfoRow(
                                    label: 'Raasi',
                                    value: matchingState
                                            .kootaDetails?['person1Raasi'] ??
                                        'Not available',
                                  ),
                                  CentralizedInfoRow(
                                    label: 'Pada',
                                    value: matchingState
                                            .kootaDetails?['person1Pada'] ??
                                        'Not available',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ResponsiveSystem.sizedBox(context,
                            height: ResponsiveSystem.spacing(context,
                                baseSpacing: 16)),
                        // Bride Details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CentralizedSectionTitle(title: 'Bride Details'),
                            CentralizedInfoCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CentralizedInfoRow(
                                      label: 'Name',
                                      value: _brideNameController.text),
                                  CentralizedInfoRow(
                                      label: 'DOB',
                                      value: DateFormat('dd-MM-yyyy')
                                          .format(_brideDob)),
                                  CentralizedInfoRow(
                                      label: 'TOB',
                                      value: _brideTob.format(context)),
                                  CentralizedInfoRow(
                                    label: 'Place of Birth',
                                    value: _bridePob,
                                  ),
                                  CentralizedInfoRow(
                                    label: 'Nakshatram',
                                    value: matchingState.kootaDetails?[
                                            'person2Nakshatram'] ??
                                        'Not available',
                                  ),
                                  CentralizedInfoRow(
                                    label: 'Raasi',
                                    value: matchingState
                                            .kootaDetails?['person2Raasi'] ??
                                        'Not available',
                                  ),
                                  CentralizedInfoRow(
                                    label: 'Pada',
                                    value: matchingState
                                            .kootaDetails?['person2Pada'] ??
                                        'Not available',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Groom Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CentralizedSectionTitle(title: 'Groom Details'),
                              CentralizedInfoCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CentralizedInfoRow(
                                        label: 'Name',
                                        value: _groomNameController.text),
                                    CentralizedInfoRow(
                                        label: 'DOB',
                                        value: DateFormat('dd-MM-yyyy')
                                            .format(_groomDob)),
                                    CentralizedInfoRow(
                                        label: 'TOB',
                                        value: _groomTob.format(context)),
                                    CentralizedInfoRow(
                                      label: 'Place of Birth',
                                      value: _groomPob,
                                    ),
                                    CentralizedInfoRow(
                                      label: 'Nakshatram',
                                      value: matchingState.kootaDetails?[
                                              'person1Nakshatram'] ??
                                          'Not available',
                                    ),
                                    CentralizedInfoRow(
                                      label: 'Raasi',
                                      value: matchingState
                                              .kootaDetails?['person1Raasi'] ??
                                          'Not available',
                                    ),
                                    CentralizedInfoRow(
                                      label: 'Pada',
                                      value: matchingState
                                              .kootaDetails?['person1Pada'] ??
                                          'Not available',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ResponsiveSystem.sizedBox(context,
                            width: ResponsiveSystem.spacing(context,
                                baseSpacing: 16)),
                        // Bride Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CentralizedSectionTitle(title: 'Bride Details'),
                              CentralizedInfoCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CentralizedInfoRow(
                                        label: 'Name',
                                        value: _brideNameController.text),
                                    CentralizedInfoRow(
                                        label: 'DOB',
                                        value: DateFormat('dd-MM-yyyy')
                                            .format(_brideDob)),
                                    CentralizedInfoRow(
                                        label: 'TOB',
                                        value: _brideTob.format(context)),
                                    CentralizedInfoRow(
                                      label: 'Place of Birth',
                                      value: _bridePob,
                                    ),
                                    CentralizedInfoRow(
                                      label: 'Nakshatram',
                                      value: matchingState.kootaDetails?[
                                              'person2Nakshatram'] ??
                                          'Not available',
                                    ),
                                    CentralizedInfoRow(
                                      label: 'Raasi',
                                      value: matchingState
                                              .kootaDetails?['person2Raasi'] ??
                                          'Not available',
                                    ),
                                    CentralizedInfoRow(
                                      label: 'Pada',
                                      value: matchingState
                                              .kootaDetails?['person2Pada'] ??
                                          'Not available',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              ResponsiveSystem.sizedBox(context,
                  height: ResponsiveSystem.spacing(context, baseSpacing: 24)),
              CentralizedSectionTitle(title: 'Matching Results'),
              CentralizedInfoCard(
                child: Column(
                  children: [
                    // Only show results if we have valid data
                    if (matchingState.compatibilityScore != null) ...[
                      Text(
                        '${matchingState.compatibilityScore!.toStringAsFixed(0)}% Compatible',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: matchingState.compatibilityScore! >= 70
                                  ? ThemeProperties.getPrimaryColor(context)
                                  : (matchingState.compatibilityScore! >= 50
                                      ? ThemeProperties.getPrimaryColor(context)
                                          .withAlpha((0.7 * 255).round())
                                      : ThemeProperties.getPrimaryColor(context)
                                          .withAlpha((0.5 * 255).round())),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      ResponsiveSystem.sizedBox(context,
                          height: ResponsiveSystem.spacing(context,
                              baseSpacing: 4)),
                      Text(
                        '${_getTotalScore(matchingState)}/36 Points',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: matchingState.compatibilityScore! >= 70
                                  ? ThemeProperties.getPrimaryColor(context)
                                  : (matchingState.compatibilityScore! >= 50
                                      ? ThemeProperties.getPrimaryColor(context)
                                          .withAlpha((0.7 * 255).round())
                                      : ThemeProperties.getPrimaryColor(context)
                                          .withAlpha((0.5 * 255).round())),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      ResponsiveSystem.sizedBox(context,
                          height: ResponsiveSystem.spacing(context,
                              baseSpacing: 8)),
                      LinearProgressIndicator(
                        value: matchingState.compatibilityScore! / 100,
                        backgroundColor: (matchingState.compatibilityScore! >=
                                    70
                                ? ThemeProperties.getPrimaryColor(context)
                                : (matchingState.compatibilityScore! >= 50
                                    ? ThemeProperties.getPrimaryColor(context)
                                        .withAlpha((0.7 * 255).round())
                                    : ThemeProperties.getPrimaryColor(context)
                                        .withAlpha((0.5 * 255).round())))
                            .withAlpha((0.2 * 255).round()),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          matchingState.compatibilityScore! >= 70
                              ? ThemeProperties.getPrimaryColor(context)
                              : (matchingState.compatibilityScore! >= 50
                                  ? ThemeProperties.getPrimaryColor(context)
                                      .withAlpha((0.7 * 255).round())
                                  : ThemeProperties.getPrimaryColor(context)
                                      .withAlpha((0.5 * 255).round())),
                        ),
                      ),
                    ] else ...[
                      // Show error message if data is missing
                      Icon(
                        Icons.error_outline,
                        color: ThemeProperties.getErrorColor(context),
                        size: ResponsiveSystem.iconSize(context, baseSize: 32),
                      ),
                      ResponsiveSystem.sizedBox(context,
                          height: ResponsiveSystem.spacing(context,
                              baseSpacing: 12)),
                      Text(
                        'Data not available',
                        style: TextStyle(
                          fontSize:
                              ResponsiveSystem.fontSize(context, baseSize: 16),
                          color: ThemeProperties.getErrorColor(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ResponsiveSystem.sizedBox(context,
                  height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
              _buildSmallCompatibilityButton(),
              ResponsiveSystem.sizedBox(context,
                  height: ResponsiveSystem.spacing(context, baseSpacing: 24)),
              _buildDetailedKootaAnalysis(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedKootaAnalysis() {
    final primaryTextColor = ThemeProperties.getPrimaryTextColor(context);
    final secondaryTextColor = ThemeProperties.getSecondaryTextColor(context);
    final matchingState = ref.watch(matchingProvider);

    // Get koota entries and filter out totalPoints
    final kootaEntries = (matchingState.kootaDetails ?? {})
        .entries
        .where(
            (entry) => _isKootaScore(entry.key) && entry.key != 'totalPoints')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CentralizedSectionTitle(title: 'Detailed Guna Milan Analysis'),
        ResponsiveSystem.sizedBox(context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 16)),

        // Two-column layout for koota cards
        _buildTwoColumnKootaLayout(
            kootaEntries, primaryTextColor, secondaryTextColor),

        ResponsiveSystem.sizedBox(context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
        _buildScoreSummary(matchingState),
        ResponsiveSystem.sizedBox(context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 24)),
        _buildOverallCompatibilityInsights(matchingState),
        ResponsiveSystem.sizedBox(context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 24)),
        _buildCalculationApproachInfo(),
      ],
    );
  }

  /// Build two-column layout for koota cards
  Widget _buildTwoColumnKootaLayout(List<MapEntry<String, String>> kootaEntries,
      Color primaryTextColor, Color secondaryTextColor) {
    return Column(
      children: [
        // Create rows of 2 columns each
        for (int i = 0; i < kootaEntries.length; i += 2) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First column
              Expanded(
                child: _buildKootaCard(
                    kootaEntries[i].key,
                    kootaEntries[i].value,
                    primaryTextColor,
                    secondaryTextColor),
              ),
              ResponsiveSystem.sizedBox(context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 16)),
              // Second column (if exists)
              Expanded(
                child: i + 1 < kootaEntries.length
                    ? _buildKootaCard(
                        kootaEntries[i + 1].key,
                        kootaEntries[i + 1].value,
                        primaryTextColor,
                        secondaryTextColor)
                    : SizedBox.shrink(), // Empty space if odd number of items
              ),
            ],
          ),
          // Add spacing between rows (except for the last row)
          if (i + 2 < kootaEntries.length)
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
        ],
      ],
    );
  }

  Widget _buildKootaCard(String kootaName, String score, Color primaryTextColor,
      Color secondaryTextColor) {
    final kootaInfo = _getKootaInfo(kootaName);
    final maxScore = kootaInfo['maxScore'] as int;

    // Safely parse the score, handle non-numeric values
    final scoreValue = double.tryParse(score) ?? 0.0;
    final percentage = (scoreValue / maxScore * 100).round();

    return CentralizedInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Koota Name and Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                kootaName,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                  fontWeight: FontWeight.bold,
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
              ),
              CentralizedInfoCard(
                backgroundColor: _getScoreColor(percentage).withAlpha(25),
                borderRadius: ResponsiveSystem.circular(context, baseRadius: 6),
                padding: ResponsiveSystem.symmetric(context,
                    horizontal:
                        ResponsiveSystem.spacing(context, baseSpacing: 8),
                    vertical:
                        ResponsiveSystem.spacing(context, baseSpacing: 4)),
                child: Text(
                  '$score/$maxScore',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                    fontWeight: FontWeight.w600,
                    color: _getScoreColor(percentage),
                  ),
                ),
              ),
            ],
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 8)),

          // Progress Bar
          LinearProgressIndicator(
            value: scoreValue / maxScore,
            backgroundColor:
                _getScoreColor(percentage).withAlpha((0.2 * 255).round()),
            valueColor:
                AlwaysStoppedAnimation<Color>(_getScoreColor(percentage)),
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 12)),

          // Description
          Text(
            kootaInfo['description'] as String,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: secondaryTextColor,
              height: ResponsiveSystem.lineHeight(context, baseHeight: 1.4),
            ),
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 8)),

          // Significance
          CentralizedInfoCard(
            backgroundColor: ThemeProperties.getPrimaryColor(context)
                .withAlpha((0.05 * 255).round()),
            borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
            padding: ResponsiveSystem.all(context,
                baseSpacing:
                    ResponsiveSystem.spacing(context, baseSpacing: 12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.info,
                      size: ResponsiveSystem.iconSize(context, baseSize: 16),
                      color: ThemeProperties.getPrimaryColor(context),
                    ),
                    ResponsiveSystem.sizedBox(context,
                        width:
                            ResponsiveSystem.spacing(context, baseSpacing: 6)),
                    Text(
                      'Significance:',
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 14),
                        fontWeight: FontWeight.w600,
                        color: ThemeProperties.getPrimaryColor(context),
                      ),
                    ),
                  ],
                ),
                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 4)),
                Text(
                  kootaInfo['significance'] as String,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 13),
                    color: secondaryTextColor,
                    height:
                        ResponsiveSystem.lineHeight(context, baseHeight: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallCompatibilityInsights(MatchingState matchingState) {
    final secondaryTextColor = ThemeProperties.getSecondaryTextColor(context);

    return CentralizedInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getOverallInsights(),
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: secondaryTextColor,
              height: ResponsiveSystem.lineHeight(context, baseHeight: 1.4),
            ),
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
          CentralizedInfoCard(
            backgroundColor:
                _getScoreColor((matchingState.compatibilityScore ?? 0).round())
                    .withAlpha((0.1 * 255).round()),
            borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
            padding: ResponsiveSystem.all(context, baseSpacing: 12),
            child: Row(
              children: [
                Icon(
                  _getCompatibilityIcon(),
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                  color: _getScoreColor(
                      (matchingState.compatibilityScore ?? 0).round()),
                ),
                ResponsiveSystem.sizedBox(context,
                    width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
                Expanded(
                  child: Text(
                    _getCompatibilityMessage(),
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 14),
                      fontWeight: FontWeight.w600,
                      color: _getScoreColor(
                          (matchingState.compatibilityScore ?? 0).round()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for koota analysis

  /// Check if a key represents a koota score (not birth data)
  bool _isKootaScore(String key) {
    const kootaKeys = [
      'Varna',
      'Vashya',
      'Tara',
      'Yoni',
      'Graha Maitri',
      'Gana',
      'Bhakoot',
      'Nadi',
      'totalPoints'
    ];
    return kootaKeys.contains(key);
  }

  Map<String, dynamic> _getKootaInfo(String kootaName) {
    switch (kootaName) {
      case 'Varna':
        return {
          'maxScore': 1,
          'description':
              'Varna Koota represents the spiritual and ego compatibility between partners. It indicates how well the couple\'s spiritual values and social status align.',
          'significance':
              'This koota is crucial for long-term harmony. Higher scores indicate better spiritual alignment and mutual respect in the relationship.',
        };
      case 'Vashya':
        return {
          'maxScore': 2,
          'description':
              'Vashya Koota measures the mutual attraction and control dynamics in the relationship. It shows how well partners can influence and be influenced by each other.',
          'significance':
              'Essential for understanding power dynamics. Good scores indicate healthy mutual influence without dominance issues.',
        };
      case 'Tara':
        return {
          'maxScore': 3,
          'description':
              'Tara Koota is related to fortune, longevity, and overall well-being of the couple. It indicates the positive or negative influences on the relationship.',
          'significance':
              'Critical for marital happiness and longevity. Higher scores suggest better fortune and fewer obstacles in married life.',
        };
      case 'Yoni':
        return {
          'maxScore': 4,
          'description':
              'Yoni Koota represents sexual and physical compatibility between partners. It indicates the level of physical attraction and intimate harmony.',
          'significance':
              'Important for physical intimacy and attraction. Good scores indicate strong physical compatibility and mutual attraction.',
        };
      case 'Graha Maitri':
        return {
          'maxScore': 5,
          'description':
              'Graha Maitri Koota shows the friendship between the planetary lords of the Moon signs. It indicates mental compatibility and understanding.',
          'significance':
              'Vital for mental compatibility and friendship. Higher scores suggest better mental rapport and mutual understanding.',
        };
      case 'Gana':
        return {
          'maxScore': 6,
          'description':
              'Gana Koota categorizes partners into Deva (divine), Manushya (human), or Rakshasa (demonic) nature. It shows temperament compatibility.',
          'significance':
              'Crucial for temperament matching. Same Gana indicates similar nature and better compatibility in daily life.',
        };
      case 'Bhakoot':
        return {
          'maxScore': 7,
          'description':
              'Bhakoot Koota examines the relative positions of Moon signs. It indicates auspicious or inauspicious combinations for marital life.',
          'significance':
              'Very important for marital harmony. Good scores indicate favorable planetary positions for a successful marriage.',
        };
      case 'Nadi':
        return {
          'maxScore': 8,
          'description':
              'Nadi Koota is the most important factor, related to progeny and genetic compatibility. It indicates the health and well-being of future children.',
          'significance':
              'Most critical for progeny and genetic compatibility. Traditional rule: Same nakshatra + different pada = Nadi dosha nullified (8 points). Same nadi + same pada = Nadi dosha (0 points).',
        };
      default:
        return {
          'maxScore': 1,
          'description':
              'This koota represents an important aspect of compatibility analysis.',
          'significance':
              'This factor plays a significant role in determining overall compatibility.',
        };
    }
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) {
      return ThemeProperties.getSecondaryColor(
          context); // Sacred green - prosperity and growth
    } else if (percentage >= 60) {
      return ThemeProperties.getPrimaryColor(
          context); // Saffron orange - divine energy
    } else if (percentage >= 40) {
      return ThemeProperties.getPrimaryColor(
          context); // Golden saffron - spiritual wisdom
    } else {
      return ThemeProperties.getErrorColor(
          context); // Sacred red - divine energy
    }
  }

  String _getOverallInsights() {
    final matchingState = ref.read(matchingProvider);
    // Only sum the actual koota scores, not birth data
    final kootaScoreKeys = [
      'Varna',
      'Vashya',
      'Tara',
      'Yoni',
      'Graha Maitri',
      'Gana',
      'Bhakoot',
      'Nadi'
    ];
    final totalScore = kootaScoreKeys
        .map((key) =>
            double.tryParse(matchingState.kootaDetails?[key] ?? '0') ?? 0.0)
        .fold(0.0, (sum, score) => sum + score);
    final maxPossibleScore = 36;
    final percentage = (totalScore / maxPossibleScore * 100).round();

    if (percentage >= 80) {
      return 'Excellent compatibility! This relationship shows strong potential for a harmonious and successful marriage. Most kootas are well-matched, indicating good spiritual, mental, and physical compatibility.';
    } else if (percentage >= 60) {
      return 'Good compatibility with room for growth. While there are some areas that could be better, the overall match shows promise for a successful relationship with mutual understanding and effort.';
    } else if (percentage >= 40) {
      return 'Moderate compatibility. This relationship may face some challenges, but with mutual understanding, compromise, and effort, it can work. Consider discussing areas of concern openly.';
    } else {
      return 'Challenging compatibility. This relationship may require significant effort and understanding from both partners. Consider seeking guidance and working on areas of concern together.';
    }
  }

  IconData _getCompatibilityIcon() {
    final matchingState = ref.read(matchingProvider);
    if ((matchingState.compatibilityScore ?? 0) >= 80) {
      return LucideIcons.heart;
    } else if ((matchingState.compatibilityScore ?? 0) >= 60) {
      return LucideIcons.thumbsUp;
    } else if ((matchingState.compatibilityScore ?? 0) >= 40) {
      return LucideIcons.info;
    } else {
      return LucideIcons.triangleAlert;
    }
  }

  String _getCompatibilityMessage() {
    final matchingState = ref.read(matchingProvider);
    if ((matchingState.compatibilityScore ?? 0) >= 80) {
      return 'Excellent Match - Highly Recommended';
    } else if ((matchingState.compatibilityScore ?? 0) >= 60) {
      return 'Good Match - Recommended with Understanding';
    } else if ((matchingState.compatibilityScore ?? 0) >= 40) {
      return 'Moderate Match - Requires Effort';
    } else {
      return 'Challenging Match - Needs Careful Consideration';
    }
  }

  /// Get total score out of 36 points
  int _getTotalScore(MatchingState matchingState) {
    // Try to get totalPoints from kootaDetails first (from astrology library)
    if (matchingState.kootaDetails?['totalPoints'] != null) {
      final totalPointsStr = matchingState.kootaDetails!['totalPoints'];
      return int.tryParse(totalPointsStr ?? '0') ?? 0;
    }
    // If totalPoints is not available, return null to indicate missing data
    // Don't calculate fallback - let the UI handle missing data appropriately
    return 0; // Return 0 only if data is truly missing, not as a fallback calculation
  }

  Widget _buildCalculationApproachInfo() {
    return CentralizedInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.info,
                size: ResponsiveSystem.iconSize(context, baseSize: 20),
                color: ThemeProperties.getPrimaryColor(context),
              ),
              ResponsiveSystem.sizedBox(context,
                  width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
              Text(
                'Our Calculation Approach',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                  fontWeight: FontWeight.bold,
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
              ),
            ],
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
          Text(
            'We use the traditional Ashta Koota system based on classical Vedic astrology texts (Brihat Parashara Hora Shastra) with Swiss Ephemeris precision (99.9% accuracy).',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: ThemeProperties.getSecondaryTextColor(context),
              height: ResponsiveSystem.lineHeight(context, baseHeight: 1.5),
            ),
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
          Container(
            padding: ResponsiveSystem.all(context, baseSpacing: 12),
            decoration: BoxDecoration(
              color: ThemeProperties.getPrimaryColor(context).withAlpha(25),
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              border: Border.all(
                color: ThemeProperties.getPrimaryColor(context).withAlpha(50),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Key Features:',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                    fontWeight: FontWeight.w600,
                    color: ThemeProperties.getPrimaryColor(context),
                  ),
                ),
                ResponsiveSystem.sizedBox(context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
                _buildFeatureItem('✓ Traditional Nadi Dosha Rules',
                    'Same nakshatra + different pada = Nadi dosha nullified (8 points)'),
                _buildFeatureItem('✓ Swiss Ephemeris Accuracy',
                    '99.9% astronomical precision for all calculations'),
                _buildFeatureItem('✓ Classical Text Compliance',
                    'Follows Brihat Parashara Hora Shastra principles'),
                _buildFeatureItem('✓ Industry Standard Scoring',
                    '36-point system with authentic Vedic rules'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: ResponsiveSystem.only(context,
          bottom: ResponsiveSystem.spacing(context, baseSpacing: 4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 13),
              fontWeight: FontWeight.w500,
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
          ),
          ResponsiveSystem.sizedBox(context,
              width: ResponsiveSystem.spacing(context, baseSpacing: 8)),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                color: ThemeProperties.getSecondaryTextColor(context),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSummary(MatchingState matchingState) {
    final totalScore = _getTotalScore(matchingState);
    final maxPossibleScore = 36;
    final percentage = (totalScore / maxPossibleScore * 100).round();

    return CentralizedInfoCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Points:',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  fontWeight: FontWeight.w600,
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
              ),
              Text(
                '$totalScore/$maxPossibleScore',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(percentage),
                ),
              ),
            ],
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Percentage:',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                  fontWeight: FontWeight.w600,
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(percentage),
                ),
              ),
            ],
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
          LinearProgressIndicator(
            value: totalScore / maxPossibleScore,
            backgroundColor:
                _getScoreColor(percentage).withAlpha((0.2 * 255).round()),
            valueColor:
                AlwaysStoppedAnimation<Color>(_getScoreColor(percentage)),
          ),
          ResponsiveSystem.sizedBox(context,
              height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
          Text(
            _getScoreInterpretation(totalScore),
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
              color: ThemeProperties.getSecondaryTextColor(context),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getScoreInterpretation(int totalScore) {
    if (totalScore >= 30) {
      return 'Excellent compatibility - Highly recommended for marriage';
    } else if (totalScore >= 24) {
      return 'Good compatibility - Recommended with understanding';
    } else if (totalScore >= 18) {
      return 'Moderate compatibility - Requires mutual effort';
    } else if (totalScore >= 12) {
      return 'Challenging compatibility - Needs careful consideration';
    } else {
      return 'Low compatibility - Significant challenges expected';
    }
  }

  Widget _buildHeroSection(TranslationService translationService) {
    final primaryGradient = ThemeProperties.getPrimaryGradient(context);

    return Container(
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(
              ResponsiveSystem.borderRadius(context, baseRadius: 30)),
          bottomRight: Radius.circular(
              ResponsiveSystem.borderRadius(context, baseRadius: 30)),
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top +
              ResponsiveSystem.spacing(context, baseSpacing: 60),
          bottom: ResponsiveSystem.spacing(context, baseSpacing: 20),
          left: ResponsiveSystem.spacing(context, baseSpacing: 20),
          right: ResponsiveSystem.spacing(context, baseSpacing: 20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.heart,
              size: ResponsiveSystem.iconSize(context, baseSize: 40),
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 12)),
            // Main title
            Text(
              '💕 ${translationService.translateHeader('kundali_matching', fallback: 'Kundali Matching')}',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                fontWeight: FontWeight.bold,
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
            // Subtitle
            Text(
              'Find your perfect partner',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeProperties.getPrimaryTextColor(context)
                    .withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsHeroSection() {
    final primaryGradient = ThemeProperties.getPrimaryGradient(context);
    final matchingState = ref.watch(matchingProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(
              ResponsiveSystem.borderRadius(context, baseRadius: 30)),
          bottomRight: Radius.circular(
              ResponsiveSystem.borderRadius(context, baseRadius: 30)),
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: ResponsiveSystem.spacing(context, baseSpacing: 32),
          bottom: ResponsiveSystem.spacing(context, baseSpacing: 24),
          left: ResponsiveSystem.spacing(context, baseSpacing: 20),
          right: ResponsiveSystem.spacing(context, baseSpacing: 20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.star,
              size: ResponsiveSystem.iconSize(context, baseSize: 48),
              color: ThemeProperties.getPrimaryTextColor(context),
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 16)),
            Text(
              'Matching Results',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 24),
                color: ThemeProperties.getPrimaryTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
            Text(
              '${(matchingState.compatibilityScore ?? 0).toStringAsFixed(0)}% Compatible',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                color: ThemeProperties.getPrimaryTextColor(context)
                    .withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build small compatibility button for top of results
  Widget _buildSmallCompatibilityButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CentralizedInfoCard(
          child: CentralizedModernButton(
            text: 'Modify Details',
            icon: LucideIcons.pencil,
            onPressed: () {
              // Reset the matching state to go back to input screen
              ref.read(matchingProvider.notifier).resetState();

              // Keep all existing form data - don't reset values
              // This allows users to modify just one field instead of re-entering everything
              CentralizedLoggingService.instance.logInfo(
                  'Check Different Compatibility - keeping existing form data',
                  tag: 'MatchingScreen');
            },
            width: ResponsiveSystem.screenWidth(context) * 0.4,
            height: ResponsiveSystem.buttonHeight(context, baseHeight: 40),
          ),
        ),
      ],
    );
  }

  /// Handle language change
  void _handleLanguageChange(WidgetRef ref, String languageValue) {
    SupportedLanguage language;
    switch (languageValue) {
      case 'en':
        language = SupportedLanguage.english;
        break;
      case 'hi':
        language = SupportedLanguage.hindi;
        break;
      case 'te':
        language = SupportedLanguage.telugu;
        break;
      default:
        language = SupportedLanguage.english;
    }

    // Change both header and content language
    ref.read(languageServiceProvider.notifier).setHeaderLanguage(language);
    ref.read(languageServiceProvider.notifier).setContentLanguage(language);
  }

  /// Handle theme change
  void _handleThemeChange(WidgetRef ref, String themeValue) {
    AppThemeMode themeMode;
    switch (themeValue) {
      case 'light':
        themeMode = AppThemeMode.light;
        break;
      case 'dark':
        themeMode = AppThemeMode.dark;
        break;
      case 'system':
        themeMode = AppThemeMode.system;
        break;
      default:
        themeMode = AppThemeMode.system;
    }

    ref.read(themeNotifierProvider.notifier).setThemeMode(themeMode);
  }

  /// Handle profile icon tap - show popup if profile incomplete, otherwise navigate to profile
  Future<void> _handleProfileTap(BuildContext context, WidgetRef ref,
      TranslationService translationService) async {
    final currentContext = context;
    try {
      final userService = ref.read(user_service.userServiceProvider.notifier);
      final result = await userService.getCurrentUser();
      final user =
          ResultHelper.isSuccess(result) ? ResultHelper.getValue(result) : null;

      // Use ProfileCompletionChecker to determine if user has real profile data
      if (user == null || !ProfileCompletionChecker.isProfileComplete(user)) {
        // Show "Complete Your Profile" popup instead of directly navigating
        _showProfileCompletionPopup(currentContext, translationService);
      } else {
        // Navigate to profile view screen
        _navigateToProfile(currentContext);
      }
    } catch (e) {
      // On error, show profile completion popup
      _showProfileCompletionPopup(currentContext, translationService);
    }
  }

  /// Show profile completion popup
  void _showProfileCompletionPopup(
      BuildContext context, TranslationService translationService) {
    showDialog(
      context: context,
      builder: (context) => CentralizedProfileCompletionPopup(
        onCompleteProfile: () {
          Navigator.of(context).pop(); // Close dialog
          _navigateToUser(context); // Navigate to edit screen
        },
        onSkip: () {
          Navigator.of(context).pop(); // Close dialog
        },
      ),
    );
  }

  /// Navigate to user edit screen with hero animation
  void _navigateToUser(BuildContext context) {
    // Get the screen size for positioning
    final screenSize = MediaQuery.of(context).size;

    // Calculate approximate position of profile icon (top right)
    final sourcePosition = Offset(
      screenSize.width -
          ResponsiveSystem.spacing(context,
              baseSpacing: 60), // Approximate position of profile icon
      ResponsiveSystem.spacing(context,
          baseSpacing: 60), // Approximate Y position
    );
    final sourceSize = Size(
        ResponsiveSystem.spacing(context, baseSpacing: 40),
        ResponsiveSystem.spacing(context,
            baseSpacing: 40)); // Approximate size of profile icon

    // Use hero navigation with zoom-out effect from profile icon
    HeroNavigationWithRipple.pushWithRipple(
      context,
      const UserEditScreen(),
      sourcePosition,
      sourceSize,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      rippleColor: ThemeProperties.getPrimaryColor(context),
      rippleRadius: 100.0,
    );
  }

  /// Navigate to profile with slide animation
  void _navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }
}

/// Custom themed time picker dialog with reactive sizing
class _CustomTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;

  const _CustomTimePickerDialog({
    required this.initialTime,
  });

  @override
  State<_CustomTimePickerDialog> createState() =>
      _CustomTimePickerDialogState();
}

class _CustomTimePickerDialogState extends State<_CustomTimePickerDialog> {
  late TimeOfDay _selectedTime;
  late int _selectedHour;
  late int _selectedMinute;
  late bool _isAM;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _selectedHour = _selectedTime.hourOfPeriod;
    _selectedMinute = _selectedTime.minute;
    _isAM = _selectedTime.period == DayPeriod.am;
  }

  void _updateTime() {
    final hour24 = _isAM ? _selectedHour : _selectedHour + 12;
    if (hour24 == 24) _selectedHour = 0;
    _selectedTime = TimeOfDay(hour: hour24, minute: _selectedMinute);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ThemeProperties.getSurfaceColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: ResponsiveSystem.circular(context,
            baseRadius: ResponsiveSystem.spacing(context, baseSpacing: 16)),
      ),
      child: Container(
        width: ResponsiveSystem.responsive(
          context,
          mobile: ResponsiveSystem.spacing(context, baseSpacing: 320),
          tablet: ResponsiveSystem.spacing(context, baseSpacing: 400),
          desktop: ResponsiveSystem.spacing(context, baseSpacing: 480),
        ),
        padding: ResponsiveSystem.all(context, baseSpacing: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Select Time',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 20),
                fontWeight: FontWeight.bold,
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 24)),

            // Time Selection Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Hour Selection
                _buildTimeSelector(
                  label: 'Hour',
                  value: _selectedHour.toString().padLeft(2, '0'),
                  onIncrement: () {
                    setState(() {
                      _selectedHour = (_selectedHour + 1) % 12;
                      if (_selectedHour == 0) _selectedHour = 12;
                      _updateTime();
                    });
                  },
                  onDecrement: () {
                    setState(() {
                      _selectedHour = (_selectedHour - 1) % 12;
                      if (_selectedHour == 0) _selectedHour = 12;
                      _updateTime();
                    });
                  },
                ),

                ResponsiveSystem.sizedBox(context,
                    width: ResponsiveSystem.spacing(context, baseSpacing: 16)),

                // Minute Selection
                _buildTimeSelector(
                  label: 'Minute',
                  value: _selectedMinute.toString().padLeft(2, '0'),
                  onIncrement: () {
                    setState(() {
                      _selectedMinute = (_selectedMinute + 5) % 60;
                      _updateTime();
                    });
                  },
                  onDecrement: () {
                    setState(() {
                      _selectedMinute = (_selectedMinute - 5) % 60;
                      if (_selectedMinute < 0) _selectedMinute = 55;
                      _updateTime();
                    });
                  },
                ),

                ResponsiveSystem.sizedBox(context,
                    width: ResponsiveSystem.spacing(context, baseSpacing: 16)),

                // AM/PM Selection
                _buildPeriodSelector(),
              ],
            ),

            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 24)),

            // Clock Display
            _buildClockDisplay(),

            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 24)),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 16),
                      color: ThemeProperties.getSecondaryTextColor(context),
                    ),
                  ),
                ),
                ResponsiveSystem.sizedBox(context,
                    width: ResponsiveSystem.spacing(context, baseSpacing: 12)),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedTime),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeProperties.getPrimaryColor(context),
                    foregroundColor:
                        ThemeProperties.getPrimaryTextColor(context),
                    padding: ResponsiveSystem.symmetric(
                      context,
                      horizontal:
                          ResponsiveSystem.spacing(context, baseSpacing: 24),
                      vertical:
                          ResponsiveSystem.spacing(context, baseSpacing: 12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: ResponsiveSystem.circular(context,
                          baseRadius: ResponsiveSystem.spacing(context,
                              baseSpacing: 8)),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize:
                          ResponsiveSystem.fontSize(context, baseSize: 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required String value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
            color: ThemeProperties.getSecondaryTextColor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        ResponsiveSystem.sizedBox(context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
        Container(
          width: ResponsiveSystem.spacing(context, baseSpacing: 80),
          height: ResponsiveSystem.spacing(context, baseSpacing: 100),
          decoration: BoxDecoration(
            color: ThemeProperties.getSurfaceContainerColor(context),
            borderRadius: ResponsiveSystem.circular(context,
                baseRadius: ResponsiveSystem.spacing(context, baseSpacing: 12)),
            border: Border.all(
              color: ThemeProperties.getPrimaryColor(context),
              width: ResponsiveSystem.borderWidth(context, baseWidth: 2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onIncrement,
                icon: Icon(
                  LucideIcons.chevronUp,
                  color: ThemeProperties.getPrimaryColor(context),
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 24),
                  fontWeight: FontWeight.bold,
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
              ),
              IconButton(
                onPressed: onDecrement,
                icon: Icon(
                  LucideIcons.chevronDown,
                  color: ThemeProperties.getPrimaryColor(context),
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      children: [
        Text(
          'Period',
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
            color: ThemeProperties.getSecondaryTextColor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        ResponsiveSystem.sizedBox(context,
            height: ResponsiveSystem.spacing(context, baseSpacing: 8)),
        Container(
          width: ResponsiveSystem.spacing(context, baseSpacing: 80),
          height: ResponsiveSystem.spacing(context, baseSpacing: 100),
          decoration: BoxDecoration(
            color: ThemeProperties.getSurfaceContainerColor(context),
            borderRadius: ResponsiveSystem.circular(context,
                baseRadius: ResponsiveSystem.spacing(context, baseSpacing: 12)),
            border: Border.all(
              color: ThemeProperties.getPrimaryColor(context),
              width: ResponsiveSystem.borderWidth(context, baseWidth: 2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isAM = true;
                    _updateTime();
                  });
                },
                child: Container(
                  width: ResponsiveSystem.screenWidth(context),
                  height: ResponsiveSystem.spacing(context, baseSpacing: 40),
                  decoration: BoxDecoration(
                    color: _isAM
                        ? ThemeProperties.getPrimaryColor(context)
                        : ThemeProperties.getTransparentColor(context),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                          ResponsiveSystem.borderRadius(context, baseRadius: 10)),
                      topRight: Radius.circular(
                          ResponsiveSystem.borderRadius(context, baseRadius: 10)),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'AM',
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 16),
                        fontWeight: FontWeight.w600,
                        color: _isAM
                            ? ThemeProperties.getPrimaryTextColor(context)
                            : ThemeProperties.getSecondaryTextColor(context),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isAM = false;
                    _updateTime();
                  });
                },
                child: Container(
                  width: ResponsiveSystem.screenWidth(context),
                  height: ResponsiveSystem.spacing(context, baseSpacing: 40),
                  decoration: BoxDecoration(
                    color: !_isAM
                        ? ThemeProperties.getPrimaryColor(context)
                        : ThemeProperties.getTransparentColor(context),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(
                          ResponsiveSystem.borderRadius(context, baseRadius: 10)),
                      bottomRight: Radius.circular(
                          ResponsiveSystem.borderRadius(context, baseRadius: 10)),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'PM',
                      style: TextStyle(
                        fontSize:
                            ResponsiveSystem.fontSize(context, baseSize: 16),
                        fontWeight: FontWeight.w600,
                        color: !_isAM
                            ? ThemeProperties.getPrimaryTextColor(context)
                            : ThemeProperties.getSecondaryTextColor(context),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClockDisplay() {
    return Container(
      width: ResponsiveSystem.spacing(context, baseSpacing: 120),
      height: ResponsiveSystem.spacing(context, baseSpacing: 120),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ThemeProperties.getSurfaceContainerColor(context),
        border: Border.all(
          color: ThemeProperties.getPrimaryColor(context),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 3),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_selectedTime.hourOfPeriod.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 24),
                fontWeight: FontWeight.bold,
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
            ),
            ResponsiveSystem.sizedBox(context,
                height: ResponsiveSystem.spacing(context, baseSpacing: 4)),
            Text(
              _selectedTime.period == DayPeriod.am ? 'AM' : 'PM',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                color: ThemeProperties.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
