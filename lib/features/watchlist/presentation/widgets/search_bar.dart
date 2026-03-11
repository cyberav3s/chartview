import 'package:chartview/features/market/domain/entities/stock_entity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/mock_data_generator.dart';
import '../../domain/entities/watchlist.dart';

class WatchlistSearchBar extends StatefulWidget {
  final List<ListSection> sections;
  final void Function(String symbol, String sectionId) onAdd;

  const WatchlistSearchBar({
    super.key,
    required this.sections,
    required this.onAdd,
  });

  @override
  State<WatchlistSearchBar> createState() => _WatchlistSearchBarState();
}

class _WatchlistSearchBarState extends State<WatchlistSearchBar>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  late final AnimationController _anim;
  late final Animation<double> _heightAnim;

  bool _expanded = false;
  List<StockEntity> _results = [];
  final _allStocks = MockDataGenerator.generateStocks();

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _heightAnim = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() => _expanded = true);
    _anim.forward();
    _focus.requestFocus();
  }

  void _collapse() {
    _ctrl.clear();
    _focus.unfocus();
    setState(() { _expanded = false; _results = []; });
    _anim.reverse();
  }

  void _onQuery(String q) {
    final trimmed = q.trim().toUpperCase();
    if (trimmed.isEmpty) { setState(() => _results = []); return; }
    setState(() {
      _results = _allStocks
          .where((s) => s.symbol.contains(trimmed) || s.name.toUpperCase().contains(trimmed))
          .take(8)
          .toList();
    });
  }

  void _pickSection(String symbol) {
    if (widget.sections.length == 1) {
      widget.onAdd(symbol, widget.sections.first.id);
      _collapse();
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text('Add $symbol to section',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ),
          const Divider(height: 1, color: AppColors.border),
          for (final sec in widget.sections)
            ListTile(
              leading: const Icon(Icons.folder_outlined, color: AppColors.textSecondary, size: 18),
              title: Text(sec.name, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary)),
              trailing: Text('${sec.symbols.length}',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
              onTap: () {
                Navigator.pop(context);
                widget.onAdd(symbol, sec.id);
                _collapse();
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
          child: Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: _expanded ? null : _expand,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _expanded ? AppColors.primary.withOpacity(0.6) : AppColors.border,
                    ),
                  ),
                  child: Row(children: [
                    const SizedBox(width: 10),
                    const Icon(Icons.search, color: AppColors.textMuted, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _expanded
                          ? TextField(
                              controller: _ctrl,
                              focusNode: _focus,
                              onChanged: _onQuery,
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Search symbol or name...',
                                hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            )
                          : Text('Search symbol or name...',
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
                    ),
                  ]),
                ),
              ),
            ),
            if (_expanded) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _collapse,
                child: Text('Cancel',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ]),
        ),
        SizeTransition(
          sizeFactor: _heightAnim,
          child: _results.isEmpty
              ? const SizedBox()
              : Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < _results.length; i++) ...[
                        if (i > 0) const Divider(height: 1, color: AppColors.border),
                        _SearchResult(
                          stock: _results[i],
                          onTap: () => _pickSection(_results[i].symbol),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
        if (_expanded && _results.isNotEmpty) const SizedBox(height: 4),
      ],
    );
  }
}

class _SearchResult extends StatelessWidget {
  final StockEntity stock;
  final VoidCallback onTap;
  const _SearchResult({required this.stock, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPos = stock.changePercent >= 0;
    final color = isPos ? AppColors.bullish : AppColors.bearish;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(stock.symbol.substring(0, stock.symbol.length.clamp(0, 3)),
                style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(stock.symbol, style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text(stock.name, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(stock.price.toStringAsFixed(2),
                style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text('${isPos ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: color)),
          ]),
          const SizedBox(width: 4),
          const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primary),
        ]),
      ),
    );
  }
}
