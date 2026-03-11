import 'package:chartview/core/error/exceptions.dart';
import 'package:chartview/features/chart/data/models/candle_model.dart';
import 'package:chartview/features/chart/domain/repositories/chart_repository.dart';

abstract interface class ChartRemoteDataSource {
  Future<List<CandleModel>> getCandles(GetCandlesParams p);
}

class ChartRemoteDataSourceImpl implements ChartRemoteDataSource {
  const ChartRemoteDataSourceImpl();

  @override
  Future<List<CandleModel>> getCandles(GetCandlesParams p) async {
    try {
      // Mock starting prices for different symbols
      final startPrices = {
        'AAPL': 189.84,
        'GOOGL': 141.58,
        'MSFT': 378.85,
        'TSLA': 248.42,
        'NVDA': 875.40,
        'META': 502.30,
        'AMZN': 183.75,
        'BTC-USD': 67842.50,
        'ETH-USD': 3524.18,
        'EUR/USD': 1.0872,
      };
      final startPrice = startPrices[p.symbol] ?? 100.0;

      return CandleModel.generateMockCandles(
        symbol: p.symbol,
        count: p.count,
        startPrice: startPrice,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
