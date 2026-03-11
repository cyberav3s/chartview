import 'package:chartview/core/error/exceptions.dart';
import 'package:chartview/features/news/data/models/news_model.dart';
import 'package:chartview/features/news/domain/repositories/news_repository.dart';

abstract interface class NewsRemoteDataSource {
  Future<List<NewsModel>> getMarketNews(GetMarketNewsParams p);
  Future<List<NewsModel>> getSymbolNews(GetSymbolNewsParams p);
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  const NewsRemoteDataSourceImpl();

  @override
  Future<List<NewsModel>> getMarketNews(GetMarketNewsParams p) async {
    try {
      final all = NewsModel.mockNews;
      if (p.category != null && p.category!.isNotEmpty) {
        return all.where((n) => n.category == p.category).toList();
      }
      return all;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<NewsModel>> getSymbolNews(GetSymbolNewsParams p) async {
    try {
      return NewsModel.mockNews
          .where((n) => n.relatedSymbol == p.symbol)
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
