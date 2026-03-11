// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'package:chartview/features/chart/domain/entities/candle.dart';
import 'package:chartview/features/chart/domain/entities/drawing.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class ChartLayout {
  static const double priceAxisW = 64.0;
  static const double topPad = 12.0;
  static const double bottomPad = 8.0;
  static const double subGap = 4.0;
  static const double rsiRatio = 0.12;
  static const double macdRatio = 0.12;
  static const double timeAxisH = 16.0;
  static const double inlineVolRatio = 0.20;

  static ChartRegions compute(double totalH, bool rsi, bool macd) =>
      computeWith(totalH, rsi, macd, rsiRatio, macdRatio);

  static ChartRegions computeWith(
    double totalH,
    bool rsi,
    bool macd,
    double rsiR,
    double macdR,
  ) {
    final remaining = totalH - timeAxisH - topPad - bottomPad;
    final rsiH = rsi ? remaining * rsiR : 0.0;
    final macdH = macd ? remaining * macdR : 0.0;
    final chartH =
        remaining - rsiH - macdH - (rsi ? subGap : 0) - (macd ? subGap : 0);
    final chartTop = topPad;
    final rsiTop = chartTop + chartH + (rsi ? subGap : 0);
    final macdTop = rsiTop + rsiH + (macd ? subGap : 0);
    return ChartRegions(
      chartH: chartH,
      chartTop: chartTop,
      rsiH: rsiH,
      rsiTop: rsiTop,
      macdH: macdH,
      macdTop: macdTop,
      timeTop: totalH - timeAxisH,
    );
  }
}

class ChartRegions {
  final double chartH, chartTop, rsiH, rsiTop, macdH, macdTop, timeTop;
  const ChartRegions({
    required this.chartH,
    required this.chartTop,
    required this.rsiH,
    required this.rsiTop,
    required this.macdH,
    required this.macdTop,
    required this.timeTop,
  });
}

class AdvancedChartPainter extends CustomPainter {
  final List<Candle> candles;
  final double visibleStart;
  final int visibleCount;
  final double candleWidth;
  final Offset? drawingCrosshair;
  final double priceMin;
  final double priceMax;
  final Offset? pointerPos;
  final Offset? crosshairPos;
  final List<ChartDrawing> drawings;
  final ChartDrawing? inProgress;
  final List<AlertLevel> alerts;
  final double currentPrice;
  final bool showVolume;
  final bool showRsi;
  final bool showMacd;
  final String chartType;
  final List<String> activeIndicators;
  final String? selectedDrawingId;
  final double rsiRatio;
  final double macdRatio;

  const AdvancedChartPainter({
    required this.candles,
    required this.visibleStart,
    required this.visibleCount,
    required this.candleWidth,
    required this.drawingCrosshair,
    this.priceMin = double.nan,
    this.priceMax = double.nan,
    this.pointerPos,
    this.crosshairPos,
    this.drawings = const [],
    this.inProgress,
    this.alerts = const [],
    required this.currentPrice,
    this.showVolume = true,
    this.showRsi = false,
    this.showMacd = false,
    this.chartType = 'candlestick',
    this.activeIndicators = const [],
    this.selectedDrawingId,
    this.rsiRatio = ChartLayout.rsiRatio,
    this.macdRatio = ChartLayout.macdRatio,
  });

  List<Candle> get _vis {
    final s = _si;
    final e = (s + visibleCount + 2).clamp(s, candles.length);
    return candles.sublist(s, e);
  }

  int get _si => visibleStart.floor().clamp(0, candles.length);
  double _xOf(int i) => (i - visibleStart) * candleWidth + candleWidth / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final vis = _vis;
    if (vis.isEmpty) return;
    final chartW = size.width - ChartLayout.priceAxisW;
    final r = ChartLayout.computeWith(
      size.height,
      showRsi,
      showMacd,
      rsiRatio,
      macdRatio,
    );

    final autoMin = vis.map((c) => c.low).reduce(min);
    final autoMax = vis.map((c) => c.high).reduce(max);
    final pad = (autoMax - autoMin) * 0.08;
    final pMin = priceMin.isNaN ? autoMin - pad : priceMin;
    final pMax = priceMax.isNaN ? autoMax + pad : priceMax;
    final pRange = (pMax - pMin).abs().clamp(0.001, double.infinity);

    double pToY(double p) =>
        r.chartTop + r.chartH - (p - pMin) / pRange * r.chartH;
    double xOf(int i) => _xOf(i);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, chartW, size.height),
      Paint()..color = AppColors.background,
    );

    _drawGrid(canvas, chartW, r, pMin, pMax, pToY);
    _drawPriceAxis(canvas, size, chartW, r, pMin, pMax, pToY);
    _drawCurrentPriceLine(canvas, chartW, pToY);
    _drawTimeAxis(canvas, chartW, r, vis);

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, r.chartTop, chartW, r.chartH));
    if (showVolume) _drawInlineVolume(canvas, vis, chartW, r);
    _drawChart(canvas, vis, chartW, pToY);
    if (activeIndicators.contains('BB')) _drawBB(canvas, vis, chartW, pToY, 20);
    if (activeIndicators.contains('MA')) {
      _drawMA(canvas, vis, chartW, pToY, 20, AppColors.warning);
    }
    if (activeIndicators.contains('EMA')) {
      _drawEMA(canvas, vis, chartW, pToY, 14, const Color(0xFF9C27B0));
    }
    if (activeIndicators.contains('VWAP')) _drawVWAP(canvas, vis, chartW, pToY);
    canvas.restore();

    for (final d in [...drawings, ?inProgress]) {
      _drawDrawing(
        canvas,
        d,
        chartW,
        r,
        pToY,
        xOf,
        selected: d.id == selectedDrawingId,
      );
    }
    for (final al in alerts) {
      _drawAlert(canvas, al, chartW, pToY);
    }

    if (showRsi && r.rsiH > 0) {
      _drawSeparatorHandle(canvas, chartW, r.rsiTop);
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, r.rsiTop, chartW, r.rsiH));
      _drawRSI(canvas, vis, chartW, r);
      canvas.restore();
      _subLabel(canvas, chartW, r.rsiTop, 'RSI(14)');
    }
    if (showMacd && r.macdH > 0) {
      _drawSeparatorHandle(canvas, chartW, r.macdTop);
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, r.macdTop, chartW, r.macdH));
      _drawMACD(canvas, vis, chartW, r);
      canvas.restore();
      _subLabel(canvas, chartW, r.macdTop, 'MACD');
    }

    if (crosshairPos != null) {
      _paintCrosshair(canvas, chartW, size.height, r, pMin, pRange);
    }
    if (pointerPos != null) {
      _drawPointer(canvas, pointerPos!, chartW, pMin, pRange, r);
    }
    if (drawingCrosshair != null) _drawDrawingCursor(canvas, chartW, r);
  }

  void _drawCurrentPriceLine(
    Canvas canvas,
    double chartW,
    double Function(double) pToY,
  ) {
    final y = pToY(currentPrice);
    _dashedH(canvas, y, 0, chartW, AppColors.primary.withOpacity(0.35), 0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(chartW + 2, y - 8, ChartLayout.priceAxisW - 4, 16),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.primary,
    );
    _text(
      canvas,
      _fmt(currentPrice),
      Offset(chartW + 4, y - 6),
      const TextStyle(
        color: Colors.white,
        fontSize: 9,
        fontFamily: 'monospace',
      ),
    );
  }

  void _drawSeparatorHandle(Canvas canvas, double chartW, double y) {
    canvas.drawLine(
      Offset(0, y),
      Offset(chartW + ChartLayout.priceAxisW, y),
      Paint()
        ..color = AppColors.border
        ..strokeWidth = 1.2,
    );
    final cx = (chartW + ChartLayout.priceAxisW) / 2;
    for (int i = -1; i <= 1; i++) {
      canvas.drawCircle(
        Offset(cx + i * 6.0, y),
        2.0,
        Paint()..color = AppColors.textMuted,
      );
    }
  }

  int _indexStep(double cw) {
    final raw = 80.0 / cw;
    if (raw <= 1) return 1;
    final mag = pow(10, (log(raw) / ln10).floor()).toInt();
    final rel = raw / mag;
    final mult = rel < 1.5
        ? 1
        : rel < 3.0
        ? 2
        : rel < 7.0
        ? 5
        : 10;
    return max(1, mag * mult);
  }

  void _drawGrid(
    Canvas canvas,
    double chartW,
    ChartRegions r,
    double pMin,
    double pMax,
    double Function(double) pToY,
  ) {
    final paint = Paint()
      ..color = AppColors.surface
      ..strokeWidth = 0.7;
    final step = _gridStep(pMax - pMin, r.chartH);
    for (double p = (pMin / step).ceil() * step; p <= pMax; p += step) {
      canvas.drawLine(Offset(0, pToY(p)), Offset(chartW, pToY(p)), paint);
    }
    final vs = _indexStep(candleWidth);
    for (
      int i = (visibleStart / vs).ceil() * vs;
      i < visibleStart + visibleCount + 2;
      i += vs
    ) {
      final x = _xOf(i);
      if (x >= 0 && x < chartW) {
        canvas.drawLine(
          Offset(x, r.chartTop),
          Offset(x, r.chartTop + r.chartH),
          paint,
        );
      }
    }
    final sep = Paint()
      ..color = AppColors.border
      ..strokeWidth = 0.8;
    final fw = chartW + ChartLayout.priceAxisW;
    if (showRsi && r.rsiH > 0) {
      canvas.drawLine(Offset(0, r.rsiTop), Offset(fw, r.rsiTop), sep);
    }
    if (showMacd && r.macdH > 0) {
      canvas.drawLine(Offset(0, r.macdTop), Offset(fw, r.macdTop), sep);
    }
  }

  void _drawPriceAxis(
    Canvas canvas,
    Size size,
    double chartW,
    ChartRegions r,
    double pMin,
    double pMax,
    double Function(double) pToY,
  ) {
    final ph = r.chartTop + r.chartH;
    canvas.drawRect(
      Rect.fromLTWH(chartW, 0, ChartLayout.priceAxisW, ph),
      Paint()..color = AppColors.background,
    );
    canvas.drawLine(
      Offset(chartW, 0),
      Offset(chartW, ph),
      Paint()
        ..color = AppColors.border
        ..strokeWidth = 0.8,
    );
    const style = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 10,
      fontFamily: 'monospace',
    );
    final step = _gridStep(pMax - pMin, r.chartH);
    for (double p = (pMin / step).ceil() * step; p <= pMax; p += step) {
      _text(canvas, _fmt(p), Offset(chartW + 4, pToY(p) - 6), style);
    }
  }

  void _drawTimeAxis(
    Canvas canvas,
    double chartW,
    ChartRegions r,
    List<Candle> vis,
  ) {
    const style = TextStyle(color: AppColors.textSecondary, fontSize: 8);
    final vs = _indexStep(candleWidth);
    for (
      int i = (visibleStart / vs).ceil() * vs;
      i < visibleStart + visibleCount + 2;
      i += vs
    ) {
      if (i < 0 || i >= candles.length) continue;
      final x = _xOf(i);
      if (x < 0 || x >= chartW) continue;
      final dt = candles[i].time;
      final label =
          '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      final tp = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, r.timeTop + 3));
    }
  }

  void _drawChart(
    Canvas canvas,
    List<Candle> vis,
    double chartW,
    double Function(double) pToY,
  ) {
    switch (chartType) {
      case 'line':
        _drawLineChart(canvas, vis, chartW, pToY);
      case 'bar':
        _drawBarChart(canvas, vis, chartW, pToY);
      default:
        _drawCandleChart(canvas, vis, chartW, pToY);
    }
  }

  void _drawCandleChart(
    Canvas canvas,
    List<Candle> vis,
    double chartW,
    double Function(double) pToY,
  ) {
    final bw = (candleWidth * 0.65).clamp(2.0, 16.0);
    final si = _si;
    for (int i = 0; i < vis.length; i++) {
      final x = _xOf(si + i);
      if (x < -bw || x > chartW + bw) continue;
      final c = vis[i];
      final col = c.isBullish ? AppColors.bullish : AppColors.bearish;
      canvas.drawLine(
        Offset(x, pToY(c.high)),
        Offset(x, pToY(c.low)),
        Paint()
          ..color = col
          ..strokeWidth = 1.2,
      );
      final top = pToY(max(c.open, c.close));
      final bh = (pToY(min(c.open, c.close)) - top).clamp(1.5, double.infinity);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - bw / 2, top, bw, bh),
          const Radius.circular(1),
        ),
        Paint()..color = col,
      );
    }
  }

  void _drawLineChart(
    Canvas canvas,
    List<Candle> vis,
    double chartW,
    double Function(double) pToY,
  ) {
    if (vis.length < 2) return;
    final path = Path(), area = Path();
    for (int i = 0; i < vis.length; i++) {
      final x = i * candleWidth + candleWidth / 2;
      if (x > chartW) break;
      final y = pToY(vis[i].close);
      if (i == 0) {
        path.moveTo(x, y);
        area.moveTo(x, 99999);
        area.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        area.lineTo(x, y);
      }
    }
    final lx =
        min(vis.length - 1, (chartW / candleWidth).ceil() - 1) * candleWidth +
        candleWidth / 2;
    area.lineTo(lx, 99999);
    area.close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.22),
            AppColors.primary.withOpacity(0.01),
          ],
        ).createShader(Rect.fromLTWH(0, 0, chartW, 99999)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawBarChart(
    Canvas canvas,
    List<Candle> vis,
    double chartW,
    double Function(double) pToY,
  ) {
    final hw = (candleWidth * 0.28).clamp(1.5, 6.0);
    for (int i = 0; i < vis.length; i++) {
      final x = i * candleWidth + candleWidth / 2;
      if (x > chartW) break;
      final c = vis[i];
      final p = Paint()
        ..color = (c.isBullish ? AppColors.bullish : AppColors.bearish)
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(x, pToY(c.high)), Offset(x, pToY(c.low)), p);
      canvas.drawLine(Offset(x - hw, pToY(c.open)), Offset(x, pToY(c.open)), p);
      canvas.drawLine(
        Offset(x, pToY(c.close)),
        Offset(x + hw, pToY(c.close)),
        p,
      );
    }
  }

  void _drawMA(
    Canvas canvas,
    List<Candle> vis,
    double chartW,
    double Function(double) pToY,
    int period,
    Color color,
  ) {
    if (vis.length < period) return;
    final path = Path();
    bool s = false;
    for (int i = period - 1; i < vis.length; i++) {
      final avg =
          vis
              .sublist(i - period + 1, i + 1)
              .map((c) => c.close)
              .reduce((a, b) => a + b) /
          period;
      final x = i * candleWidth + candleWidth / 2;
      if (x > chartW) break;
      if (s) {
        path.lineTo(x, pToY(avg));
      } else {
        s = true;
        path.moveTo(x, pToY(avg));
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(0.9)
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawEMA(
    Canvas canvas,
    List<Candle> vis,
    double chartW,
    double Function(double) pToY,
    int period,
    Color color,
  ) {
    if (vis.length < period) return;
    final k = 2.0 / (period + 1);
    double ema =
        vis.sublist(0, period).map((c) => c.close).reduce((a, b) => a + b) /
        period;
    final path = Path();
    bool s = false;
    for (int i = period; i < vis.length; i++) {
      ema = vis[i].close * k + ema * (1 - k);
      final x = i * candleWidth + candleWidth / 2;
      if (x > chartW) break;
      if (s) {
        path.lineTo(x, pToY(ema));
      } else {
        s = true;
        path.moveTo(x, pToY(ema));
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(0.9)
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawBB(
    Canvas canvas,
    List<Candle> vis,
    double chartW,
    double Function(double) pToY,
    int period,
  ) {
    if (vis.length < period) return;
    final upper = Path(), mid = Path(), lower = Path();
    bool s = false;
    for (int i = period - 1; i < vis.length; i++) {
      final sl = vis
          .sublist(i - period + 1, i + 1)
          .map((c) => c.close)
          .toList();
      final avg = sl.reduce((a, b) => a + b) / period;
      final std = sqrt(
        sl.map((p) => pow(p - avg, 2)).reduce((a, b) => a + b) / period,
      );
      final x = i * candleWidth + candleWidth / 2;
      if (x > chartW) break;
      if (!s) {
        upper.moveTo(x, pToY(avg + 2 * std));
        mid.moveTo(x, pToY(avg));
        lower.moveTo(x, pToY(avg - 2 * std));
        s = true;
      } else {
        upper.lineTo(x, pToY(avg + 2 * std));
        mid.lineTo(x, pToY(avg));
        lower.lineTo(x, pToY(avg - 2 * std));
      }
    }
    for (final p in [upper, lower]) {
      canvas.drawPath(
        p,
        Paint()
          ..color = AppColors.error.withOpacity(0.7)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke,
      );
    }
    canvas.drawPath(
      mid,
      Paint()
        ..color = AppColors.error.withOpacity(0.4)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawVWAP(
    Canvas canvas,
    List<Candle> vis,
    double chartW,
    double Function(double) pToY,
  ) {
    final path = Path();
    bool s = false;
    double cv = 0, cvp = 0;
    for (int i = 0; i < vis.length; i++) {
      final c = vis[i];
      cv += c.volume;
      cvp += (c.high + c.low + c.close) / 3 * c.volume;
      final x = i * candleWidth + candleWidth / 2;
      if (x > chartW) break;
      if (s) {
        path.lineTo(x, pToY(cvp / cv));
      } else {
        s = true;
        path.moveTo(x, pToY(cvp / cv));
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF26C6DA).withOpacity(0.9)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawInlineVolume(
    Canvas canvas,
    List<Candle> vis,
    double chartW,
    ChartRegions r,
  ) {
    if (vis.isEmpty) return;
    final maxVol = vis.map((c) => c.volume).reduce(max);
    if (maxVol == 0) return;
    final maxH = r.chartH * ChartLayout.inlineVolRatio;
    final bw = (candleWidth * 0.65).clamp(2.0, 14.0);
    final si = _si;
    final cb = r.chartTop + r.chartH;
    for (int i = 0; i < vis.length; i++) {
      final x = _xOf(si + i);
      if (x < -bw || x > chartW + bw) continue;
      final c = vis[i];
      canvas.drawRect(
        Rect.fromLTWH(
          x - bw / 2,
          cb - (c.volume / maxVol * maxH).clamp(1.0, maxH),
          bw,
          (c.volume / maxVol * maxH).clamp(1.0, maxH),
        ),
        Paint()
          ..color = (c.isBullish ? AppColors.bullish : AppColors.bearish)
              .withOpacity(0.25),
      );
    }
  }

  void _drawRSI(
    Canvas canvas,
    List<Candle> vis,
    double chartW,
    ChartRegions r,
  ) {
    const period = 14;
    if (vis.length < period + 1) return;
    final vals = _calcRSI(vis, period);
    final path = Path();
    bool s = false;
    for (int i = 0; i < vals.length; i++) {
      final x = (i + period) * candleWidth + candleWidth / 2;
      if (x > chartW) break;
      final y = r.rsiTop + r.rsiH - (vals[i] / 100) * r.rsiH;
      if (s) {
        path.lineTo(x, y);
      } else {
        s = true;
        path.moveTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color =  AppColors.primary
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke,
    );
    final lp = Paint()
      ..color = AppColors.textMuted
      ..strokeWidth = 0.6;
    for (final lvl in [30.0, 50.0, 70.0]) {
      final y = r.rsiTop + r.rsiH - (lvl / 100) * r.rsiH;
      canvas.drawLine(Offset(0, y), Offset(chartW, y), lp);
      _text(
        canvas,
        '${lvl.toInt()}',
        Offset(chartW + 4, y - 6),
        const TextStyle(color: Color(0xFF6B7280), fontSize: 9),
      );
    }
    if (vals.isNotEmpty) {
      _text(
        canvas,
        'RSI ${vals.last.toStringAsFixed(1)}',
        Offset(2, r.rsiTop + 2),
        const TextStyle(
          color: AppColors.primaryVariant,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }

  List<double> _calcRSI(List<Candle> vis, int period) {
    final gains = <double>[], losses = <double>[];
    for (int i = 1; i < vis.length; i++) {
      final d = vis[i].close - vis[i - 1].close;
      gains.add(d > 0 ? d : 0);
      losses.add(d < 0 ? -d : 0);
    }
    if (gains.length < period) return [];
    double ag = gains.sublist(0, period).reduce((a, b) => a + b) / period;
    double al = losses.sublist(0, period).reduce((a, b) => a + b) / period;
    final res = <double>[];
    for (int i = period; i < gains.length; i++) {
      ag = (ag * (period - 1) + gains[i]) / period;
      al = (al * (period - 1) + losses[i]) / period;
      res.add(al == 0 ? 100 : 100 - 100 / (1 + ag / al));
    }
    return res;
  }

  void _drawMACD(
    Canvas canvas,
    List<Candle> vis,
    double chartW,
    ChartRegions r,
  ) {
    if (vis.length < 26) return;
    final data = _calcMACD(vis);
    if (data.isEmpty) return;
    final maxV = data
        .expand((m) => [m[0].abs(), m[1].abs(), m[2].abs()])
        .reduce(max);
    if (maxV == 0) return;
    final midY = r.macdTop + r.macdH / 2;
    double vToY(double v) => midY - (v / maxV) * (r.macdH / 2 - 2);
    canvas.drawLine(
      Offset(0, midY),
      Offset(chartW, midY),
      Paint()
        ..color = Colors.white12
        ..strokeWidth = 0.6,
    );
    final bw = (candleWidth * 0.5).clamp(1.5, 10.0);
    for (int i = 0; i < data.length; i++) {
      final x = (i + 26) * candleWidth + candleWidth / 2;
      if (x > chartW) break;
      final hist = data[i][2];
      final y = vToY(hist);
      canvas.drawRect(
        Rect.fromLTWH(
          x - bw / 2,
          min(y, midY),
          bw,
          (y - midY).abs().clamp(1, double.infinity),
        ),
        Paint()
          ..color = (hist >= 0 ? AppColors.bullish : AppColors.bearish)
              .withOpacity(0.5),
      );
    }
    final mp = Path(), sp = Path();
    bool sm = false, ss = false;
    for (int i = 0; i < data.length; i++) {
      final x = (i + 26) * candleWidth + candleWidth / 2;
      if (x > chartW) break;
      if (sm) {
        mp.lineTo(x, vToY(data[i][0]));
      } else {
        sm = true;
        mp.moveTo(x, vToY(data[i][0]));
      }
      if (ss) {
        sp.lineTo(x, vToY(data[i][1]));
      } else {
        ss = true;
        sp.moveTo(x, vToY(data[i][1]));
      }
    }
    canvas.drawPath(
      mp,
      Paint()
        ..color = const Color(0xFF2962FF)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      sp,
      Paint()
        ..color = const Color(0xFFFF6B6B)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
    _text(
      canvas,
      'MACD(12,26,9)',
      Offset(2, r.macdTop + 2),
      const TextStyle(
        color: Color(0xFF2962FF),
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  List<List<double>> _calcMACD(List<Candle> vis) {
    List<double> ema(int p) {
      final k = 2.0 / (p + 1);
      double e =
          vis.sublist(0, p).map((c) => c.close).reduce((a, b) => a + b) / p;
      final res = <double>[];
      for (int i = p; i < vis.length; i++) {
        e = vis[i].close * k + e * (1 - k);
        res.add(e);
      }
      return res;
    }

    final e12 = ema(12), e26 = ema(26);
    final off = e12.length - e26.length;
    final macdLine = List.generate(e26.length, (i) => e12[i + off] - e26[i]);
    if (macdLine.length < 9) return [];
    double se = macdLine.sublist(0, 9).reduce((a, b) => a + b) / 9;
    const sk = 2.0 / 10;
    final result = <List<double>>[];
    for (int i = 9; i < macdLine.length; i++) {
      se = macdLine[i] * sk + se * (1 - sk);
      result.add([macdLine[i], se, macdLine[i] - se]);
    }
    return result;
  }

  void _drawDrawing(
    Canvas canvas,
    ChartDrawing d,
    double chartW,
    ChartRegions r,
    double Function(double) pToY,
    double Function(int) xOf, {
    bool selected = false,
  }) {
    final col = selected ? AppColors.primary : d.color;
    final sw = selected ? 2.2 : 1.5;

    void dot(Offset p) {
      canvas.drawCircle(p, selected ? 5.5 : 3.5, Paint()..color = col);
      if (selected) {
        canvas.drawCircle(
          p,
          5.5,
          Paint()
            ..color = col
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
        canvas.drawCircle(p, 10, Paint()..color = col.withOpacity(0.18));
      }
    }

    if (d is HorizLineDrawing) {
      _dashedH(canvas, pToY(d.price), 0, chartW, col, sw);
      _priceTag(canvas, chartW, pToY(d.price), d.price, col);
    } else if (d is HorizRayDrawing) {
      final y = pToY(d.price);
      final sx = xOf(d.startCandleIndex).clamp(0.0, chartW);
      canvas.drawLine(
        Offset(sx, y),
        Offset(chartW, y),
        Paint()
          ..color = col
          ..strokeWidth = sw,
      );
      canvas.drawPath(
        Path()
          ..moveTo(chartW - 8, y - 4)
          ..lineTo(chartW, y)
          ..lineTo(chartW - 8, y + 4),
        Paint()
          ..color = col
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw,
      );
      _priceTag(canvas, chartW, y, d.price, col);
      if (selected) dot(Offset(sx, y));
    } else if (d is TrendLineDrawing) {
      final p1 = Offset(xOf(d.startIndex), pToY(d.startPrice));
      final p2 = Offset(xOf(d.endIndex), pToY(d.endPrice));
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = col
          ..strokeWidth = sw,
      );
      dot(p1);
      dot(p2);
    } else if (d is FibDrawing) {
      final x1 = xOf(d.startIndex);
      final x2 = xOf(d.endIndex);
      final range = d.endPrice - d.startPrice;
      for (final lvl in FibDrawing.levels) {
        final p = d.startPrice + range * lvl;
        final y = pToY(p);
        canvas.drawLine(
          Offset(min(x1, x2), y),
          Offset(max(x1, x2), y),
          Paint()
            ..color = col.withOpacity(0.65)
            ..strokeWidth = selected ? 1.2 : 0.9,
        );
        _text(
          canvas,
          '${(lvl * 100).toStringAsFixed(1)}%  ${_fmt(p)}',
          Offset(min(x1, x2) + 2, y - 11),
          TextStyle(color: col, fontSize: 8.5, fontWeight: FontWeight.w500),
        );
      }
      if (selected) {
        dot(Offset(x1, pToY(d.startPrice)));
        dot(Offset(x2, pToY(d.endPrice)));
      }
    } else if (d is RectDrawing) {
      final p1 = Offset(xOf(d.startIndex), pToY(d.startPrice));
      final p2 = Offset(xOf(d.endIndex), pToY(d.endPrice));
      final rect = Rect.fromPoints(p1, p2);
      canvas.drawRect(
        rect,
        Paint()..color = col.withOpacity(selected ? 0.14 : 0.08),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = col.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw,
      );
      if (selected) {
        dot(p1);
        dot(p2);
      }
    }
  }

  void _drawAlert(
    Canvas canvas,
    AlertLevel al,
    double chartW,
    double Function(double) pToY,
  ) {
    final y = pToY(al.price);
    final col = al.triggered ? AppColors.bullish : AppColors.warning;
    _dashedH(canvas, y, 0, chartW, col, 1.0);
    final box = RRect.fromRectAndRadius(
      Rect.fromLTWH(chartW + 2, y - 9, ChartLayout.priceAxisW - 4, 17),
      const Radius.circular(3),
    );
    canvas.drawRRect(box, Paint()..color = col.withOpacity(0.15));
    canvas.drawRRect(
      box,
      Paint()
        ..color = col
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    _text(
      canvas,
      '🔔 ${_fmt(al.price)}',
      Offset(chartW + 4, y - 7),
      TextStyle(color: col, fontSize: 8.5, fontFamily: 'monospace'),
    );
  }

  void _paintCrosshair(
    Canvas canvas,
    double chartW,
    double totalH,
    ChartRegions r,
    double pMin,
    double pRange,
  ) {
    final cp = crosshairPos!;
    final i = (cp.dx / candleWidth + visibleStart).floor().clamp(
      0,
      candles.length - 1,
    );
    final c = candles[i];
    final x = _xOf(i);
    final y = cp.dy.clamp(r.chartTop, r.chartTop + r.chartH);
    if (x < 0 || x > chartW) return;

    final paint = Paint()
      ..color = AppColors.chartCrosshair.withOpacity(0.65)
      ..strokeWidth = 0.8;
    canvas.drawLine(
      Offset(x, r.chartTop),
      Offset(x, r.chartTop + r.chartH),
      paint,
    );
    canvas.drawLine(Offset(0, y), Offset(chartW, y), paint);
    canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = AppColors.primary);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(chartW + 2, y - 9, ChartLayout.priceAxisW - 4, 17),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.primary,
    );
    _text(
      canvas,
      _fmt(pMin + (1 - (y - r.chartTop) / r.chartH) * pRange),
      Offset(chartW + 4, y - 7),
      const TextStyle(
        color: Colors.white,
        fontSize: 9.5,
        fontFamily: 'monospace',
      ),
    );

    final ts =
        '${c.time.hour.toString().padLeft(2, '0')}:${c.time.minute.toString().padLeft(2, '0')}';
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 22, r.timeTop - 1, 44, 16),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.primary,
    );
    _text(
      canvas,
      ts,
      Offset(x - 19, r.timeTop + 1),
      const TextStyle(color: Colors.white, fontSize: 8),
    );
  }

  void _drawPointer(
    Canvas canvas,
    Offset pos,
    double chartW,
    double pMin,
    double pRange,
    ChartRegions r,
  ) {
    if (pos.dx > chartW) return;
    final p = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..strokeWidth = 0.6;
    canvas.drawLine(
      Offset(pos.dx, r.chartTop),
      Offset(pos.dx, r.chartTop + r.chartH),
      p,
    );
    canvas.drawLine(Offset(0, pos.dy), Offset(chartW, pos.dy), p);
    canvas.drawCircle(pos, 3, Paint()..color = Colors.white.withOpacity(0.6));
    if (pos.dy >= r.chartTop && pos.dy <= r.chartTop + r.chartH) {
      final price = pMin + (1 - (pos.dy - r.chartTop) / r.chartH) * pRange;
      const bh = 18.0;
      const bw = 70.0;
      final bx = pos.dx + 12 > chartW - bw ? pos.dx - bw - 8 : pos.dx + 12;
      final by = pos.dy - bh / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, by, bw, bh),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFF2A2E3F),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, by, bw, bh),
          const Radius.circular(4),
        ),
        Paint()
          ..color = Colors.white24
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
      _text(
        canvas,
        _fmt(price),
        Offset(bx + 5, by + 4),
        const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontFamily: 'monospace',
        ),
      );
    }
  }

  void _drawDrawingCursor(Canvas canvas, double chartW, ChartRegions r) {
    final cx = drawingCrosshair!.dx;
    final cy = drawingCrosshair!.dy;
    _dashedH(canvas, cy, 0, chartW, AppColors.primary.withOpacity(0.6), 1.0);
    final vp = Paint()
      ..color = AppColors.primary.withOpacity(0.6)
      ..strokeWidth = 1.0;
    double y = r.chartTop;
    while (y < r.chartTop + r.chartH) {
      canvas.drawLine(
        Offset(cx, y),
        Offset(cx, min(y + 7, r.chartTop + r.chartH)),
        vp,
      );
      y += 12;
    }
    canvas.drawCircle(
      drawingCrosshair!,
      3.5,
      Paint()..color = AppColors.primary,
    );
    canvas.drawCircle(
      drawingCrosshair!,
      9.0,
      Paint()..color = AppColors.primary.withOpacity(0.25),
    );
  }

  double _gridStep(double range, double height) {
    final raw = range / (height / 45.0);
    final mag = pow(10, (log(raw) / ln10).floor()).toDouble();
    final rel = raw / mag;
    return mag *
        (rel < 1.5
            ? 1.0
            : rel < 3.0
            ? 2.0
            : rel < 7.0
            ? 5.0
            : 10.0);
  }

  void _subLabel(Canvas canvas, double chartW, double top, String label) =>
      _text(
        canvas,
        label,
        Offset(4, top + 3),
        const TextStyle(
          color: AppColors.chartGrid,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );

  void _dashedH(
    Canvas canvas,
    double y,
    double x0,
    double x1,
    Color color,
    double width,
  ) {
    final p = Paint()
      ..color = color
      ..strokeWidth = width;
    double x = x0;
    while (x < x1) {
      canvas.drawLine(Offset(x, y), Offset(min(x + 7, x1), y), p);
      x += 12;
    }
  }

  void _priceTag(
    Canvas canvas,
    double chartW,
    double y,
    double price,
    Color color,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(chartW + 2, y - 8, ChartLayout.priceAxisW - 4, 16),
        const Radius.circular(3),
      ),
      Paint()..color = color.withOpacity(0.9),
    );
    _text(
      canvas,
      _fmt(price),
      Offset(chartW + 4, y - 6),
      const TextStyle(
        color: Colors.white,
        fontSize: 9,
        fontFamily: 'monospace',
      ),
    );
  }

  void _text(Canvas canvas, String text, Offset offset, TextStyle style) =>
      (TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )..layout()).paint(canvas, offset);

  String _fmt(double v) => v.toStringAsFixed(2);

  @override
  bool shouldRepaint(AdvancedChartPainter o) => true;
}
