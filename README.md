# ChartView — Flutter Clean Architecture

![Screenshot](https://i.ibb.co/8kpH9N6/IMG-20260311-183438-1.jpg)   

A production-quality TradingView-inspired trading app built with Flutter using Clean Architecture principles.

## 🏗️ Architecture
Follows Clean Architecture with strict separation of concerns:
```
lib/
├── core/
│   ├── constants/        # App colors, themes, text styles
│   ├── error/            # Failures & Exceptions
│   ├── network/          # API client, connectivity
│   └── utils/            # Number formatter, mock data
│
├── features/
│   ├── market_overview/  # Markets screen
│   │   ├── data/         # Datasources, Models, Repositories (impl)
│   │   ├── domain/       # Entities, Repository interfaces, UseCases
│   │   └── presentation/ # BLoC, Pages, Widgets
│   │
│   ├── chart/            # Candlestick charting
│   ├── watchlist/        # User watchlist management
│   ├── news/             # Financial news feed
│   ├── user_profile/     # User account & portfolio
│   └── authentication/   # Login, signup, main shell
│
└── service_locator.dart  # Dependency injection registry
```

## ✨ Features

### Markets Screen
- Live market data (mock) with bullish/bearish coloring
- Tab-based filtering: All / Top Gainers / Top Losers / Most Active
- Real-time search across symbols and company names
- Pull-to-refresh support
- Dismissible loading shimmer states

### Chart Screen
- **Candlestick charts** with wick and body rendering
- **Line charts** with area fill gradient
- **Bar charts** toggle
- Interval selector: 1m, 5m, 15m, 1H, 4H, 1D, 1W, 1M
- Technical indicators toggle: MA, EMA, RSI, MACD, BB, VWAP
- OHLCV data display panel
- **Buy/Sell trade sheet** with market/limit/stop order types
- Price grid lines with labels

### Watchlist Screen
- Personalized symbol tracking
- Swipe-to-delete with Dismissible
- Add custom symbols via dialog
- Real-time P&L display

### News Screen
- Category filtering: Economy, Earnings, Crypto, Tech, Auto
- Article cards with source, time, and hashtags
- Pull-to-refresh

### Profile Screen
- Portfolio summary with total value + daily P&L
- Follower/Following/Ideas stats
- PRO plan badge
- Settings menu items
- Sign out

## 🛠️ Tech Stack
| Category | Package |
| State Management | flutter_bloc |
| DI | get_it |
| Charts | Custom CustomPainter |
| Fonts | google_fonts (JetBrains Mono + Inter) |
| Navigation | Native Navigator |
| Utilities | intl, dartz, equatable |

## 🎨 Design System
**Color Palette (Dark Trading Theme)**
- Background: `#131722` (TradingView-inspired)
- Surface: `#1E2130`
- Bullish: `#26A69A`
- Bearish: `#EF5350`
- Primary: `#2962FF`

**Typography**
- Display/Prices: JetBrains Mono (monospaced for clean number alignment)
- UI: Inter (clean, readable)

## 🚀 Getting Started
```bash
# Clone the repo
git clone <repo-url>
cd tradingview_clone

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 📱 Supported Platforms
- iOS
- Android

## 🔌 Connecting Real Data
Replace mock data in `MockDataGenerator` with real API calls:
1. Configure `ApiClient` with your broker/data provider base URL
2. Implement the repository interfaces in `/data/repositories/`
3. Update datasources in `/data/datasources/` to call real endpoints
4. Register providers in `service_locator.dart`

Popular data providers:
- Alpha Vantage (free tier)
- Polygon.io
- Finnhub
- Yahoo Finance (unofficial)
- Alpaca (for trading)
