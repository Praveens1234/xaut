part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}
class CompleteOnboarding extends SettingsEvent {}
class ResetSettings extends SettingsEvent {}

class UpdateSettings extends SettingsEvent {
  final AppSettings settings;
  const UpdateSettings(this.settings);
  @override
  List<Object?> get props => [settings];
}

class UpdateSingleSetting extends SettingsEvent {
  final String key;
  final dynamic value;
  const UpdateSingleSetting(this.key, this.value);
  @override
  List<Object?> get props => [key, value];
}
