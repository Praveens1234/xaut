import 'package:get_it/get_it.dart';

import '../../data/repositories/alert_repository.dart';
import '../../data/repositories/price_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/gold_price_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/alert_engine.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/widget_service.dart';
import '../../presentation/bloc/price/price_bloc.dart';
import '../../presentation/bloc/alert/alert_bloc.dart';
import '../../presentation/bloc/settings/settings_bloc.dart';

final GetIt _sl = GetIt.instance;

void setupDependencies() {
  // Services
  _sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  _sl.registerLazySingleton<GoldPriceService>(() => GoldPriceService(
        connectivityService: _sl<ConnectivityService>(),
      ));
  _sl.registerLazySingleton<NotificationService>(() => NotificationService());
  _sl.registerLazySingleton<WidgetService>(() => WidgetService());

  // Repositories
  _sl.registerLazySingleton<PriceRepository>(
      () => PriceRepository(priceService: _sl<GoldPriceService>()));
  _sl.registerLazySingleton<AlertRepository>(() => AlertRepository());
  _sl.registerLazySingleton<SettingsRepository>(() => SettingsRepository());

  // Alert Engine
  _sl.registerLazySingleton<AlertEngine>(() => AlertEngine(
        alertRepository: _sl<AlertRepository>(),
        notificationService: _sl<NotificationService>(),
        priceRepository: _sl<PriceRepository>(),
      ));

  // BLoCs
  _sl.registerFactory<PriceBloc>(() => PriceBloc(
        priceRepository: _sl<PriceRepository>(),
        alertEngine: _sl<AlertEngine>(),
        widgetService: _sl<WidgetService>(),
      ));
  _sl.registerFactory<AlertBloc>(() => AlertBloc(
        alertRepository: _sl<AlertRepository>(),
        notificationService: _sl<NotificationService>(),
      ));
  _sl.registerFactory<SettingsBloc>(
      () => SettingsBloc(settingsRepository: _sl<SettingsRepository>()));
}
