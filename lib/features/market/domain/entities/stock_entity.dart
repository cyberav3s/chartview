import 'package:equatable/equatable.dart';

class StockEntity extends Equatable {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final double high;
  final double low;
  final double open;
  final double volume;
  final double marketCap;
  final String type;

  const StockEntity({
    required this.symbol, required this.name, required this.price,
    required this.change, required this.changePercent, required this.high,
    required this.low, required this.open, required this.volume,
    required this.marketCap, required this.type,
  });

  bool get isBullish => changePercent >= 0;

  @override
  List<Object?> get props => [symbol, price, changePercent];
}