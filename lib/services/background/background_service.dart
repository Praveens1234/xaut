import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

class BackgroundService {
  static Future<bool> handleTask(String task, Map<String, dynamic>? inputData) async {
    switch (task) {
      case 'priceSyncTask':
        return await _syncPrice();
      default:
        return false;
    }
  }

  static Future<bool> _syncPrice() async {
    try {
      await Hive.initFlutter();
      if (!Hive.isBoxOpen('price_cache')) {
        await Hive.openBox('price_cache');
      }

      final response = await http
          .get(Uri.parse('https://api.metals.live/v1/spot'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          for (final item in data) {
            if (item['metal'] == 'gold') {
              final price = item['price'];
              final box = Hive.box('price_cache');
              await box.put('bg_sync_price', price);
              await box.put('bg_sync_time', DateTime.now().toIso8601String());
              return true;
            }
          }
        }
      }
    } catch (e) {
      // Silent fail — background task
    }
    return false;
  }
}
