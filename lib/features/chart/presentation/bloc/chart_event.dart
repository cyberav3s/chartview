part of 'chart_bloc.dart';

abstract class ChartEvent extends Equatable {
  const ChartEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadChartData extends ChartEvent {
  final String symbol;
  final String interval;
  final double startPrice;

  const LoadChartData({
    required this.symbol, this.interval = '1D', this.startPrice = 150.0,
  });

  @override
  List<Object?> get props => [symbol, interval, startPrice];
}

class ChangeInterval extends ChartEvent {
  final String interval;
  const ChangeInterval(this.interval);
  @override
  List<Object?> get props => [interval];
}

class ChangeChartType extends ChartEvent {
  final String chartType;
  const ChangeChartType(this.chartType);
  @override
  List<Object?> get props => [chartType];
}

class ToggleIndicator extends ChartEvent {
  final String indicator;
  const ToggleIndicator(this.indicator);
  @override
  List<Object?> get props => [indicator];
}