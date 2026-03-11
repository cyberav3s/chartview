import 'package:chartview/core/constants/app_colors.dart';
import 'package:chartview/features/positions/presentation/pages/positions_page.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../market/presentation/pages/market_page.dart';
import '../../../watchlist/presentation/pages/watchlist_page.dart';
import '../../../news/presentation/pages/news_page.dart';
import '../../../account/presentation/pages/account_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    MarketPage(),
    WatchlistPage(),
    PositionsPage(),
    NewsPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        height: 64,
        indicatorColor: Colors.transparent,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Symbols.data_exploration,
              color: _currentIndex == 0 ? AppColors.primary : Colors.grey,
            ),
            label: 'Markets',
          ),
          NavigationDestination(
            icon: Icon(
              Symbols.book,
              color: _currentIndex == 1 ? AppColors.primary : Colors.grey,
            ),
            label: 'Watchlists',
          ),
          NavigationDestination(
            icon: Icon(
              Symbols.service_toolbox,
              color: _currentIndex == 2 ? AppColors.primary : Colors.grey,
            ),
            label: 'Positions',
          ),
          NavigationDestination(
            icon: Icon(
              Symbols.newsstand,
              weight: 600,
              color: _currentIndex == 3 ? AppColors.primary : Colors.grey,
            ),
            label: 'Sentiments',
          ),
          NavigationDestination(
            icon: Icon(
              Symbols.menu,
              color: _currentIndex == 4 ? AppColors.primary : Colors.grey,
            ),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
