part of 'market_bloc.dart';

abstract class MarketEvent extends Equatable {
  const MarketEvent();
  @override
  List<Object?> get props => [];
}

class LoadMarketData extends MarketEvent {
  const LoadMarketData();
}
class RefreshMarketData extends MarketEvent {
  const RefreshMarketData();
}
class SearchStocks extends MarketEvent {
  final String query;
  const SearchStocks(this.query);
  @override
  List<Object?> get props => [query];
}
class FilterByCategory extends MarketEvent {
  final String category;
  const FilterByCategory(this.category);
  @override
  List<Object?> get props => [category];
}