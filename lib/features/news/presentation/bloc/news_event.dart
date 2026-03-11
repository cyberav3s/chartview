part of 'news_bloc.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();
  @override
  List<Object?> get props => [];
}

class LoadMarketNewsEvent extends NewsEvent {
  final GetMarketNewsParams params;
  const LoadMarketNewsEvent({this.params = const GetMarketNewsParams()});
  @override
  List<Object?> get props => [params];
}

class LoadSymbolNewsEvent extends NewsEvent {
  final GetSymbolNewsParams params;
  const LoadSymbolNewsEvent({required this.params});
  @override
  List<Object?> get props => [params];
}

class FilterNewsByCategoryEvent extends NewsEvent {
  final String? category;
  const FilterNewsByCategoryEvent({this.category});
  @override
  List<Object?> get props => [category];
}
