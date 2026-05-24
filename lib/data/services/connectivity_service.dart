import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _controller.stream;
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  StreamSubscription? _sub;

  ConnectivityService() {
    _init();
  }

  void _init() {
    _sub = _connectivity.onConnectivityChanged.listen((results) {
      final connected = results.any((r) => r != ConnectivityResult.none);
      if (connected != _isConnected) {
        _isConnected = connected;
        _controller.add(connected);
      }
    });

    _checkInitial();
  }

  Future<void> _checkInitial() async {
    final results = await _connectivity.checkConnectivity();
    _isConnected = results.any((r) => r != ConnectivityResult.none);
    _controller.add(_isConnected);
  }

  Future<bool> check() async {
    final results = await _connectivity.checkConnectivity();
    _isConnected = results.any((r) => r != ConnectivityResult.none);
    return _isConnected;
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
