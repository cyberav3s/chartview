import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const Color background = Color(0xFF060606);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceVariant = Color(0xFF121212);
  static const Color card = Color(0xFF121212);
  
  // Brand
  static const Color primary = Color(0xFF2962FF);
  static const Color primaryVariant = Color(0xFF1E88E5);
  static const Color accent = Color(0xFF00BCD4);
  
  // Trading Colors
  static const Color bullish = Color(0xFF26A69A);
  static const Color bearish = Color(0xFFEF5350);
  static const Color bullishLight = Color(0xFF1B5E55);
  static const Color bearishLight = Color(0xFF5D2424);
  
  // Text
  static const Color textPrimary = Color(0xFFD1D4DC);
  static const Color textSecondary = Color(0xFF787B86);
  static const Color textMuted = Color(0xFF4C5066);
  
  // Border
  static const Color border = Color(0xFF212121);
  static const Color borderLight = Color(0xFF212121);
  
  // Chart
  static const Color chartGrid = Color(0xFF1F2436);
  static const Color chartCrosshair = Color(0xFF9598A1);
  static const Color volume = Color(0xFF2962FF);
  
  // Gradients
  static const LinearGradient bullishGradient = LinearGradient(
    colors: [Color(0xFF26A69A), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient bearishGradient = LinearGradient(
    colors: [Color(0xFFEF5350), Color(0xFFB71C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2962FF), Color(0xFF1565C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  
  // Status
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFEF5350);
  static const Color success = Color(0xFF26A69A);
  static const Color info = Color(0xFF29B6F6);
}
