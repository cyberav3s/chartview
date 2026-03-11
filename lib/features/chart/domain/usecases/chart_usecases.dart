import 'package:chartview/core/error/failure.dart';
import 'package:chartview/core/utils/usecase/base_usecase.dart';
import 'package:chartview/features/chart/domain/entities/candle.dart';
import 'package:chartview/features/chart/domain/repositories/chart_repository.dart';
import 'package:dartz/dartz.dart';

class GetCandles extends UseCase<List<Candle>, GetCandlesParams> {
  final ChartRepository _repository;
  GetCandles(this._repository);

  @override
  Future<Either<Failure, List<Candle>>> call(GetCandlesParams p) async {
    return await _repository.getCandles(p);
  }
}
