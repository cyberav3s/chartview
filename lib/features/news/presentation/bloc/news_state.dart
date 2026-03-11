part of 'news_bloc.dart';

class NewsState extends Equatable {
  final List<News> news;
  final NewsStatus status;
  final String message;
  final String? selectedCategory;

  const NewsState({
    this.news = const [],
    this.status = NewsStatus.initial,
    this.message = '',
    this.selectedCategory,
  });

  bool get isLoading => status == NewsStatus.loading;
  bool get hasError => status == NewsStatus.error;
  bool get isEmpty => status == NewsStatus.empty;

  NewsState copyWith({
    List<News>? news,
    NewsStatus? status,
    String? message,
    String? selectedCategory,
  }) {
    return NewsState(
      news: news ?? this.news,
      status: status ?? this.status,
      message: message ?? this.message,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [news, status, message, selectedCategory];
}
