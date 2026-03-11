import 'package:chartview/core/error/failure.dart';
import 'package:chartview/features/news/domain/entities/news_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

abstract interface class NewsRepository {
  Future<Either<Failure, List<News>>> getMarketNews(GetMarketNewsParams p);
  Future<Either<Failure, List<News>>> getSymbolNews(GetSymbolNewsParams p);
}

class GetMarketNewsParams extends Equatable {
  final String? category;
  final int page;
  final int perPage;

  const GetMarketNewsParams({
    this.category,
    this.page = 1,
    this.perPage = 20,
  });

  @override
  List<Object?> get props => [category, page, perPage];
}

class GetSymbolNewsParams extends Equatable {
  final String symbol;
  final int page;

  const GetSymbolNewsParams({required this.symbol, this.page = 1});

  @override
  List<Object?> get props => [symbol, page];
}
