import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../data/models/settings_model.dart';
import '../../../data/repositories/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsBloc({required this.settingsRepository}) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoad);
    on<UpdateSettings>(_onUpdate);
    on<UpdateSingleSetting>(_onUpdateSingle);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    on<ResetSettings>(_onReset);
  }

  Future<void> _onLoad(LoadSettings event, Emitter<SettingsState> emit) async {
    try {
      final settings = settingsRepository.getSettings();
      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      emit(SettingsLoaded(settings: const AppSettings()));
    }
  }

  Future<void> _onUpdate(UpdateSettings event, Emitter<SettingsState> emit) async {
    await settingsRepository.saveSettings(event.settings);
    emit(SettingsLoaded(settings: event.settings));
  }

  Future<void> _onUpdateSingle(UpdateSingleSetting event, Emitter<SettingsState> emit) async {
    await settingsRepository.saveSetting(event.key, event.value);
    final settings = settingsRepository.getSettings();
    emit(SettingsLoaded(settings: settings));
  }

  Future<void> _onCompleteOnboarding(CompleteOnboarding event, Emitter<SettingsState> emit) async {
    await settingsRepository.saveSetting('onboarding_complete', true);
    final settings = settingsRepository.getSettings();
    emit(SettingsLoaded(settings: settings));
  }

  Future<void> _onReset(ResetSettings event, Emitter<SettingsState> emit) async {
    await settingsRepository.clear();
    emit(SettingsLoaded(settings: const AppSettings()));
  }
}
