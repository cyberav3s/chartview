import 'package:equatable/equatable.dart';

class Candle extends Equatable {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const Candle({
    required this.time, required this.open, required this.high,
    required this.low, required this.close, required this.volume,
  });

  bool get isBullish => close >= open;

  @override
  List<Object?> get props => [time, open, high, low, close, volume];
}