import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:logger/logger.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../models/price_model.dart';
import 'connectivity_service.dart';

enum PriceFeedStatus {
  connecting,
  connected,
  reconnecting,
  disconnected,
  error,
}

class GoldPriceService {
  final ConnectivityService connectivityService;
  final Logger _log = Logger();

  final BehaviorSubject<PriceModel> _priceController =
      BehaviorSubject<PriceModel>();
  final BehaviorSubject<PriceFeedStatus> _statusController =
      BehaviorSubject<PriceFeedStatus>.seeded(PriceFeedStatus.disconnected);
  final BehaviorSubject<List<PriceTick>> _tickController =
      BehaviorSubject<List<PriceTick>>.seeded([]);

  Stream<PriceModel> get priceStream => _priceController.stream;
  Stream<PriceFeedStatus> get statusStream => _statusController.stream;
  Stream<List<PriceTick>> get tickStream => _tickController.stream;
  PriceModel? get currentPrice => _priceController.valueOrNull;
  PriceFeedStatus get status => _statusController.value;

  Timer? _httpPollTimer;
  Timer? _reconnectTimer;
  StreamSubscription? _connectivitySub;
  bool _isRunning = false;
  int _reconnectAttempts = 0;

  final List<PriceTick> _ticks = [];
  static const int _maxTicks = 300; // 5 min of 1s ticks

  // Simulated base price for demo (real app uses live API)
  double _basePrice = 2345.50;
  double _previousPrice = 2345.50;
  double _openPrice = 2345.50;
  double _highPrice = 2345.50;
  double _lowPrice = 2345.50;
  final Random _random = Random();

  GoldPriceService({required this.connectivityService});

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _reconnectAttempts = 0;
    _log.i('GoldPriceService starting...');
    _statusController.add(PriceFeedStatus.connecting);
    _subscribeToConnectivity();
    _startHttpPolling();
  }

  void stop() {
    _isRunning = false;
    _httpPollTimer?.cancel();
    _reconnectTimer?.cancel();
    _connectivitySub?.cancel();
    _statusController.add(PriceFeedStatus.disconnected);
    _log.i('GoldPriceService stopped');
  }

  void _subscribeToConnectivity() {
    _connectivitySub =
        connectivityService.connectivityStream.listen((isConnected) {
      if (isConnected && _isRunning) {
        _log.i('Connectivity restored, restarting price feed');
        _reconnectAttempts = 0;
        _startHttpPolling();
      } else if (!isConnected) {
        _statusController.add(PriceFeedStatus.disconnected);
        _httpPollTimer?.cancel();
      }
    });
  }

  void _startHttpPolling() {
    _httpPollTimer?.cancel();
    // Try fetching real price first, then fall back to simulation
    _fetchRealPrice();
    _httpPollTimer = Timer.periodic(
      Duration(milliseconds: AppConstants.priceUpdateIntervalMs),
      (_) => _fetchRealPrice(),
    );
  }

  Future<void> _fetchRealPrice() async {
    try {
      // Try metals.live API (free, no auth required)
      final response = await http.get(
        Uri.parse('https://api.metals.live/v1/spot'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          for (final item in data) {
            if (item['metal'] == 'gold') {
              final price = (item['price'] as num).toDouble();
              _emitPriceFromReal(price);
              _statusController.add(PriceFeedStatus.connected);
              _reconnectAttempts = 0;
              return;
            }
          }
        }
      }
    } catch (_) {}

    // Try Yahoo Finance fallback
    try {
      final response = await http.get(
        Uri.parse(
            'https://query1.finance.yahoo.com/v8/finance/chart/XAUUSD=X?interval=1m&range=1d'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['chart']?['result']?[0];
        if (result != null) {
          final meta = result['meta'];
          final price = (meta['regularMarketPrice'] as num?)?.toDouble();
          final open = (meta['chartPreviousClose'] as num?)?.toDouble();
          if (price != null) {
            _emitPriceFromReal(price, open: open);
            _statusController.add(PriceFeedStatus.connected);
            _reconnectAttempts = 0;
            return;
          }
        }
      }
    } catch (_) {}

    // Simulate realistic price movement as final fallback
    _simulatePrice();
  }

  void _emitPriceFromReal(double price, {double? open}) {
    if (open != null) _openPrice = open;
    final spread = 0.25 + _random.nextDouble() * 0.15;
    final bid = price - spread / 2;
    final ask = price + spread / 2;
    final change = price - _openPrice;
    final changePercent =
        _openPrice > 0 ? (change / _openPrice) * 100 : 0.0;

    if (price > _highPrice) _highPrice = price;
    if (_lowPrice == 0 || price < _lowPrice) _lowPrice = price;

    final model = PriceModel(
      bid: bid,
      ask: ask,
      mid: price,
      change: change,
      changePercent: changePercent,
      spread: spread,
      high: _highPrice,
      low: _lowPrice,
      open: _openPrice,
      timestamp: DateTime.now(),
      isLive: true,
      source: 'api',
    );

    _addTick(price, price >= _previousPrice);
    _previousPrice = price;
    _priceController.add(model);
    _cachePrice(model);
  }

  void _simulatePrice() {
    // Realistic Brownian motion simulation for XAUUSD
    final delta =
        (_random.nextDouble() - 0.499) * 0.45 + (_random.nextDouble() - 0.5) * 0.1;
    _basePrice = (_basePrice + delta).clamp(1800.0, 3000.0);

    final spread = 0.25 + _random.nextDouble() * 0.15;
    final bid = _basePrice - spread / 2;
    final ask = _basePrice + spread / 2;
    final change = _basePrice - _openPrice;
    final changePercent =
        _openPrice > 0 ? (change / _openPrice) * 100 : 0.0;

    if (_basePrice > _highPrice) _highPrice = _basePrice;
    if (_lowPrice == 0 || _basePrice < _lowPrice) _lowPrice = _basePrice;

    final isUp = _basePrice >= _previousPrice;

    final model = PriceModel(
      bid: bid,
      ask: ask,
      mid: _basePrice,
      change: change,
      changePercent: changePercent,
      spread: spread,
      high: _highPrice,
      low: _lowPrice,
      open: _openPrice,
      timestamp: DateTime.now(),
      isLive: false,
      source: 'simulated',
    );

    _addTick(_basePrice, isUp);
    _previousPrice = _basePrice;

    if (_statusController.value != PriceFeedStatus.connected) {
      _statusController.add(PriceFeedStatus.connected);
    }
    _priceController.add(model);
    _cachePrice(model);
  }

  void _addTick(double price, bool isUp) {
    _ticks.add(PriceTick(
      price: price,
      timestamp: DateTime.now(),
      isUp: isUp,
    ));
    if (_ticks.length > _maxTicks) {
      _ticks.removeAt(0);
    }
    _tickController.add(List.from(_ticks));
  }

  void _cachePrice(PriceModel model) {
    try {
      final box = Hive.box('price_cache');
      box.put('last_price', model.toJson());
    } catch (_) {}
  }

  PriceModel? getCachedPrice() {
    try {
      final box = Hive.box('price_cache');
      final json = box.get('last_price');
      if (json != null) {
        return PriceModel.fromJson(Map<String, dynamic>.from(json));
      }
    } catch (_) {}
    return null;
  }

  void dispose() {
    stop();
    _priceController.close();
    _statusController.close();
    _tickController.close();
  }
}
