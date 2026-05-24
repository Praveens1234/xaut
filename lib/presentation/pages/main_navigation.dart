import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/price/price_bloc.dart';
import '../bloc/alert/alert_bloc.dart';
import 'home/home_page.dart';
import 'alerts/alerts_page.dart';
import 'settings/settings_page.dart';
import '../../core/theme/app_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    AlertsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return BlocBuilder<PriceBloc, PriceState>(
      buildWhen: (prev, curr) =>
          (prev is PriceLoaded) != (curr is PriceLoaded),
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppTheme.darkBorder,
                width: 1,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.show_chart_rounded,
                  color: _currentIndex == 0
                      ? AppTheme.goldPrimary
                      : const Color(0xFF9898B8),
                ),
                label: 'Live',
                selectedIcon: const Icon(
                  Icons.show_chart_rounded,
                  color: AppTheme.goldPrimary,
                ),
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: _getActiveAlertCount(context) > 0,
                  label: Text(_getActiveAlertCount(context).toString()),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: _currentIndex == 1
                        ? AppTheme.goldPrimary
                        : const Color(0xFF9898B8),
                  ),
                ),
                label: 'Alerts',
                selectedIcon: const Icon(
                  Icons.notifications_rounded,
                  color: AppTheme.goldPrimary,
                ),
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.tune_rounded,
                  color: _currentIndex == 2
                      ? AppTheme.goldPrimary
                      : const Color(0xFF9898B8),
                ),
                label: 'Settings',
                selectedIcon: const Icon(
                  Icons.tune_rounded,
                  color: AppTheme.goldPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _getActiveAlertCount(BuildContext context) {
    final state = context.read<AlertBloc>().state;
    if (state is AlertLoaded) return state.activeCount;
    return 0;
  }
}
