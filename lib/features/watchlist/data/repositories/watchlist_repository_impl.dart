import 'package:chartview/core/error/exceptions.dart';
import 'package:chartview/core/error/failure.dart';
import 'package:chartview/features/watchlist/data/datasources/watchlist_remote_data_source.dart';
import 'package:chartview/features/watchlist/domain/entities/watchlist.dart';
import 'package:chartview/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:dartz/dartz.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistLocalDataSource _localDataSource;

  WatchlistRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<Watchlist>>> getFolders() async {
    try {
      final result = await _localDataSource.getFolders();
      return Right(result);
    } on ServerException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  @override
  Future<Either<Failure, Watchlist>> createFolder(String name) async {
    try {
      final result = await _localDataSource.createFolder(name);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  @override
  Future<Either<Failure, void>> renameFolder(
    String folderId,
    String name,
  ) async {
    try {
      await _localDataSource.renameFolder(folderId, name);
      return const Right(null);
    } on ServerException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFolder(String folderId) async {
    try {
      await _localDataSource.deleteFolder(folderId);
      return const Right(null);
    } on ServerException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  @override
  Future<Either<Failure, void>> reorderFolders(List<String> ids) async {
    try {
      await _localDataSource.reorderFolders(ids);
      return const Right(null);
    } on ServerException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  @override
  Future<Either<Failure, ListSection>> createSection(
    String folderId,
    String name,
  ) async {
    try {
      final result = await _localDataSource.createSection(folderId, name);
      return Right(result);
    } on ServerException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  @override
  Future<Either<Failure, void>> renameSection(
    String sectionId,
    String name,
  ) async {
    try {
      await _localDataSource.renameSection(sectionId, name);
      return const Right(null);
    } on ServerException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSection(String sectionId) async {
    try {
      await _localDataSource.deleteSection(sectionId);
      return const Right(null);
    } on ServerException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  @override
  Future<Either<Failure, void>> setSectionCollapsed(
    String sectionId,
    bool collapsed,
  ) async {
    try {
      await _localDataSource.setSectionCollapsed(sectionId, collapsed);
      return const Right(null);
    } on ServerException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  @override
  Future<Either<Failure, void>> addSymbol(
    String sectionId,
    String symbol,
  ) async {
    try {
      await _localDataSource.addSymbol(sectionId, symbol);
      return const Right(null);
    } on ServerException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeSymbol(
    String sectionId,
    String symbol,
  ) async {
    try {
      await _localDataSource.removeSymbol(sectionId, symbol);
      return const Right(null);
    } on ServerException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  @override
  Future<Either<Failure, void>> reorderSymbols(
    String sectionId,
    List<String> symbols,
  ) async {
    try {
      await _localDataSource.reorderSymbols(sectionId, symbols);
      return const Right(null);
    } on ServerException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  @override
  Future<Either<Failure, void>> moveSymbol(
    String symbol,
    String from,
    String to,
  ) async {
    try {
      await _localDataSource.moveSymbol(symbol, from, to);
      return const Right(null);
    } on ServerException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }
}
