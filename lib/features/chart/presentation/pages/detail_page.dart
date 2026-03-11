import 'package:chartview/core/utils/extensions/double_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/chart_bloc.dart';
import '../widgets/chart_painter.dart';
import '../../../../core/constants/app_colors.dart';

class ChartDetailPage extends StatefulWidget {
  final String symbol;
  final String name;
  final double price;
  final double changePercent;

  const ChartDetailPage({
    super.key,
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
  });

  @override
  State<ChartDetailPage> createState() => _ChartDetailPageState();
}

class _ChartDetailPageState extends State<ChartDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChartBloc>().add(
      LoadChartData(symbol: widget.symbol, startPrice: widget.price),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.changePercent >= 0;
    final changeColor = isPositive ? AppColors.bullish : AppColors.bearish;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.symbol,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              widget.name,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.share,
              color: AppColors.textSecondary,
              weight: 500,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.price.formatPrice(),
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -1,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: changeColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.changePercent.formatChange(),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: changeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Today',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    _ActionButton(
                      label: 'Buy',
                      color: AppColors.bullish,
                      onTap: () => _showTradeSheet(context, 'buy'),
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      label: 'Sell',
                      color: AppColors.bearish,
                      onTap: () => _showTradeSheet(context, 'sell'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          BlocBuilder<ChartBloc, ChartState>(
            builder: (context, state) {
              final interval = state is ChartLoaded ? state.interval : '1D';
              final chartType = state is ChartLoaded
                  ? state.chartType
                  : 'candlestick';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children:
                          ['1m', '5m', '15m', '1H', '4H', '1D', '1W', '1M']
                              .map(
                                (i) => _IntervalButton(
                                  label: i,
                                  isSelected: i == interval,
                                  onTap: () => context.read<ChartBloc>().add(
                                    ChangeInterval(i),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        for (final type in [
                          ('candlestick', Icons.candlestick_chart),
                          ('line', Icons.show_chart),
                          ('bar', Icons.bar_chart),
                        ])
                          _ChartTypeButton(
                            icon: type.$2,
                            label: type.$1,
                            isSelected: type.$1 == chartType,
                            onTap: () => context.read<ChartBloc>().add(
                              ChangeChartType(type.$1),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          BlocBuilder<ChartBloc, ChartState>(
            builder: (context, state) {
              if (state is ChartLoading) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              if (state is ChartLoaded) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRect(
                      child: state.chartType == 'line'
                          ? CustomPaint(
                              painter: LinePainter(candles: state.candles),
                              size: Size.infinite,
                            )
                          : CustomPaint(
                              painter: CandlestickPainter(
                                candles: state.candles,
                              ),
                              size: Size.infinite,
                            ),
                    ),
                  ),
                );
              }
              return const Expanded(child: SizedBox());
            },
          ),
          BlocBuilder<ChartBloc, ChartState>(
            builder: (context, state) {
              final active = state is ChartLoaded
                  ? state.activeIndicators
                  : <String>[];
              return Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['MA', 'EMA', 'RSI', 'MACD', 'BB', 'VWAP'].map((
                    ind,
                  ) {
                    final isActive = active.contains(ind);
                    return GestureDetector(
                      onTap: () =>
                          context.read<ChartBloc>().add(ToggleIndicator(ind)),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary.withAlpha(20)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          ind,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          BlocBuilder<ChartBloc, ChartState>(
            builder: (context, state) {
              if (state is! ChartLoaded || state.candles.isEmpty) {
                return const SizedBox();
              }
              final last = state.candles.last;
              return Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _OHLCVItem(label: 'Open', value: last.open.toStringAsFixed(2)),
                    _OHLCVItem(
                      label: 'High',
                      value: last.high.toStringAsFixed(2),
                      color: AppColors.bullish,
                    ),
                    _OHLCVItem(
                      label: 'Low',
                      value: last.low.toStringAsFixed(2),
                      color: AppColors.bearish,
                    ),
                    _OHLCVItem(
                      label: 'Close',
                      value: last.close.toStringAsFixed(2),
                    ),
                    _OHLCVItem(
                      label: 'Volume',
                      value: last.volume.formatVolume(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showTradeSheet(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) =>
          _TradeSheet(symbol: widget.symbol, price: widget.price, type: type),
    );
  }
}

class _IntervalButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _IntervalButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _ChartTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _ChartTypeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? AppColors.primary : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _OHLCVItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _OHLCVItem({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _TradeSheet extends StatefulWidget {
  final String symbol;
  final double price;
  final String type;
  const _TradeSheet({
    required this.symbol,
    required this.price,
    required this.type,
  });

  @override
  State<_TradeSheet> createState() => _TradeSheetState();
}

class _TradeSheetState extends State<_TradeSheet> {
  int _shares = 1;

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.type == 'buy';
    final color = isPositive ? AppColors.bullish : AppColors.bearish;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${widget.type.toUpperCase()} ${widget.symbol}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text(
                      'Shares',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(
                            () => _shares = (_shares - 1).clamp(1, 999),
                          ),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: AppColors.textPrimary,
                              size: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '$_shares',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _shares++),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColors.textPrimary,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Est. Amount',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${(widget.price * _shares).toStringAsFixed(2)}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Order placed: ${widget.type.toUpperCase()} $_shares ${widget.symbol} @ \$${widget.price.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(fontSize: 13),
                    ),
                    backgroundColor: color,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Place ${widget.type.toUpperCase()} Order',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
