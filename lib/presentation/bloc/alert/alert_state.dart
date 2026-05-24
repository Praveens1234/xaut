part of 'alert_bloc.dart';

abstract class AlertState extends Equatable {
  const AlertState();
  @override
  List<Object?> get props => [];
}

class AlertInitial extends AlertState {}
class AlertLoading extends AlertState {}

class AlertError extends AlertState {
  final String message;
  const AlertError(this.message);
  @override
  List<Object?> get props => [message];
}

class AlertLoaded extends AlertState {
  final List<AlertModel> alerts;
  final AlertFilter filter;
  final String searchQuery;
  final String? successMessage;

  const AlertLoaded({
    required this.alerts,
    required this.filter,
    required this.searchQuery,
    this.successMessage,
  });

  int get activeCount => alerts.where((a) => a.status == AlertStatus.active).length;
  int get triggeredCount => alerts.where((a) => a.status == AlertStatus.triggered).length;
  int get totalCount => alerts.length;

  AlertLoaded copyWith({
    List<AlertModel>? alerts,
    AlertFilter? filter,
    String? searchQuery,
    String? successMessage,
  }) {
    return AlertLoaded(
      alerts: alerts ?? this.alerts,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [alerts, filter, searchQuery, successMessage];
}
