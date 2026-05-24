import 'package:hive/hive.dart';
import '../models/settings_model.dart';

class SettingsRepository {
  Box get _box => Hive.box('settings');

  AppSettings getSettings() {
    final map = Map<String, dynamic>.from(_box.toMap().map(
          (k, v) => MapEntry(k.toString(), v),
        ));
    return AppSettings.fromMap(map);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final map = settings.toMap();
    for (final entry in map.entries) {
      await _box.put(entry.key, entry.value);
    }
  }

  Future<void> saveSetting(String key, dynamic value) async {
    await _box.put(key, value);
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    return _box.get(key, defaultValue: defaultValue);
  }

  Future<void> clear() async => await _box.clear();
}
