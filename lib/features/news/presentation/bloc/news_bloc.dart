import 'package:chartview/core/utils/enums.dart';
import 'package:chartview/features/news/domain/entities/news_entity.dart';
import 'package:chartview/features/news/domain/repositories/news_repository.dart';
import 'package:chartview/features/news/domain/usecases/news_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'news_event.dart';
part 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetMarketNews _getMarketNews;
  final GetSymbolNews _getSymbolNews;

  NewsBloc(this._getMarketNews, this._getSymbolNews)
    : super(const NewsState()) {
    on<LoadMarketNewsEvent>(_onLoadMarketNews);
    on<LoadSymbolNewsEvent>(_onLoadSymbolNews);
    on<FilterNewsByCategoryEvent>(_onFilterByCategory);
  }

  Future<void> _onLoadMarketNews(
    LoadMarketNewsEvent event,
    Emitter<NewsState> emit,
  ) async {
    emit(state.copyWith(status: NewsStatus.loading));
    final res = await _getMarketNews(event.params);
    res.fold(
      (f) => emit(state.copyWith(status: NewsStatus.error, message: f.message)),
      (news) => emit(
        state.copyWith(
          status: news.isEmpty ? NewsStatus.empty : NewsStatus.loaded,
          news: news,
        ),
      ),
    );
  }

  Future<void> _onLoadSymbolNews(
    LoadSymbolNewsEvent event,
    Emitter<NewsState> emit,
  ) async {
    emit(state.copyWith(status: NewsStatus.loading));
    final res = await _getSymbolNews(event.params);
    res.fold(
      (f) => emit(state.copyWith(status: NewsStatus.error, message: f.message)),
      (news) => emit(
        state.copyWith(
          status: news.isEmpty ? NewsStatus.empty : NewsStatus.loaded,
          news: news,
        ),
      ),
    );
  }

  void _onFilterByCategory(
    FilterNewsByCategoryEvent event,
    Emitter<NewsState> emit,
  ) {
    emit(state.copyWith(selectedCategory: event.category));
    add(
      LoadMarketNewsEvent(
        params: GetMarketNewsParams(category: event.category),
      ),
    );
  }
}
