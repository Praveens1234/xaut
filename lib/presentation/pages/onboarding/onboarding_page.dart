import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/services/notification_service.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../main_navigation.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _requesting = false;

  static const List<_OnboardingData> _pages = <_OnboardingData>[
    _OnboardingData(
      icon: Icons.currency_exchange_rounded,
      color: AppTheme.goldPrimary,
      title: 'Welcome to XAUT',
      subtitle:
          'Ultra-reliable live XAUUSD gold price tracking with '
          'second-by-second updates from real market data sources.',
      features: <String>[
        'Live bid/ask price with spread',
        'Real-time mini price chart',
        'Market direction indicators',
      ],
    ),
    _OnboardingData(
      icon: Icons.add_alert_rounded,
      color: AppTheme.priceUp,
      title: 'Smart Price Alerts',
      subtitle:
          'Set custom price levels and receive instant notifications '
          'the moment the market crosses them.',
      features: <String>[
        'Cross above / below detection',
        'Full-screen alarm support',
        'Multiple repeat modes',
      ],
    ),
    _OnboardingData(
      icon: Icons.shield_rounded,
      color: Color(0xFF7B61FF),
      title: 'Permissions Required',
      subtitle:
          'To ensure you never miss a critical price alert, we need '
          'a few permissions.',
      features: <String>[
        'Notifications — for price alerts',
        'Battery optimization — for 24/7 monitoring',
        'Exact alarms — for precise trigger timing',
      ],
      isPermissionPage: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int i) =>
                    setState(() => _currentPage = i),
                itemBuilder: (_, int i) => _buildPage(_pages[i]),
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
        children: <Widget>[
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: data.color.withAlpha(26),
              shape: BoxShape.circle,
              border: Border.all(
                color: data.color.withAlpha(77),
                width: 2,
              ),
            ),
            child: Icon(data.icon, color: data.color, size: 44),
          )
              .animate()
              .scale(
                begin: const Offset(0.6, 0.6),
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),
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
          ...data.features.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: data.color.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: data.color,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              )
                  .animate(delay: (400 + entry.key * 80).ms)
                  .fadeIn()
                  .slideX(begin: -0.2),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottom(BuildContext context) {
    final bool isLast = _currentPage == _pages.length - 1;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(_pages.length, (int i) {
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
              onPressed: _requesting
                  ? null
                  : () => _handleNext(context),
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
          if (!isLast) ...<Widget>[
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
      await _pageController.nextPage(
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
    } catch (_) {}

    if (!mounted) return;
    setState(() => _requesting = false);
    _complete(context);
  }

  void _complete(BuildContext context) {
    context.read<SettingsBloc>().add(CompleteOnboarding());
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const MainNavigation(),
      ),
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
