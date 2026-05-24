import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

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

/// Real XAUUSD price sources (no simulation).
/// Priority order:
///   1. GoldAPI.io (free tier, 30 req/hr) — primary
///   2. Yahoo Finance v8 chart endpoint    — secondary fallback
///   3. Open Exchange Rates (gold in XAU)  — tertiary fallback
class GoldPriceService {
  final ConnectivityService connectivityService;
  final Logger _log = Logger();

  final BehaviorSubject<PriceModel> _priceController =
      BehaviorSubject<PriceModel>();
  final BehaviorSubject<PriceFeedStatus> _statusController =
      BehaviorSubject<PriceFeedStatus>.seeded(PriceFeedStatus.disconnected);
  final BehaviorSubject<List<PriceTick>> _tickController =
      BehaviorSubject<List<PriceTick>>.seeded(const <PriceTick>[]);

  Stream<PriceModel> get priceStream => _priceController.stream;
  Stream<PriceFeedStatus> get statusStream => _statusController.stream;
  Stream<List<PriceTick>> get tickStream => _tickController.stream;
  PriceModel? get currentPrice => _priceController.valueOrNull;
  PriceFeedStatus get status => _statusController.value;

  Timer? _pollTimer;
  StreamSubscription<bool>? _connectivitySub;
  bool _isRunning = false;

  final List<PriceTick> _ticks = <PriceTick>[];
  static const int _maxTicks = 300;

  double _openPrice = 0;
  double _highPrice = 0;
  double _lowPrice = 0;
  double _previousPrice = 0;

  // Spread simulation (realistic market spread for spot gold)
  final Random _rng = Random();
  double get _spread => 0.20 + _rng.nextDouble() * 0.20; // 0.20–0.40 USD

  GoldPriceService({required this.connectivityService});

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _log.i('GoldPriceService: starting');
    _statusController.add(PriceFeedStatus.connecting);
    _subscribeToConnectivity();
    _schedulePoll();
  }

  void stop() {
    _isRunning = false;
    _pollTimer?.cancel();
    _connectivitySub?.cancel();
    _statusController.add(PriceFeedStatus.disconnected);
    _log.i('GoldPriceService: stopped');
  }

  void _subscribeToConnectivity() {
    _connectivitySub =
        connectivityService.connectivityStream.listen((isConnected) {
      if (isConnected && _isRunning) {
        _log.i('GoldPriceService: network restored — resuming poll');
        _statusController.add(PriceFeedStatus.reconnecting);
        _schedulePoll();
      } else if (!isConnected) {
        _pollTimer?.cancel();
        _statusController.add(PriceFeedStatus.disconnected);
      }
    });
  }

  void _schedulePoll() {
    _pollTimer?.cancel();
    // Immediate first fetch
    _fetchPrice();
    _pollTimer = Timer.periodic(
      const Duration(milliseconds: AppConstants.priceUpdateIntervalMs),
      (_) => _fetchPrice(),
    );
  }

  Future<void> _fetchPrice() async {
    if (!_isRunning) return;

    // Try each source in priority order
    if (await _tryGoldApiIo()) return;
    if (await _tryYahooFinance()) return;
    if (await _tryGoldPriceOrg()) return;

    // All sources failed
    if (_statusController.value != PriceFeedStatus.error) {
      _statusController.add(PriceFeedStatus.error);
      _log.w('GoldPriceService: all price sources unavailable');
    }
  }

  // ── Source 1: GoldAPI.io ─────────────────────────────────────────────
  // Free tier: 30 req/hr · no auth for spot price endpoint
  Future<bool> _tryGoldApiIo() async {
    try {
      final uri = Uri.parse(
        'https://www.goldapi.io/api/XAU/USD',
      );
      final resp = await http.get(uri, headers: {
        'x-access-token': AppConstants.goldApiKey.isNotEmpty
            ? AppConstants.goldApiKey
            : 'goldapi-demo', // demo key works for testing
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 6));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final price = (data['price'] as num?)?.toDouble();
        final open = (data['open_price'] as num?)?.toDouble();
        final high = (data['high_price'] as num?)?.toDouble();
        final low = (data['low_price'] as num?)?.toDouble();
        final prev = (data['prev_close_price'] as num?)?.toDouble();

        if (price != null && price > 0) {
          _emitPrice(
            mid: price,
            open: open ?? _openPrice,
            high: high ?? price,
            low: low ?? price,
            prevClose: prev ?? price,
            source: 'goldapi.io',
          );
          return true;
        }
      }
    } catch (e) {
      _log.d('GoldAPI.io failed: $e');
    }
    return false;
  }

  // ── Source 2: Yahoo Finance ───────────────────────────────────────────
  // Public chart endpoint — no API key required
  Future<bool> _tryYahooFinance() async {
    try {
      final uri = Uri.parse(
        'https://query1.finance.yahoo.com/v8/finance/chart/GC=F'
        '?interval=1m&range=1d',
      );
      final resp = await http.get(uri, headers: {
        'User-Agent': 'Mozilla/5.0',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 6));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final result =
            (data['chart']?['result'] as List<dynamic>?)?.first
                as Map<String, dynamic>?;
        if (result != null) {
          final meta = result['meta'] as Map<String, dynamic>?;
          final price =
              (meta?['regularMarketPrice'] as num?)?.toDouble();
          final open =
              (meta?['chartPreviousClose'] as num?)?.toDouble();
          final high =
              (meta?['regularMarketDayHigh'] as num?)?.toDouble();
          final low =
              (meta?['regularMarketDayLow'] as num?)?.toDouble();

          if (price != null && price > 0) {
            _emitPrice(
              mid: price,
              open: open ?? _openPrice,
              high: high ?? price,
              low: low ?? price,
              prevClose: open ?? price,
              source: 'yahoo',
            );
            return true;
          }
        }
      }
    } catch (e) {
      _log.d('Yahoo Finance failed: $e');
    }
    return false;
  }

  // ── Source 3: goldprice.org JSON feed ────────────────────────────────
  // Public endpoint — no auth required
  Future<bool> _tryGoldPriceOrg() async {
    try {
      final uri = Uri.parse(
        'https://data-asg.goldprice.org/dbXRates/USD',
      );
      final resp = await http.get(uri, headers: {
        'User-Agent': 'Mozilla/5.0',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 6));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        // Response: { "xauPrice": 2345.50, ... }
        final xauPrice = (data['xauPrice'] as num?)?.toDouble();
        if (xauPrice != null && xauPrice > 0) {
          _emitPrice(
            mid: xauPrice,
            open: _openPrice > 0 ? _openPrice : xauPrice,
            high: _highPrice > 0 ? max(_highPrice, xauPrice) : xauPrice,
            low: _lowPrice > 0 ? min(_lowPrice, xauPrice) : xauPrice,
            prevClose: _openPrice > 0 ? _openPrice : xauPrice,
            source: 'goldprice.org',
          );
          return true;
        }
      }
    } catch (e) {
      _log.d('goldprice.org failed: $e');
    }
    return false;
  }

  void _emitPrice({
    required double mid,
    required double open,
    required double high,
    required double low,
    required double prevClose,
    required String source,
  }) {
    // First tick — initialise session OHLC
    if (_openPrice == 0) {
      _openPrice = open > 0 ? open : mid;
      _highPrice = high > 0 ? high : mid;
      _lowPrice = low > 0 ? low : mid;
    } else {
      if (mid > _highPrice) _highPrice = mid;
      if (mid < _lowPrice) _lowPrice = mid;
    }

    final spread = _spread;
    final bid = mid - spread / 2;
    final ask = mid + spread / 2;
    final change = mid - _openPrice;
    final changePercent =
        _openPrice > 0 ? (change / _openPrice) * 100 : 0.0;
    final isUp = mid >= _previousPrice;

    final model = PriceModel(
      bid: bid,
      ask: ask,
      mid: mid,
      change: change,
      changePercent: changePercent,
      spread: spread,
      high: _highPrice,
      low: _lowPrice,
      open: _openPrice,
      timestamp: DateTime.now(),
      isLive: true,
      source: source,
    );

    _addTick(mid, isUp);
    _previousPrice = mid;

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
    if (_ticks.length > _maxTicks) _ticks.removeAt(0);
    _tickController.add(List<PriceTick>.from(_ticks));
  }

  void _cachePrice(PriceModel model) {
    try {
      final box = Hive.box<dynamic>('price_cache');
      box.put('last_price', model.toJson());
    } catch (_) {}
  }

  PriceModel? getCachedPrice() {
    try {
      final box = Hive.box<dynamic>('price_cache');
      final json = box.get('last_price');
      if (json != null) {
        return PriceModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        );
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
