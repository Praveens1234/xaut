class AppConstants {
  // API Keys (set via --dart-define=GOLD_API_KEY=yourkey)
  static const String goldApiKey =
      String.fromEnvironment('GOLD_API_KEY');

  // REST endpoints
  static const String goldApiUrl = 'https://www.goldapi.io/api/XAU/USD';
  static const String yahooFinanceUrl =
      'https://query1.finance.yahoo.com/v8/finance/chart/GC=F'
      '?interval=1m&range=1d';
  static const String goldPriceOrgUrl =
      'https://data-asg.goldprice.org/dbXRates/USD';

  // App
  static const String appName = 'XAUT';
  static const String appVersion = '1.0.0';
  static const String appSymbol = 'XAU/USD';

  // Hive Boxes
  static const String alertsBox = 'alerts';
  static const String settingsBox = 'settings';
  static const String priceCacheBox = 'price_cache';

  // Settings Keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyBackgroundService = 'background_service';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyVibrationEnabled = 'vibration_enabled';
  static const String keyAlarmSoundTheme = 'alarm_sound_theme';
  static const String keyRefreshInterval = 'refresh_interval';
  static const String keyApiKey = 'api_key';
  static const String keyPriceDecimals = 'price_decimals';

  // Notification Channels
  static const String channelPriceService = 'xaut_price_service';
  static const String channelAlerts = 'xaut_alerts';
  static const String channelHighPriority = 'xaut_alerts_high';
  static const String channelAlarm = 'xaut_alarm';

  // Timing
  static const int priceUpdateIntervalMs = 3000; // 3s — respects free API rate limits
  static const int widgetUpdateIntervalMs = 5000;
  static const int connectionTimeoutMs = 10000;

  // Notification IDs
  static const int notifIdPriceService = 1001;
  static const int notifIdAlertBase = 2000;
  static const int notifIdAlarmBase = 3000;

  // Sound themes
  static const List<String> soundThemes = <String>[
    'Default',
    'Chime',
    'Bell',
    'Alert',
    'Alarm',
    'Digital',
  ];
}
