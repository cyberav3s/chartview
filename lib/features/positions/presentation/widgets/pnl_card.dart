import 'package:chartview/core/utils/extensions/double_extension.dart';
import 'package:chartview/core/widgets/gap.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/positions_bloc.dart';

class PNLCard extends StatelessWidget {
  final PositionsLoaded state;
  const PNLCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final pnl = state.totalPnL;
    final pnlPct = state.totalPnLPercent;
    final isPos = pnl >= 0;
    final pnlColor = isPos ? AppColors.bullish : AppColors.bearish;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    'Unrealized P&L',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 8,
                    children: [
                      Text(
                        '${isPos ? '+' : ''}\$${pnl.formatPrice()}',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: pnlColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: pnlColor.withAlpha(15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '${isPos ? '+' : ''}${pnlPct.toStringAsFixed(2)}%',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: pnlColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Gap.v(12),
          const Divider(color: AppColors.border),
          const Gap.v(12),
          Row(
            children: [
              _Stat(
                label: 'Portfolio Value',
                value: '\$${state.totalValue.formatPrice()}',
              ),
              _VertDivider(),
              _Stat(
                label: 'Cost Basis',
                value: '\$${state.totalCost.formatPrice()}',
              ),
              _VertDivider(),
              _Stat(
                label: 'Positions',
                value: '${state.positions.length}',
                sub: '${state.winnersCount}W / ${state.losersCount}L',
                subColor: state.winnersCount >= state.losersCount
                    ? AppColors.bullish
                    : AppColors.bearish,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final String? sub;
  final Color? subColor;
  const _Stat({
    required this.label,
    required this.value,
    this.sub,
    this.subColor,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: AppColors.textMuted,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (sub != null)
          Text(
            sub!,
            style: GoogleFonts.inter(
              fontSize: 8,
              color: subColor ?? AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    ),
  );
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 36,
    color: AppColors.border,
    margin: const EdgeInsets.symmetric(horizontal: 12),
  );
}
