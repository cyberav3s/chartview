part of 'positions_bloc.dart';

abstract class PositionsEvent extends Equatable {
  const PositionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPositionsEvent extends PositionsEvent {
  const LoadPositionsEvent();
}

class TickPricesEvent extends PositionsEvent {
  const TickPricesEvent();
}

class ClosePositionEvent extends PositionsEvent {
  final String positionId;
  const ClosePositionEvent(this.positionId);
  @override List<Object?> get props => [positionId];
}

class AddPositionEvent extends PositionsEvent {
  final PositionEntity position;
  const AddPositionEvent(this.position);
  @override List<Object?> get props => [position];
}

class SetSortModeEvent extends PositionsEvent {
  final PositionSortMode mode;
  const SetSortModeEvent(this.mode);
  @override List<Object?> get props => [mode];
}