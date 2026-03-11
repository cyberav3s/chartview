part of 'positions_bloc.dart';

enum PositionSortMode { byPnLDesc, byPnLAsc, byValue, bySymbol }

abstract class PositionsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PositionsInitial extends PositionsState {}

class PositionsLoaded extends PositionsState {
  final List<PositionEntity> positions;
  final PositionSortMode sortMode;
  final PositionEntity? recentlyClosed;

  PositionsLoaded({
    required this.positions,
    required this.sortMode,
    this.recentlyClosed,
  });

  double get totalPnL => positions.fold(0.0, (sum, p) => sum + p.unrealizedPnL);

  double get totalValue =>
      positions.fold(0.0, (sum, p) => sum + p.notionalValue);

  double get totalCost => positions.fold(0.0, (sum, p) => sum + p.costBasis);

  double get totalPnLPercent =>
      totalCost == 0 ? 0 : (totalPnL / totalCost) * 100;

  int get winnersCount => positions.where((p) => p.isProfit).length;

  int get losersCount => positions.where((p) => !p.isProfit).length;

  List<PositionEntity> get sortedPositions => positions.sorted(sortMode);

  PositionsLoaded copyWith({
    List<PositionEntity>? positions,
    PositionSortMode? sortMode,
    PositionEntity? recentlyClosed,
  }) => PositionsLoaded(
    positions: positions ?? this.positions,
    sortMode: sortMode ?? this.sortMode,
    recentlyClosed: recentlyClosed ?? this.recentlyClosed,
  );

  @override
  List<Object?> get props => [positions, sortMode];
}
