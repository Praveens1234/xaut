class AppConstants {
  // API Keys (set via --dart-define=GOLD_API_KEY=yourkey or leave empty for demo)
  static const String goldApiKey =
      String.fromEnvironment('GOLD_API_KEY', defaultValue: '');

  // WebSocket endpoints for XAUUSD (free/public feeds)
  static const String wsGoldApiUrl = 'wss://marketdata.tradermade.com/feedadv';
  static const String wsBackupUrl = 'wss://streaming.forexapi.eu/stream';

  // REST fallback endpoints
  static const String goldPriceApiUrl =
      'https://query1.finance.yahoo.com/v8/finance/chart/XAUUSD=X';
  static const String metalPriceApiUrl =
      'https://api.metals.live/v1/spot/gold';

  // App
  static const String appName = 'XAUT';
  static const String appVersion = '1.0.0';
  static const String appSymbol = 'XAU/USD';
  static const String currency = 'USD';

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
  static const int wsReconnectDelayMs = 3000;
  static const int wsMaxReconnectDelay = 30000;
  static const int priceUpdateIntervalMs = 1000;
  static const int httpFallbackIntervalMs = 3000;
  static const int widgetUpdateIntervalMs = 5000;
  static const int alertCheckIntervalMs = 500;
  static const int connectionTimeoutMs = 10000;

  // Price
  static const int priceDecimals = 2;
  static const double spreadDefault = 0.30;

  // Notification IDs
  static const int notifIdPriceService = 1001;
  static const int notifIdAlertBase = 2000;
  static const int notifIdAlarmBase = 3000;

  // Widget
  static const String widgetDataKey = 'xaut_widget_data';

  // Sound themes
  static const List<String> soundThemes = [
    'Default',
    'Chime',
    'Bell',
    'Alert',
    'Alarm',
    'Digital',
  ];
}
