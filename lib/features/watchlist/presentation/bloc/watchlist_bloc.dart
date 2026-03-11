import 'package:chartview/core/utils/usecase/base_usecase.dart';
import 'package:chartview/features/market/domain/entities/stock_entity.dart';
import 'package:chartview/features/watchlist/domain/usecases/watchlist_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/mock_data_generator.dart';
import '../../domain/entities/watchlist.dart';

part 'watchlist_event.dart';
part 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final GetFolders _getFolders;
  final CreateFolder _createFolder;
  final RenameFolder _renameFolder;
  final DeleteFolder _deleteFolder;
  final ReorderFolders _reorderFolders;
  final CreateSection _createSection;
  final RenameSection _renameSection;
  final DeleteSection _deleteSection;
  final SetSectionCollapsed _setSectionCollapsed;
  final AddSymbol _addSymbol;
  final RemoveSymbol _removeSymbol;
  final ReorderSymbols _reorderSymbols;
  final MoveSymbol _moveSymbol;

  WatchlistBloc(
    this._addSymbol,
    this._getFolders,
    this._createFolder,
    this._renameFolder,
    this._deleteFolder,
    this._reorderFolders,
    this._createSection,
    this._renameSection,
    this._deleteSection,
    this._setSectionCollapsed,
    this._removeSymbol,
    this._reorderSymbols,
    this._moveSymbol,
  ) : super(const WatchlistState()) {
    on<LoadWatchlistEvent>(_onLoad);
    on<CreateWatchlistEvent>(_onCreate);
    on<RenameWatchlistEvent>(_onRename);
    on<DeleteWatchlistEvent>(_onDelete);
    on<ReorderWatchlistsEvent>(_onReorderWatchlists);
    on<AddSectionEvent>(_onAddSection);
    on<RenameSectionEvent>(_onRenameSection);
    on<DeleteSectionEvent>(_onDeleteSection);
    on<ToggleSectionCollapsed>(_onToggleSection);
    on<AddSymbolToSection>(_onAddSymbol);
    on<RemoveSymbolFromSection>(_onRemoveSymbol);
    on<ReorderSymbolsInSection>(_onReorderSymbols);
    on<MoveSymbolToSection>(_onMoveSymbol);
    on<SetActiveIndexEvent>(_onSetActive);
  }

  final _stockMap = <String, StockEntity>{
    for (final s in MockDataGenerator.generateStocks()) s.symbol: s,
  };

  int get _currentIndex => state.activeIndex;

  Future<void> _reload(Emitter<WatchlistState> emit, {int? activeIndex}) async {
    final res = await _getFolders(const NoParameters());
    res.fold(
      (error) => emit(
        state.copyWith(status: WatchlistStatus.error, message: error.message),
      ),
      (folders) {
        final idx = (activeIndex ?? _currentIndex).clamp(
          0,
          (folders.length - 1).clamp(0, 999),
        );
        emit(
          state.copyWith(
            status: WatchlistStatus.loaded,
            folders: folders,
            stockMap: _stockMap,
            activeIndex: idx,
            message: '',
          ),
        );
      },
    );
  }

  Future<void> _onLoad(
    LoadWatchlistEvent e,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(status: WatchlistStatus.loading));
    await _reload(emit);
  }

  Future<void> _onCreate(
    CreateWatchlistEvent e,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(status: WatchlistStatus.loading));
    final res = await _createFolder(e.name);
    if (res.isLeft()) {
      res.fold(
        (error) => emit(
          state.copyWith(status: WatchlistStatus.error, message: error.message),
        ),
        (_) {},
      );
    } else {
      await _reload(emit, activeIndex: state.folders.length);
    }
  }

  Future<void> _onRename(
    RenameWatchlistEvent e,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(status: WatchlistStatus.loading));
    final res = await _renameFolder(RenameFolderParams(e.folderId, e.name));
    if (res.isLeft()) {
      res.fold(
        (error) => emit(
          state.copyWith(status: WatchlistStatus.error, message: error.message),
        ),
        (_) {},
      );
    } else {
      await _reload(emit);
    }
  }

  Future<void> _onDelete(
    DeleteWatchlistEvent e,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(status: WatchlistStatus.loading));
    final res = await _deleteFolder(e.folderId);
    if (res.isLeft()) {
      res.fold(
        (error) => emit(
          state.copyWith(status: WatchlistStatus.error, message: error.message),
        ),
        (_) {},
      );
    } else {
      await _reload(emit);
    }
  }

  Future<void> _onReorderWatchlists(
    ReorderWatchlistsEvent e,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(status: WatchlistStatus.loading));
    final folders = List<Watchlist>.from(state.folders);
    final item = folders.removeAt(e.oldIndex);
    folders.insert(e.newIndex, item);
    final res = await _reorderFolders(folders.map((f) => f.id).toList());
    if (res.isLeft()) {
      res.fold(
        (error) => emit(
          state.copyWith(status: WatchlistStatus.error, message: error.message),
        ),
        (_) {},
      );
    } else {
      await _reload(emit, activeIndex: e.newIndex);
    }
  }

  Future<void> _onAddSection(
    AddSectionEvent e,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(status: WatchlistStatus.loading));
    final res = await _createSection(CreateSectionParams(e.folderId, e.name));
    if (res.isLeft()) {
      res.fold(
        (error) => emit(
          state.copyWith(status: WatchlistStatus.error, message: error.message),
        ),
        (_) {},
      );
    } else {
      await _reload(emit);
    }
  }

  Future<void> _onRenameSection(
    RenameSectionEvent e,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(status: WatchlistStatus.loading));
    final res = await _renameSection(RenameSectionParams(e.sectionId, e.name));
    if (res.isLeft()) {
      res.fold(
        (error) => emit(
          state.copyWith(status: WatchlistStatus.error, message: error.message),
        ),
        (_) {},
      );
    } else {
      await _reload(emit);
    }
  }

  Future<void> _onDeleteSection(
    DeleteSectionEvent e,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(status: WatchlistStatus.loading));
    final res = await _deleteSection(e.sectionId);
    if (res.isLeft()) {
      res.fold(
        (error) => emit(
          state.copyWith(status: WatchlistStatus.error, message: error.message),
        ),
        (_) {},
      );
    } else {
      await _reload(emit);
    }
  }

  Future<void> _onToggleSection(
    ToggleSectionCollapsed e,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(status: WatchlistStatus.loading));
    final section = state.folders
        .expand((f) => f.sections)
        .firstWhere((s) => s.id == e.sectionId);
    final res = await _setSectionCollapsed(
      SetSectionCollapsedParams(e.sectionId, !section.collapsed),
    );
    if (res.isLeft()) {
      res.fold(
        (error) => emit(
          state.copyWith(status: WatchlistStatus.error, message: error.message),
        ),
        (_) {},
      );
    } else {
      await _reload(emit);
    }
  }

  Future<void> _onAddSymbol(
    AddSymbolToSection e,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(status: WatchlistStatus.loading));
    final res = await _addSymbol(SymbolSectionParams(e.sectionId, e.symbol));
    if (res.isLeft()) {
      res.fold(
        (error) => emit(
          state.copyWith(status: WatchlistStatus.error, message: error.message),
        ),
        (_) {},
      );
    } else {
      await _reload(emit);
    }
  }

  Future<void> _onRemoveSymbol(
    RemoveSymbolFromSection e,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(status: WatchlistStatus.loading));
    final res = await _removeSymbol(SymbolSectionParams(e.sectionId, e.symbol));
    if (res.isLeft()) {
      res.fold(
        (error) => emit(
          state.copyWith(status: WatchlistStatus.error, message: error.message),
        ),
        (_) {},
      );
    } else {
      await _reload(emit);
    }
  }

  Future<void> _onReorderSymbols(
    ReorderSymbolsInSection e,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(status: WatchlistStatus.loading));
    final section = state.folders
        .expand((f) => f.sections)
        .firstWhere((s) => s.id == e.sectionId);
    final syms = List<String>.from(section.symbols);
    final item = syms.removeAt(e.oldIndex);
    final targetIdx = e.newIndex > e.oldIndex ? e.newIndex - 1 : e.newIndex;
    syms.insert(targetIdx, item);
    final res = await _reorderSymbols(ReorderSymbolsParams(e.sectionId, syms));
    if (res.isLeft()) {
      res.fold(
        (error) => emit(
          state.copyWith(status: WatchlistStatus.error, message: error.message),
        ),
        (_) {},
      );
    } else {
      await _reload(emit);
    }
  }

  Future<void> _onMoveSymbol(
    MoveSymbolToSection e,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(status: WatchlistStatus.loading));
    final res = await _moveSymbol(
      MoveSymbolParams(e.symbol, e.fromSectionId, e.toSectionId),
    );
    if (res.isLeft()) {
      res.fold(
        (error) => emit(
          state.copyWith(status: WatchlistStatus.error, message: error.message),
        ),
        (_) {},
      );
    } else {
      await _reload(emit);
    }
  }

  void _onSetActive(SetActiveIndexEvent e, Emitter<WatchlistState> emit) {
    emit(state.copyWith(activeIndex: e.index));
  }
}
