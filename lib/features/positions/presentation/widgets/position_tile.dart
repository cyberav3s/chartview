import 'package:chartview/core/utils/extensions/double_extension.dart';
import 'package:chartview/core/widgets/tappable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/position_entity.dart';

class PositionTile extends StatelessWidget {
  final PositionEntity position;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const PositionTile({
    super.key,
    required this.position,
    this.onTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final p = position;
    final isPos = p.isProfit;
    final pnlColor = isPos ? AppColors.bullish : AppColors.bearish;

    return Dismissible(
      key: Key(p.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        return await _confirmClose(context);
      },
      onDismissed: (_) => onClose?.call(),
      background: _SwipeCloseBackground(),
      child: Tappable.faded(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Row(
                      spacing: 4,
                      children: [
                        Text(
                          p.symbol,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        _SideChip(side: p.side),
                      ],
                    ),
                    Text(
                      '${_fmtQty(p.quantity)} @ ${p.avgEntryPrice.formatPrice()}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      _daysAgo(p.openedAt),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _AnimatedPrice(
                    price: p.currentPrice,
                    prevColor: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isPos ? '+' : ''}\$${p.unrealizedPnL.formatPrice()}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: pnlColor,
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

  String _fmtQty(double qty) =>
      qty == qty.truncateToDouble() ? qty.toInt().toString() : qty.toString();

  String _daysAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Today';
  }

  Future<bool> _confirmClose(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (_) => _CloseConfirmSheet(position: position),
    );
    return result ?? false;
  }
}

class _SideChip extends StatelessWidget {
  final PositionSide side;
  const _SideChip({required this.side});

  @override
  Widget build(BuildContext context) {
    final isLong = side == PositionSide.long;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: (isLong ? AppColors.bullish : AppColors.bearish).withAlpha(15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        isLong ? 'LONG' : 'SHORT',
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isLong ? AppColors.bullish : AppColors.bearish,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _AnimatedPrice extends StatefulWidget {
  final double price;
  final Color prevColor;
  const _AnimatedPrice({required this.price, required this.prevColor});
  @override
  State<_AnimatedPrice> createState() => _AnimatedPriceState();
}

class _AnimatedPriceState extends State<_AnimatedPrice>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _colorAnim;
  Color _flashColor = AppColors.textPrimary;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _colorAnim = ColorTween(
      begin: AppColors.textPrimary,
      end: AppColors.textPrimary,
    ).animate(_ctrl);
  }

  @override
  void didUpdateWidget(_AnimatedPrice old) {
    super.didUpdateWidget(old);
    if (old.price != widget.price) {
      _flashColor = widget.price > old.price
          ? AppColors.bullish
          : AppColors.bearish;
      _colorAnim = ColorTween(
        begin: _flashColor,
        end: AppColors.textPrimary,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, _) => Text(
      widget.price.formatPrice(),
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: _colorAnim.value ?? AppColors.textPrimary,
      ),
    ),
  );
}

class _SwipeCloseBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.bearish.withAlpha(85),
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.close, color: Colors.white, size: 22),
        const SizedBox(height: 2),
        Text(
          'Close',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

class _CloseConfirmSheet extends StatelessWidget {
  final PositionEntity position;
  const _CloseConfirmSheet({required this.position});

  @override
  Widget build(BuildContext context) {
    final p = position;
    return Padding(
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 20),
          Text(
            'Close Position',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${p.symbol} · ${p.side == PositionSide.long ? 'LONG' : 'SHORT'}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Row2('Qty', _fmtQty(p.quantity)),
                _Row2('Entry', '\$${p.avgEntryPrice.formatPrice()}'),
                _Row2('Exit', '\$${p.currentPrice.formatPrice()}'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bearish,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Close Position',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _fmtQty(double qty) =>
      qty == qty.truncateToDouble() ? qty.toInt().toString() : qty.toString();
}

class _Row2 extends StatelessWidget {
  final String label, value;
  const _Row2(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    ],
  );
}
