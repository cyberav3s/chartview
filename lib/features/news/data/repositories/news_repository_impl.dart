import 'package:chartview/core/error/failure.dart';
import 'package:chartview/core/network/connection_checker.dart';
import 'package:chartview/features/news/data/datasources/news_remote_data_source.dart';
import 'package:chartview/features/news/domain/entities/news_entity.dart';
import 'package:chartview/features/news/domain/repositories/news_repository.dart';
import 'package:dartz/dartz.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource _remoteDataSource;
  final ConnectionChecker _connectionChecker;

  const NewsRepositoryImpl(this._remoteDataSource, this._connectionChecker);

  @override
  Future<Either<Failure, List<News>>> getMarketNews(GetMarketNewsParams p) async {
    try {
      if (!await _connectionChecker.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }
      final result = await _remoteDataSource.getMarketNews(p);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<News>>> getSymbolNews(GetSymbolNewsParams p) async {
    try {
      if (!await _connectionChecker.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }
      final result = await _remoteDataSource.getSymbolNews(p);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
