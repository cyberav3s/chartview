// ignore_for_file: deprecated_member_use

import 'package:chartview/core/utils/extensions/double_extension.dart';
import 'package:chartview/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../chart/presentation/pages/chart_page.dart';
import '../../domain/entities/position_entity.dart';
import '../bloc/positions_bloc.dart';
import '../widgets/pnl_card.dart';
import '../widgets/position_tile.dart';

class PositionsPage extends StatefulWidget {
  const PositionsPage({super.key});

  @override
  State<PositionsPage> createState() => _PositionsPageState();
}

class _PositionsPageState extends State<PositionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<PositionsBloc>().add(LoadPositionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PositionsBloc, PositionsState>(
      listener: _onStateChange,
      builder: (ctx, state) {
        if (state is PositionsInitial) {
          return AppLoader();
        }
        if (state is PositionsLoaded) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              titleSpacing: 16,
              title: Text(
                'Positions',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              actions: [
                BlocBuilder<PositionsBloc, PositionsState>(
                  builder: (ctx, state) {
                    if (state is! PositionsLoaded) return const SizedBox();
                    return IconButton(
                      onPressed: () => _showAddPositionSheet(ctx, state),
                      icon: Icon(Icons.add, color: AppColors.textSecondary),
                    );
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(130),
                child: PNLCard(state: state),
              ),
            ),
            body: _buildBody(ctx, state),
          );
        }
        return const SizedBox();
      },
    );
  }

  void _onStateChange(BuildContext ctx, PositionsState state) {
    if (state is PositionsLoaded && state.recentlyClosed != null) {
      final p = state.recentlyClosed!;
      final isPos = p.isProfit;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            children: [
              Icon(
                isPos ? Icons.trending_up : Icons.trending_down,
                color: isPos ? AppColors.bullish : AppColors.bearish,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${p.symbol} position closed',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'P&L: ${isPos ? '+' : ''}\$${p.unrealizedPnL.formatChange()} '
                      '(${isPos ? '+' : ''}${p.unrealizedPnLPercent.toStringAsFixed(2)}%)',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: isPos ? AppColors.bullish : AppColors.bearish,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildBody(BuildContext ctx, PositionsLoaded state) {
    if (state.positions.isEmpty) return Container();

    final sorted = state.sortedPositions;

    return RefreshIndicator(
      color: AppColors.white,
      backgroundColor: AppColors.surface,
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        ctx.read<PositionsBloc>().add(LoadPositionsEvent());
        await Future.delayed(const Duration(milliseconds: 600));
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'OPEN POSITIONS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${state.positions.length}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Swipe left to close',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((_, i) {
              final pos = sorted[i];
              return PositionTile(
                key: ValueKey(pos.id),
                position: pos,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChartPage(
                      symbol: pos.symbol,
                      name: pos.name,
                      price: pos.currentPrice,
                      changePercent: pos.unrealizedPnLPercent,
                    ),
                  ),
                ),
                onClose: () =>
                    ctx.read<PositionsBloc>().add(ClosePositionEvent(pos.id)),
              );
            }, childCount: sorted.length),
          ),
        ],
      ),
    );
  }

  void _showAddPositionSheet(BuildContext ctx, PositionsLoaded state) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (sheetCtx) => _AddPositionSheet(
        onAdd: (pos) {
          ctx.read<PositionsBloc>().add(AddPositionEvent(pos));
          Navigator.pop(sheetCtx);
        },
      ),
    );
  }
}

class _AddPositionSheet extends StatefulWidget {
  final void Function(PositionEntity) onAdd;
  const _AddPositionSheet({required this.onAdd});

  @override
  State<_AddPositionSheet> createState() => _AddPositionSheetState();
}

class _AddPositionSheetState extends State<_AddPositionSheet> {
  final _symbolCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  PositionSide _side = PositionSide.long;

  @override
  void dispose() {
    _symbolCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final sym = _symbolCtrl.text.trim().toUpperCase();
    final qty = double.tryParse(_qtyCtrl.text.trim());
    final price = double.tryParse(_priceCtrl.text.trim());

    if (sym.isEmpty || qty == null || qty <= 0 || price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields with valid values'),
          backgroundColor: AppColors.bearish,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final pos = PositionEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      symbol: sym,
      name: sym,
      type: 'stock',
      side: _side,
      quantity: qty,
      avgEntryPrice: price,
      currentPrice: price,
      openedAt: DateTime.now(),
    );
    widget.onAdd(pos);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add Position',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Side toggle
          Row(
            children: [
              Expanded(
                child: _SideButton(
                  label: 'LONG',
                  color: AppColors.bullish,
                  selected: _side == PositionSide.long,
                  onTap: () => setState(() => _side = PositionSide.long),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SideButton(
                  label: 'SHORT',
                  color: AppColors.bearish,
                  selected: _side == PositionSide.short,
                  onTap: () => setState(() => _side = PositionSide.short),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _Field(
            ctrl: _symbolCtrl,
            label: 'Symbol',
            hint: 'e.g. AAPL',
            caps: TextCapitalization.characters,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Field(
                  ctrl: _qtyCtrl,
                  label: 'Quantity',
                  hint: 'e.g. 10',
                  inputType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Field(
                  ctrl: _priceCtrl,
                  label: 'Avg Entry Price',
                  hint: 'e.g. 182.50',
                  inputType: TextInputType.number,
                  prefix: '\$',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Add Position',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _SideButton({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(vertical: 11),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.18) : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? color : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: selected ? color : AppColors.textSecondary,
        ),
      ),
    ),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final TextInputType inputType;
  final TextCapitalization caps;
  final String? prefix;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.inputType = TextInputType.text,
    this.caps = TextCapitalization.none,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    keyboardType: inputType,
    textCapitalization: caps,
    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      labelStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
      hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
      prefixStyle: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.textSecondary,
      ),
      filled: true,
      fillColor: AppColors.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primary.withOpacity(0.7),
          width: 1.5,
        ),
      ),
    ),
  );
}
