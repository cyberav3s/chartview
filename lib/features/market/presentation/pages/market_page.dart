import 'package:chartview/core/widgets/app_tabbar.dart';
import 'package:chartview/features/chart/presentation/pages/chart_view_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../bloc/market_bloc.dart';
import '../../../../core/widgets/stock_tile.dart';
import '../../domain/entities/stock_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../chart/presentation/pages/chart_page.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _activeTabIndex = 0;
  final _searchController = TextEditingController();
  bool _isSearching = false;

  static const _tabs = [
    AppTabbarItem(id: 'all', label: 'All'),
    AppTabbarItem(id: 'gainers', label: 'Gainers'),
    AppTabbarItem(id: 'losers', label: 'Losers'),
    AppTabbarItem(id: 'active', label: 'Active'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    context.read<MarketBloc>().add(LoadMarketData());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() => _activeTabIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onReorder(int oldIndex, int newIndex) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: AppColors.background,
            title: _isSearching
                ? _SearchBar(
                    controller: _searchController,
                    onChanged: (q) =>
                        context.read<MarketBloc>().add(SearchStocks(q)),
                    onClose: () {
                      setState(() => _isSearching = false);
                      _searchController.clear();
                      context.read<MarketBloc>().add(LoadMarketData());
                    },
                  )
                : Row(
                    children: [
                      Text(
                        'Markets',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bullish.withAlpha(15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Symbols.trending_up,
                              size: 10,
                              color: AppColors.bullish,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'LIVE',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: AppColors.bullish,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            actions: [
              if (!_isSearching) ...[
                IconButton(
                  icon: const Icon(Symbols.search, color: AppColors.textSecondary),
                  onPressed: () => setState(() => _isSearching = true),
                ),
                IconButton(
                  icon: const Icon(Symbols.refresh, color: AppColors.textSecondary),
                  onPressed: () =>
                      context.read<MarketBloc>().add(RefreshMarketData()),
                ),
              ],
            ],
            bottom: _isSearching
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(44),
                    child: AppTabbar(
                      tabs: _tabs,
                      activeIndex: _activeTabIndex,
                      onTabChanged: _onTabChanged,
                      onReorder: _onReorder,
                      onTabLongPress: (_) {},
                    ),
                  ),
          ),
        ],
        body: BlocBuilder<MarketBloc, MarketState>(
          builder: (context, state) {
            if (state is MarketLoading) {
              return const _LoadingList();
            }
            if (state is MarketSearchResult) {
              return _StockList(
                stocks: state.results,
                emptyMessage: 'No results for "${state.query}"',
              );
            }
            if (state is MarketLoaded) {
              return PageView(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _activeTabIndex = index),
                children: [
                  _StockList(stocks: state.stocks, showVolume: true),
                  _StockList(
                    stocks: state.topGainers,
                    emptyMessage: 'No gainers today',
                  ),
                  _StockList(
                    stocks: state.topLosers,
                    emptyMessage: 'No losers today',
                  ),
                  _StockList(stocks: state.mostActive, showVolume: true),
                ],
              );
            }
            return const _LoadingList();
          },
        ),
      ),
    );
  }
}

class _StockList extends StatelessWidget {
  final List<StockEntity> stocks;
  final String? emptyMessage;
  final bool showVolume;

  const _StockList({
    required this.stocks,
    this.emptyMessage,
    this.showVolume = false,
  });

  @override
  Widget build(BuildContext context) {
    if (stocks.isEmpty) {
      return Center(
        child: Text(
          emptyMessage ?? 'No data',
          style: GoogleFonts.inter(color: AppColors.textMuted),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: stocks.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.border),
      itemBuilder: (context, i) => StockTile(
        stock: stocks[i],
        showVolume: showVolume,
        onLongPress: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChartViewPage(
              symbol: stocks[i].symbol,
              name: stocks[i].name,
              price: stocks[i].price,
              changePercent: stocks[i].changePercent,
            ),
          ),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChartPage(
              symbol: stocks[i].symbol,
              name: stocks[i].name,
              price: stocks[i].price,
              changePercent: stocks[i].changePercent,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 12,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.border),
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: 60,
                    color: AppColors.surfaceVariant,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    width: 120,
                    color: AppColors.surfaceVariant,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 12,
                  width: 60,
                  color: AppColors.surfaceVariant,
                ),
                const SizedBox(height: 6),
                Container(
                  height: 18,
                  width: 50,
                  color: AppColors.surfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      onChanged: onChanged,
      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search symbols, companies...',
        prefixIcon: Icon(
          Symbols.search,
          color: AppColors.textSecondary,
          size: 22,
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(
            Symbols.close,
            color: AppColors.textSecondary,
            size: 22,
          ),
          onPressed: onClose,
        ),
      ),
    );
  }
}