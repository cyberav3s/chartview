import 'package:chartview/core/error/failure.dart';
import 'package:chartview/core/utils/usecase/base_usecase.dart';
import 'package:chartview/features/news/domain/entities/news_entity.dart';
import 'package:chartview/features/news/domain/repositories/news_repository.dart';
import 'package:dartz/dartz.dart';

class GetMarketNews extends UseCase<List<News>, GetMarketNewsParams> {
  final NewsRepository _repository;
  GetMarketNews(this._repository);

  @override
  Future<Either<Failure, List<News>>> call(GetMarketNewsParams p) async {
    return await _repository.getMarketNews(p);
  }
}

class GetSymbolNews extends UseCase<List<News>, GetSymbolNewsParams> {
  final NewsRepository _repository;
  GetSymbolNews(this._repository);

  @override
  Future<Either<Failure, List<News>>> call(GetSymbolNewsParams p) async {
    return await _repository.getSymbolNews(p);
  }
}
