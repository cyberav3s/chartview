part of 'market_bloc.dart';

abstract class MarketState extends Equatable {
  const MarketState();

  @override
  List<Object?> get props => [];
}

class MarketInitial extends MarketState {
  const MarketInitial();
}

class MarketLoading extends MarketState {
  const MarketLoading();
}

class MarketLoaded extends MarketState {
  final List<StockEntity> stocks;
  final List<StockEntity> topGainers;
  final List<StockEntity> topLosers;
  final List<StockEntity> mostActive;

  const MarketLoaded({
    required this.stocks, required this.topGainers,
    required this.topLosers, required this.mostActive,
  });

  @override
  List<Object?> get props => [stocks, topGainers, topLosers, mostActive];
}

class MarketSearchResult extends MarketState {
  final List<StockEntity> results;
  final String query;

  const MarketSearchResult({required this.results, required this.query}) : super();

  @override
  List<Object?> get props => [results, query];
}

class MarketError extends MarketState {
  final String message;
  const MarketError(this.message) : super();
  @override
  List<Object?> get props => [message];
}