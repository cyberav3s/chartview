import 'package:chartview/core/error/failure.dart';
import 'package:chartview/core/network/connection_checker.dart';
import 'package:chartview/features/chart/data/datasources/chart_remote_data_source.dart';
import 'package:chartview/features/chart/domain/entities/candle.dart';
import 'package:chartview/features/chart/domain/repositories/chart_repository.dart';
import 'package:dartz/dartz.dart';

class ChartRepositoryImpl implements ChartRepository {
  final ChartRemoteDataSource _remoteDataSource;
  final ConnectionChecker _connectionChecker;

  const ChartRepositoryImpl(this._remoteDataSource, this._connectionChecker);

  @override
  Future<Either<Failure, List<Candle>>> getCandles(
      GetCandlesParams p) async {
    try {
      if (!await _connectionChecker.isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }
      final result = await _remoteDataSource.getCandles(p);
      return Right(result);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
