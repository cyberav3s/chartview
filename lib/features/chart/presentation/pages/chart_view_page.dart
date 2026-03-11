// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'package:chartview/core/utils/enums.dart';
import 'package:chartview/core/utils/extensions/double_extension.dart';
import 'package:chartview/features/chart/domain/entities/candle.dart';
import 'package:chartview/features/chart/domain/entities/drawing.dart';
import 'package:chartview/features/chart/presentation/widgets/bottom_toolbar.dart';
import '../widgets/chart_sheets.dart' as sheets;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../bloc/chart_bloc.dart';
import '../widgets/advanced_chart_painter.dart';
import '../widgets/chart_components.dart';
import '../widgets/chart_theme.dart';
import '../../../../../core/constants/app_colors.dart';

class ChartViewPage extends StatelessWidget {
  final String symbol;
  final String name;
  final double price;
  final double changePercent;

  const ChartViewPage({
    super.key,
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
  });

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        ChartBloc()..add(LoadChartData(symbol: symbol, startPrice: price)),
    child: _ChartBody(
      symbol: symbol,
      name: name,
      price: price,
      changePercent: changePercent,
    ),
  );
}

enum _HitZone { priceAxis, timeAxis, indicatorPanel, chart }

enum _DrawingHit { body, start, end }

class _DrawingSelection {
  final String id;
  final _DrawingHit hit;
  const _DrawingSelection(this.id, this.hit);
}

class _ChartBody extends StatefulWidget {
  final String symbol, name;
  final double price, changePercent;

  const _ChartBody({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
  });

  @override
  State<_ChartBody> createState() => _ChartBodyState();
}

class _ChartBodyState extends State<_ChartBody> with TickerProviderStateMixin {
  static const double _minCW = 3.0;
  static const double _maxCW = 48.0;
  static const double _defaultCW = 8.0;

  double _candleWidth = _defaultCW;
  double _scrollPx = 0;
  double _lastChartWidth = 300;

  double _cwAtStart = _defaultCW;
  double _priceScaleAtStart = 1.0;
  double _vertOffsetAtStart = 0;
  Offset _focalAtStart = Offset.zero;

  bool _isPriceScaleManual = false;
  double _priceScale = 1.0;
  double _vertOffset = 0;

  late final AnimationController _inertiaCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  double _inertiaVelocity = 0;
  final List<double> _dragHistory = [];
  double _lastDragX = 0;

  bool _crosshairVisible = false;
  Offset? _crosshairPos;
  Candle? _crosshairCandle;

  DrawingTool _activeTool = DrawingTool.none;
  int _drawStep = 1;
  int? _drawStartIdx;
  double? _drawStartPrice;
  ChartDrawing? _drawPreview;
  Offset? _drawCursor;

  final List<ChartDrawing> _drawings = [];
  final List<ChartDrawing> _undoStack = [];

  _DrawingSelection? _selection;
  ChartDrawing? _selectedDrawingAtStart;

  Offset? _pointerPos;

  double _rsiRatio = ChartLayout.rsiRatio;
  double _macdRatio = ChartLayout.macdRatio;
  String? _resizingPanel;
  double _totalHeightCache = 600;

  String _chartType = 'candlestick';
  final List<String> _activeIndicators = [];
  final bool _showVolume = true;
  bool _showRsi = false;
  bool _showMacd = false;
  final List<AlertLevel> _alerts = [];
  bool _isFullscreen = false;
  List<Candle> _candles = [];

  late String _symbol;
  late double _currentPrice;
  late double _changePercent;

  final _repaintKey = GlobalKey();
  String get _newId => DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    _symbol = widget.symbol;
    _currentPrice = widget.price;
    _changePercent = widget.changePercent;
    _inertiaCtrl.addListener(_onInertiaFrame);
  }

  @override
  void dispose() {
    _inertiaCtrl.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  void _beginInertia(double velPxPerMs) {
    _inertiaVelocity = velPxPerMs * 16.7;
    _inertiaCtrl
      ..stop()
      ..reset()
      ..forward();
  }

  void _onInertiaFrame() {
    if (!mounted) return;
    setState(() {
      _inertiaVelocity *= 0.96;
      if (_inertiaVelocity.abs() < 0.15) {
        _inertiaCtrl.stop();
        return;
      }
      _scrollPx = (_scrollPx + _inertiaVelocity).clamp(
        -_lastChartWidth * 0.8,
        _maxScroll,
      );
    });
  }

  double get _maxScroll => max(
    0.0,
    (_candles.length - _visibleCandleCount(_lastChartWidth)) * _candleWidth,
  );

  int _visibleCandleCount(double w) =>
      (w / _candleWidth).ceil().clamp(5, max(5, _candles.length));

  double _visibleStartIndex(double w) {
    if (_candles.isEmpty) return 0.0;
    final vc = _visibleCandleCount(w);
    _scrollPx = _scrollPx.clamp(
      -w * 0.8,
      max(0.0, (_candles.length - vc) * _candleWidth),
    );
    return (_candles.length - vc) - (_scrollPx / _candleWidth);
  }

  _PriceRange _visiblePriceRange(int startIdx, int visibleCount) {
    if (_candles.isEmpty) return const _PriceRange(0, 1);
    final end = (startIdx + visibleCount).clamp(0, _candles.length);
    final vis = _candles.sublist(startIdx.clamp(0, _candles.length), end);
    if (vis.isEmpty) return const _PriceRange(0, 1);
    final low = vis.map((c) => c.low).reduce(min);
    final high = vis.map((c) => c.high).reduce(max);
    final baseRange = (high - low) == 0 ? 1.0 : (high - low);
    final pad = baseRange * 0.08;
    if (!_isPriceScaleManual) return _PriceRange(low - pad, high + pad);
    final mid = (high + low) / 2 + _vertOffset;
    final half = (baseRange / 2 + pad) / _priceScale;
    return _PriceRange(mid - half, mid + half);
  }

  double _xToDataIndex(double x, double visibleStart) =>
      visibleStart + x / _candleWidth;

  double _yToPrice(
    double y,
    double totalHeight,
    int startIdx,
    int visibleCount,
  ) {
    final range = _visiblePriceRange(startIdx, visibleCount);
    final r = ChartLayout.computeWith(
      totalHeight,
      _showRsi,
      _showMacd,
      _rsiRatio,
      _macdRatio,
    );
    if (y < r.chartTop || y > r.chartTop + r.chartH) return double.nan;
    return range.min + (1 - (y - r.chartTop) / r.chartH) * range.span;
  }

  _HitZone _zoneFor(Offset pos, double chartWidth, double totalHeight) {
    final r = ChartLayout.computeWith(
      totalHeight,
      _showRsi,
      _showMacd,
      _rsiRatio,
      _macdRatio,
    );
    if (pos.dx > chartWidth) return _HitZone.priceAxis;
    if (pos.dy >= r.timeTop) return _HitZone.timeAxis;
    if (_showRsi &&
        r.rsiH > 0 &&
        pos.dy >= r.rsiTop &&
        pos.dy <= r.rsiTop + r.rsiH) {
      return _HitZone.indicatorPanel;
    }
    if (_showMacd &&
        r.macdH > 0 &&
        pos.dy >= r.macdTop &&
        pos.dy <= r.macdTop + r.macdH) {
      return _HitZone.indicatorPanel;
    }
    return _HitZone.chart;
  }

  String? _separatorAt(Offset pos, double totalHeight) {
    final r = ChartLayout.computeWith(
      totalHeight,
      _showRsi,
      _showMacd,
      _rsiRatio,
      _macdRatio,
    );
    if (_showRsi && r.rsiH > 0 && (pos.dy - r.rsiTop).abs() < 10) return 'rsi';
    if (_showMacd && r.macdH > 0 && (pos.dy - r.macdTop).abs() < 10) {
      return 'macd';
    }
    return null;
  }

  static const double _hitR = 12.0;
  static const double _epR = 14.0;

  _DrawingSelection? _hitTestDrawings(
    Offset pos,
    double chartWidth,
    double totalHeight,
    double visibleStart,
    int startIdx,
    int visibleCount,
  ) {
    final r = ChartLayout.computeWith(
      totalHeight,
      _showRsi,
      _showMacd,
      _rsiRatio,
      _macdRatio,
    );
    final range = _visiblePriceRange(startIdx, visibleCount);
    double xOf(int i) => (i - visibleStart) * _candleWidth + _candleWidth / 2;
    double yOf(double p) =>
        r.chartTop + r.chartH - (p - range.min) / range.span * r.chartH;

    for (final d in _drawings.reversed) {
      if (d is HorizLineDrawing) {
        if ((pos.dy - yOf(d.price)).abs() < _hitR) {
          return _DrawingSelection(d.id, _DrawingHit.body);
        }
      } else if (d is HorizRayDrawing) {
        if ((pos.dy - yOf(d.price)).abs() < _hitR &&
            pos.dx >= xOf(d.startCandleIndex).clamp(0.0, chartWidth)) {
          return _DrawingSelection(d.id, _DrawingHit.body);
        }
      } else if (d is TrendLineDrawing) {
        final p1 = Offset(xOf(d.startIndex), yOf(d.startPrice));
        final p2 = Offset(xOf(d.endIndex), yOf(d.endPrice));
        if ((pos - p1).distance < _epR) {
          return _DrawingSelection(d.id, _DrawingHit.start);
        }
        if ((pos - p2).distance < _epR) {
          return _DrawingSelection(d.id, _DrawingHit.end);
        }
        if (_segDist(pos, p1, p2) < _hitR) {
          return _DrawingSelection(d.id, _DrawingHit.body);
        }
      } else if (d is FibDrawing) {
        final p1 = Offset(xOf(d.startIndex), yOf(d.startPrice));
        final p2 = Offset(xOf(d.endIndex), yOf(d.endPrice));
        if ((pos - p1).distance < _epR) {
          return _DrawingSelection(d.id, _DrawingHit.start);
        }
        if ((pos - p2).distance < _epR) {
          return _DrawingSelection(d.id, _DrawingHit.end);
        }
        if (_segDist(pos, p1, p2) < _hitR) {
          return _DrawingSelection(d.id, _DrawingHit.body);
        }
      } else if (d is RectDrawing) {
        final p1 = Offset(xOf(d.startIndex), yOf(d.startPrice));
        final p2 = Offset(xOf(d.endIndex), yOf(d.endPrice));
        if ((pos - p1).distance < _epR) {
          return _DrawingSelection(d.id, _DrawingHit.start);
        }
        if ((pos - p2).distance < _epR) {
          return _DrawingSelection(d.id, _DrawingHit.end);
        }
        if (Rect.fromPoints(p1, p2).inflate(_hitR).contains(pos)) {
          return _DrawingSelection(d.id, _DrawingHit.body);
        }
      }
    }
    return null;
  }

  static double _segDist(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (len2 == 0) return (p - a).distance;
    final t = ((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2;
    final proj =
        a + Offset(ab.dx * t.clamp(0.0, 1.0), ab.dy * t.clamp(0.0, 1.0));
    return (p - proj).distance;
  }

  ChartDrawing _buildTwoPoint(
    String id,
    int si,
    double sp,
    int ei,
    double ep,
  ) => switch (_activeTool) {
    DrawingTool.trendLine => TrendLineDrawing(
      id: id,
      startIndex: si,
      startPrice: sp,
      endIndex: ei,
      endPrice: ep,
    ),
    DrawingTool.fibonacci => FibDrawing(
      id: id,
      startIndex: si,
      startPrice: sp,
      endIndex: ei,
      endPrice: ep,
    ),
    _ => RectDrawing(
      id: id,
      startIndex: si,
      startPrice: sp,
      endIndex: ei,
      endPrice: ep,
    ),
  };

  ChartDrawing? _findDrawing(String id) {
    try {
      return _drawings.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  void _replaceDrawing(ChartDrawing updated) {
    final idx = _drawings.indexWhere((d) => d.id == updated.id);
    if (idx >= 0) setState(() => _drawings[idx] = updated);
  }

  void _translateDrawingFrom(ChartDrawing orig, double dIdx, double dPrice) {
    int cl(double v) => v.round().clamp(0, _candles.length - 1);
    ChartDrawing u;
    if (orig is HorizLineDrawing) {
      u = HorizLineDrawing(id: orig.id, price: orig.price + dPrice);
    } else if (orig is HorizRayDrawing) {
      u = HorizRayDrawing(
        id: orig.id,
        price: orig.price + dPrice,
        startCandleIndex: cl(orig.startCandleIndex - dIdx),
      );
    } else if (orig is TrendLineDrawing) {
      u = TrendLineDrawing(
        id: orig.id,
        startIndex: cl(orig.startIndex - dIdx),
        startPrice: orig.startPrice + dPrice,
        endIndex: cl(orig.endIndex - dIdx),
        endPrice: orig.endPrice + dPrice,
      );
    } else if (orig is FibDrawing) {
      u = FibDrawing(
        id: orig.id,
        startIndex: cl(orig.startIndex - dIdx),
        startPrice: orig.startPrice + dPrice,
        endIndex: cl(orig.endIndex - dIdx),
        endPrice: orig.endPrice + dPrice,
      );
    } else if (orig is RectDrawing) {
      u = RectDrawing(
        id: orig.id,
        startIndex: cl(orig.startIndex - dIdx),
        startPrice: orig.startPrice + dPrice,
        endIndex: cl(orig.endIndex - dIdx),
        endPrice: orig.endPrice + dPrice,
      );
    } else {
      return;
    }
    _replaceDrawing(u);
  }

  void _stretchDrawing(ChartDrawing d, _DrawingHit hit, int ni, double np) {
    int c(int v) => v.clamp(0, _candles.length - 1);
    ChartDrawing u;
    if (d is TrendLineDrawing) {
      u = hit == _DrawingHit.start
          ? TrendLineDrawing(
              id: d.id,
              startIndex: c(ni),
              startPrice: np,
              endIndex: d.endIndex,
              endPrice: d.endPrice,
            )
          : TrendLineDrawing(
              id: d.id,
              startIndex: d.startIndex,
              startPrice: d.startPrice,
              endIndex: c(ni),
              endPrice: np,
            );
    } else if (d is FibDrawing) {
      u = hit == _DrawingHit.start
          ? FibDrawing(
              id: d.id,
              startIndex: c(ni),
              startPrice: np,
              endIndex: d.endIndex,
              endPrice: d.endPrice,
            )
          : FibDrawing(
              id: d.id,
              startIndex: d.startIndex,
              startPrice: d.startPrice,
              endIndex: c(ni),
              endPrice: np,
            );
    } else if (d is RectDrawing) {
      u = hit == _DrawingHit.start
          ? RectDrawing(
              id: d.id,
              startIndex: c(ni),
              startPrice: np,
              endIndex: d.endIndex,
              endPrice: d.endPrice,
            )
          : RectDrawing(
              id: d.id,
              startIndex: d.startIndex,
              startPrice: d.startPrice,
              endIndex: c(ni),
              endPrice: np,
            );
    } else if (d is HorizRayDrawing) {
      u = HorizRayDrawing(id: d.id, price: np, startCandleIndex: c(ni));
    } else {
      return;
    }
    _replaceDrawing(u);
  }

  void _resetView() => setState(() {
    _candleWidth = _defaultCW;
    _scrollPx = 0;
    _vertOffset = 0;
    _priceScale = 1.0;
    _isPriceScaleManual = false;
    _crosshairVisible = false;
    _crosshairPos = null;
    _crosshairCandle = null;
    _drawCursor = null;
    _selection = null;
    _inertiaCtrl.stop();
  });

  void _showCrosshair(Offset pos, double visibleStart) {
    if (_candles.isEmpty) return;
    final idx = _xToDataIndex(
      pos.dx,
      visibleStart,
    ).floor().clamp(0, _candles.length - 1);
    setState(() {
      _crosshairVisible = true;
      _crosshairPos = pos;
      _crosshairCandle = _candles[idx];
    });
  }

  void _moveCrosshair(Offset pos, double visibleStart) {
    if (_candles.isEmpty) return;
    final idx = _xToDataIndex(
      pos.dx,
      visibleStart,
    ).floor().clamp(0, _candles.length - 1);
    setState(() {
      _crosshairPos = pos;
      _crosshairCandle = _candles[idx];
    });
  }

  void _hideCrosshair() => setState(() {
    _crosshairVisible = false;
    _crosshairPos = null;
    _crosshairCandle = null;
  });

  void _cancelTool() => setState(() {
    _activeTool = DrawingTool.none;
    _drawStep = 1;
    _drawStartIdx = null;
    _drawStartPrice = null;
    _drawPreview = null;
    _drawCursor = null;
  });

  void _onLongPressStart(
    LongPressStartDetails details,
    double chartWidth,
    double totalHeight,
    double visibleStart,
    int startIdx,
    int visibleCount,
  ) {
    _inertiaCtrl.stop();
    final pos = details.localPosition;

    if (_activeTool == DrawingTool.none) {
      final hit = _hitTestDrawings(
        pos,
        chartWidth,
        totalHeight,
        visibleStart,
        startIdx,
        visibleCount,
      );
      if (hit != null) {
        HapticFeedback.heavyImpact();
        _showDrawingContextMenu(context, hit.id);
        return;
      }
    }

    if (_zoneFor(pos, chartWidth, totalHeight) == _HitZone.chart &&
        _activeTool == DrawingTool.none &&
        _separatorAt(pos, totalHeight) == null) {
      HapticFeedback.heavyImpact();
      _showChartContextMenu(context);
      return;
    }

    _showCrosshair(pos, visibleStart);
    HapticFeedback.heavyImpact();
  }

  void _onLongPressDrag(LongPressMoveUpdateDetails d, double visibleStart) {
    if (_crosshairVisible) _moveCrosshair(d.localPosition, visibleStart);
  }

  void _onScaleStart(
    ScaleStartDetails details,
    double chartWidth,
    double totalHeight,
    double visibleStart,
    int startIdx,
    int visibleCount,
  ) {
    _inertiaCtrl.stop();
    _dragHistory.clear();
    _lastDragX = details.localFocalPoint.dx;
    _cwAtStart = _candleWidth;
    _vertOffsetAtStart = _vertOffset;
    _priceScaleAtStart = _priceScale;
    _focalAtStart = details.localFocalPoint;

    if (_crosshairVisible && details.pointerCount == 1) _hideCrosshair();

    _resizingPanel = _separatorAt(details.localFocalPoint, totalHeight);

    if (_activeTool == DrawingTool.none && _resizingPanel == null) {
      final hit = _hitTestDrawings(
        details.localFocalPoint,
        chartWidth,
        totalHeight,
        visibleStart,
        startIdx,
        visibleCount,
      );
      setState(() {
        if (hit != null) {
          _selection = hit;
          _selectedDrawingAtStart = _findDrawing(hit.id);
        } else if (_selection != null) {
          _selection = null;
        }
      });
    }
  }

  void _onScaleUpdate(
    ScaleUpdateDetails details,
    double chartWidth,
    double totalHeight,
    double visibleStart,
    int startIdx,
    int visibleCount,
    _PriceRange priceRange,
  ) {
    final pos = details.localFocalPoint;
    final dx = pos.dx - _focalAtStart.dx;
    final dy = pos.dy - _focalAtStart.dy;

    // Incremental delta since last frame — used for smooth per-frame scroll
    final frameDx = pos.dx - _lastDragX;
    _lastDragX = pos.dx;

    if (_resizingPanel != null) {
      _handlePanelResize(pos, totalHeight);
      return;
    }
    if (details.pointerCount >= 2) {
      _handleTwoFingerGesture(details, chartWidth, pos);
      return;
    }

    _dragHistory.add(frameDx);
    if (_dragHistory.length > 12) _dragHistory.removeAt(0);

    setState(() {
      switch (_zoneFor(_focalAtStart, chartWidth, totalHeight)) {
        case _HitZone.priceAxis:
          _isPriceScaleManual = true;
          _priceScale = (_priceScaleAtStart * exp(-dy / 150)).clamp(0.1, 50.0);
        case _HitZone.timeAxis:
          _candleWidth = (_cwAtStart * (1.0 - dx / (chartWidth * 0.5))).clamp(
            _minCW,
            _maxCW,
          );
        case _HitZone.indicatorPanel:
          break;
        case _HitZone.chart:
          if (_crosshairVisible) {
            _moveCrosshair(pos, visibleStart);
          } else if (_activeTool == DrawingTool.pointer) {
            _pointerPos = pos;
          } else if (_selection != null && _selectedDrawingAtStart != null) {
            if (_selection!.hit == _DrawingHit.body) {
              _translateDrawingFrom(
                _selectedDrawingAtStart!,
                -dx / _candleWidth,
                -(dy / (totalHeight * 0.7)) * priceRange.span,
              );
            } else {
              final ni = _xToDataIndex(
                pos.dx,
                visibleStart,
              ).floor().clamp(0, _candles.length - 1);
              final np = _yToPrice(pos.dy, totalHeight, startIdx, visibleCount);
              if (!np.isNaN) {
                _stretchDrawing(
                  _selectedDrawingAtStart!,
                  _selection!.hit,
                  ni,
                  np,
                );
              }
            }
          } else if (_activeTool != DrawingTool.none) {
            _moveDrawingCursor(
              pos,
              totalHeight,
              visibleStart,
              startIdx,
              visibleCount,
            );
          } else {
            // Incremental scroll: add per-frame delta to current position
            // This eliminates the "jump on fast swipe" artifact
            _scrollPx = (_scrollPx + frameDx).clamp(
              -chartWidth * 0.8,
              _maxScroll,
            );
            if (_isPriceScaleManual) {
              _vertOffset =
                  _vertOffsetAtStart + dy / (totalHeight / priceRange.span);
            }
          }
      }
    });
  }

  void _handleTwoFingerGesture(
    ScaleUpdateDetails details,
    double chartWidth,
    Offset pos,
  ) {
    setState(() {
      if (_focalAtStart.dx > chartWidth) {
        _isPriceScaleManual = true;
        _priceScale = (_priceScaleAtStart * details.verticalScale).clamp(
          0.1,
          50.0,
        );
      } else {
        _candleWidth = (_cwAtStart * details.horizontalScale).clamp(
          _minCW,
          _maxCW,
        );
        if (details.verticalScale > 1.12 || details.verticalScale < 0.88) {
          _isPriceScaleManual = true;
          _priceScale = (_priceScaleAtStart * details.verticalScale).clamp(
            0.1,
            50.0,
          );
        }
        if (details.scale.abs() < 0.05) {
          _scrollPx =
              (_scrollPx -
                      (pos.dx -
                          _focalAtStart.dx -
                          (_lastDragX - _focalAtStart.dx)))
                  .clamp(-chartWidth * 0.8, _maxScroll);
        }
      }
    });
  }

  void _handlePanelResize(Offset pos, double totalHeight) {
    const minR = 0.06;
    const maxR = 0.30;
    final usable =
        totalHeight -
        ChartLayout.timeAxisH -
        ChartLayout.topPad -
        ChartLayout.bottomPad;
    setState(() {
      final newH =
          (totalHeight - ChartLayout.timeAxisH - ChartLayout.bottomPad) -
          pos.dy;
      if (_resizingPanel == 'rsi') {
        _rsiRatio = (newH / usable).clamp(minR, maxR);
      } else if (_resizingPanel == 'macd') {
        _macdRatio = (newH / usable).clamp(minR, maxR);
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _resizingPanel = null;
    _selectedDrawingAtStart = null;
    if (_crosshairVisible ||
        _activeTool != DrawingTool.none ||
        _selection != null) {
      return;
    }
    if (_dragHistory.length < 2) return;
    // Use Flutter's native velocity tracker — most accurate source
    final vel = details.velocity.pixelsPerSecond.dx / 1000;
    if (vel.abs() > 0.1) _beginInertia(vel);
  }

  void _onTap(
    Offset pos,
    double chartWidth,
    double totalHeight,
    double visibleStart,
    int startIdx,
    int visibleCount,
  ) {
    if (_candles.isEmpty) return;
    if (_crosshairVisible) {
      _hideCrosshair();
      return;
    }

    if (_activeTool == DrawingTool.none) {
      final hit = _hitTestDrawings(
        pos,
        chartWidth,
        totalHeight,
        visibleStart,
        startIdx,
        visibleCount,
      );
      setState(
        () => _selection = hit != null
            ? (_selection?.id == hit.id ? null : hit)
            : null,
      );
      return;
    }

    if (_activeTool == DrawingTool.pointer) {
      setState(() => _pointerPos = pos);
      return;
    }

    final commit = _drawCursor ?? pos;
    final ci = _xToDataIndex(
      commit.dx,
      visibleStart,
    ).floor().clamp(0, _candles.length - 1);
    final price = _yToPrice(commit.dy, totalHeight, startIdx, visibleCount);
    if (price.isNaN) return;

    if (_activeTool == DrawingTool.horizontalLine) {
      setState(() {
        _drawings.add(HorizLineDrawing(id: _newId, price: price));
        _undoStack.clear();
        _cancelTool();
      });
      HapticFeedback.mediumImpact();
      return;
    }

    if (_activeTool == DrawingTool.horizontalRay) {
      setState(() {
        _drawings.add(
          HorizRayDrawing(id: _newId, price: price, startCandleIndex: ci),
        );
        _undoStack.clear();
        _cancelTool();
      });
      HapticFeedback.mediumImpact();
      return;
    }

    if (_drawStep == 1) {
      setState(() {
        _drawStartIdx = ci;
        _drawStartPrice = price;
        _drawStep = 2;
        _drawPreview = null;
      });
      HapticFeedback.selectionClick();
    } else {
      setState(() {
        _drawings.add(
          _buildTwoPoint(_newId, _drawStartIdx!, _drawStartPrice!, ci, price),
        );
        _undoStack.clear();
        _cancelTool();
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _onDoubleTap(
    Offset pos,
    double chartWidth,
    double totalHeight,
    double visibleStart,
    int startIdx,
    int visibleCount,
  ) {
    if (_activeTool == DrawingTool.none) {
      final hit = _hitTestDrawings(
        pos,
        chartWidth,
        totalHeight,
        visibleStart,
        startIdx,
        visibleCount,
      );
      if (hit != null) {
        HapticFeedback.selectionClick();
        _showDrawingStyleSheet(context, hit.id);
        return;
      }
    }
    _resetView();
    HapticFeedback.lightImpact();
  }

  void _moveDrawingCursor(
    Offset pos,
    double totalHeight,
    double visibleStart,
    int startIdx,
    int visibleCount,
  ) {
    setState(() => _drawCursor = pos);
    if (_drawStep != 2 || _drawStartIdx == null || _drawStartPrice == null) {
      return;
    }
    final ei = _xToDataIndex(
      pos.dx,
      visibleStart,
    ).floor().clamp(0, _candles.length - 1);
    final ep = _yToPrice(pos.dy, totalHeight, startIdx, visibleCount);
    if (!ep.isNaN) {
      setState(
        () => _drawPreview = _buildTwoPoint(
          'preview',
          _drawStartIdx!,
          _drawStartPrice!,
          ei,
          ep,
        ),
      );
    }
  }

  void _showDrawingContextMenu(BuildContext ctx, String drawingId) {
    final d = _findDrawing(drawingId);
    if (d == null) return;
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _DrawingContextSheet(
        drawing: d,
        onDelete: () {
          setState(() {
            _drawings.removeWhere((x) => x.id == drawingId);
            if (_selection?.id == drawingId) _selection = null;
          });
          Navigator.pop(ctx);
        },
        onClone: () {
          setState(() => _drawings.add(_cloneDrawing(d)));
          Navigator.pop(ctx);
        },
        onSettings: () {
          Navigator.pop(ctx);
          _showDrawingStyleSheet(ctx, drawingId);
        },
      ),
    );
  }

  ChartDrawing _cloneDrawing(ChartDrawing d) {
    final id = '${_newId}_clone';
    if (d is HorizLineDrawing) {
      return HorizLineDrawing(id: id, price: d.price + 10);
    }
    if (d is HorizRayDrawing) {
      return HorizRayDrawing(
        id: id,
        price: d.price + 10,
        startCandleIndex: d.startCandleIndex + 3,
      );
    }
    if (d is TrendLineDrawing) {
      return TrendLineDrawing(
        id: id,
        startIndex: d.startIndex + 3,
        startPrice: d.startPrice,
        endIndex: d.endIndex + 3,
        endPrice: d.endPrice,
      );
    }
    if (d is FibDrawing) {
      return FibDrawing(
        id: id,
        startIndex: d.startIndex + 3,
        startPrice: d.startPrice,
        endIndex: d.endIndex + 3,
        endPrice: d.endPrice,
      );
    }
    if (d is RectDrawing) {
      return RectDrawing(
        id: id,
        startIndex: d.startIndex + 3,
        startPrice: d.startPrice,
        endIndex: d.endIndex + 3,
        endPrice: d.endPrice,
      );
    }
    return d;
  }

  void _showDrawingStyleSheet(BuildContext ctx, String drawingId) {
    final d = _findDrawing(drawingId);
    if (d != null) ChartTheme.showSheet(ctx, _DrawingStyleSheet(drawing: d));
  }

  void _showChartContextMenu(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _ChartContextSheet(
        onAddDrawing: () {
          Navigator.pop(ctx);
          _openDrawingSheet(ctx);
        },
        onAddIndicator: () {
          Navigator.pop(ctx);
          _openIndicatorSheet(ctx);
        },
        onResetView: () {
          _resetView();
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _openSymbolSheet(BuildContext ctx) => ChartTheme.showSheet(
    ctx,
    sheets.SymbolSwitcherSheet(
      currentSymbol: _symbol,
      onSelect: (s) {
        setState(() {
          _symbol = s.$1;
          _currentPrice = s.$3;
          _changePercent = s.$4;
          _candles = [];
          _crosshairVisible = false;
          _crosshairPos = null;
          _crosshairCandle = null;
          _vertOffset = 0;
          _scrollPx = 0;
          _isPriceScaleManual = false;
          _selection = null;
        });
        ctx.read<ChartBloc>().add(
          LoadChartData(symbol: s.$1, startPrice: s.$3),
        );
      },
    ),
  );

  void _openDrawingSheet(BuildContext ctx) => ChartTheme.showSheet(
    ctx,
    sheets.DrawingToolSheet(
      activeTool: _activeTool,
      hasDrawings: _drawings.isNotEmpty,
      onSelect: (tool) => setState(() {
        _activeTool = tool;
        _drawStep = 1;
        _drawStartIdx = null;
        _drawStartPrice = null;
        _drawPreview = null;
        _drawCursor = Offset(_lastChartWidth / 2, _totalHeightCache / 2);
        _crosshairVisible = false;
        _crosshairPos = null;
        _crosshairCandle = null;
        _selection = null;
      }),
      onClearAll: () => setState(() => _drawings.clear()),
    ),
  );

  void _openIndicatorSheet(BuildContext ctx) => ChartTheme.showSheet(
    ctx,
    sheets.IndicatorSheet(
      activeIndicators: _activeIndicators,
      showRsi: _showRsi,
      showMacd: _showMacd,
      onChanged: (indicators, rsi, macd) => setState(() {
        _activeIndicators
          ..clear()
          ..addAll(indicators);
        _showRsi = rsi;
        _showMacd = macd;
      }),
    ),
    scrollControlled: true,
  );

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      _isFullscreen
          ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
          : [DeviceOrientation.portraitUp],
    );
    return BlocListener<ChartBloc, ChartState>(
      listener: (_, state) {
        if (state is ChartLoaded) {
          setState(() {
            _candles = state.candles;
            _chartType = state.chartType;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _isFullscreen ? null : _buildAppBar(context),
        bottomNavigationBar: _buildBottomToolbar(context),
        body: Column(
          children: [
            if (_crosshairCandle != null)
              _OHLCBar(candle: _crosshairCandle!, onDismiss: _hideCrosshair),
            if (_activeTool != DrawingTool.none)
              _DrawingBanner(tool: _activeTool, onDismiss: _cancelTool),
            Expanded(child: _buildCanvas()),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
    backgroundColor: AppColors.surface,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Symbols.arrow_back, color: AppColors.textSecondary),
      onPressed: () => Navigator.pop(context),
    ),
    titleSpacing: 4,
    title: GestureDetector(
      onTap: () => _openSymbolSheet(context),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Row(
                children: [
                  Text(
                    _symbol,
                    style: ChartTheme.mono(16, weight: FontWeight.w700),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Symbols.arrow_drop_down,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _changePercent >= 0
                        ? Symbols.arrow_upward
                        : Symbols.arrow_downward,
                    size: 10,
                    color: _changePercent >= 0
                        ? AppColors.bullish
                        : AppColors.bearish,
                  ),
                  Text(
                    _changePercent.formatChange(),
                    style: ChartTheme.mono(
                      11,
                      color: _changePercent >= 0
                          ? AppColors.bullish
                          : AppColors.bearish,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'INR',
              style: ChartTheme.sans(9, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    ),
    actionsPadding: const EdgeInsets.only(right: 4),
    actions: [
      PriceActionBox(
        label: 'SELL',
        price: _currentPrice * 0.9999,
        color: AppColors.bearish,
      ),
      const SizedBox(width: 8),
      PriceActionBox(
        label: 'BUY',
        price: _currentPrice * 1.0001,
        color: AppColors.primary,
      ),
      const SizedBox(width: 8),
      ChartIcon(icon: Symbols.share, tooltip: 'Share', onTap: () {}),
      ChartIcon(icon: Symbols.bookmark, tooltip: 'Bookmark', onTap: () {}),
    ],
  );

  Widget _buildBottomToolbar(BuildContext context) => BottomToolbar(
    symbol: _symbol,
    chartType: _chartType,
    tool: _activeTool,
    hasIndicators: _activeIndicators.isNotEmpty || _showRsi || _showMacd,
    canUndo: _drawings.isNotEmpty,
    canRedo: _undoStack.isNotEmpty,
    fullscreen: _isFullscreen,
    onSymbolTap: () => _openSymbolSheet(context),
    onDrawingTap: () => _openDrawingSheet(context),
    onIndicatorTap: () => _openIndicatorSheet(context),
    onUndoTap: () => setState(() => _undoStack.add(_drawings.removeLast())),
    onRedoTap: () => setState(() => _drawings.add(_undoStack.removeLast())),
    onFullscreenTap: () => setState(() => _isFullscreen = !_isFullscreen),
    onChartTypeTap: (type) => setState(() => _chartType = type),
  );

  Widget _buildCanvas() => LayoutBuilder(
    builder: (_, constraints) {
      final chartWidth = constraints.maxWidth - ChartLayout.priceAxisW;
      final totalHeight = constraints.maxHeight;
      _lastChartWidth = chartWidth;
      _totalHeightCache = totalHeight;

      final visibleCount = _visibleCandleCount(chartWidth);
      final visibleStart = _visibleStartIndex(chartWidth);
      final startIdx = visibleStart.floor().clamp(
        0,
        max<int>(0, _candles.length - 1),
      );
      final priceRange = _visiblePriceRange(startIdx, visibleCount);

      return RepaintBoundary(
        key: _repaintKey,
        child: GestureDetector(
          onLongPressStart: (d) => _onLongPressStart(
            d,
            chartWidth,
            totalHeight,
            visibleStart,
            startIdx,
            visibleCount,
          ),
          onLongPressMoveUpdate: (d) => _onLongPressDrag(d, visibleStart),
          onLongPressEnd: (_) {},
          onScaleStart: (d) => _onScaleStart(
            d,
            chartWidth,
            totalHeight,
            visibleStart,
            startIdx,
            visibleCount,
          ),
          onScaleUpdate: (d) => _onScaleUpdate(
            d,
            chartWidth,
            totalHeight,
            visibleStart,
            startIdx,
            visibleCount,
            priceRange,
          ),
          onScaleEnd: _onScaleEnd,
          onDoubleTapDown: (d) => _onDoubleTap(
            d.localPosition,
            chartWidth,
            totalHeight,
            visibleStart,
            startIdx,
            visibleCount,
          ),
          onTapUp: (d) => _onTap(
            d.localPosition,
            chartWidth,
            totalHeight,
            visibleStart,
            startIdx,
            visibleCount,
          ),
          child: _candles.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                )
              : CustomPaint(
                  painter: AdvancedChartPainter(
                    candles: _candles,
                    visibleStart: visibleStart,
                    visibleCount: visibleCount,
                    candleWidth: _candleWidth,
                    priceMin: priceRange.min,
                    priceMax: priceRange.max,
                    pointerPos: _activeTool == DrawingTool.pointer
                        ? _pointerPos
                        : null,
                    crosshairPos: _crosshairVisible ? _crosshairPos : null,
                    drawingCrosshair:
                        _activeTool != DrawingTool.none &&
                            _activeTool != DrawingTool.pointer
                        ? _drawCursor
                        : null,
                    drawings: _drawings,
                    inProgress: _drawPreview,
                    alerts: _alerts,
                    currentPrice: _currentPrice,
                    showVolume: _showVolume,
                    showRsi: _showRsi,
                    showMacd: _showMacd,
                    chartType: _chartType,
                    activeIndicators: _activeIndicators,
                    selectedDrawingId: _selection?.id,
                    rsiRatio: _rsiRatio,
                    macdRatio: _macdRatio,
                  ),
                  size: Size.infinite,
                ),
        ),
      );
    },
  );
}

class _PriceRange {
  final double min, max;
  double get span => max - min;
  const _PriceRange(this.min, this.max);
}

class _OHLCBar extends StatelessWidget {
  final Candle candle;
  final VoidCallback onDismiss;
  const _OHLCBar({required this.candle, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final color = candle.isBullish ? AppColors.bullish : AppColors.bearish;
    return ColoredBox(
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            OHLCItem(label: 'O', value: candle.open, color: color),
            OHLCItem(label: 'H', value: candle.high, color: AppColors.bullish),
            OHLCItem(label: 'L', value: candle.low, color: AppColors.bearish),
            OHLCItem(label: 'C', value: candle.close, color: color),
            Text(
              'V: ${candle.volume.formatVolume()}',
              style: ChartTheme.mono(11, color: AppColors.textSecondary),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(
                Symbols.close,
                size: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawingBanner extends StatelessWidget {
  final DrawingTool tool;
  final VoidCallback onDismiss;
  const _DrawingBanner({required this.tool, required this.onDismiss});

  static const _hints = {
    DrawingTool.horizontalLine: 'Drag to position · Tap to place line',
    DrawingTool.horizontalRay: 'Drag to position · Tap to place ray',
    DrawingTool.trendLine: 'Tap start · drag · tap to finish',
    DrawingTool.fibonacci: 'Tap start · drag · tap to finish',
    DrawingTool.rectangle: 'Tap start · drag · tap to finish',
    DrawingTool.pointer: 'Move finger over chart',
  };

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.primary.withAlpha(12),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(
        children: [
          Text(
            _hints[tool] ?? '',
            style: ChartTheme.sans(11, color: AppColors.primary),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(
              Symbols.close,
              size: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    ),
  );
}

class _DrawingContextSheet extends StatelessWidget {
  final ChartDrawing drawing;
  final VoidCallback onDelete;
  final VoidCallback onClone;
  final VoidCallback onSettings;

  const _DrawingContextSheet({
    required this.drawing,
    required this.onDelete,
    required this.onClone,
    required this.onSettings,
  });

  static String _label(ChartDrawing d) {
    if (d is HorizLineDrawing) return 'Horizontal Line';
    if (d is HorizRayDrawing) return 'Horizontal Ray';
    if (d is TrendLineDrawing) return 'Trend Line';
    if (d is FibDrawing) return 'Fibonacci';
    if (d is RectDrawing) return 'Rectangle';
    return 'Drawing';
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetHeader(title: _label(drawing)),
        _ActionTile(
          icon: Symbols.delete,
          label: 'Delete',
          color: AppColors.bearish,
          onTap: onDelete,
        ),
        _ActionTile(icon: Symbols.content_copy, label: 'Clone', onTap: onClone),
        _ActionTile(
          icon: Symbols.settings,
          label: 'Settings',
          onTap: onSettings,
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: color ?? AppColors.textSecondary, size: 20),
    title: Text(
      label,
      style: ChartTheme.sans(14, color: color ?? AppColors.textSecondary),
    ),
    onTap: onTap,
    dense: true,
  );
}

class _DrawingStyleSheet extends StatelessWidget {
  final ChartDrawing drawing;
  const _DrawingStyleSheet({required this.drawing});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetHeader(title: 'Style: ${_DrawingContextSheet._label(drawing)}'),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Color, line width, and dash pattern options.',
            style: ChartTheme.sans(13, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
}

class _ChartContextSheet extends StatelessWidget {
  final VoidCallback onAddDrawing;
  final VoidCallback onAddIndicator;
  final VoidCallback onResetView;
  const _ChartContextSheet({
    required this.onAddDrawing,
    required this.onAddIndicator,
    required this.onResetView,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SheetHeader(title: 'Chart Options'),
        _ActionTile(
          icon: Symbols.edit,
          label: 'Add Drawing',
          onTap: onAddDrawing,
        ),
        _ActionTile(
          icon: Symbols.toolbar,
          label: 'Add Indicator',
          onTap: onAddIndicator,
        ),
        _ActionTile(
          icon: Symbols.fit_screen,
          label: 'Reset View',
          onTap: onResetView,
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
}
