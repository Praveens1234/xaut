import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/price_model.dart';
import '../../../data/repositories/price_repository.dart';
import '../../../data/services/alert_engine.dart';
import '../../../data/services/gold_price_service.dart';
import '../../../data/services/widget_service.dart';

part 'price_event.dart';
part 'price_state.dart';

class PriceBloc extends Bloc<PriceEvent, PriceState> {
  final PriceRepository priceRepository;
  final AlertEngine alertEngine;
  final WidgetService widgetService;

  StreamSubscription? _priceSub;
  StreamSubscription? _statusSub;
  StreamSubscription? _tickSub;

  int _widgetUpdateCounter = 0;
  static const int _widgetUpdateFrequency = 5; // Update widget every 5 ticks

  PriceBloc({
    required this.priceRepository,
    required this.alertEngine,
    required this.widgetService,
  }) : super(PriceInitial()) {
    on<StartPriceFeed>(_onStart);
    on<StopPriceFeed>(_onStop);
    on<PriceUpdated>(_onPriceUpdated);
    on<PriceFeedStatusChanged>(_onStatusChanged);
    on<PriceTicksUpdated>(_onTicksUpdated);
    on<RestartPriceFeed>(_onRestart);
  }

  Future<void> _onStart(StartPriceFeed event, Emitter<PriceState> emit) async {
    emit(PriceLoading());

    // Load cached price immediately
    final cached = priceRepository.getCachedPrice();
    if (cached != null) {
      emit(PriceLoaded(
        price: cached,
        ticks: const [],
        feedStatus: PriceFeedStatus.connecting,
      ));
    }

    priceRepository.startFeed();
    alertEngine.start();

    _priceSub = priceRepository.priceStream.listen((price) {
      add(PriceUpdated(price));
    });

    _statusSub = priceRepository.statusStream.listen((status) {
      add(PriceFeedStatusChanged(status));
    });

    _tickSub = priceRepository.tickStream.listen((ticks) {
      add(PriceTicksUpdated(ticks));
    });
  }

  Future<void> _onStop(StopPriceFeed event, Emitter<PriceState> emit) async {
    _priceSub?.cancel();
    _statusSub?.cancel();
    _tickSub?.cancel();
    priceRepository.stopFeed();
    alertEngine.stop();
    emit(PriceStopped());
  }

  Future<void> _onRestart(RestartPriceFeed event, Emitter<PriceState> emit) async {
    add(const StopPriceFeed());
    await Future.delayed(const Duration(milliseconds: 500));
    add(const StartPriceFeed());
  }

  void _onPriceUpdated(PriceUpdated event, Emitter<PriceState> emit) {
    final currentState = state;
    final ticks = currentState is PriceLoaded ? currentState.ticks : <PriceTick>[];
    final status = currentState is PriceLoaded
        ? currentState.feedStatus
        : PriceFeedStatus.connected;

    emit(PriceLoaded(
      price: event.price,
      ticks: ticks,
      feedStatus: status,
    ));

    // Throttle widget updates
    _widgetUpdateCounter++;
    if (_widgetUpdateCounter >= _widgetUpdateFrequency) {
      _widgetUpdateCounter = 0;
      widgetService.updateWidget(event.price);
    }
  }

  void _onStatusChanged(PriceFeedStatusChanged event, Emitter<PriceState> emit) {
    if (state is PriceLoaded) {
      final current = state as PriceLoaded;
      emit(current.copyWith(feedStatus: event.status));
    }
  }

  void _onTicksUpdated(PriceTicksUpdated event, Emitter<PriceState> emit) {
    if (state is PriceLoaded) {
      final current = state as PriceLoaded;
      emit(current.copyWith(ticks: event.ticks));
    }
  }

  @override
  Future<void> close() {
    _priceSub?.cancel();
    _statusSub?.cancel();
    _tickSub?.cancel();
    alertEngine.dispose();
    return super.close();
  }
}
