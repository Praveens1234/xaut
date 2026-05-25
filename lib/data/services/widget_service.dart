
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/price_model.dart';

/// Updates the Android home screen widget by writing data to SharedPreferences
/// then sending a broadcast intent to trigger [GoldPriceWidgetReceiver].
class WidgetService {
  final Logger _log = Logger();

  static const MethodChannel _channel =
      MethodChannel('com.xaut.app/widget');

  Future<void> updateWidget(PriceModel price) async {
    try {
      final String timeStr =
          DateFormat('HH:mm:ss').format(price.timestamp);
      final String sign = price.change >= 0 ? '+' : '';
      final String changeStr =
          '$sign${price.change.toStringAsFixed(2)}'
          ' ($sign${price.changePercent.toStringAsFixed(2)}%)';

      // Persist data for the native widget to read
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('xaut_price', price.mid.toStringAsFixed(2));
      await prefs.setString('xaut_change', changeStr);
      await prefs.setBool('xaut_is_positive', price.isUp);
      await prefs.setString('xaut_time', timeStr);
      await prefs.setBool('xaut_is_live', price.isLive);

      // Notify native side to push update to AppWidget
      await _channel.invokeMethod<void>('updateWidget');
    } catch (e) {
      _log.w('Widget update failed: $e');
    }
  }

  Future<void> clearWidget() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('xaut_price', '---.--');
      await prefs.setString('xaut_change', '+0.00 (0.00%)');
      await prefs.setBool('xaut_is_positive', true);
      await prefs.setString('xaut_time', '--:--:--');
      await prefs.setBool('xaut_is_live', false);
      await _channel.invokeMethod<void>('updateWidget');
    } catch (_) {}
  }
}
