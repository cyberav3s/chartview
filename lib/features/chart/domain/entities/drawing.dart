import 'package:flutter/material.dart';

abstract class ChartDrawing {
  final String id;
  final Color color;
  ChartDrawing({required this.id, required this.color});
}

class HorizLineDrawing extends ChartDrawing {
  final double price;
  HorizLineDrawing({
    required super.id,
    required this.price,
    super.color = const Color(0xFFFFA726),
  });
}

class HorizRayDrawing extends ChartDrawing {
  final double price;
  final int startCandleIndex;
  HorizRayDrawing({
    required super.id,
    required this.price,
    required this.startCandleIndex,
    super.color = const Color(0xFF26C6DA),
  });
}

class TrendLineDrawing extends ChartDrawing {
  final int startIndex;
  final double startPrice;
  final int endIndex;
  final double endPrice;
  TrendLineDrawing({
    required super.id,
    required this.startIndex,
    required this.startPrice,
    required this.endIndex,
    required this.endPrice,
    super.color = const Color(0xFF2962FF),
  });
}

class FibDrawing extends ChartDrawing {
  final int startIndex;
  final double startPrice;
  final int endIndex;
  final double endPrice;
  static const levels = [0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0];
  FibDrawing({
    required super.id,
    required this.startIndex,
    required this.startPrice,
    required this.endIndex,
    required this.endPrice,
    super.color = const Color(0xFF9C27B0),
  });
}

class RectDrawing extends ChartDrawing {
  final int startIndex;
  final double startPrice;
  final int endIndex;
  final double endPrice;
  RectDrawing({
    required super.id,
    required this.startIndex,
    required this.startPrice,
    required this.endIndex,
    required this.endPrice,
    super.color = const Color(0xFF4CAF50),
  });
}

class AlertLevel {
  final String id;
  final double price;
  final String label;
  final bool triggered;
  AlertLevel({
    required this.id,
    required this.price,
    required this.label,
    this.triggered = false,
  });
}
