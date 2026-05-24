import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/app_constants.dart';
import '../models/alert_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final Logger _log = Logger();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onBgNotificationResponse,
    );
    _initialized = true;
    _log.i('NotificationService initialized');
  }

  void _onNotificationResponse(NotificationResponse response) {
    _log.d('Notification tapped: ${response.id}');
  }

  @pragma('vm:entry-point')
  static void _onBgNotificationResponse(NotificationResponse response) {}

  Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> hasNotificationPermission() async =>
      Permission.notification.isGranted;

  Future<void> showPriceAlert({
    required AlertModel alert,
    required double triggerPrice,
  }) async {
    await initialize();

    final label = alert.label.isNotEmpty ? alert.label : 'Price Alert';
    final dirText = alert.direction == TriggerDirection.crossAbove
        ? 'crossed above'
        : 'crossed below';
    final body =
        'XAU/USD $dirText \$${triggerPrice.toStringAsFixed(2)}'
        ' (target: \$${alert.targetPrice.toStringAsFixed(2)})';

    switch (alert.alertType) {
      case AlertType.standard:
        await _showStandard(alert, label, body);
      case AlertType.highPriority:
        await _showHighPriority(alert, label, body);
      case AlertType.fullScreenAlarm:
        await _showFullScreen(alert, label, body);
    }

    if (alert.vibrationEnabled &&
        (alert.notificationType == NotificationType.vibration ||
            alert.notificationType == NotificationType.soundAndVibration)) {
      _vibrate(alert.alertType);
    }
  }

  Future<void> _showStandard(
    AlertModel alert,
    String title,
    String body,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      AppConstants.channelAlerts,
      'Price Alerts',
      channelDescription: 'XAUUSD price alert notifications',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: alert.vibrationEnabled,
      color: const Color(0xFFFFD700),
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction('dismiss', 'Dismiss'),
        AndroidNotificationAction('view', 'View'),
      ],
    );
    await _plugin.show(
      AppConstants.notifIdAlertBase + alert.id.hashCode.abs() % 1000,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }

  Future<void> _showHighPriority(
    AlertModel alert,
    String title,
    String body,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      AppConstants.channelHighPriority,
      'High Priority Alerts',
      importance: Importance.max,
      priority: Priority.max,
      vibrationPattern:
          Int64List.fromList(<int>[0, 500, 250, 500, 250, 500]),
      color: const Color(0xFFFF5252),
      visibility: NotificationVisibility.public,
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction('dismiss', 'Dismiss'),
        AndroidNotificationAction('view', 'View Alert'),
      ],
    );
    await _plugin.show(
      AppConstants.notifIdAlertBase + alert.id.hashCode.abs() % 1000,
      '⚠️ $title',
      body,
      NotificationDetails(android: androidDetails),
    );
  }

  Future<void> _showFullScreen(
    AlertModel alert,
    String title,
    String body,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      AppConstants.channelAlarm,
      'Gold Price Alarms',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      vibrationPattern: Int64List.fromList(<int>[0, 1000, 500, 1000]),
      visibility: NotificationVisibility.public,
      color: const Color(0xFFFFD700),
    );
    await _plugin.show(
      AppConstants.notifIdAlarmBase + alert.id.hashCode.abs() % 1000,
      '🔔 $title',
      body,
      NotificationDetails(android: androidDetails),
    );
  }

  void _vibrate(AlertType type) {
    switch (type) {
      case AlertType.standard:
        HapticFeedback.mediumImpact();
      case AlertType.highPriority:
        HapticFeedback.heavyImpact();
      case AlertType.fullScreenAlarm:
        HapticFeedback.heavyImpact();
    }
  }

  Future<void> showForegroundService(String title, String message) async {
    await initialize();
    const androidDetails = AndroidNotificationDetails(
      AppConstants.channelPriceService,
      'Live Gold Price Service',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      showWhen: false,
      enableVibration: false,
      playSound: false,
    );
    await _plugin.show(
      AppConstants.notifIdPriceService,
      title,
      message,
      const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
  Future<void> cancel(int id) => _plugin.cancel(id);
}
