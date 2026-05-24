part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => <Object?>[];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoaded extends SettingsState {
  final AppSettings settings;
  const SettingsLoaded({required this.settings});
  @override
  List<Object?> get props => <Object?>[settings];
}
