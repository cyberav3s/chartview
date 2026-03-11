// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import 'chart_theme.dart';

class ChartIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final String tooltip;
  final VoidCallback? onTap;

  const ChartIcon({
    super.key,
    required this.icon,
    this.active = false,
    this.tooltip = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 22,
        weight: 600,
        color: onTap == null
            ? AppColors.textMuted
            : active
            ? AppColors.primary
            : AppColors.textSecondary,
      ),
    ),
  );
}

class PriceActionBox extends StatelessWidget {
  final String label;
  final double price;
  final Color color;

  const PriceActionBox({
    super.key,
    required this.label,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.14),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withOpacity(0.5)),
    ),
    child: Text(
      label,
      style: ChartTheme.sans(10, color: color, weight: FontWeight.w700),
    ),
  );
}

class IntervalChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const IntervalChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: ChartTheme.sans(
          12,
          color: selected ? Colors.white : AppColors.textMuted,
          weight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    ),
  );
}

class ChartTypeButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const ChartTypeButton({
    super.key,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Icon(
        icon,
        size: 20,
        color: selected ? AppColors.primary : AppColors.textMuted,
      ),
    ),
  );
}

class OHLCItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const OHLCItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 9),
    child: RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: ChartTheme.sans(10, color: AppColors.textMuted),
          ),
          TextSpan(
            text: value.toStringAsFixed(2),
            style: ChartTheme.mono(10, color: color, weight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}

class SheetHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SheetHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(title, style: ChartTheme.sans(15, weight: FontWeight.w700)),
            const Spacer(),
            ?trailing,
          ],
        ),
      ),
      const Divider(height: 1, color: AppColors.border),
    ],
  );
}

class SheetSectionLabel extends StatelessWidget {
  final String label;

  const SheetSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: ChartTheme.sans(
          10,
          color: AppColors.textMuted,
          letterSpacing: 1.0,
        ),
      ),
    ),
  );
}

class IndicatorCheckTile extends StatelessWidget {
  final String label;
  final Color dotColor;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const IndicatorCheckTile({
    super.key,
    required this.label,
    required this.dotColor,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    value: value,
    onChanged: onChanged,
    title: Text(label, style: ChartTheme.sans(13)),
    secondary: Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
    ),
    activeColor: AppColors.primary,
    checkColor: Colors.white,
    dense: true,
  );
}

class ColoredPctButton extends StatelessWidget {
  final double pct;
  final VoidCallback onTap;

  const ColoredPctButton({super.key, required this.pct, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPos = pct >= 0;
    final color = isPos ? AppColors.bullish : AppColors.bearish;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${isPos ? '+' : ''}${pct.toInt()}%',
            textAlign: TextAlign.center,
            style: ChartTheme.sans(11, color: color, weight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
