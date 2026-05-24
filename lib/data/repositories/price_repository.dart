import 'dart:async';
import '../models/price_model.dart';
import '../services/gold_price_service.dart';

class PriceRepository {
  final GoldPriceService priceService;

  PriceRepository({required this.priceService});

  Stream<PriceModel> get priceStream => priceService.priceStream;
  Stream<PriceFeedStatus> get statusStream => priceService.statusStream;
  Stream<List<PriceTick>> get tickStream => priceService.tickStream;

  PriceModel? get currentPrice => priceService.currentPrice;
  PriceFeedStatus get feedStatus => priceService.status;

  void startFeed() => priceService.start();
  void stopFeed() => priceService.stop();
  PriceModel? getCachedPrice() => priceService.getCachedPrice();
}
