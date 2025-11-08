import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../core/design_system/design_system.dart';

/// About Screen - 100% Centralized Libraries
class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<Animation<double>> _staggerAnimations;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Initialize stagger animation controller
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Create stagger animations for cards
    _staggerAnimations = List.generate(4, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _staggerController,
        curve: Interval(
          index * 0.2,
          (index * 0.2) + 0.6,
          curve: Curves.easeOutCubic,
        ),
      ));
    });

    // Start animations
    _animationController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedCard(BuildContext context, int index,
      {required Widget child}) {
    return AnimatedBuilder(
      animation: _staggerAnimations[index],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _staggerAnimations[index].value)),
          child: Opacity(
            opacity: _staggerAnimations[index].value,
            child: Card(
              elevation: ResponsiveSystem.elevation(
                context,
                baseElevation: 4,
              ),
              child: Padding(
                padding: ResponsiveSystem.padding(context),
                child: child!,
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight:
                    ResponsiveSystem.spacing(context, baseSpacing: 120),
                floating: false,
                pinned: true,
                backgroundColor: ThemeProperties.getTransparentColor(context),
                elevation:
                    ResponsiveSystem.elevation(context, baseElevation: 0),
                toolbarHeight:
                    ResponsiveSystem.spacing(context, baseSpacing: 60),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'About Vedic Astrology Pro',
                    style: ResponsiveSystem.responsive(
                      context,
                      mobile: Theme.of(context).textTheme.titleLarge,
                      tablet: Theme.of(context).textTheme.headlineSmall,
                      desktop: Theme.of(context).textTheme.headlineMedium,
                      largeDesktop: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: ThemeProperties.getPrimaryGradient(context),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: ResponsiveSystem.only(context, top: 20),
                  child: Column(
                    children: [
                      _buildAnimatedCard(context, 0, child: _buildAppInfo()),
                      ResponsiveSystem.sizedBox(context, height: 16),
                      _buildAnimatedCard(context, 1, child: _buildFeatures()),
                      ResponsiveSystem.sizedBox(context, height: 16),
                      _buildAnimatedCard(context, 2,
                          child: _buildTechnicalInfo()),
                      ResponsiveSystem.sizedBox(context, height: 16),
                      _buildAnimatedCard(context, 3,
                          child: _buildAttribution()),
                      ResponsiveSystem.sizedBox(context, height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.star,
              color: ThemeProperties.getPrimaryColor(context),
              size: ResponsiveSystem.iconSize(context, baseSize: 24),
            ),
            ResponsiveSystem.sizedBox(context, width: 8),
            Text(
              'Vedic Astrology Pro',
              style: ResponsiveSystem.responsive(
                context,
                mobile: Theme.of(context).textTheme.titleLarge,
                tablet: Theme.of(context).textTheme.headlineSmall,
                desktop: Theme.of(context).textTheme.headlineMedium,
                largeDesktop: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ],
        ),
        ResponsiveSystem.sizedBox(context, height: 12),
        Text(
          'A comprehensive Vedic astrology application built with Flutter, featuring advanced calculations, personalized insights, and traditional astrological wisdom.',
          style: ResponsiveSystem.responsive(
            context,
            mobile: Theme.of(context).textTheme.bodyMedium,
            tablet: Theme.of(context).textTheme.bodyLarge,
            desktop: Theme.of(context).textTheme.bodyLarge,
            largeDesktop: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    final features = [
      {
        'icon': LucideIcons.calendar,
        'title': 'Hindu Calendar',
        'desc': 'Traditional Panchang with festivals'
      },
      {
        'icon': LucideIcons.heart,
        'title': 'Kundali Matching',
        'desc': 'Compatibility analysis for marriages'
      },
      {
        'icon': LucideIcons.zap,
        'title': 'Daily Predictions',
        'desc': 'Personalized daily insights'
      },
      {
        'icon': LucideIcons.chartBar,
        'title': 'Birth Charts',
        'desc': 'Detailed astrological charts'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: ResponsiveSystem.responsive(
            context,
            mobile: Theme.of(context).textTheme.titleLarge,
            tablet: Theme.of(context).textTheme.headlineSmall,
            desktop: Theme.of(context).textTheme.headlineMedium,
            largeDesktop: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        ResponsiveSystem.sizedBox(context, height: 16),
        ...features.map((feature) => Padding(
              padding: ResponsiveSystem.only(context, bottom: 12),
              child: Row(
                children: [
                  Icon(
                    feature['icon'] as IconData,
                    color: ThemeProperties.getPrimaryColor(context),
                    size: ResponsiveSystem.iconSize(context, baseSize: 20),
                  ),
                  ResponsiveSystem.sizedBox(context, width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'] as String,
                          style: ResponsiveSystem.responsive(
                            context,
                            mobile: Theme.of(context).textTheme.titleMedium,
                            tablet: Theme.of(context).textTheme.titleLarge,
                            desktop: Theme.of(context).textTheme.titleLarge,
                            largeDesktop:
                                Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          feature['desc'] as String,
                          style: ResponsiveSystem.responsive(
                            context,
                            mobile: Theme.of(context).textTheme.bodySmall,
                            tablet: Theme.of(context).textTheme.bodyMedium,
                            desktop: Theme.of(context).textTheme.bodyMedium,
                            largeDesktop:
                                Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildTechnicalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Technical Information',
          style: ResponsiveSystem.responsive(
            context,
            mobile: Theme.of(context).textTheme.titleLarge,
            tablet: Theme.of(context).textTheme.headlineSmall,
            desktop: Theme.of(context).textTheme.headlineMedium,
            largeDesktop: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        ResponsiveSystem.sizedBox(context, height: 12),
        _buildInfoRow('Framework', 'Flutter 3.x'),
        _buildInfoRow('Language', 'Dart'),
        _buildInfoRow('Architecture', 'Clean Architecture + Riverpod'),
        _buildInfoRow('Database', 'Local SQLite'),
        _buildInfoRow('Version', '1.0.0'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: ResponsiveSystem.only(context, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: ResponsiveSystem.responsive(
              context,
              mobile: Theme.of(context).textTheme.bodyMedium,
              tablet: Theme.of(context).textTheme.bodyLarge,
              desktop: Theme.of(context).textTheme.bodyLarge,
              largeDesktop: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: ResponsiveSystem.responsive(
              context,
              mobile: Theme.of(context).textTheme.bodyMedium,
              tablet: Theme.of(context).textTheme.bodyLarge,
              desktop: Theme.of(context).textTheme.bodyLarge,
              largeDesktop: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttribution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attribution',
          style: ResponsiveSystem.responsive(
            context,
            mobile: Theme.of(context).textTheme.titleLarge,
            tablet: Theme.of(context).textTheme.headlineSmall,
            desktop: Theme.of(context).textTheme.headlineMedium,
            largeDesktop: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        ResponsiveSystem.sizedBox(context, height: 12),
        _buildAttributionItem(
          'Flutter',
          'UI framework',
          'https://flutter.dev',
        ),
        _buildAttributionItem(
          'Lucide Icons',
          'Icon library',
          'https://lucide.dev',
        ),
      ],
    );
  }

  Widget _buildAttributionItem(String title, String description, String url) {
    return Padding(
      padding: ResponsiveSystem.only(context, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ResponsiveSystem.responsive(
              context,
              mobile: Theme.of(context).textTheme.titleMedium,
              tablet: Theme.of(context).textTheme.titleLarge,
              desktop: Theme.of(context).textTheme.titleLarge,
              largeDesktop: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Text(
            description,
            style: ResponsiveSystem.responsive(
              context,
              mobile: Theme.of(context).textTheme.bodySmall,
              tablet: Theme.of(context).textTheme.bodyMedium,
              desktop: Theme.of(context).textTheme.bodyMedium,
              largeDesktop: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
