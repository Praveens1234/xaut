import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'alert_model.g.dart';

@HiveType(typeId: 0)
enum AlertType {
  @HiveField(0)
  standard,
  @HiveField(1)
  highPriority,
  @HiveField(2)
  fullScreenAlarm,
}

@HiveType(typeId: 1)
enum TriggerDirection {
  @HiveField(0)
  crossAbove,
  @HiveField(1)
  crossBelow,
}

@HiveType(typeId: 2)
enum NotificationType {
  @HiveField(0)
  notification,
  @HiveField(1)
  sound,
  @HiveField(2)
  vibration,
  @HiveField(3)
  soundAndVibration,
}

@HiveType(typeId: 3)
enum RepeatMode {
  @HiveField(0)
  once,
  @HiveField(1)
  everyMinute,
  @HiveField(2)
  every5Minutes,
  @HiveField(3)
  every15Minutes,
  @HiveField(4)
  untilDismissed,
}

@HiveType(typeId: 4)
enum AlertStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  inactive,
  @HiveField(2)
  triggered,
  @HiveField(3)
  expired,
}

@HiveType(typeId: 5)
class AlertModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double targetPrice;

  @HiveField(2)
  final TriggerDirection direction;

  @HiveField(3)
  final AlertType alertType;

  @HiveField(4)
  final NotificationType notificationType;

  @HiveField(5)
  final String soundTheme;

  @HiveField(6)
  final bool vibrationEnabled;

  @HiveField(7)
  final RepeatMode repeatMode;

  @HiveField(8)
  AlertStatus status;

  @HiveField(9)
  final String label;

  @HiveField(10)
  final String notes;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  DateTime? triggeredAt;

  @HiveField(13)
  double? triggerPrice;

  @HiveField(14)
  int triggerCount;

  AlertModel({
    String? id,
    required this.targetPrice,
    required this.direction,
    this.alertType = AlertType.standard,
    this.notificationType = NotificationType.soundAndVibration,
    this.soundTheme = 'Default',
    this.vibrationEnabled = true,
    this.repeatMode = RepeatMode.once,
    this.status = AlertStatus.active,
    this.label = '',
    this.notes = '',
    DateTime? createdAt,
    this.triggeredAt,
    this.triggerPrice,
    this.triggerCount = 0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  bool get isActive => status == AlertStatus.active;
  bool get isTriggered => status == AlertStatus.triggered;
  bool get isInactive => status == AlertStatus.inactive;

  String get directionLabel =>
      direction == TriggerDirection.crossAbove ? 'Cross Above' : 'Cross Below';
  String get directionIcon =>
      direction == TriggerDirection.crossAbove ? '↑' : '↓';

  String get alertTypeLabel {
    switch (alertType) {
      case AlertType.standard:
        return 'Standard';
      case AlertType.highPriority:
        return 'High Priority';
      case AlertType.fullScreenAlarm:
        return 'Full Screen Alarm';
    }
  }

  AlertModel copyWith({
    double? targetPrice,
    TriggerDirection? direction,
    AlertType? alertType,
    NotificationType? notificationType,
    String? soundTheme,
    bool? vibrationEnabled,
    RepeatMode? repeatMode,
    AlertStatus? status,
    String? label,
    String? notes,
    DateTime? triggeredAt,
    double? triggerPrice,
    int? triggerCount,
  }) {
    return AlertModel(
      id: id,
      targetPrice: targetPrice ?? this.targetPrice,
      direction: direction ?? this.direction,
      alertType: alertType ?? this.alertType,
      notificationType: notificationType ?? this.notificationType,
      soundTheme: soundTheme ?? this.soundTheme,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      status: status ?? this.status,
      label: label ?? this.label,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      triggerPrice: triggerPrice ?? this.triggerPrice,
      triggerCount: triggerCount ?? this.triggerCount,
    );
  }
}
