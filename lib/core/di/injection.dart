import 'package:get_it/get_it.dart';

import '../../data/repositories/alert_repository.dart';
import '../../data/repositories/price_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/services/alert_engine.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/gold_price_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/widget_service.dart';
import '../../presentation/bloc/alert/alert_bloc.dart';
import '../../presentation/bloc/price/price_bloc.dart';
import '../../presentation/bloc/settings/settings_bloc.dart';

void setupDependencies() {
  // Services
  GetIt.I.registerLazySingleton<ConnectivityService>(
    ConnectivityService.new,
  );
  GetIt.I.registerLazySingleton<GoldPriceService>(
    () => GoldPriceService(
      connectivityService: GetIt.I<ConnectivityService>(),
    ),
  );
  GetIt.I.registerLazySingleton<NotificationService>(
    NotificationService.new,
  );
  GetIt.I.registerLazySingleton<WidgetService>(WidgetService.new);

  // Repositories
  GetIt.I.registerLazySingleton<PriceRepository>(
    () => PriceRepository(
      priceService: GetIt.I<GoldPriceService>(),
    ),
  );
  GetIt.I.registerLazySingleton<AlertRepository>(AlertRepository.new);
  GetIt.I.registerLazySingleton<SettingsRepository>(SettingsRepository.new);

  // Alert Engine
  GetIt.I.registerLazySingleton<AlertEngine>(
    () => AlertEngine(
      alertRepository: GetIt.I<AlertRepository>(),
      notificationService: GetIt.I<NotificationService>(),
      priceRepository: GetIt.I<PriceRepository>(),
    ),
  );

  // BLoCs
  GetIt.I.registerFactory<PriceBloc>(
    () => PriceBloc(
      priceRepository: GetIt.I<PriceRepository>(),
      alertEngine: GetIt.I<AlertEngine>(),
      widgetService: GetIt.I<WidgetService>(),
    ),
  );
  GetIt.I.registerFactory<AlertBloc>(
    () => AlertBloc(
      alertRepository: GetIt.I<AlertRepository>(),
      notificationService: GetIt.I<NotificationService>(),
    ),
  );
  GetIt.I.registerFactory<SettingsBloc>(
    () => SettingsBloc(
      settingsRepository: GetIt.I<SettingsRepository>(),
    ),
  );
}
