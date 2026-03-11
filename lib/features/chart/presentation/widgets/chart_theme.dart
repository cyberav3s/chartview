import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

abstract final class ChartTheme {
  static TextStyle mono(double size, {Color color = AppColors.textPrimary, FontWeight weight = FontWeight.w500}) =>
      GoogleFonts.inter(fontSize: size, color: color, fontWeight: weight);

  static TextStyle sans(double size, {Color color = AppColors.textPrimary, FontWeight weight = FontWeight.w500, double? letterSpacing}) =>
      GoogleFonts.inter(fontSize: size, color: color, fontWeight: weight, letterSpacing: letterSpacing);

  static const _sheetShape = RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(14)));

  static Future<T?> showSheet<T>(BuildContext context, Widget child, {bool scrollControlled = false}) =>
      showModalBottomSheet<T>(
        context: context,
        backgroundColor: AppColors.surface,
        isScrollControlled: scrollControlled,
        shape: _sheetShape,
        builder: (_) => child,
      );

  static InputDecoration inputDecoration(String label, {String? prefix}) => InputDecoration(
    labelText: label,
    labelStyle: sans(13, color: AppColors.textMuted),
    prefixText: prefix,
    prefixStyle: sans(13, color: AppColors.textMuted),
    filled: true,
    fillColor: AppColors.surfaceVariant,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
  );
}
