import 'dart:math';

import 'package:chartview/features/chart/domain/entities/candle.dart';

class CandleModel extends Candle {
  const CandleModel({
    required super.time,
    required super.open,
    required super.high,
    required super.low,
    required super.close,
    required super.volume,
  });

  factory CandleModel.fromJson(Map<String, dynamic> json) {
    return CandleModel(
      time: json['time'] is int
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['time'] as int) * 1000)
          : DateTime.parse(json['time'] as String),
      open: (json['open'] ?? json['o'] ?? 0).toDouble(),
      high: (json['high'] ?? json['h'] ?? 0).toDouble(),
      low: (json['low'] ?? json['l'] ?? 0).toDouble(),
      close: (json['close'] ?? json['c'] ?? 0).toDouble(),
      volume: (json['volume'] ?? json['v'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'time': time.millisecondsSinceEpoch ~/ 1000,
        'open': open,
        'high': high,
        'low': low,
        'close': close,
        'volume': volume,
      };

  /// Generate realistic mock candle data
  static List<CandleModel> generateMockCandles({
    required String symbol,
    int count = 200,
    double startPrice = 100.0,
  }) {
    final random = Random(symbol.hashCode);
    final candles = <CandleModel>[];
    double price = startPrice;
    final now = DateTime.now();

    for (int i = count; i >= 0; i--) {
      final time = now.subtract(Duration(days: i));
      final volatility = price * 0.02;
      final change = (random.nextDouble() - 0.48) * volatility;

      final open = price;
      final close = (price + change).clamp(price * 0.95, price * 1.05);
      final high = [open, close].reduce((a, b) => a > b ? a : b) +
          random.nextDouble() * volatility * 0.5;
      final low = [open, close].reduce((a, b) => a < b ? a : b) -
          random.nextDouble() * volatility * 0.5;
      final volume =
          (1000000 + random.nextDouble() * 9000000).roundToDouble();

      candles.add(CandleModel(
        time: time,
        open: double.parse(open.toStringAsFixed(2)),
        high: double.parse(high.toStringAsFixed(2)),
        low: double.parse(low.toStringAsFixed(2)),
        close: double.parse(close.toStringAsFixed(2)),
        volume: volume,
      ));
      price = close;
    }
    return candles;
  }

  CandleModel copyWith({
    DateTime? time,
    double? open,
    double? high,
    double? low,
    double? close,
    double? volume,
  }) {
    return CandleModel(
      time: time ?? this.time,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
    );
  }
}
