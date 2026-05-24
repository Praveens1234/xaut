part of 'alert_bloc.dart';

enum AlertFilter { all, active, inactive, triggered }

abstract class AlertEvent extends Equatable {
  const AlertEvent();
  @override
  List<Object?> get props => [];
}

class LoadAlerts extends AlertEvent {}
class RefreshAlerts extends AlertEvent {}
class DeleteTriggeredAlerts extends AlertEvent {}
class ActivateAllAlerts extends AlertEvent {}
class DeactivateAllAlerts extends AlertEvent {}
class DeleteAllAlerts extends AlertEvent {}

class CreateAlert extends AlertEvent {
  final AlertModel alert;
  const CreateAlert(this.alert);
  @override
  List<Object?> get props => [alert.id];
}

class UpdateAlert extends AlertEvent {
  final AlertModel alert;
  const UpdateAlert(this.alert);
  @override
  List<Object?> get props => [alert.id];
}

class DeleteAlert extends AlertEvent {
  final String alertId;
  const DeleteAlert(this.alertId);
  @override
  List<Object?> get props => [alertId];
}

class ToggleAlert extends AlertEvent {
  final String alertId;
  const ToggleAlert(this.alertId);
  @override
  List<Object?> get props => [alertId];
}

class SearchAlerts extends AlertEvent {
  final String query;
  const SearchAlerts(this.query);
  @override
  List<Object?> get props => [query];
}

class FilterAlerts extends AlertEvent {
  final AlertFilter filter;
  const FilterAlerts(this.filter);
  @override
  List<Object?> get props => [filter];
}
