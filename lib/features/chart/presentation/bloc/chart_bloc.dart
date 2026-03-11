import 'package:chartview/features/chart/domain/entities/candle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/mock_data_generator.dart';

part 'chart_event.dart';
part 'chart_state.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  ChartBloc() : super(ChartInitial()) {
    on<LoadChartData>(_onLoadChartData);
    on<ChangeInterval>(_onChangeInterval);
    on<ChangeChartType>(_onChangeChartType);
    on<ToggleIndicator>(_onToggleIndicator);
  }

  Future<void> _onLoadChartData(LoadChartData event, Emitter<ChartState> emit) async {
    emit(ChartLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    final candles = MockDataGenerator.generateCandles(
      count: _getCandleCount(event.interval),
      startPrice: event.startPrice,
      interval: event.interval,
    );
    emit(ChartLoaded(
      symbol: event.symbol,
      candles: candles,
      interval: event.interval,
      chartType: 'candlestick',
      activeIndicators: const [],
    ));
  }

  Future<void> _onChangeInterval(ChangeInterval event, Emitter<ChartState> emit) async {
    if (state is ChartLoaded) {
      final current = state as ChartLoaded;
      emit(ChartLoading());
      await Future.delayed(const Duration(milliseconds: 400));
      final candles = MockDataGenerator.generateCandles(
        count: _getCandleCount(event.interval),
        startPrice: current.candles.isNotEmpty ? current.candles.last.close : 150,
        interval: event.interval,
      );
      emit(ChartLoaded(
        symbol: current.symbol, candles: candles, interval: event.interval,
        chartType: current.chartType, activeIndicators: current.activeIndicators,
      ));
    }
  }

  Future<void> _onChangeChartType(ChangeChartType event, Emitter<ChartState> emit) async {
    if (state is ChartLoaded) {
      final current = state as ChartLoaded;
      emit(current.copyWith(chartType: event.chartType));
    }
  }

  Future<void> _onToggleIndicator(ToggleIndicator event, Emitter<ChartState> emit) async {
    if (state is ChartLoaded) {
      final current = state as ChartLoaded;
      final indicators = List<String>.from(current.activeIndicators);
      if (indicators.contains(event.indicator)) {
        indicators.remove(event.indicator);
      } else {
        indicators.add(event.indicator);
      }
      emit(current.copyWith(activeIndicators: indicators));
    }
  }

  int _getCandleCount(String interval) {
    switch (interval) {
      case '1m': return 60;
      case '5m': return 100;
      case '15m': return 100;
      case '1H': return 100;
      case '4H': return 100;
      case '1D': return 365;
      case '1W': return 104;
      case '1M': return 60;
      default: return 100;
    }
  }
}