import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/settings/settings_bloc.dart';
import '../main_navigation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/notification_service.dart';
import 'package:get_it/get_it.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _requesting = false;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.currency_exchange_rounded,
      color: AppTheme.goldPrimary,
      title: 'Welcome to XAUT',
      subtitle: 'Ultra-reliable live XAUUSD gold price tracking with second-by-second updates.',
      features: [
        'Live bid/ask price with spread',
        'Real-time mini price chart',
        'Market direction indicators',
      ],
    ),
    _OnboardingData(
      icon: Icons.add_alert_rounded,
      color: AppTheme.priceUp,
      title: 'Smart Price Alerts',
      subtitle: 'Set custom price levels and receive instant notifications the moment market crosses them.',
      features: [
        'Cross above / below detection',
        'Full-screen alarm support',
        'Multiple repeat modes',
      ],
    ),
    _OnboardingData(
      icon: Icons.shield_rounded,
      color: const Color(0xFF7B61FF),
      title: 'Permissions Required',
      subtitle: 'To ensure you never miss a critical price alert, we need a few permissions.',
      features: [
        'Notifications — for price alerts',
        'Battery optimization — for 24/7 monitoring',
        'Exact alarms — for precise trigger timing',
      ],
      isPermissionPage: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _buildPage(_pages[i]),
              ),
            ),
            _buildBottom(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: data.color.withOpacity(0.3), width: 2),
            ),
            child: Icon(data.icon, color: data.color, size: 44),
          )
              .animate()
              .scale(begin: const Offset(0.6, 0.6), duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 32),
          Text(
            data.title,
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          Text(
            data.subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: const Color(0xFF9898B8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 32),
          ...data.features.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: data.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded, color: data.color, size: 14),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.value,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ).animate(delay: (400 + e.key * 80).ms).fadeIn().slideX(begin: -0.2),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottom(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: i == _currentPage ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: i == _currentPage
                      ? AppTheme.goldPrimary
                      : const Color(0xFF3A3A5A),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _requesting ? null : () => _handleNext(context),
              child: _requesting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF1A1000),
                      ),
                    )
                  : Text(
                      isLast ? 'Grant Permissions & Start' : 'Continue',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          if (!isLast) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _complete(context),
              child: Text(
                'Skip',
                style: GoogleFonts.dmSans(
                  color: const Color(0xFF5A5A7A),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleNext(BuildContext context) async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      await _requestPermissions(context);
    }
  }

  Future<void> _requestPermissions(BuildContext context) async {
    setState(() => _requesting = true);
    try {
      await GetIt.I<NotificationService>().requestPermissions();
      await Permission.notification.request();
      await Permission.ignoreBatteryOptimizations.request();
      // Exact alarm requires settings navigation on Android 12+
    } catch (_) {}
    setState(() => _requesting = false);
    if (mounted) _complete(context);
  }

  void _complete(BuildContext context) {
    context.read<SettingsBloc>().add(CompleteOnboarding());
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final List<String> features;
  final bool isPermissionPage;

  const _OnboardingData({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.features,
    this.isPermissionPage = false,
  });
}
