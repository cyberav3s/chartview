part of 'watchlist_bloc.dart';

enum WatchlistStatus { initial, loading, loaded, error }

class WatchlistState extends Equatable {
  final List<Watchlist> folders;
  final Map<String, StockEntity> stockMap;
  final int activeIndex;
  final WatchlistStatus status;
  final String message;

  const WatchlistState({
    this.folders = const [],
    this.stockMap = const {},
    this.activeIndex = 0,
    this.status = WatchlistStatus.initial,
    this.message = '',
  });

  bool get isLoading => status == WatchlistStatus.loading;
  bool get hasError => status == WatchlistStatus.error;
  bool get isLoaded => status == WatchlistStatus.loaded;

  Watchlist? get activeFolder =>
      folders.isEmpty ? null : folders[activeIndex.clamp(0, folders.length - 1)];

  WatchlistState copyWith({
    List<Watchlist>? folders,
    Map<String, StockEntity>? stockMap,
    int? activeIndex,
    WatchlistStatus? status,
    String? message,
  }) {
    return WatchlistState(
      folders: folders ?? this.folders,
      stockMap: stockMap ?? this.stockMap,
      activeIndex: activeIndex ?? this.activeIndex,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [folders, activeIndex, status, message];
}