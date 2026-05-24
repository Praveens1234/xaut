import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../models/price_model.dart';

class WidgetService {
  final Logger _log = Logger();
  static const String _appGroupId = 'com.xaut.app';

  Future<void> updateWidget(PriceModel price) async {
    try {
      final timeStr = DateFormat('HH:mm:ss').format(price.timestamp);
      final changeStr = '${price.change >= 0 ? '+' : ''}${price.change.toStringAsFixed(2)} (${price.changePercent >= 0 ? '+' : ''}${price.changePercent.toStringAsFixed(2)}%)';

      await HomeWidget.saveWidgetData<String>('price', price.mid.toStringAsFixed(2));
      await HomeWidget.saveWidgetData<String>('change', changeStr);
      await HomeWidget.saveWidgetData<bool>('is_positive', price.isUp);
      await HomeWidget.saveWidgetData<String>('time', timeStr);
      await HomeWidget.saveWidgetData<bool>('is_live', price.isLive);
      await HomeWidget.updateWidget(
        androidName: 'GoldPriceWidgetReceiver',
      );
    } catch (e) {
      _log.w('Widget update failed: $e');
    }
  }

  Future<void> clearWidget() async {
    try {
      await HomeWidget.saveWidgetData<String>('price', '---.--');
      await HomeWidget.saveWidgetData<String>('change', '+0.00 (0.00%)');
      await HomeWidget.saveWidgetData<bool>('is_positive', true);
      await HomeWidget.saveWidgetData<String>('time', '--:--:--');
      await HomeWidget.saveWidgetData<bool>('is_live', false);
      await HomeWidget.updateWidget(androidName: 'GoldPriceWidgetReceiver');
    } catch (_) {}
  }
}
