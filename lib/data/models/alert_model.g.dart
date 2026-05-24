// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlertModelAdapter extends TypeAdapter<AlertModel> {
  @override
  final int typeId = 5;

  @override
  AlertModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlertModel(
      id: fields[0] as String?,
      targetPrice: fields[1] as double,
      direction: fields[2] as TriggerDirection,
      alertType: fields[3] as AlertType,
      notificationType: fields[4] as NotificationType,
      soundTheme: fields[5] as String,
      vibrationEnabled: fields[6] as bool,
      repeatMode: fields[7] as RepeatMode,
      status: fields[8] as AlertStatus,
      label: fields[9] as String,
      notes: fields[10] as String,
      createdAt: fields[11] as DateTime?,
      triggeredAt: fields[12] as DateTime?,
      triggerPrice: fields[13] as double?,
      triggerCount: fields[14] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AlertModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.targetPrice)
      ..writeByte(2)
      ..write(obj.direction)
      ..writeByte(3)
      ..write(obj.alertType)
      ..writeByte(4)
      ..write(obj.notificationType)
      ..writeByte(5)
      ..write(obj.soundTheme)
      ..writeByte(6)
      ..write(obj.vibrationEnabled)
      ..writeByte(7)
      ..write(obj.repeatMode)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.label)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.triggeredAt)
      ..writeByte(13)
      ..write(obj.triggerPrice)
      ..writeByte(14)
      ..write(obj.triggerCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlertTypeAdapter extends TypeAdapter<AlertType> {
  @override
  final int typeId = 0;

  @override
  AlertType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AlertType.standard;
      case 1:
        return AlertType.highPriority;
      case 2:
        return AlertType.fullScreenAlarm;
      default:
        return AlertType.standard;
    }
  }

  @override
  void write(BinaryWriter writer, AlertType obj) {
    switch (obj) {
      case AlertType.standard:
        writer.writeByte(0);
        break;
      case AlertType.highPriority:
        writer.writeByte(1);
        break;
      case AlertType.fullScreenAlarm:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TriggerDirectionAdapter extends TypeAdapter<TriggerDirection> {
  @override
  final int typeId = 1;

  @override
  TriggerDirection read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TriggerDirection.crossAbove;
      case 1:
        return TriggerDirection.crossBelow;
      default:
        return TriggerDirection.crossAbove;
    }
  }

  @override
  void write(BinaryWriter writer, TriggerDirection obj) {
    switch (obj) {
      case TriggerDirection.crossAbove:
        writer.writeByte(0);
        break;
      case TriggerDirection.crossBelow:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TriggerDirectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationTypeAdapter extends TypeAdapter<NotificationType> {
  @override
  final int typeId = 2;

  @override
  NotificationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationType.notification;
      case 1:
        return NotificationType.sound;
      case 2:
        return NotificationType.vibration;
      case 3:
        return NotificationType.soundAndVibration;
      default:
        return NotificationType.soundAndVibration;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationType obj) {
    switch (obj) {
      case NotificationType.notification:
        writer.writeByte(0);
        break;
      case NotificationType.sound:
        writer.writeByte(1);
        break;
      case NotificationType.vibration:
        writer.writeByte(2);
        break;
      case NotificationType.soundAndVibration:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RepeatModeAdapter extends TypeAdapter<RepeatMode> {
  @override
  final int typeId = 3;

  @override
  RepeatMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RepeatMode.once;
      case 1:
        return RepeatMode.everyMinute;
      case 2:
        return RepeatMode.every5Minutes;
      case 3:
        return RepeatMode.every15Minutes;
      case 4:
        return RepeatMode.untilDismissed;
      default:
        return RepeatMode.once;
    }
  }

  @override
  void write(BinaryWriter writer, RepeatMode obj) {
    switch (obj) {
      case RepeatMode.once:
        writer.writeByte(0);
        break;
      case RepeatMode.everyMinute:
        writer.writeByte(1);
        break;
      case RepeatMode.every5Minutes:
        writer.writeByte(2);
        break;
      case RepeatMode.every15Minutes:
        writer.writeByte(3);
        break;
      case RepeatMode.untilDismissed:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlertStatusAdapter extends TypeAdapter<AlertStatus> {
  @override
  final int typeId = 4;

  @override
  AlertStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AlertStatus.active;
      case 1:
        return AlertStatus.inactive;
      case 2:
        return AlertStatus.triggered;
      case 3:
        return AlertStatus.expired;
      default:
        return AlertStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, AlertStatus obj) {
    switch (obj) {
      case AlertStatus.active:
        writer.writeByte(0);
        break;
      case AlertStatus.inactive:
        writer.writeByte(1);
        break;
      case AlertStatus.triggered:
        writer.writeByte(2);
        break;
      case AlertStatus.expired:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
