import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/alert_model.dart';
import '../../../data/repositories/alert_repository.dart';
import '../../../data/services/notification_service.dart';

part 'alert_event.dart';
part 'alert_state.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final AlertRepository alertRepository;
  final NotificationService notificationService;

  AlertBloc({
    required this.alertRepository,
    required this.notificationService,
  }) : super(AlertInitial()) {
    on<LoadAlerts>(_onLoad);
    on<CreateAlert>(_onCreate);
    on<UpdateAlert>(_onUpdate);
    on<DeleteAlert>(_onDelete);
    on<DeleteAllAlerts>(_onDeleteAll);
    on<ToggleAlert>(_onToggle);
    on<ActivateAllAlerts>(_onActivateAll);
    on<DeactivateAllAlerts>(_onDeactivateAll);
    on<SearchAlerts>(_onSearch);
    on<FilterAlerts>(_onFilter);
    on<DeleteTriggeredAlerts>(_onDeleteTriggered);
    on<RefreshAlerts>(_onRefresh);
  }

  Future<void> _onLoad(LoadAlerts event, Emitter<AlertState> emit) async {
    emit(AlertLoading());
    try {
      final alerts = alertRepository.getAllAlerts();
      emit(AlertLoaded(
        alerts: alerts,
        filter: AlertFilter.all,
        searchQuery: '',
      ));
    } catch (e) {
      emit(AlertError(e.toString()));
    }
  }

  Future<void> _onCreate(CreateAlert event, Emitter<AlertState> emit) async {
    try {
      await alertRepository.saveAlert(event.alert);
      await _emitLoaded(emit, state);
      emit(_withMessage(state, 'Alert created'));
    } catch (e) {
      emit(AlertError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateAlert event, Emitter<AlertState> emit) async {
    try {
      await alertRepository.updateAlert(event.alert);
      await _emitLoaded(emit, state);
    } catch (e) {
      emit(AlertError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteAlert event, Emitter<AlertState> emit) async {
    try {
      await alertRepository.deleteAlert(event.alertId);
      await _emitLoaded(emit, state);
    } catch (e) {
      emit(AlertError(e.toString()));
    }
  }

  Future<void> _onDeleteAll(DeleteAllAlerts event, Emitter<AlertState> emit) async {
    try {
      await alertRepository.deleteAllAlerts();
      await _emitLoaded(emit, state);
    } catch (e) {
      emit(AlertError(e.toString()));
    }
  }

  Future<void> _onToggle(ToggleAlert event, Emitter<AlertState> emit) async {
    try {
      await alertRepository.toggleAlert(event.alertId);
      await _emitLoaded(emit, state);
    } catch (e) {
      emit(AlertError(e.toString()));
    }
  }

  Future<void> _onActivateAll(ActivateAllAlerts event, Emitter<AlertState> emit) async {
    try {
      await alertRepository.activateAll();
      await _emitLoaded(emit, state);
    } catch (e) {
      emit(AlertError(e.toString()));
    }
  }

  Future<void> _onDeactivateAll(DeactivateAllAlerts event, Emitter<AlertState> emit) async {
    try {
      await alertRepository.deactivateAll();
      await _emitLoaded(emit, state);
    } catch (e) {
      emit(AlertError(e.toString()));
    }
  }

  Future<void> _onSearch(SearchAlerts event, Emitter<AlertState> emit) async {
    if (state is AlertLoaded) {
      final current = state as AlertLoaded;
      final results = event.query.isEmpty
          ? alertRepository.getAllAlerts()
          : alertRepository.search(event.query);
      emit(current.copyWith(alerts: results, searchQuery: event.query));
    }
  }

  Future<void> _onFilter(FilterAlerts event, Emitter<AlertState> emit) async {
    if (state is AlertLoaded) {
      final current = state as AlertLoaded;
      List<AlertModel> alerts;
      switch (event.filter) {
        case AlertFilter.all:
          alerts = alertRepository.getAllAlerts();
          break;
        case AlertFilter.active:
          alerts = alertRepository.getActiveAlerts();
          break;
        case AlertFilter.inactive:
          alerts = alertRepository.getInactiveAlerts();
          break;
        case AlertFilter.triggered:
          alerts = alertRepository.getTriggeredAlerts();
          break;
      }
      emit(current.copyWith(alerts: alerts, filter: event.filter));
    }
  }

  Future<void> _onDeleteTriggered(DeleteTriggeredAlerts event, Emitter<AlertState> emit) async {
    await alertRepository.deleteTriggered();
    await _emitLoaded(emit, state);
  }

  Future<void> _onRefresh(RefreshAlerts event, Emitter<AlertState> emit) async {
    await _emitLoaded(emit, state);
  }

  Future<void> _emitLoaded(Emitter<AlertState> emit, AlertState currentState) async {
    final filter = currentState is AlertLoaded ? currentState.filter : AlertFilter.all;
    final query = currentState is AlertLoaded ? currentState.searchQuery : '';

    List<AlertModel> alerts;
    if (query.isNotEmpty) {
      alerts = alertRepository.search(query);
    } else {
      switch (filter) {
        case AlertFilter.all:
          alerts = alertRepository.getAllAlerts();
          break;
        case AlertFilter.active:
          alerts = alertRepository.getActiveAlerts();
          break;
        case AlertFilter.inactive:
          alerts = alertRepository.getInactiveAlerts();
          break;
        case AlertFilter.triggered:
          alerts = alertRepository.getTriggeredAlerts();
          break;
      }
    }

    emit(AlertLoaded(
      alerts: alerts,
      filter: filter,
      searchQuery: query,
    ));
  }

  AlertState _withMessage(AlertState state, String message) {
    if (state is AlertLoaded) {
      return state.copyWith(successMessage: message);
    }
    return state;
  }
}
