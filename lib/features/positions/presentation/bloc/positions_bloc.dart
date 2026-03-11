import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/position_entity.dart';

part 'positions_event.dart';
part 'positions_state.dart';

const _uuid = Uuid();
final _rng = Random();

class PositionsBloc extends Bloc<PositionsEvent, PositionsState> {
  PositionsBloc() : super(PositionsInitial()) {
    on<LoadPositionsEvent>(_onLoad);
    on<TickPricesEvent>(_onTick);
    on<ClosePositionEvent>(_onClose);
    on<AddPositionEvent>(_onAdd);
    on<SetSortModeEvent>(_onToggleSort);
  }

  Timer? _ticker;

  // ── Seed positions ─────────────────────────────────────────────────────────

  static List<PositionEntity> _seed() => [
        PositionEntity(
          id: _uuid.v4(), symbol: 'AAPL', name: 'Apple Inc.',
          type: 'stock', side: PositionSide.long,
          quantity: 50, avgEntryPrice: 171.20, currentPrice: 182.50,
          openedAt: DateTime.now().subtract(const Duration(days: 12)),
        ),
        PositionEntity(
          id: _uuid.v4(), symbol: 'NVDA', name: 'NVIDIA Corp.',
          type: 'stock', side: PositionSide.long,
          quantity: 15, avgEntryPrice: 820.00, currentPrice: 875.40,
          openedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        PositionEntity(
          id: _uuid.v4(), symbol: 'TSLA', name: 'Tesla Inc.',
          type: 'stock', side: PositionSide.short,
          quantity: 20, avgEntryPrice: 255.80, currentPrice: 238.40,
          openedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        PositionEntity(
          id: _uuid.v4(), symbol: 'BTC', name: 'Bitcoin USD',
          type: 'crypto', side: PositionSide.long,
          quantity: 0.5, avgEntryPrice: 61500.00, currentPrice: 67420.00,
          openedAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
        PositionEntity(
          id: _uuid.v4(), symbol: 'ETH', name: 'Ethereum USD',
          type: 'crypto', side: PositionSide.long,
          quantity: 3.2, avgEntryPrice: 3200.00, currentPrice: 3540.00,
          openedAt: DateTime.now().subtract(const Duration(days: 8)),
        ),
        PositionEntity(
          id: _uuid.v4(), symbol: 'META', name: 'Meta Platforms',
          type: 'stock', side: PositionSide.short,
          quantity: 10, avgEntryPrice: 510.00, currentPrice: 492.60,
          openedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        PositionEntity(
          id: _uuid.v4(), symbol: 'MSFT', name: 'Microsoft Corp.',
          type: 'stock', side: PositionSide.long,
          quantity: 25, avgEntryPrice: 365.00, currentPrice: 378.90,
          openedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ];

  // ── Handlers ───────────────────────────────────────────────────────────────

  void _onLoad(LoadPositionsEvent e, Emitter<PositionsState> emit) {
    _ticker?.cancel();
    final positions = _seed();
    emit(PositionsLoaded(
      positions: positions,
      sortMode: PositionSortMode.byPnLDesc,
    ));
    // Simulate live price feed — tick every 1.5 s
    _ticker = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (!isClosed) add(TickPricesEvent());
    });
  }

  void _onTick(TickPricesEvent e, Emitter<PositionsState> emit) {
    if (state is! PositionsLoaded) return;
    final s = state as PositionsLoaded;
    // Each price drifts ±0.12% per tick  (crypto ±0.25%)
    final updated = s.positions.map((p) {
      final volatility = p.type == 'crypto' ? 0.0025 : 0.0012;
      final drift = (_rng.nextDouble() * 2 - 1) * volatility;
      final newPrice = (p.currentPrice * (1 + drift)).clamp(
        p.currentPrice * 0.85,
        p.currentPrice * 1.15,
      );
      return p.copyWith(currentPrice: double.parse(newPrice.toStringAsFixed(2)));
    }).toList();
    emit(s.copyWith(positions: updated));
  }

  void _onClose(ClosePositionEvent e, Emitter<PositionsState> emit) {
    if (state is! PositionsLoaded) return;
    final s = state as PositionsLoaded;
    final closed = s.positions.firstWhere((p) => p.id == e.positionId);
    final remaining = s.positions.where((p) => p.id != e.positionId).toList();
    emit(s.copyWith(
      positions: remaining,
      recentlyClosed: closed,
    ));
  }

  void _onAdd(AddPositionEvent e, Emitter<PositionsState> emit) {
    if (state is! PositionsLoaded) return;
    final s = state as PositionsLoaded;
    emit(s.copyWith(positions: [...s.positions, e.position]));
  }

  void _onToggleSort(SetSortModeEvent e, Emitter<PositionsState> emit) {
    if (state is! PositionsLoaded) return;
    final s = state as PositionsLoaded;
    emit(s.copyWith(sortMode: e.mode));
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}

extension PositionSort on List<PositionEntity> {
  List<PositionEntity> sorted(PositionSortMode mode) {
    final copy = List<PositionEntity>.from(this);
    switch (mode) {
      case PositionSortMode.byPnLDesc:
        copy.sort((a, b) => b.unrealizedPnL.compareTo(a.unrealizedPnL));
      case PositionSortMode.byPnLAsc:
        copy.sort((a, b) => a.unrealizedPnL.compareTo(b.unrealizedPnL));
      case PositionSortMode.byValue:
        copy.sort((a, b) => b.notionalValue.compareTo(a.notionalValue));
      case PositionSortMode.bySymbol:
        copy.sort((a, b) => a.symbol.compareTo(b.symbol));
    }
    return copy;
  }
}
