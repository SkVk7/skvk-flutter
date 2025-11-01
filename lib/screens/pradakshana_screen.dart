import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/design_system/design_system.dart';
import '../core/services/language_service.dart';
import '../core/services/translation_service.dart';
import '../core/logging/logging_helper.dart';
import '../core/theme/theme_provider.dart';
import '../shared/widgets/centralized_widgets.dart';
import '../features/user/presentation/screens/user_edit_screen.dart';
import 'dart:async';

/// Simple Pradakshana Counter
/// 
/// A clean, simple counter for pradakshana practice.
/// Features:
/// - Large count display (45-50% of screen)
/// - Simple + button (30% of screen)
/// - Timer lock functionality
/// - Reset button
class PradakshanaScreen extends ConsumerStatefulWidget {
  const PradakshanaScreen({super.key});

  @override
  ConsumerState<PradakshanaScreen> createState() => _PradakshanaScreenState();
}

class _PradakshanaScreenState extends ConsumerState<PradakshanaScreen>
    with TickerProviderStateMixin {
  
  // State variables
  int _pradakshanaCount = 0;
  bool _isButtonDisabled = false;
  Duration _cooldownDuration = const Duration(seconds: 30);
  Timer? _cooldownTimer;
  DateTime? _lastTriggerTime;
  Duration _remainingCooldown = Duration.zero;
  
  // Storage keys
  static const String _countKey = 'pradakshana_count';
  static const String _cooldownKey = 'pradakshana_cooldown_duration';
  static const String _lastTriggerKey = 'pradakshana_last_trigger_time';
  
  // Animation controllers
  late AnimationController _countAnimationController;
  late AnimationController _buttonAnimationController;
  
  // Animations
  late Animation<double> _countScaleAnimation;
  late Animation<double> _buttonScaleAnimation;
  
  // Scroll controllers for time selector
  late FixedExtentScrollController _hoursScrollController;
  late FixedExtentScrollController _minutesScrollController;
  
  // Text editing controllers for time inputs
  late TextEditingController _hoursTextController;
  late TextEditingController _minutesTextController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeScrollControllers();
    _loadPersistedData();
  }

  void _initializeAnimations() {
    // Count animation controller
    _countAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Button animation controller
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Count scale animation
    _countScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _countAnimationController,
      curve: Curves.elasticOut,
    ));
    
    // Button scale animation
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeScrollControllers() {
    _hoursScrollController = FixedExtentScrollController();
    _minutesScrollController = FixedExtentScrollController();
    _hoursTextController = TextEditingController();
    _minutesTextController = TextEditingController();
  }

  @override
  void dispose() {
    _countAnimationController.dispose();
    _buttonAnimationController.dispose();
    _hoursScrollController.dispose();
    _minutesScrollController.dispose();
    _hoursTextController.dispose();
    _minutesTextController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  // Load persisted data from storage
  Future<void> _loadPersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load count
      final savedCount = prefs.getInt(_countKey) ?? 0;
      
      // Load cooldown duration
      final savedCooldownSeconds = prefs.getInt(_cooldownKey) ?? 30;
      
      // Load last trigger time
      final savedLastTriggerTime = prefs.getString(_lastTriggerKey);
      DateTime? lastTriggerTime;
      if (savedLastTriggerTime != null) {
        lastTriggerTime = DateTime.parse(savedLastTriggerTime);
      }
      
      setState(() {
        _pradakshanaCount = savedCount;
        _cooldownDuration = Duration(seconds: savedCooldownSeconds);
        _lastTriggerTime = lastTriggerTime;
      });
      
      // Calculate and apply dynamic cooldown
      _calculateAndApplyDynamicCooldown();
    } catch (e) {
      // If loading fails, use defaults
      debugPrint('Failed to load persisted data: $e');
    }
  }
  
  // Save count to storage
  Future<void> _saveCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_countKey, _pradakshanaCount);
    } catch (e) {
      debugPrint('Failed to save count: $e');
    }
  }
  
  // Save cooldown duration to storage
  Future<void> _saveCooldownDuration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_cooldownKey, _cooldownDuration.inSeconds);
    } catch (e) {
      debugPrint('Failed to save cooldown duration: $e');
    }
  }
  
  // Save last trigger time to storage
  Future<void> _saveLastTriggerTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_lastTriggerTime != null) {
        await prefs.setString(_lastTriggerKey, _lastTriggerTime!.toIso8601String());
      }
    } catch (e) {
      debugPrint('Failed to save last trigger time: $e');
    }
  }
  
  // Calculate dynamic cooldown based on time difference
  void _calculateAndApplyDynamicCooldown() {
    // If cooldown duration is zero, button should always be enabled
    if (_cooldownDuration.inSeconds == 0) {
      setState(() {
        _isButtonDisabled = false;
        _remainingCooldown = Duration.zero;
      });
      return;
    }
    
    if (_lastTriggerTime == null) {
      // No previous trigger, button should be enabled
      setState(() {
        _isButtonDisabled = false;
        _remainingCooldown = Duration.zero;
      });
      return;
    }
    
    final now = DateTime.now();
    final timeSinceLastTrigger = now.difference(_lastTriggerTime!);
    
    if (timeSinceLastTrigger >= _cooldownDuration) {
      // Cooldown period has passed
      setState(() {
        _isButtonDisabled = false;
        _remainingCooldown = Duration.zero;
      });
    } else {
      // Still in cooldown period
      setState(() {
        _isButtonDisabled = true;
        _remainingCooldown = _cooldownDuration - timeSinceLastTrigger;
      });
      
      // Start a timer to update the remaining cooldown
      _startDynamicCooldownTimer();
    }
  }
  
  // Start dynamic cooldown timer that updates every second
  void _startDynamicCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _calculateAndApplyDynamicCooldown();
      } else {
        timer.cancel();
      }
    });
  }
  
  // Format remaining cooldown time for display
  String _formatRemainingCooldown() {
    if (_remainingCooldown.inHours > 0) {
      return '${_remainingCooldown.inHours}h ${_remainingCooldown.inMinutes % 60}m remaining';
    } else if (_remainingCooldown.inMinutes > 0) {
      return '${_remainingCooldown.inMinutes}m ${_remainingCooldown.inSeconds % 60}s remaining';
    } else {
      return '${_remainingCooldown.inSeconds}s remaining';
    }
  }

  // Handle language change
  void _handleLanguageChange(WidgetRef ref, String languageValue) {
    SupportedLanguage language;
    switch (languageValue) {
      case 'en':
        language = SupportedLanguage.english;
        break;
      case 'hi':
        language = SupportedLanguage.hindi;
        break;
      default:
        language = SupportedLanguage.english;
    }
    ref.read(languageServiceProvider.notifier).setHeaderLanguage(language);
    ref.read(languageServiceProvider.notifier).setContentLanguage(language);
  }

  // Handle theme change
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

  // Handle profile tap
  void _handleProfileTap(BuildContext context, WidgetRef ref, TranslationService translationService) {
    // Navigate to user edit screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserEditScreen(),
      ),
    );
  }

  // Show message
  void _showMessage(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess 
            ? ThemeProperties.getSuccessColor(context)
            : ThemeProperties.getErrorColor(context),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
        ),
      ),
    );
  }
  
  // Reset count with confirmation
  Future<void> _resetCount() async {
    final confirmed = await _showResetConfirmationDialog();
    if (confirmed) {
      setState(() {
        _pradakshanaCount = 0;
        _lastTriggerTime = null;
        _isButtonDisabled = false;
        _remainingCooldown = Duration.zero;
      });
      await _saveCount();
      await _saveLastTriggerTime();
      
      // Cancel any running timer
      _cooldownTimer?.cancel();
      
      // Show success message
      if (mounted) {
        _showMessage('Pradakshana count has been reset');
      }
    }
  }
  
  // Show reset confirmation dialog
  Future<bool> _showResetConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: ThemeProperties.getErrorColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 24),
            ),
            ResponsiveSystem.sizedBox(context, width: 12),
            Text(
              'Reset Count',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                fontWeight: FontWeight.bold,
                color: ThemeProperties.getPrimaryTextColor(context),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to reset your Pradakshana count? This action cannot be undone.',
          style: TextStyle(
            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
            color: ThemeProperties.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: ThemeProperties.getSecondaryTextColor(context),
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeProperties.getErrorColor(context),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
              ),
            ),
            child: Text(
              'Reset',
              style: TextStyle(
                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _incrementCount() {
    if (_isButtonDisabled) return;
    
    setState(() {
      _pradakshanaCount++;
      _lastTriggerTime = DateTime.now();
      // Only disable button if cooldown duration is greater than zero
      _isButtonDisabled = _cooldownDuration.inSeconds > 0;
    });
    
    // Save count and trigger time to storage
    _saveCount();
    _saveLastTriggerTime();
    
    // Trigger count animation
    _countAnimationController.forward().then((_) {
      _countAnimationController.reverse();
    });
    
    // Calculate and apply cooldown immediately (handles zero cooldown case)
    _calculateAndApplyDynamicCooldown();
  }


  // Show time selector
  void _showTimeSelector() {
    // Update text controllers with current values
    _hoursTextController.text = _cooldownDuration.inHours.toString();
    _minutesTextController.text = (_cooldownDuration.inMinutes % 60).toString();
    
    // Position scroll controllers to current time values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hoursScrollController.animateToItem(
        _cooldownDuration.inHours,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _minutesScrollController.animateToItem(
        _cooldownDuration.inMinutes % 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildTimeSelectorSheet(),
    );
  }

  Widget _buildTimeSelectorSheet() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive max height based on screen size and safe area
        final screenHeight = MediaQuery.of(context).size.height;
        final safeAreaPadding = MediaQuery.of(context).padding;
        final availableHeight = screenHeight - safeAreaPadding.top - safeAreaPadding.bottom;
        final maxHeight = ResponsiveSystem.responsive(
          context,
          mobile: availableHeight * 0.85,
          tablet: availableHeight * 0.80,
          desktop: availableHeight * 0.75,
          largeDesktop: availableHeight * 0.75,
        );
        
        return Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
          ),
          decoration: BoxDecoration(
            color: ThemeProperties.getSurfaceColor(context),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 20)),
              topRight: Radius.circular(ResponsiveSystem.borderRadius(context, baseRadius: 20)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: ResponsiveSystem.spacing(context, baseSpacing: 40),
                height: ResponsiveSystem.spacing(context, baseSpacing: 4),
                margin: ResponsiveSystem.symmetric(context, vertical: 12),
                decoration: BoxDecoration(
                  color: ThemeProperties.getDividerColor(context),
                  borderRadius: ResponsiveSystem.circular(context, baseRadius: 2),
                ),
              ),
              
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Padding(
                        padding: ResponsiveSystem.symmetric(context, horizontal: 20, vertical: 8),
                        child: Text(
                          'Set Each Pradakshana Time',
                          style: TextStyle(
                            fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                            fontWeight: FontWeight.bold,
                            color: ThemeProperties.getPrimaryTextColor(context),
                          ),
                        ),
                      ),
                      
                      // Editable time input boxes
                      Padding(
                        padding: ResponsiveSystem.symmetric(context, horizontal: 20, vertical: 8),
                        child: _buildEditableTimeInputs(),
                      ),
                      
                      // Time selector with scroll wheels - responsive sizing
                      LayoutBuilder(
                        builder: (context, innerConstraints) {
                          // Calculate responsive height based on available space
                          final availableSpace = maxHeight - 
                              ResponsiveSystem.spacing(context, baseSpacing: 200); // Account for other elements
                          final scrollHeight = ResponsiveSystem.responsive(
                            context,
                            mobile: availableSpace * 0.5,
                            tablet: availableSpace * 0.55,
                            desktop: availableSpace * 0.60,
                            largeDesktop: availableSpace * 0.60,
                          ).clamp(
                            ResponsiveSystem.spacing(context, baseSpacing: 150),
                            ResponsiveSystem.spacing(context, baseSpacing: 280),
                          );
                          
                          return Container(
                            constraints: BoxConstraints(
                              maxHeight: scrollHeight,
                              minHeight: ResponsiveSystem.spacing(context, baseSpacing: 150),
                            ),
                            height: scrollHeight,
                            padding: ResponsiveSystem.all(context, baseSpacing: 16),
                            child: _buildCrownTimeSelector(scrollHeight),
                          );
                        },
                      ),
                      
                      // Save button
                      Padding(
                        padding: ResponsiveSystem.symmetric(context, horizontal: 20, vertical: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _saveCooldownDuration();
                              // Recalculate cooldown with new time setting
                              _calculateAndApplyDynamicCooldown();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeProperties.getPrimaryColor(context),
                              foregroundColor: Colors.white,
                              padding: ResponsiveSystem.symmetric(context, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
                              ),
                            ),
                            child: Text(
                              'Set Time',
                              style: TextStyle(
                                fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Bottom padding for safe area
                      SizedBox(height: MediaQuery.of(context).padding.bottom + ResponsiveSystem.spacing(context, baseSpacing: 8)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditableTimeInputs() {
    return Row(
      children: [
        // Hours input
        Expanded(
          child: Column(
            children: [
              Text(
                'Hours',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  fontWeight: FontWeight.w600,
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
              ),
              ResponsiveSystem.sizedBox(context, height: 8),
              Container(
                constraints: BoxConstraints(
                  minHeight: ResponsiveSystem.spacing(context, baseSpacing: 48),
                  maxHeight: ResponsiveSystem.spacing(context, baseSpacing: 60),
                ),
                decoration: BoxDecoration(
                  color: ThemeProperties.getSurfaceColor(context),
                  borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
                  border: Border.all(
                    color: ThemeProperties.getBorderColor(context),
                    width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
                  ),
                ),
                child: TextFormField(
                  controller: _hoursTextController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                    fontWeight: FontWeight.bold,
                    color: ThemeProperties.getPrimaryTextColor(context),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: ResponsiveSystem.all(context, baseSpacing: 12),
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: ThemeProperties.getSecondaryTextColor(context),
                    ),
                  ),
                  onChanged: (value) {
                    final hours = int.tryParse(value) ?? 0;
                    if (hours >= 0 && hours <= 23) {
                      setState(() {
                        final minutes = _cooldownDuration.inMinutes % 60;
                        _cooldownDuration = Duration(hours: hours, minutes: minutes);
                      });
                      // Sync scroll wheel
                      _hoursScrollController.animateToItem(
                        hours,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        
        ResponsiveSystem.sizedBox(context, width: 16),
        
        // Minutes input
        Expanded(
          child: Column(
            children: [
              Text(
                'Minutes',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  fontWeight: FontWeight.w600,
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
              ),
              ResponsiveSystem.sizedBox(context, height: 8),
              Container(
                constraints: BoxConstraints(
                  minHeight: ResponsiveSystem.spacing(context, baseSpacing: 48),
                  maxHeight: ResponsiveSystem.spacing(context, baseSpacing: 60),
                ),
                decoration: BoxDecoration(
                  color: ThemeProperties.getSurfaceColor(context),
                  borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
                  border: Border.all(
                    color: ThemeProperties.getBorderColor(context),
                    width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
                  ),
                ),
                child: TextFormField(
                  controller: _minutesTextController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                    fontWeight: FontWeight.bold,
                    color: ThemeProperties.getPrimaryTextColor(context),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: ResponsiveSystem.all(context, baseSpacing: 12),
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: ThemeProperties.getSecondaryTextColor(context),
                    ),
                  ),
                  onChanged: (value) {
                    final minutes = int.tryParse(value) ?? 0;
                    if (minutes >= 0 && minutes <= 59) {
                      setState(() {
                        final hours = _cooldownDuration.inHours;
                        _cooldownDuration = Duration(hours: hours, minutes: minutes);
                      });
                      // Sync scroll wheel
                      _minutesScrollController.animateToItem(
                        minutes,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCrownTimeSelector(double containerHeight) {
    // Calculate responsive itemExtent based on container height
    // Show 3-4 visible items, with some padding
    // Subtract padding and label space from container height
    final padding = ResponsiveSystem.spacing(context, baseSpacing: 16) * 2; // top and bottom padding
    final labelHeight = ResponsiveSystem.spacing(context, baseSpacing: 28); // label and spacing
    final scrollViewHeight = (containerHeight - padding - labelHeight).clamp(
      ResponsiveSystem.spacing(context, baseSpacing: 120),
      ResponsiveSystem.spacing(context, baseSpacing: 220),
    );
    
    // Calculate itemExtent to show 3-4 items (25-33% of scrollViewHeight per item)
    final itemExtent = (scrollViewHeight / 3.5).clamp(
      ResponsiveSystem.spacing(context, baseSpacing: 35),
      ResponsiveSystem.spacing(context, baseSpacing: 60),
    );
    
    return Row(
      children: [
        // Hours scroll wheel
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hours',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  fontWeight: FontWeight.w600,
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
              ),
              ResponsiveSystem.sizedBox(context, height: 8),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: scrollViewHeight,
                    minHeight: ResponsiveSystem.spacing(context, baseSpacing: 120),
                  ),
                  height: scrollViewHeight,
                  decoration: BoxDecoration(
                    color: ThemeProperties.getSurfaceColor(context),
                    borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
                    border: Border.all(
                      color: ThemeProperties.getBorderColor(context),
                      width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
                    ),
                  ),
                  child: ListWheelScrollView.useDelegate(
                    controller: _hoursScrollController,
                    itemExtent: itemExtent,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        final hours = index;
                        final minutes = _cooldownDuration.inMinutes % 60;
                        _cooldownDuration = Duration(hours: hours, minutes: minutes);
                      });
                      // Sync text controller
                      _hoursTextController.text = index.toString();
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        final isSelected = index == _cooldownDuration.inHours;
                        return Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveSystem.spacing(context, baseSpacing: 4),
                          ),
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected 
                                  ? ThemeProperties.getPrimaryColor(context)
                                  : ThemeProperties.getPrimaryTextColor(context),
                            ),
                          ),
                        );
                      },
                      childCount: 24, // 0-23 hours
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        ResponsiveSystem.sizedBox(context, width: 16),
        
        // Minutes scroll wheel
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Minutes',
                style: TextStyle(
                  fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                  fontWeight: FontWeight.w600,
                  color: ThemeProperties.getPrimaryTextColor(context),
                ),
              ),
              ResponsiveSystem.sizedBox(context, height: 8),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: scrollViewHeight,
                    minHeight: ResponsiveSystem.spacing(context, baseSpacing: 120),
                  ),
                  height: scrollViewHeight,
                  decoration: BoxDecoration(
                    color: ThemeProperties.getSurfaceColor(context),
                    borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
                    border: Border.all(
                      color: ThemeProperties.getBorderColor(context),
                      width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
                    ),
                  ),
                  child: ListWheelScrollView.useDelegate(
                    controller: _minutesScrollController,
                    itemExtent: itemExtent,
                    perspective: 0.005,
                    diameterRatio: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        final hours = _cooldownDuration.inHours;
                        final minutes = index;
                        _cooldownDuration = Duration(hours: hours, minutes: minutes);
                      });
                      // Sync text controller
                      _minutesTextController.text = index.toString();
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        final isSelected = index == (_cooldownDuration.inMinutes % 60);
                        return Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveSystem.spacing(context, baseSpacing: 4),
                          ),
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected 
                                  ? ThemeProperties.getPrimaryColor(context)
                                  : ThemeProperties.getPrimaryTextColor(context),
                            ),
                          ),
                        );
                      },
                      childCount: 60, // 0-59 minutes
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: BackgroundGradients.getBackgroundGradient(
            isDark: isDark,
            isEvening: false, // You can make this dynamic based on time
            useSacredFire: false,
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final translationService = ref.watch(translationServiceProvider);
    
    return CentralizedGradientAppBar(
      title: 'Pradakshana Counter',
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: ThemeProperties.getAppBarTextColor(context),
          size: ResponsiveSystem.iconSize(context, baseSize: 20),
        ),
        onPressed: () => Navigator.pop(context),
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
            onTap: () => _handleProfileTap(context, ref, translationService),
            tooltip: translationService.translateContent(
              'my_profile',
              fallback: 'My Profile',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: ResponsiveSystem.all(context, baseSpacing: 20),
        child: Column(
          children: [
            // Count display (45-50% of screen)
            Expanded(
              flex: 5,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: ResponsiveSystem.spacing(context, baseSpacing: 200),
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: _buildCountDisplay(),
              ),
            ),
            
            ResponsiveSystem.sizedBox(context, height: 20),
            
            // Add Pradakshana button (30% of screen)
            Expanded(
              flex: 3,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: ResponsiveSystem.spacing(context, baseSpacing: 150),
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: _buildAddButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountDisplay() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeProperties.getPrimaryColor(context).withValues(alpha: 0.1),
            ThemeProperties.getPrimaryColor(context).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: ResponsiveSystem.circular(context, baseRadius: 20),
        border: Border.all(
          color: ThemeProperties.getPrimaryColor(context).withValues(alpha: 0.3),
          width: ResponsiveSystem.borderWidth(context, baseWidth: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeProperties.getPrimaryColor(context).withValues(alpha: 0.2),
            blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 16),
            spreadRadius: ResponsiveSystem.spacing(context, baseSpacing: 1),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Reset button in top right corner
          Positioned(
            top: ResponsiveSystem.spacing(context, baseSpacing: 12),
            right: ResponsiveSystem.spacing(context, baseSpacing: 12),
            child: GestureDetector(
              onTap: _resetCount,
              child: Container(
                padding: ResponsiveSystem.all(context, baseSpacing: 8),
                decoration: BoxDecoration(
                  color: ThemeProperties.getErrorColor(context).withValues(alpha: 0.1),
                  borderRadius: ResponsiveSystem.circular(context, baseRadius: 8),
                  border: Border.all(
                    color: ThemeProperties.getErrorColor(context).withValues(alpha: 0.3),
                    width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
                  ),
                ),
                child: Icon(
                  Icons.refresh,
                  color: ThemeProperties.getErrorColor(context),
                  size: ResponsiveSystem.iconSize(context, baseSize: 20),
                ),
              ),
            ),
          ),
          // Main content - centered
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          
          // Count display with animation
          AnimatedBuilder(
            animation: _countScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _countScaleAnimation.value,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    '$_pradakshanaCount',
                    style: TextStyle(
                      fontSize: ResponsiveSystem.fontSize(context, baseSize: 72),
                      fontWeight: FontWeight.bold,
                      color: ThemeProperties.getPrimaryColor(context),
                      shadows: [
                        Shadow(
                          color: ThemeProperties.getPrimaryColor(context).withValues(alpha: 0.3),
                          blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 8),
                          offset: Offset(0, ResponsiveSystem.spacing(context, baseSpacing: 4)),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
          
          ResponsiveSystem.sizedBox(context, height: 8),
          
          // Label
          Text(
            'Pradakshanas',
            style: TextStyle(
              fontSize: ResponsiveSystem.fontSize(context, baseSize: 18),
              fontWeight: FontWeight.w600,
              color: ThemeProperties.getSecondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Column(
      children: [
        // Time selector button
        GestureDetector(
          onTap: _showTimeSelector,
          child: Container(
            constraints: BoxConstraints(
              minHeight: ResponsiveSystem.spacing(context, baseSpacing: 48),
              maxHeight: ResponsiveSystem.spacing(context, baseSpacing: 60),
            ),
            padding: ResponsiveSystem.all(context, baseSpacing: 12),
            decoration: BoxDecoration(
              color: ThemeProperties.getPrimaryColor(context).withValues(alpha: 0.1),
              borderRadius: ResponsiveSystem.circular(context, baseRadius: 12),
              border: Border.all(
                color: ThemeProperties.getPrimaryColor(context),
                width: ResponsiveSystem.borderWidth(context, baseWidth: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule,
                  size: ResponsiveSystem.iconSize(context, baseSize: 16),
                  color: ThemeProperties.getPrimaryColor(context),
                ),
                ResponsiveSystem.sizedBox(context, width: 8),
                Text(
                  'Each Pradakshana Time',
                  style: TextStyle(
                    fontSize: ResponsiveSystem.fontSize(context, baseSize: 14),
                    color: ThemeProperties.getPrimaryColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ResponsiveSystem.sizedBox(context, width: 8),
                Icon(
                  Icons.arrow_drop_down,
                  size: ResponsiveSystem.iconSize(context, baseSize: 16),
                  color: ThemeProperties.getPrimaryColor(context),
                ),
              ],
            ),
          ),
        ),
        
        ResponsiveSystem.sizedBox(context, height: 16),
        
        // Add button
        Expanded(
          child: AnimatedBuilder(
            animation: _buttonScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _buttonScaleAnimation.value,
                child: GestureDetector(
                  onTapDown: (_) => _buttonAnimationController.forward(),
                  onTapUp: (_) => _buttonAnimationController.reverse(),
                  onTapCancel: () => _buttonAnimationController.reverse(),
                  onTap: _incrementCount,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: ResponsiveSystem.spacing(context, baseSpacing: 100),
                      maxHeight: ResponsiveSystem.spacing(context, baseSpacing: 200),
                    ),
                    decoration: BoxDecoration(
                      gradient: _isButtonDisabled
                          ? LinearGradient(
                              colors: [
                                ThemeProperties.getSecondaryTextColor(context).withValues(alpha: 0.3),
                                ThemeProperties.getSecondaryTextColor(context).withValues(alpha: 0.2),
                              ],
                            )
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                ThemeProperties.getPrimaryColor(context),
                                ThemeProperties.getPrimaryColor(context).withValues(alpha: 0.8),
                              ],
                            ),
                      borderRadius: ResponsiveSystem.circular(context, baseRadius: 16),
                      boxShadow: _isButtonDisabled
                          ? null
                          : [
                              BoxShadow(
                                color: ThemeProperties.getPrimaryColor(context).withValues(alpha: 0.4),
                                blurRadius: ResponsiveSystem.spacing(context, baseSpacing: 12),
                                spreadRadius: ResponsiveSystem.spacing(context, baseSpacing: 2),
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: ResponsiveSystem.iconSize(context, baseSize: 32),
                          color: _isButtonDisabled
                              ? ThemeProperties.getSecondaryTextColor(context)
                              : ThemeProperties.getTextColor(context),
                        ),
                        
                        ResponsiveSystem.sizedBox(context, height: 8),
                        
                        Text(
                          _isButtonDisabled ? 'Please Wait...' : 'Add Pradakshana',
                          style: TextStyle(
                            fontSize: ResponsiveSystem.fontSize(context, baseSize: 16),
                            fontWeight: FontWeight.w600,
                            color: _isButtonDisabled
                                ? ThemeProperties.getSecondaryTextColor(context)
                                : ThemeProperties.getTextColor(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        if (_isButtonDisabled) ...[
                          ResponsiveSystem.sizedBox(context, height: 4),
                          Text(
                            _formatRemainingCooldown(),
                            style: TextStyle(
                              fontSize: ResponsiveSystem.fontSize(context, baseSize: 12),
                              color: ThemeProperties.getSecondaryTextColor(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

}
