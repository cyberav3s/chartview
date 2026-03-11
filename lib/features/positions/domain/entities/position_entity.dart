import 'package:equatable/equatable.dart';

enum PositionSide { long, short }

class PositionEntity extends Equatable {
  final String id;
  final String symbol;
  final String name;
  final String type;
  final PositionSide side;
  final double quantity;
  final double avgEntryPrice;
  final double currentPrice;
  final DateTime openedAt;

  const PositionEntity({
    required this.id,
    required this.symbol,
    required this.name,
    required this.type,
    required this.side,
    required this.quantity,
    required this.avgEntryPrice,
    required this.currentPrice,
    required this.openedAt,
  });

  // ── Computed P&L ──────────────────────────────────────────────────────────

  double get notionalValue => quantity * currentPrice;

  double get unrealizedPnL {
    final diff = currentPrice - avgEntryPrice;
    return side == PositionSide.long
        ? diff * quantity
        : -diff * quantity;
  }

  double get unrealizedPnLPercent {
    if (avgEntryPrice == 0) return 0;
    return (unrealizedPnL / (avgEntryPrice * quantity)) * 100;
  }

  double get costBasis => avgEntryPrice * quantity;

  bool get isProfit => unrealizedPnL >= 0;

  PositionEntity copyWith({double? currentPrice}) => PositionEntity(
        id: id,
        symbol: symbol,
        name: name,
        type: type,
        side: side,
        quantity: quantity,
        avgEntryPrice: avgEntryPrice,
        currentPrice: currentPrice ?? this.currentPrice,
        openedAt: openedAt,
      );

  @override
  List<Object?> get props =>
      [id, symbol, side, quantity, avgEntryPrice, currentPrice];
}
