import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

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
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  Future<bool> hasNotificationPermission() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    }
    return true;
  }

  Future<void> showPriceAlert({
    required AlertModel alert,
    required double triggerPrice,
  }) async {
    await initialize();

    final label = alert.label.isNotEmpty ? alert.label : 'Price Alert';
    final directionText =
        alert.direction == TriggerDirection.crossAbove ? 'crossed above' : 'crossed below';
    final body =
        'XAU/USD $directionText \$${triggerPrice.toStringAsFixed(2)} (target: \$${alert.targetPrice.toStringAsFixed(2)})';

    switch (alert.alertType) {
      case AlertType.standard:
        await _showStandardNotification(alert, label, body);
        break;
      case AlertType.highPriority:
        await _showHighPriorityNotification(alert, label, body);
        break;
      case AlertType.fullScreenAlarm:
        await _showFullScreenAlarm(alert, label, body, triggerPrice);
        break;
    }

    if (alert.vibrationEnabled &&
        (alert.notificationType == NotificationType.vibration ||
            alert.notificationType == NotificationType.soundAndVibration)) {
      _vibrate(alert.alertType);
    }
  }

  Future<void> _showStandardNotification(
      AlertModel alert, String title, String body) async {
    final androidDetails = AndroidNotificationDetails(
      AppConstants.channelAlerts,
      'Price Alerts',
      channelDescription: 'XAUUSD price alert notifications',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: alert.vibrationEnabled,
      playSound: alert.notificationType != NotificationType.vibration,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFFFD700),
      actions: [
        const AndroidNotificationAction('dismiss', 'Dismiss'),
        const AndroidNotificationAction('view', 'View'),
      ],
    );

    await _plugin.show(
      AppConstants.notifIdAlertBase + alert.id.hashCode.abs() % 1000,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }

  Future<void> _showHighPriorityNotification(
      AlertModel alert, String title, String body) async {
    final androidDetails = AndroidNotificationDetails(
      AppConstants.channelHighPriority,
      'High Priority Alerts',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: false,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 250, 500, 250, 500]),
      playSound: true,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFFF5252),
      visibility: NotificationVisibility.public,
      actions: [
        const AndroidNotificationAction('dismiss', 'Dismiss'),
        const AndroidNotificationAction('view', 'View Alert'),
      ],
    );

    await _plugin.show(
      AppConstants.notifIdAlertBase + alert.id.hashCode.abs() % 1000,
      '⚠️ $title',
      body,
      NotificationDetails(android: androidDetails),
    );
  }

  Future<void> _showFullScreenAlarm(
      AlertModel alert, String title, String body, double triggerPrice) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.channelAlarm,
      'Gold Price Alarms',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      playSound: true,
      visibility: NotificationVisibility.public,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.show(
      AppConstants.notifIdAlarmBase + alert.id.hashCode.abs() % 1000,
      '🔔 $title',
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  void _vibrate(AlertType type) {
    switch (type) {
      case AlertType.standard:
        HapticFeedback.mediumImpact();
        break;
      case AlertType.highPriority:
        HapticFeedback.heavyImpact();
        break;
      case AlertType.fullScreenAlarm:
        HapticFeedback.heavyImpact();
        break;
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
      icon: '@mipmap/ic_launcher',
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
