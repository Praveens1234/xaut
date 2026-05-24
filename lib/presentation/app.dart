import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../core/theme/app_theme.dart';
import '../presentation/bloc/price/price_bloc.dart';
import '../presentation/bloc/alert/alert_bloc.dart';
import '../presentation/bloc/settings/settings_bloc.dart';
import '../presentation/pages/onboarding/onboarding_page.dart';
import '../presentation/pages/main_navigation.dart';

class XautApp extends StatelessWidget {
  const XautApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.I<PriceBloc>()..add(StartPriceFeed())),
        BlocProvider(create: (_) => GetIt.I<AlertBloc>()..add(LoadAlerts())),
        BlocProvider(create: (_) => GetIt.I<SettingsBloc>()..add(LoadSettings())),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            title: 'XAUT',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsState is SettingsLoaded
                ? settingsState.settings.themeMode
                : ThemeMode.dark,
            home: _buildHome(settingsState),
          );
        },
      ),
    );
  }

  Widget _buildHome(SettingsState state) {
    if (state is SettingsLoaded && state.settings.onboardingComplete) {
      return const MainNavigation();
    }
    return const OnboardingPage();
  }
}
