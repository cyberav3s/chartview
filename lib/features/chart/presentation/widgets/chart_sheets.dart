import 'package:chartview/core/utils/enums.dart';
import 'package:chartview/core/utils/extensions/double_extension.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import 'chart_components.dart';
import 'chart_theme.dart';

const _kSymbols = [
  ('NIFTY', 'Nifty 50 Index', 24849.75, -1.24),
  ('BANKNF', 'Bank Nifty', 52310.40, -0.87),
  ('AAPL', 'Apple Inc.', 182.50, 0.85),
  ('TSLA', 'Tesla Inc.', 238.40, -1.24),
  ('NVDA', 'NVIDIA Corp.', 875.40, 3.21),
  ('BTC', 'Bitcoin USD', 67420.00, 2.54),
  ('ETH', 'Ethereum USD', 3540.00, 1.87),
  ('GOOGL', 'Alphabet Inc.', 141.20, 0.63),
];

typedef SymbolRecord = (String, String, double, double);

class SymbolSwitcherSheet extends StatelessWidget {
  final String currentSymbol;
  final void Function(SymbolRecord) onSelect;

  const SymbolSwitcherSheet({
    super.key,
    required this.currentSymbol,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetHeader(title: 'Switch Symbol'),
          for (final s in _kSymbols)
            ListTile(
              title: Text(
                s.$1,
                style: ChartTheme.mono(13, weight: FontWeight.w700),
              ),
              subtitle: Text(
                s.$2,
                style: ChartTheme.sans(11, color: AppColors.textMuted),
              ),
              trailing: Text(
                s.$4.formatChange(),
                style: ChartTheme.mono(
                  12,
                  color: s.$4 >= 0 ? AppColors.bullish : AppColors.bearish,
                  weight: FontWeight.w600,
                ),
              ),
              selected: s.$1 == currentSymbol,
              selectedTileColor: AppColors.primary.withAlpha(08),
              onTap: () {
                Navigator.pop(context);
                onSelect(s);
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

class DrawingToolSheet extends StatelessWidget {
  final DrawingTool activeTool;
  final bool hasDrawings;
  final void Function(DrawingTool) onSelect;
  final VoidCallback onClearAll;

  const DrawingToolSheet({
    super.key,
    required this.activeTool,
    required this.hasDrawings,
    required this.onSelect,
    required this.onClearAll,
  });

  static const _tools = [
    (DrawingTool.horizontalLine, Icons.horizontal_rule, 'Horizontal Line'),
    (DrawingTool.horizontalRay, Icons.trending_flat, 'Horizontal Ray'),
    (DrawingTool.trendLine, Icons.trending_up, 'Trend Line'),
    (
      DrawingTool.fibonacci,
      Icons.format_list_numbered,
      'Fibonacci Retracement',
    ),
    (DrawingTool.rectangle, Icons.crop_square, 'Rectangle'),
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(
            title: 'Drawing Tools',
            trailing: hasDrawings
                ? TextButton(
                    onPressed: () {
                      onClearAll();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Clear all',
                      style: ChartTheme.sans(12, color: AppColors.bearish),
                    ),
                  )
                : null,
          ),
          for (final t in _tools)
            ListTile(
              leading: Icon(
                t.$2,
                color: activeTool == t.$1
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              title: Text(t.$3, style: ChartTheme.sans(13)),
              selected: activeTool == t.$1,
              selectedTileColor: AppColors.primary.withAlpha(08),
              onTap: () {
                onSelect(t.$1);
                Navigator.pop(context);
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

class IndicatorSheet extends StatefulWidget {
  final List<String> activeIndicators;
  final bool showRsi;
  final bool showMacd;
  final void Function(List<String> indicators, bool rsi, bool macd) onChanged;

  const IndicatorSheet({
    super.key,
    required this.activeIndicators,
    required this.showRsi,
    required this.showMacd,
    required this.onChanged,
  });

  @override
  State<IndicatorSheet> createState() => _IndicatorSheetState();
}

class _IndicatorSheetState extends State<IndicatorSheet> {
  late final List<String> _indicators;
  late bool _rsi;
  late bool _macd;

  static const _overlays = [
    ('MA', 'Moving Average (20)', AppColors.warning),
    ('EMA', 'EMA (14)', Color(0xFF9C27B0)),
    ('BB', 'Bollinger Bands (20)', Color(0xFFFF7043)),
    ('VWAP', 'VWAP', Color(0xFF26C6DA)),
  ];

  @override
  void initState() {
    super.initState();
    _indicators = List.from(widget.activeIndicators);
    _rsi = widget.showRsi;
    _macd = widget.showMacd;
  }

  void _notify() => widget.onChanged(_indicators, _rsi, _macd);

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(
            title: 'Indicators',
            trailing: TextButton(
              onPressed: () {
                setState(() {
                  _indicators.clear();
                  _rsi = false;
                  _macd = false;
                });
                _notify();
              },
              child: Text(
                'Clear all',
                style: ChartTheme.sans(12, color: AppColors.bearish),
              ),
            ),
          ),
          const SheetSectionLabel(label: 'OVERLAYS'),
          for (final ind in _overlays)
            IndicatorCheckTile(
              label: ind.$2,
              dotColor: ind.$3,
              value: _indicators.contains(ind.$1),
              onChanged: (v) {
                setState(
                  () =>
                      v! ? _indicators.add(ind.$1) : _indicators.remove(ind.$1),
                );
                _notify();
              },
            ),
          const Divider(),
          const SheetSectionLabel(label: 'SUB-PANELS'),
          IndicatorCheckTile(
            label: 'RSI (14)',
            dotColor: const Color(0xFF29B6F6),
            value: _rsi,
            onChanged: (v) {
              setState(() => _rsi = v!);
              _notify();
            },
          ),
          IndicatorCheckTile(
            label: 'MACD (12,26,9)',
            dotColor: const Color(0xFF2962FF),
            value: _macd,
            onChanged: (v) {
              setState(() => _macd = v!);
              _notify();
            },
          ),
        ],
      ),
    ),
  );
}

class AlertDialog extends StatefulWidget {
  final double currentPrice;
  final void Function(double price, String label) onSet;

  const AlertDialog({
    super.key,
    required this.currentPrice,
    required this.onSet,
  });

  @override
  State<AlertDialog> createState() => _AlertDialogState();
}

class _AlertDialogState extends State<AlertDialog> {
  late final TextEditingController _priceCtrl;
  final _labelCtrl = TextEditingController(text: 'Alert');

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController(
      text: widget.currentPrice.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  void _applyPct(double pct) => _priceCtrl.text =
      (widget.currentPrice * (1 + pct / 100)).toStringAsFixed(2);

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Set Price Alert',
              style: ChartTheme.sans(16, weight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelCtrl,
              style: ChartTheme.sans(13),
              decoration: ChartTheme.inputDecoration('Label'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: ChartTheme.mono(16),
              decoration: ChartTheme.inputDecoration('Price', prefix: '₹ '),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final pct in [-2.0, -1.0, 1.0, 2.0])
                  ColoredPctButton(pct: pct, onTap: () => _applyPct(pct)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: ChartTheme.sans(13, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final p = double.tryParse(_priceCtrl.text);
                    if (p != null) {
                      widget.onSet(p, _labelCtrl.text);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Set Alert',
                    style: ChartTheme.sans(
                      13,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
