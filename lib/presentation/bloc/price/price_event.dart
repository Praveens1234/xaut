part of 'price_bloc.dart';

abstract class PriceEvent extends Equatable {
  const PriceEvent();
  @override
  List<Object?> get props => [];
}

class StartPriceFeed extends PriceEvent {
  const StartPriceFeed();
}

class StopPriceFeed extends PriceEvent {
  const StopPriceFeed();
}

class RestartPriceFeed extends PriceEvent {
  const RestartPriceFeed();
}

class PriceUpdated extends PriceEvent {
  final PriceModel price;
  const PriceUpdated(this.price);
  @override
  List<Object?> get props => [price.timestamp];
}

class PriceFeedStatusChanged extends PriceEvent {
  final PriceFeedStatus status;
  const PriceFeedStatusChanged(this.status);
  @override
  List<Object?> get props => [status];
}

class PriceTicksUpdated extends PriceEvent {
  final List<PriceTick> ticks;
  const PriceTicksUpdated(this.ticks);
  @override
  List<Object?> get props => [ticks.length];
}
