import 'package:chartview/features/chart/domain/entities/candle.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../../core/constants/app_colors.dart';

class CandlestickPainter extends CustomPainter {
  final List<Candle> candles;
  final double? highlightedIndex;

  CandlestickPainter({required this.candles, this.highlightedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final visibleCandles = candles.length > 80
        ? candles.sublist(candles.length - 80)
        : candles;

    final minLow = visibleCandles.map((c) => c.low).reduce(min);
    final maxHigh = visibleCandles.map((c) => c.high).reduce(max);
    final priceRange = maxHigh - minLow;
    if (priceRange == 0) return;

    final candleWidth = size.width / visibleCandles.length;
    final bodyWidth = (candleWidth * 0.6).clamp(2.0, 12.0);
    final padding = 24.0;
    final chartHeight = size.height - padding * 2;

    double priceToY(double price) =>
        padding + chartHeight - (price - minLow) / priceRange * chartHeight;

    for (int i = 0; i < visibleCandles.length; i++) {
      final c = visibleCandles[i];
      final x = i * candleWidth + candleWidth / 2;
      final color = c.isBullish ? AppColors.bullish : AppColors.bearish;

      final wickPaint = Paint()
        ..color = color.withAlpha(70)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      // Wick
      canvas.drawLine(Offset(x, priceToY(c.high)), Offset(x, priceToY(c.low)), wickPaint);

      // Body
      final bodyTop = priceToY(max(c.open, c.close));
      final bodyBottom = priceToY(min(c.open, c.close));
      final bodyHeight = (bodyBottom - bodyTop).clamp(1.5, double.infinity);

      final bodyPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - bodyWidth / 2, bodyTop, bodyWidth, bodyHeight),
          const Radius.circular(1),
        ),
        bodyPaint,
      );
    }

    // Draw grid lines
    _drawGrid(canvas, size, minLow, maxHigh, priceRange, padding, chartHeight);
  }

  void _drawGrid(Canvas canvas, Size size, double minLow, double maxHigh,
      double priceRange, double padding, double chartHeight) {
    final gridPaint = Paint()
      ..color = AppColors.chartGrid
      ..strokeWidth = 0.5;

    final textStyle = const TextStyle(
      color: AppColors.textMuted, fontSize: 9,
    );

    for (int i = 1; i < 5; i++) {
      final y = padding + chartHeight * (i / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      final price = maxHigh - priceRange * (i / 5);
      final tp = TextPainter(
        text: TextSpan(text: price.toStringAsFixed(2), style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - tp.width - 4, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(CandlestickPainter oldDelegate) =>
      oldDelegate.candles != candles;
}

class LinePainter extends CustomPainter {
  final List<Candle> candles;

  const LinePainter({required this.candles});

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    final visibleCandles = candles.length > 80
        ? candles.sublist(candles.length - 80)
        : candles;

    final minPrice = visibleCandles.map((c) => c.close).reduce(min);
    final maxPrice = visibleCandles.map((c) => c.close).reduce(max);
    final priceRange = maxPrice - minPrice;
    if (priceRange == 0) return;

    final padding = 24.0;
    final chartHeight = size.height - padding * 2;
    final stepX = size.width / (visibleCandles.length - 1);

    double priceToY(double price) =>
        padding + chartHeight - (price - minPrice) / priceRange * chartHeight;

    final path = Path();
    final areaPath = Path();

    for (int i = 0; i < visibleCandles.length; i++) {
      final x = i * stepX;
      final y = priceToY(visibleCandles[i].close);
      if (i == 0) {
        path.moveTo(x, y);
        areaPath.moveTo(x, size.height);
        areaPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        areaPath.lineTo(x, y);
      }
    }

    areaPath.lineTo((visibleCandles.length - 1) * stepX, size.height);
    areaPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.primary.withAlpha(30), AppColors.primary.withAlpha(2)],
    );

    canvas.drawPath(
      areaPath,
      Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => oldDelegate.candles != candles;
}