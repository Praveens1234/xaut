import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'core/di/injection.dart';
import 'data/models/alert_model.dart';
import 'presentation/app.dart';
import 'services/background/background_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await BackgroundService.handleTask(task, inputData);
    return true;
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  await SystemChrome.setPreferredOrientations(
    <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  // Hive
  await Hive.initFlutter();
  Hive.registerAdapter(AlertModelAdapter());
  Hive.registerAdapter(AlertTypeAdapter());
  Hive.registerAdapter(TriggerDirectionAdapter());
  Hive.registerAdapter(NotificationTypeAdapter());
  Hive.registerAdapter(RepeatModeAdapter());
  Hive.registerAdapter(AlertStatusAdapter());
  await Hive.openBox<AlertModel>('alerts');
  await Hive.openBox<dynamic>('settings');
  await Hive.openBox<dynamic>('price_cache');

  // Timezone
  tz.initializeTimeZones();
  try {
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  } catch (_) {}

  // Dependency Injection
  setupDependencies();

  // Workmanager background sync
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'xaut_price_sync',
    'priceSyncTask',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  runApp(const XautApp());
}
