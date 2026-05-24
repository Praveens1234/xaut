class PriceModel {
  final double bid;
  final double ask;
  final double mid;
  final double change;
  final double changePercent;
  final double spread;
  final double high;
  final double low;
  final double open;
  final DateTime timestamp;
  final bool isLive;
  final String source;

  const PriceModel({
    required this.bid,
    required this.ask,
    required this.mid,
    required this.change,
    required this.changePercent,
    required this.spread,
    required this.high,
    required this.low,
    required this.open,
    required this.timestamp,
    this.isLive = true,
    this.source = 'websocket',
  });

  PriceModel copyWith({
    double? bid,
    double? ask,
    double? mid,
    double? change,
    double? changePercent,
    double? spread,
    double? high,
    double? low,
    double? open,
    DateTime? timestamp,
    bool? isLive,
    String? source,
  }) {
    return PriceModel(
      bid: bid ?? this.bid,
      ask: ask ?? this.ask,
      mid: mid ?? this.mid,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      spread: spread ?? this.spread,
      high: high ?? this.high,
      low: low ?? this.low,
      open: open ?? this.open,
      timestamp: timestamp ?? this.timestamp,
      isLive: isLive ?? this.isLive,
      source: source ?? this.source,
    );
  }

  bool get isUp => change >= 0;
  bool get isDown => change < 0;

  Map<String, dynamic> toJson() => {
        'bid': bid,
        'ask': ask,
        'mid': mid,
        'change': change,
        'change_percent': changePercent,
        'spread': spread,
        'high': high,
        'low': low,
        'open': open,
        'timestamp': timestamp.toIso8601String(),
        'is_live': isLive,
        'source': source,
      };

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      bid: (json['bid'] as num?)?.toDouble() ?? 0,
      ask: (json['ask'] as num?)?.toDouble() ?? 0,
      mid: (json['mid'] as num?)?.toDouble() ?? 0,
      change: (json['change'] as num?)?.toDouble() ?? 0,
      changePercent: (json['change_percent'] as num?)?.toDouble() ?? 0,
      spread: (json['spread'] as num?)?.toDouble() ?? 0,
      high: (json['high'] as num?)?.toDouble() ?? 0,
      low: (json['low'] as num?)?.toDouble() ?? 0,
      open: (json['open'] as num?)?.toDouble() ?? 0,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isLive: json['is_live'] as bool? ?? true,
      source: json['source'] as String? ?? 'unknown',
    );
  }

  static PriceModel empty() => PriceModel(
        bid: 0,
        ask: 0,
        mid: 0,
        change: 0,
        changePercent: 0,
        spread: 0,
        high: 0,
        low: 0,
        open: 0,
        timestamp: DateTime.now(),
        isLive: false,
        source: 'none',
      );
}

class PriceTick {
  final double price;
  final DateTime timestamp;
  final bool isUp;

  const PriceTick({
    required this.price,
    required this.timestamp,
    required this.isUp,
  });
}
