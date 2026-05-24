import 'package:hive/hive.dart';
import '../models/alert_model.dart';

class AlertRepository {
  Box<AlertModel> get _box => Hive.box<AlertModel>('alerts');

  List<AlertModel> getAllAlerts() => _box.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<AlertModel> getActiveAlerts() =>
      _box.values.where((a) => a.status == AlertStatus.active).toList();

  List<AlertModel> getInactiveAlerts() =>
      _box.values.where((a) => a.status == AlertStatus.inactive).toList();

  List<AlertModel> getTriggeredAlerts() =>
      _box.values.where((a) => a.status == AlertStatus.triggered).toList();

  AlertModel? getAlert(String id) {
    try {
      return _box.values.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveAlert(AlertModel alert) async {
    await _box.put(alert.id, alert);
  }

  Future<void> updateAlert(AlertModel alert) async {
    await _box.put(alert.id, alert);
  }

  Future<void> deleteAlert(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAllAlerts() async {
    await _box.clear();
  }

  Future<void> activateAll() async {
    for (final alert in _box.values) {
      if (alert.status == AlertStatus.inactive) {
        final updated = alert.copyWith(status: AlertStatus.active);
        await _box.put(alert.id, updated);
      }
    }
  }

  Future<void> deactivateAll() async {
    for (final alert in _box.values) {
      if (alert.status == AlertStatus.active) {
        final updated = alert.copyWith(status: AlertStatus.inactive);
        await _box.put(alert.id, updated);
      }
    }
  }

  Future<void> toggleAlert(String id) async {
    final alert = getAlert(id);
    if (alert == null) return;
    final newStatus = alert.status == AlertStatus.active
        ? AlertStatus.inactive
        : AlertStatus.active;
    await updateAlert(alert.copyWith(status: newStatus));
  }

  Future<void> deleteTriggered() async {
    final triggered = getTriggeredAlerts();
    for (final a in triggered) {
      await _box.delete(a.id);
    }
  }

  List<AlertModel> search(String query) {
    final q = query.toLowerCase();
    return _box.values
        .where((a) =>
            a.label.toLowerCase().contains(q) ||
            a.notes.toLowerCase().contains(q) ||
            a.targetPrice.toString().contains(q))
        .toList();
  }

  int get totalCount => _box.length;
  int get activeCount => getActiveAlerts().length;
  int get triggeredCount => getTriggeredAlerts().length;
}
