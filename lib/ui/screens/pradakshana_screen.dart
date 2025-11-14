/// Pradakshana Counter Screen
///
/// A minimalist counter for pradakshana practice with modern design
/// Features:
/// - Large central count display
/// - Green plus button at bottom
/// - Time reset selector
/// - App bar with title, theme, language, and profile
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skvk_application/core/logging/logging_helper.dart';
import 'package:skvk_application/core/services/language/translation_service.dart';
import 'package:skvk_application/ui/components/app_bar/standard_app_bar.dart';
import 'package:skvk_application/ui/components/counter/index.dart';
import 'package:skvk_application/ui/components/dialogs/index.dart';
import 'package:skvk_application/ui/utils/responsive_system.dart';
import 'package:skvk_application/ui/utils/screen_handlers.dart';
import 'package:skvk_application/ui/utils/theme_helpers.dart';

/// Pradakshana Counter Screen
class PradakshanaScreen extends ConsumerStatefulWidget {
  const PradakshanaScreen({super.key});

  @override
  ConsumerState<PradakshanaScreen> createState() => _PradakshanaScreenState();
}

class _PradakshanaScreenState extends ConsumerState<PradakshanaScreen>
    with TickerProviderStateMixin {
  // State variables
  int _count = 0;
  bool _isButtonDisabled = false;
  Duration _cooldownDuration = Duration.zero;
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

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPersistedData();
  }

  void _initializeAnimations() {
    _countAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _countScaleAnimation = Tween<double>(
      begin: 1,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _countAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _buttonScaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _countAnimationController.dispose();
    _buttonAnimationController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCount = prefs.getInt(_countKey) ?? 0;
      final savedCooldownSeconds = prefs.getInt(_cooldownKey) ?? 0;
      final savedLastTriggerTime = prefs.getString(_lastTriggerKey);

      DateTime? lastTriggerTime;
      if (savedLastTriggerTime != null) {
        lastTriggerTime = DateTime.parse(savedLastTriggerTime);
      }

      setState(() {
        _count = savedCount;
        _cooldownDuration = Duration(seconds: savedCooldownSeconds);
        _lastTriggerTime = lastTriggerTime;
      });

      _calculateAndApplyDynamicCooldown();
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError(
        'Failed to load persisted data: $e',
        error: e,
        stackTrace: stackTrace,
        source: 'PradakshanaScreen',
      );
    }
  }

  Future<void> _saveCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_countKey, _count);
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError(
        'Failed to save count: $e',
        error: e,
        stackTrace: stackTrace,
        source: 'PradakshanaScreen',
      );
    }
  }

  Future<void> _saveCooldownDuration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_cooldownKey, _cooldownDuration.inSeconds);
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError(
        'Failed to save cooldown duration: $e',
        error: e,
        stackTrace: stackTrace,
        source: 'PradakshanaScreen',
      );
    }
  }

  Future<void> _saveLastTriggerTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_lastTriggerTime != null) {
        await prefs.setString(
            _lastTriggerKey, _lastTriggerTime!.toIso8601String(),);
      }
    } on Exception catch (e, stackTrace) {
      await LoggingHelper.logError(
        'Failed to save last trigger time: $e',
        error: e,
        stackTrace: stackTrace,
        source: 'PradakshanaScreen',
      );
    }
  }

  void _calculateAndApplyDynamicCooldown() {
    if (_cooldownDuration.inSeconds == 0) {
      setState(() {
        _isButtonDisabled = false;
        _remainingCooldown = Duration.zero;
      });
      return;
    }

    if (_lastTriggerTime == null) {
      setState(() {
        _isButtonDisabled = false;
        _remainingCooldown = Duration.zero;
      });
      return;
    }

    final now = DateTime.now();
    final timeSinceLastTrigger = now.difference(_lastTriggerTime!);

    if (timeSinceLastTrigger >= _cooldownDuration) {
      setState(() {
        _isButtonDisabled = false;
        _remainingCooldown = Duration.zero;
      });
    } else {
      setState(() {
        _isButtonDisabled = true;
        _remainingCooldown = _cooldownDuration - timeSinceLastTrigger;
      });
      _startDynamicCooldownTimer();
    }
  }

  // Start dynamic cooldown timer
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

  // Increment count
  void _incrementCount() {
    if (_isButtonDisabled) return;

    setState(() {
      _count++;
      _lastTriggerTime = DateTime.now();
      _isButtonDisabled = _cooldownDuration.inSeconds > 0;
    });

    _saveCount();
    _saveLastTriggerTime();

    _countAnimationController.forward().then((_) {
      _countAnimationController.reverse();
    });

    _calculateAndApplyDynamicCooldown();
  }

  // Reset count
  Future<void> _resetCount() async {
    final translationService = ref.watch(translationServiceProvider);
    await ResetConfirmationDialog.show(
      context,
      translationService: translationService,
      title: translationService.translateContent(
        'reset_count',
        fallback: 'Reset Count?',
      ),
      message: translationService.translateContent(
        'reset_count_message',
        fallback: 'Are you sure you want to reset your count?',
      ),
      onConfirm: () {
        setState(() {
          _count = 0;
          _lastTriggerTime = null;
          _isButtonDisabled = false;
          _remainingCooldown = Duration.zero;
        });
        _saveCount();
        _saveLastTriggerTime();
        _cooldownTimer?.cancel();
      },
    );
  }

  void _showTimeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeHelpers.getTransparentColor(context),
      isScrollControlled: true,
      builder: (context) => TimeSelectorSheet(
        initialDuration: _cooldownDuration,
        onDurationSelected: (duration) {
          setState(() {
            _cooldownDuration = duration;
          });
          _saveCooldownDuration();
          _calculateAndApplyDynamicCooldown();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final translationService = ref.watch(translationServiceProvider);

    return Scaffold(
      backgroundColor: ThemeHelpers.getBackgroundColor(context),
      appBar: StandardAppBar(
        title: translationService.translateHeader(
          'pradakshana_counter',
          fallback: 'Pradakshana Counter',
        ),
        onProfileTap: () =>
            ScreenHandlers.handleProfileTap(context, ref, translationService),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Reset button section
            Padding(
              padding: ResponsiveSystem.symmetric(
                context,
                horizontal: ResponsiveSystem.spacing(context, baseSpacing: 20),
                vertical: ResponsiveSystem.spacing(context, baseSpacing: 16),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ResetButton(
                  translationService: translationService,
                  onTap: _resetCount,
                ),
              ),
            ),

            // Central count display
            Expanded(
              child: Center(
                child: CounterDisplay(
                  count: _count,
                  scaleAnimation: _countScaleAnimation,
                ),
              ),
            ),

            // Bottom section with time selector and plus button
            Padding(
              padding: ResponsiveSystem.all(context, baseSpacing: 20),
              child: Column(
                children: [
                  // Time selector button
                  TimeSelectorButton(
                    translationService: translationService,
                    duration: _cooldownDuration,
                    onTap: _showTimeSelector,
                  ),

                  ResponsiveSystem.sizedBox(
                    context,
                    height: ResponsiveSystem.spacing(context, baseSpacing: 16),
                  ),

                  // Plus button
                  CounterButtons(
                    onIncrement: _incrementCount,
                    onDecrement:
                        () {}, // No longer used, but kept for component compatibility
                    isDisabled: _isButtonDisabled,
                    remainingCooldown: _remainingCooldown,
                    scaleAnimation: _buttonScaleAnimation,
                    buttonAnimationController: _buttonAnimationController,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
