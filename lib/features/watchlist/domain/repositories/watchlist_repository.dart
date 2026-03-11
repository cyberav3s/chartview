import 'package:chartview/core/error/failure.dart';
import 'package:dartz/dartz.dart';

import '../entities/watchlist.dart';

abstract interface class WatchlistRepository {
  Future<Either<Failure, List<Watchlist>>> getFolders();
  Future<Either<Failure, Watchlist>> createFolder(String name);
  Future<Either<Failure, void>> renameFolder(String folderId, String name);
  Future<Either<Failure, void>> deleteFolder(String folderId);
  Future<Either<Failure, void>> reorderFolders(List<String> orderedIds);
  Future<Either<Failure, ListSection>> createSection(String folderId, String name);
  Future<Either<Failure, void>> renameSection(String sectionId, String name);
  Future<Either<Failure, void>> deleteSection(String sectionId);
  Future<Either<Failure, void>> setSectionCollapsed(String sectionId, bool collapsed);
  Future<Either<Failure, void>> addSymbol(String sectionId, String symbol);
  Future<Either<Failure, void>> removeSymbol(String sectionId, String symbol);
  Future<Either<Failure, void>> reorderSymbols(String sectionId, List<String> orderedSymbols);
  Future<Either<Failure, void>> moveSymbol(String symbol, String fromSectionId, String toSectionId);
}
