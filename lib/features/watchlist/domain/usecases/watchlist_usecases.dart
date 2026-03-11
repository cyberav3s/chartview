import 'package:chartview/core/utils/usecase/base_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:chartview/core/error/failure.dart';
import '../entities/watchlist.dart';
import '../repositories/watchlist_repository.dart';

class GetFolders implements UseCase<List<Watchlist>, NoParameters> {
  final WatchlistRepository _repo;
  const GetFolders(this._repo);

  @override
  Future<Either<Failure, List<Watchlist>>> call(NoParameters p) async =>
      _repo.getFolders();
}

class CreateFolder implements UseCase<Watchlist, String> {
  final WatchlistRepository _repo;
  const CreateFolder(this._repo);

  @override
  Future<Either<Failure, Watchlist>> call(String name) =>
      _repo.createFolder(name);
}

class RenameFolder implements UseCase<void, RenameFolderParams> {
  final WatchlistRepository _repo;
  const RenameFolder(this._repo);

  @override
  Future<Either<Failure, void>> call(RenameFolderParams p) =>
      _repo.renameFolder(p.folderId, p.name);
}

class DeleteFolder implements UseCase<void, String> {
  final WatchlistRepository _repo;
  const DeleteFolder(this._repo);

  @override
  Future<Either<Failure, void>> call(String folderId) =>
      _repo.deleteFolder(folderId);
}

class ReorderFolders implements UseCase<void, List<String>> {
  final WatchlistRepository _repo;
  const ReorderFolders(this._repo);

  @override
  Future<Either<Failure, void>> call(List<String> orderedIds) =>
      _repo.reorderFolders(orderedIds);
}

class CreateSection implements UseCase<ListSection, CreateSectionParams> {
  final WatchlistRepository _repo;
  const CreateSection(this._repo);

  @override
  Future<Either<Failure, ListSection>> call(CreateSectionParams p) =>
      _repo.createSection(p.folderId, p.name);
}

class RenameSection implements UseCase<void, RenameSectionParams> {
  final WatchlistRepository _repo;
  const RenameSection(this._repo);

  @override
  Future<Either<Failure, void>> call(RenameSectionParams p) =>
      _repo.renameSection(p.sectionId, p.name);
}

class DeleteSection implements UseCase<void, String> {
  final WatchlistRepository _repo;
  const DeleteSection(this._repo);

  @override
  Future<Either<Failure, void>> call(String sectionId) =>
      _repo.deleteSection(sectionId);
}

class SetSectionCollapsed implements UseCase<void, SetSectionCollapsedParams> {
  final WatchlistRepository _repo;
  const SetSectionCollapsed(this._repo);

  @override
  Future<Either<Failure, void>> call(SetSectionCollapsedParams p) =>
      _repo.setSectionCollapsed(p.sectionId, p.collapsed);
}

class AddSymbol implements UseCase<void, SymbolSectionParams> {
  final WatchlistRepository _repo;
  const AddSymbol(this._repo);

  @override
  Future<Either<Failure, void>> call(SymbolSectionParams p) =>
      _repo.addSymbol(p.sectionId, p.symbol);
}

class RemoveSymbol implements UseCase<void, SymbolSectionParams> {
  final WatchlistRepository _repo;
  const RemoveSymbol(this._repo);

  @override
  Future<Either<Failure, void>> call(SymbolSectionParams p) =>
      _repo.removeSymbol(p.sectionId, p.symbol);
}

class ReorderSymbols implements UseCase<void, ReorderSymbolsParams> {
  final WatchlistRepository _repo;
  const ReorderSymbols(this._repo);

  @override
  Future<Either<Failure, void>> call(ReorderSymbolsParams p) =>
      _repo.reorderSymbols(p.sectionId, p.orderedSymbols);
}

class MoveSymbol implements UseCase<void, MoveSymbolParams> {
  final WatchlistRepository _repo;
  const MoveSymbol(this._repo);

  @override
  Future<Either<Failure, void>> call(MoveSymbolParams p) =>
      _repo.moveSymbol(p.symbol, p.fromSectionId, p.toSectionId);
}

// ── Params ─────────────────────────────────────────────────────────────────

class RenameFolderParams {
  final String folderId, name;
  const RenameFolderParams(this.folderId, this.name);
}

class CreateSectionParams {
  final String folderId, name;
  const CreateSectionParams(this.folderId, this.name);
}

class RenameSectionParams {
  final String sectionId, name;
  const RenameSectionParams(this.sectionId, this.name);
}

class SetSectionCollapsedParams {
  final String sectionId;
  final bool collapsed;
  const SetSectionCollapsedParams(this.sectionId, this.collapsed);
}

class SymbolSectionParams {
  final String sectionId, symbol;
  const SymbolSectionParams(this.sectionId, this.symbol);
}

class ReorderSymbolsParams {
  final String sectionId;
  final List<String> orderedSymbols;
  const ReorderSymbolsParams(this.sectionId, this.orderedSymbols);
}

class MoveSymbolParams {
  final String symbol, fromSectionId, toSectionId;
  const MoveSymbolParams(this.symbol, this.fromSectionId, this.toSectionId);
}