import 'dart:async';
import 'package:logger/logger.dart';

import '../models/alert_model.dart';
import '../models/price_model.dart';
import '../repositories/alert_repository.dart';
import '../repositories/price_repository.dart';
import 'notification_service.dart';

class AlertEngine {
  final AlertRepository alertRepository;
  final NotificationService notificationService;
  final PriceRepository priceRepository;
  final Logger _log = Logger();

  StreamSubscription? _priceSub;
  double? _lastPrice;
  bool _isRunning = false;

  // Track last trigger time per alert to enforce repeat mode
  final Map<String, DateTime> _lastTriggerTime = {};

  AlertEngine({
    required this.alertRepository,
    required this.notificationService,
    required this.priceRepository,
  });

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _priceSub = priceRepository.priceStream.listen(_onPriceUpdate);
    _log.i('AlertEngine started');
  }

  void stop() {
    _isRunning = false;
    _priceSub?.cancel();
    _lastPrice = null;
    _log.i('AlertEngine stopped');
  }

  void _onPriceUpdate(PriceModel price) {
    final currentPrice = price.mid;
    if (_lastPrice == null) {
      _lastPrice = currentPrice;
      return;
    }

    final previousPrice = _lastPrice!;
    _lastPrice = currentPrice;

    final activeAlerts = alertRepository.getActiveAlerts();
    for (final alert in activeAlerts) {
      _checkAlert(alert, previousPrice, currentPrice);
    }
  }

  void _checkAlert(AlertModel alert, double prev, double current) {
    bool triggered = false;

    switch (alert.direction) {
      case TriggerDirection.crossAbove:
        // Triggers when price moves from below to above target
        triggered = prev < alert.targetPrice && current >= alert.targetPrice;
        break;
      case TriggerDirection.crossBelow:
        // Triggers when price moves from above to below target
        triggered = prev > alert.targetPrice && current <= alert.targetPrice;
        break;
    }

    if (!triggered) return;

    // Check repeat mode cooldown
    if (!_shouldTrigger(alert)) return;

    _log.i('Alert triggered: ${alert.id} at price $current');
    _triggerAlert(alert, current);
  }

  bool _shouldTrigger(AlertModel alert) {
    switch (alert.repeatMode) {
      case RepeatMode.once:
        return !alert.isTriggered;
      case RepeatMode.everyMinute:
        return _checkCooldown(alert.id, const Duration(minutes: 1));
      case RepeatMode.every5Minutes:
        return _checkCooldown(alert.id, const Duration(minutes: 5));
      case RepeatMode.every15Minutes:
        return _checkCooldown(alert.id, const Duration(minutes: 15));
      case RepeatMode.untilDismissed:
        return _checkCooldown(alert.id, const Duration(seconds: 30));
    }
  }

  bool _checkCooldown(String alertId, Duration cooldown) {
    final lastTime = _lastTriggerTime[alertId];
    if (lastTime == null) return true;
    return DateTime.now().difference(lastTime) >= cooldown;
  }

  Future<void> _triggerAlert(AlertModel alert, double triggerPrice) async {
    _lastTriggerTime[alert.id] = DateTime.now();

    // Update alert status
    final updatedAlert = alert.copyWith(
      status: alert.repeatMode == RepeatMode.once
          ? AlertStatus.triggered
          : alert.status,
      triggeredAt: DateTime.now(),
      triggerPrice: triggerPrice,
      triggerCount: alert.triggerCount + 1,
    );

    await alertRepository.updateAlert(updatedAlert);

    // Send notification
    await notificationService.showPriceAlert(
      alert: updatedAlert,
      triggerPrice: triggerPrice,
    );
  }

  void dispose() {
    stop();
  }
}
