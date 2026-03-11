import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_entity.dart';
import '../../../../core/utils/mock_data_generator.dart';

part 'market_event.dart';
part 'market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  MarketBloc() : super(MarketInitial()) {
    on<LoadMarketData>(_onLoadMarketData);
    on<RefreshMarketData>(_onRefreshMarketData);
    on<SearchStocks>(_onSearchStocks);
    on<FilterByCategory>(_onFilterByCategory);
  }

  final List<StockEntity> _allStocks = [];

  Future<void> _onLoadMarketData(LoadMarketData event, Emitter<MarketState> emit) async {
    emit(MarketLoading());
    await Future.delayed(const Duration(milliseconds: 800));
    final stocks = MockDataGenerator.generateStocks();
    _allStocks.clear();
    _allStocks.addAll(stocks);
    emit(MarketLoaded(
      stocks: stocks,
      topGainers: stocks.where((s) => s.changePercent > 1).toList()..sort((a, b) => b.changePercent.compareTo(a.changePercent)),
      topLosers: stocks.where((s) => s.changePercent < -0.5).toList()..sort((a, b) => a.changePercent.compareTo(b.changePercent)),
      mostActive: List.from(stocks)..sort((a, b) => b.volume.compareTo(a.volume)),
    ));
  }

  Future<void> _onRefreshMarketData(RefreshMarketData event, Emitter<MarketState> emit) async {
    final stocks = MockDataGenerator.generateStocks();
    _allStocks.clear();
    _allStocks.addAll(stocks);
    emit(MarketLoaded(
      stocks: stocks,
      topGainers: stocks.where((s) => s.changePercent > 1).toList()..sort((a, b) => b.changePercent.compareTo(a.changePercent)),
      topLosers: stocks.where((s) => s.changePercent < -0.5).toList()..sort((a, b) => a.changePercent.compareTo(b.changePercent)),
      mostActive: List.from(stocks)..sort((a, b) => b.volume.compareTo(a.volume)),
    ));
  }

  Future<void> _onSearchStocks(SearchStocks event, Emitter<MarketState> emit) async {
    if (event.query.isEmpty) {
      add(LoadMarketData());
      return;
    }
    final filtered = _allStocks.where((s) =>
      s.symbol.toLowerCase().contains(event.query.toLowerCase()) ||
      s.name.toLowerCase().contains(event.query.toLowerCase())
    ).toList();
    emit(MarketSearchResult(results: filtered, query: event.query));
  }

  Future<void> _onFilterByCategory(FilterByCategory event, Emitter<MarketState> emit) async {
    final filtered = event.category == 'all'
        ? _allStocks
        : _allStocks.where((s) => s.type == event.category).toList();
    emit(MarketLoaded(
      stocks: filtered,
      topGainers: filtered.where((s) => s.changePercent > 1).toList(),
      topLosers: filtered.where((s) => s.changePercent < -0.5).toList(),
      mostActive: List.from(filtered)..sort((a, b) => b.volume.compareTo(a.volume)),
    ));
  }
}