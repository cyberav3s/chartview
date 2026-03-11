
class AppConstants {
  AppConstants._();

  // App
  static const String appName = 'ChartView';
  static const String appVersion = '1.0.0';

  // Supabase
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Tables
  static const String usersTable = 'users';
  static const String watchlistTable = 'watchlist';
  static const String portfolioTable = 'portfolio';
  static const String alertsTable = 'alerts';
  static const String newsTable = 'news';
  static const String symbolsTable = 'symbols';
  static const String candlesTable = 'candles';

  // Storage Buckets
  static const String avatarsBucket = 'avatars';

  // Cache
  static const Duration cacheDuration = Duration(minutes: 5);
  static const Duration marketDataCacheDuration = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int newsPageSize = 15;

  // Chart
  static const int defaultCandleCount = 200;

  // API
  static const String alphaVantageBaseUrl = 'https://www.alphavantage.co/query';
  static const String finnhubBaseUrl = 'https://finnhub.io/api/v1';
  static const String cryptoCompareBaseUrl = 'https://min-api.cryptocompare.com/data';
}

class AppColors {
  AppColors._();

  static const int primaryDark = 0xFF131722;
  static const int surfaceDark = 0xFF1E222D;
  static const int cardDark = 0xFF2A2E39;
  static const int accent = 0xFF2962FF;
  static const int bullish = 0xFF26A69A;
  static const int bearish = 0xFFEF5350;
  static const int textPrimary = 0xFFD1D4DC;
  static const int textSecondary = 0xFF787B86;
  static const int divider = 0xFF363A45;
  static const int warning = 0xFFFF9800;
  static const int success = 0xFF4CAF50;
}

class AppStrings {
  AppStrings._();

  static const String markets = 'Markets';
  static const String watchlist = 'Watchlist';
  static const String chart = 'Chart';
  static const String news = 'News';
  static const String portfolio = 'Portfolio';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String search = 'Search symbols...';
  static const String noData = 'No data available';
  static const String loading = 'Loading...';
  static const String error = 'Something went wrong';
  static const String retry = 'Retry';
  static const String signIn = 'Sign In';
  static const String signOut = 'Sign Out';
  static const String signInWithGoogle = 'Continue with Google';
  static const String email = 'Email';
  static const String password = 'Password';
}
