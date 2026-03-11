enum RequestStatus { initial, loading, loaded, error, empty }

enum MarketStatus { initial, loading, loaded, error, empty }

enum WatchlistStatus { initial, loading, loaded, added, removed, error }

enum ChartStatus { initial, loading, loaded, error }

enum NewsStatus { initial, loading, loaded, error, empty }

enum PortfolioStatus { initial, loading, loaded, error, empty }

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

enum UserProfileStatus { initial, loading, loaded, updated, error }

enum ChartInterval {
  oneMinute,
  fiveMinutes,
  fifteenMinutes,
  thirtyMinutes,
  oneHour,
  fourHours,
  oneDay,
  oneWeek,
  oneMonth,
}

enum ChartType { candlestick, line, bar, area }

enum MarketType { stocks, crypto, forex, futures, indices }

enum OrderSide { buy, sell }

enum OrderType { market, limit, stopLoss, takeProfit }

enum DrawingTool {
  none,
  horizontalLine,
  horizontalRay,
  trendLine,
  fibonacci,
  rectangle,
  pointer,
}
