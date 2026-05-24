import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AppSettings {
  final bool onboardingComplete;
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool backgroundServiceEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String alarmSoundTheme;
  final int refreshIntervalMs;
  final String apiKey;
  final int priceDecimals;
  final bool batteryOptimizationIgnored;
  final bool exactAlarmGranted;

  const AppSettings({
    this.onboardingComplete = false,
    this.themeMode = ThemeMode.dark,
    this.notificationsEnabled = true,
    this.backgroundServiceEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.alarmSoundTheme = 'Default',
    this.refreshIntervalMs = 1000,
    this.apiKey = '',
    this.priceDecimals = 2,
    this.batteryOptimizationIgnored = false,
    this.exactAlarmGranted = false,
  });

  AppSettings copyWith({
    bool? onboardingComplete,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? backgroundServiceEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? alarmSoundTheme,
    int? refreshIntervalMs,
    String? apiKey,
    int? priceDecimals,
    bool? batteryOptimizationIgnored,
    bool? exactAlarmGranted,
  }) {
    return AppSettings(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      backgroundServiceEnabled:
          backgroundServiceEnabled ?? this.backgroundServiceEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      alarmSoundTheme: alarmSoundTheme ?? this.alarmSoundTheme,
      refreshIntervalMs: refreshIntervalMs ?? this.refreshIntervalMs,
      apiKey: apiKey ?? this.apiKey,
      priceDecimals: priceDecimals ?? this.priceDecimals,
      batteryOptimizationIgnored:
          batteryOptimizationIgnored ?? this.batteryOptimizationIgnored,
      exactAlarmGranted: exactAlarmGranted ?? this.exactAlarmGranted,
    );
  }

  Map<String, dynamic> toMap() => {
        AppConstants.keyOnboardingComplete: onboardingComplete,
        AppConstants.keyThemeMode: themeMode.index,
        AppConstants.keyNotificationsEnabled: notificationsEnabled,
        AppConstants.keyBackgroundService: backgroundServiceEnabled,
        AppConstants.keySoundEnabled: soundEnabled,
        AppConstants.keyVibrationEnabled: vibrationEnabled,
        AppConstants.keyAlarmSoundTheme: alarmSoundTheme,
        AppConstants.keyRefreshInterval: refreshIntervalMs,
        AppConstants.keyApiKey: apiKey,
        AppConstants.keyPriceDecimals: priceDecimals,
        'battery_optimization_ignored': batteryOptimizationIgnored,
        'exact_alarm_granted': exactAlarmGranted,
      };

  static AppSettings fromMap(Map<String, dynamic> map) {
    return AppSettings(
      onboardingComplete:
          map[AppConstants.keyOnboardingComplete] as bool? ?? false,
      themeMode:
          ThemeMode.values[map[AppConstants.keyThemeMode] as int? ?? 2],
      notificationsEnabled:
          map[AppConstants.keyNotificationsEnabled] as bool? ?? true,
      backgroundServiceEnabled:
          map[AppConstants.keyBackgroundService] as bool? ?? true,
      soundEnabled: map[AppConstants.keySoundEnabled] as bool? ?? true,
      vibrationEnabled:
          map[AppConstants.keyVibrationEnabled] as bool? ?? true,
      alarmSoundTheme:
          map[AppConstants.keyAlarmSoundTheme] as String? ?? 'Default',
      refreshIntervalMs:
          map[AppConstants.keyRefreshInterval] as int? ?? 1000,
      apiKey: map[AppConstants.keyApiKey] as String? ?? '',
      priceDecimals: map[AppConstants.keyPriceDecimals] as int? ?? 2,
      batteryOptimizationIgnored:
          map['battery_optimization_ignored'] as bool? ?? false,
      exactAlarmGranted: map['exact_alarm_granted'] as bool? ?? false,
    );
  }
}
