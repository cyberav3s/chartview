part of 'chart_bloc.dart';

abstract class ChartState extends Equatable {
  const ChartState();
  @override
  List<Object?> get props => [];
}

class ChartInitial extends ChartState {
  const ChartInitial();
}
class ChartLoading extends ChartState {
  const ChartLoading();
}

class ChartLoaded extends ChartState {
  final String symbol;
  final List<Candle> candles;
  final String interval;
  final String chartType;
  final List<String> activeIndicators;

  const ChartLoaded({
    required this.symbol, required this.candles, required this.interval,
    required this.chartType, required this.activeIndicators,
  });

  ChartLoaded copyWith({
    String? symbol, List<Candle>? candles, String? interval,
    String? chartType, List<String>? activeIndicators,
  }) => ChartLoaded(
    symbol: symbol ?? this.symbol, candles: candles ?? this.candles,
    interval: interval ?? this.interval, chartType: chartType ?? this.chartType,
    activeIndicators: activeIndicators ?? this.activeIndicators,
  );

  @override
  List<Object?> get props => [symbol, candles, interval, chartType, activeIndicators];
}

class ChartError extends ChartState {
  final String message;
  const ChartError(this.message);
  @override
  List<Object?> get props => [message];
}