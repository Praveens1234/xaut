part of 'price_bloc.dart';

abstract class PriceState extends Equatable {
  const PriceState();
  @override
  List<Object?> get props => [];
}

class PriceInitial extends PriceState {}

class PriceLoading extends PriceState {}

class PriceStopped extends PriceState {}

class PriceError extends PriceState {
  final String message;
  const PriceError(this.message);
  @override
  List<Object?> get props => [message];
}

class PriceLoaded extends PriceState {
  final PriceModel price;
  final List<PriceTick> ticks;
  final PriceFeedStatus feedStatus;

  const PriceLoaded({
    required this.price,
    required this.ticks,
    required this.feedStatus,
  });

  bool get isConnected => feedStatus == PriceFeedStatus.connected;
  bool get isConnecting =>
      feedStatus == PriceFeedStatus.connecting ||
      feedStatus == PriceFeedStatus.reconnecting;

  PriceLoaded copyWith({
    PriceModel? price,
    List<PriceTick>? ticks,
    PriceFeedStatus? feedStatus,
  }) {
    return PriceLoaded(
      price: price ?? this.price,
      ticks: ticks ?? this.ticks,
      feedStatus: feedStatus ?? this.feedStatus,
    );
  }

  @override
  List<Object?> get props => [price.timestamp, feedStatus, ticks.length];
}
