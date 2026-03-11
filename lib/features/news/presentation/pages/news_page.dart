import 'package:chartview/core/widgets/app_tabbar.dart';
import 'package:chartview/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/mock_data_generator.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final List<Map<String, dynamic>> _news = [];
  bool _loading = true;
  int _activeTabIndex = 0;

  static const _tabs = [
    AppTabbarItem(id: 'all', label: 'All'),
    AppTabbarItem(id: 'economy', label: 'Economy'),
    AppTabbarItem(id: 'earnings', label: 'Earnings'),
    AppTabbarItem(id: 'crypto', label: 'Crypto'),
    AppTabbarItem(id: 'tech', label: 'Tech'),
    AppTabbarItem(id: 'auto', label: 'Auto'),
  ];

  String get _selectedCategory => _tabs[_activeTabIndex].label;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      _news.addAll(MockDataGenerator.generateNews());
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _news
        : _news.where((n) => n['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'News',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          AppTabbar(
            tabs: _tabs,
            activeIndex: _activeTabIndex,
            onTabChanged: (i) => setState(() => _activeTabIndex = i),
            onReorder: (_, __) {},
            onTabLongPress: (_) {},
          ),
          Expanded(
            child: _loading
                ? const AppLoader()
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _loading = true;
                        _news.clear();
                      });
                      await _loadNews();
                    },
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const Divider(color: AppColors.border),
                      itemBuilder: (context, i) =>
                          _NewsCard(article: filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final Map<String, dynamic> article;

  const _NewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              children: [
                Text(
                  article['source'],
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  article['time'],
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            Text(
              article['title'],
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
            Text(
              article['summary'],
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: (article['tags'] as List<String>)
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#$tag',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
