import 'package:intl/intl.dart';

extension DoubleX on double {
  String formatPrice({int decimals = 2}) {
    if (this >= 1000) return NumberFormat('#,##0.##').format(this);
    return toStringAsFixed(decimals);
  }

  String formatVolume() {
    if (this >= 1e12) return '${(this / 1e12).toStringAsFixed(2)}T';
    if (this >= 1e9) return '${(this / 1e9).toStringAsFixed(2)}B';
    if (this >= 1e6) return '${(this / 1e6).toStringAsFixed(2)}M';
    if (this >= 1e3) return '${(this / 1e3).toStringAsFixed(2)}K';
    return toStringAsFixed(0);
  }

  String formatChange() {
    final sign = this > 0 ? '+' : '';
    return '$sign${toStringAsFixed(2)}%';
  }

  String formatMarketCap() {
    if (this >= 1e12) return '\$${(this / 1e12).toStringAsFixed(2)}T';
    if (this >= 1e9) return '\$${(this / 1e9).toStringAsFixed(2)}B';
    if (this >= 1e6) return '\$${(this / 1e6).toStringAsFixed(2)}M';
    return '\$${toStringAsFixed(0)}';
  }
}