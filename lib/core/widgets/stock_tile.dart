import 'package:chartview/core/utils/extensions/double_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/market/domain/entities/stock_entity.dart';
import '../constants/app_colors.dart';

class StockTile extends StatelessWidget {
  final StockEntity stock;
  final VoidCallback? onTap;
  final bool showVolume;
  final VoidCallback? onLongPress;

  const StockTile({
    super.key,
    required this.stock,
    this.onTap,
    this.showVolume = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = stock.isBullish;
    final changeColor = isPositive ? AppColors.bullish : AppColors.bearish;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _SymbolAvatar(symbol: stock.symbol, type: stock.type),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.symbol,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    stock.name,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stock.price.formatPrice(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${stock.changePercent.formatChange()} (${stock.change})",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: changeColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SymbolAvatar extends StatelessWidget {
  final String symbol;
  final String type;

  const _SymbolAvatar({required this.symbol, required this.type});

  Color get _bgColor {
    switch (type) {
      case 'crypto':
        return AppColors.card;
      case 'index':
        return const Color(0xFF1B5E20);
      default:
        return AppColors.card;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Center(
        child: Text(
          symbol.length > 3 ? symbol.substring(0, 3) : symbol,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
