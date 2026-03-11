import 'dart:math';
import '../../features/market/domain/entities/stock_entity.dart';
import '../../features/chart/domain/entities/candle.dart';

class MockDataGenerator {
  static final Random _random = Random();

  static List<StockEntity> generateStocks() {
    final symbols = [
      ('AAPL', 'Apple Inc.', 182.50, 0.85, 'stock'),
      ('TSLA', 'Tesla Inc.', 238.40, -1.24, 'stock'),
      ('GOOGL', 'Alphabet Inc.', 141.20, 0.63, 'stock'),
      ('MSFT', 'Microsoft Corp.', 378.90, 1.12, 'stock'),
      ('AMZN', 'Amazon.com Inc.', 178.30, -0.43, 'stock'),
      ('META', 'Meta Platforms', 492.60, 2.34, 'stock'),
      ('NVDA', 'NVIDIA Corp.', 875.40, 3.21, 'stock'),
      ('NFLX', 'Netflix Inc.', 628.10, -0.78, 'stock'),
      ('AMD', 'AMD Inc.', 164.20, 1.89, 'stock'),
      ('INTC', 'Intel Corp.', 43.80, -0.95, 'stock'),
      ('JPM', 'JP Morgan Chase', 196.40, 0.42, 'stock'),
      ('BAC', 'Bank of America', 37.20, -0.32, 'stock'),
      ('GS', 'Goldman Sachs', 438.70, 0.91, 'stock'),
      ('V', 'Visa Inc.', 273.50, 0.67, 'stock'),
      ('MA', 'Mastercard', 464.20, 0.88, 'stock'),
      ('BTC', 'Bitcoin USD', 67420.00, 2.54, 'crypto'),
      ('ETH', 'Ethereum USD', 3540.00, 1.87, 'crypto'),
      ('SOL', 'Solana USD', 142.30, -2.14, 'crypto'),
      ('SPY', 'SPDR S&P 500', 520.40, 0.34, 'index'),
      ('QQQ', 'Invesco QQQ', 440.80, 0.56, 'index'),
    ];

    return symbols.map((s) {
      final vol = (_random.nextDouble() * 50 + 10) * 1e6;
      final high = s.$3 * (1 + _random.nextDouble() * 0.03);
      final low = s.$3 * (1 - _random.nextDouble() * 0.03);
      return StockEntity(
        symbol: s.$1,
        name: s.$2,
        price: s.$3,
        change: s.$4,
        changePercent: s.$4,
        high: high,
        low: low,
        open: s.$3 * (1 - s.$4 / 100),
        volume: vol,
        marketCap: s.$3 * vol * 100,
        type: s.$5,
      );
    }).toList();
  }

  static List<Candle> generateCandles({
    int count = 100,
    double startPrice = 150.0,
    String interval = '1D',
  }) {
    final candles = <Candle>[];
    double price = startPrice;
    final now = DateTime.now();
    for (int i = count; i >= 0; i--) {
      final change = (_random.nextDouble() - 0.48) * price * 0.025;
      final open = price;
      price = (price + change).abs();
      final close = price;
      final high = max(open, close) * (1 + _random.nextDouble() * 0.01);
      final low = min(open, close) * (1 - _random.nextDouble() * 0.01);
      final volume = (_random.nextDouble() * 50 + 10) * 1e6;
      final date = interval == '1D'
          ? now.subtract(Duration(days: i))
          : now.subtract(Duration(hours: i));
      candles.add(
        Candle(
          time: date,
          open: open,
          high: high,
          low: low,
          close: close,
          volume: volume,
        ),
      );
    }
    return candles;
  }

  static List<Map<String, dynamic>> generateNews() {
    return [
      {
        'id': '1',
        'title': 'Fed signals potential rate cuts as inflation cools',
        'summary':
            'Federal Reserve officials indicated they may begin cutting interest rates as inflation data shows signs of cooling.',
        'source': 'Reuters',
        'time': '2h ago',
        'category': 'Economy',
        'tags': ['Fed', 'Interest Rates', 'Inflation'],
      },
      {
        'id': '2',
        'title': 'NVIDIA posts record quarterly earnings, beats estimates',
        'summary':
            'NVIDIA Corporation reported record revenue driven by surging demand for AI chips.',
        'source': 'Bloomberg',
        'time': '3h ago',
        'category': 'Earnings',
        'tags': ['NVDA', 'AI', 'Earnings'],
      },
      {
        'id': '3',
        'title': 'Bitcoin surges past \$67,000 on ETF inflow momentum',
        'summary':
            'Bitcoin reached its highest level in months as institutional inflows into spot ETFs accelerated.',
        'source': 'CoinDesk',
        'time': '4h ago',
        'category': 'Crypto',
        'tags': ['BTC', 'ETF', 'Crypto'],
      },
      {
        'id': '4',
        'title': "Apple Vision Pro sales exceed expectations in Q1",
        'summary':
            'Apple reported stronger than expected Vision Pro sales in its first fiscal quarter.',
        'source': 'WSJ',
        'time': '5h ago',
        'category': 'Tech',
        'tags': ['AAPL', 'Vision Pro', 'AR'],
      },
      {
        'id': '5',
        'title': 'Tesla cuts prices amid increased competition from China',
        'summary':
            'Tesla reduced prices across its lineup in major markets to counter growing competition.',
        'source': 'CNBC',
        'time': '6h ago',
        'category': 'Auto',
        'tags': ['TSLA', 'EV', 'Competition'],
      },
    ];
  }
}
