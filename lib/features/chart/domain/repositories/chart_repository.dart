import 'package:chartview/core/error/failure.dart';
import 'package:chartview/core/utils/enums.dart';
import 'package:chartview/features/chart/domain/entities/candle.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

abstract interface class ChartRepository {
  Future<Either<Failure, List<Candle>>> getCandles(GetCandlesParams p);
}

class GetCandlesParams extends Equatable {
  final String symbol;
  final ChartInterval interval;
  final int count;
  final DateTime? from;
  final DateTime? to;

  const GetCandlesParams({
    required this.symbol,
    required this.interval,
    this.count = 200,
    this.from,
    this.to,
  });

  @override
  List<Object?> get props => [symbol, interval, count, from, to];
}
