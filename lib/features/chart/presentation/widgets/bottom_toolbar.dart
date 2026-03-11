import 'package:chartview/core/constants/app_colors.dart';
import 'package:chartview/core/utils/enums.dart';
import 'package:chartview/features/chart/presentation/bloc/chart_bloc.dart';
import 'package:chartview/features/chart/presentation/widgets/chart_components.dart';
import 'package:chartview/features/chart/presentation/widgets/chart_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

const _intervals = ['1m', '5m', '15m', '1H', '4H', '1D', '1W', '1M'];

const _chartTypes = [
  ('candlestick', Symbols.candlestick_chart),
  ('line', Symbols.show_chart),
  ('bar', Symbols.bar_chart),
];

class BottomToolbar extends StatelessWidget {
  final String symbol;
  final String chartType;
  final DrawingTool tool;
  final bool hasIndicators;
  final bool canUndo;
  final bool canRedo;
  final bool fullscreen;
  final VoidCallback onSymbolTap;
  final VoidCallback onDrawingTap;
  final VoidCallback onIndicatorTap;
  final VoidCallback onUndoTap;
  final VoidCallback onRedoTap;
  final VoidCallback onFullscreenTap;
  final ValueChanged<String> onChartTypeTap;

  const BottomToolbar({
    super.key,
    required this.symbol,
    required this.chartType,
    required this.tool,
    required this.hasIndicators,
    required this.canUndo,
    required this.canRedo,
    required this.fullscreen,
    required this.onSymbolTap,
    required this.onDrawingTap,
    required this.onIndicatorTap,
    required this.onUndoTap,
    required this.onRedoTap,
    required this.onFullscreenTap,
    required this.onChartTypeTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: AppColors.black),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IntervalRow(chartType: chartType, onChartTypeTap: onChartTypeTap),
        _ActionsRow(
          symbol: symbol,
          tool: tool,
          hasIndicators: hasIndicators,
          canUndo: canUndo,
          canRedo: canRedo,
          fullscreen: fullscreen,
          onSymbolTap: onSymbolTap,
          onDrawingTap: onDrawingTap,
          onIndicatorTap: onIndicatorTap,
          onUndoTap: onUndoTap,
          onRedoTap: onRedoTap,
          onFullscreenTap: onFullscreenTap,
        ),
      ],
    ),
  );
}

class _IntervalRow extends StatelessWidget {
  final String chartType;
  final ValueChanged<String> onChartTypeTap;

  const _IntervalRow({required this.chartType, required this.onChartTypeTap});

  @override
  Widget build(BuildContext context) => BlocBuilder<ChartBloc, ChartState>(
    builder: (ctx, state) {
      final current = state is ChartLoaded ? state.interval : '15m';
      return SizedBox(
        height: 44,
        child: Row(
          children: [
            for (final label in _intervals)
              IntervalChip(
                label: label,
                selected: label == current,
                onTap: () => ctx.read<ChartBloc>().add(ChangeInterval(label)),
              ),
            const Spacer(),
            for (final entry in _chartTypes)
              ChartTypeButton(
                icon: entry.$2,
                selected: chartType == entry.$1,
                onTap: () {
                  onChartTypeTap(entry.$1);
                  ctx.read<ChartBloc>().add(ChangeChartType(entry.$1));
                },
              ),
            const SizedBox(width: 8),
          ],
        ),
      );
    },
  );
}

class _ActionsRow extends StatelessWidget {
  final String symbol;
  final DrawingTool tool;
  final bool hasIndicators;
  final bool canUndo;
  final bool canRedo;
  final bool fullscreen;
  final VoidCallback onSymbolTap;
  final VoidCallback onDrawingTap;
  final VoidCallback onIndicatorTap;
  final VoidCallback onUndoTap;
  final VoidCallback onRedoTap;
  final VoidCallback onFullscreenTap;

  const _ActionsRow({
    required this.symbol,
    required this.tool,
    required this.hasIndicators,
    required this.canUndo,
    required this.canRedo,
    required this.fullscreen,
    required this.onSymbolTap,
    required this.onDrawingTap,
    required this.onIndicatorTap,
    required this.onUndoTap,
    required this.onRedoTap,
    required this.onFullscreenTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onSymbolTap,
            child: Row(
              spacing: 4,
              children: [
                Text(
                  symbol,
                  style: ChartTheme.sans(16, weight: FontWeight.w700),
                ),
                const Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ),
          const Spacer(),
          ChartIcon(
            icon: Symbols.edit,
            active: tool != DrawingTool.none && tool != DrawingTool.pointer,
            onTap: onDrawingTap,
          ),
          ChartIcon(
            icon: Symbols.toolbar,
            active: hasIndicators,
            onTap: onIndicatorTap,
          ),
          ChartIcon(icon: Symbols.undo, onTap: canUndo ? onUndoTap : null),
          ChartIcon(icon: Symbols.redo, onTap: canRedo ? onRedoTap : null),
          ChartIcon(
            icon: Symbols.crop_free,
            active: fullscreen,
            onTap: onFullscreenTap,
          ),
        ],
      ),
    ),
  );
}
