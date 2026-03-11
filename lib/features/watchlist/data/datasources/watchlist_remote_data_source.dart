import 'package:chartview/core/database/local_database.dart';
import 'package:chartview/features/watchlist/domain/entities/watchlist.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class WatchlistLocalDataSource {
  Future<List<Watchlist>> getFolders();
  Future<Watchlist> createFolder(String name);
  Future<void> renameFolder(String folderId, String name);
  Future<void> deleteFolder(String folderId);
  Future<void> reorderFolders(List<String> orderedIds);
  Future<ListSection> createSection(String folderId, String name);
  Future<void> renameSection(String sectionId, String name);
  Future<void> deleteSection(String sectionId);
  Future<void> setSectionCollapsed(String sectionId, bool collapsed);
  Future<void> addSymbol(String sectionId, String symbol);
  Future<void> removeSymbol(String sectionId, String symbol);
  Future<void> reorderSymbols(String sectionId, List<String> orderedSymbols);
  Future<void> moveSymbol(
    String symbol,
    String fromSectionId,
    String toSectionId,
  );
}

class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  final LocalDatabase _db;
  WatchlistLocalDataSourceImpl(this._db);

  @override
  Future<List<Watchlist>> getFolders() async {
    final db = await _db.sqlite;

    final folderRows = await db.query(
      'watchlist_folders',
      orderBy: 'sort_order ASC',
    );
    final sectionRows = await db.query(
      'watchlist_sections',
      orderBy: 'sort_order ASC',
    );
    final symbolRows = await db.query(
      'watchlist_symbols',
      orderBy: 'sort_order ASC',
    );

    final symbolsBySectionId = <String, List<String>>{};
    for (final row in symbolRows) {
      symbolsBySectionId
          .putIfAbsent(row['section_id'] as String, () => [])
          .add(row['symbol'] as String);
    }

    final sectionsByFolderId = <String, List<ListSection>>{};
    for (final row in sectionRows) {
      final sid = row['id'] as String;
      sectionsByFolderId
          .putIfAbsent(row['folder_id'] as String, () => [])
          .add(
            ListSection(
              id: sid,
              name: row['name'] as String,
              symbols: symbolsBySectionId[sid] ?? [],
              collapsed: (row['collapsed'] as int) == 1,
            ),
          );
    }

    return folderRows.map((row) {
      final fid = row['id'] as String;
      return Watchlist(
        id: fid,
        name: row['name'] as String,
        sections: sectionsByFolderId[fid] ?? [],
      );
    }).toList();
  }

  @override
  Future<Watchlist> createFolder(String name) async {
    final db = await _db.sqlite;
    final id = _db.generateId();
    final maxOrder =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT MAX(sort_order) FROM watchlist_folders'),
        ) ??
        -1;
    await db.insert('watchlist_folders', {
      'id': id,
      'name': name,
      'sort_order': maxOrder + 1,
    });
    return Watchlist(id: id, name: name, sections: []);
  }

  @override
  Future<void> renameFolder(String folderId, String name) async {
    final db = await _db.sqlite;
    await db.update(
      'watchlist_folders',
      {'name': name},
      where: 'id = ?',
      whereArgs: [folderId],
    );
  }

  @override
  Future<void> deleteFolder(String folderId) async {
    final db = await _db.sqlite;
    await db.delete(
      'watchlist_folders',
      where: 'id = ?',
      whereArgs: [folderId],
    );
  }

  @override
  Future<void> reorderFolders(List<String> orderedIds) async {
    final db = await _db.sqlite;
    final batch = db.batch();
    for (int i = 0; i < orderedIds.length; i++) {
      batch.update(
        'watchlist_folders',
        {'sort_order': i},
        where: 'id = ?',
        whereArgs: [orderedIds[i]],
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<ListSection> createSection(String folderId, String name) async {
    final db = await _db.sqlite;
    final id = _db.generateId();
    final maxOrder =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT MAX(sort_order) FROM watchlist_sections WHERE folder_id = ?',
            [folderId],
          ),
        ) ??
        -1;
    await db.insert('watchlist_sections', {
      'id': id,
      'folder_id': folderId,
      'name': name,
      'collapsed': 0,
      'sort_order': maxOrder + 1,
    });
    return ListSection(id: id, name: name, symbols: []);
  }

  @override
  Future<void> renameSection(String sectionId, String name) async {
    final db = await _db.sqlite;
    await db.update(
      'watchlist_sections',
      {'name': name},
      where: 'id = ?',
      whereArgs: [sectionId],
    );
  }

  @override
  Future<void> deleteSection(String sectionId) async {
    final db = await _db.sqlite;
    await db.delete(
      'watchlist_sections',
      where: 'id = ?',
      whereArgs: [sectionId],
    );
  }

  @override
  Future<void> setSectionCollapsed(String sectionId, bool collapsed) async {
    final db = await _db.sqlite;
    await db.update(
      'watchlist_sections',
      {'collapsed': collapsed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [sectionId],
    );
  }

  @override
  Future<void> addSymbol(String sectionId, String symbol) async {
    final db = await _db.sqlite;
    final exists =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM watchlist_symbols WHERE section_id = ? AND symbol = ?',
            [sectionId, symbol],
          ),
        ) ??
        0;
    if (exists > 0) return;
    final maxOrder =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT MAX(sort_order) FROM watchlist_symbols WHERE section_id = ?',
            [sectionId],
          ),
        ) ??
        -1;
    await db.insert('watchlist_symbols', {
      'id': _db.generateId(),
      'section_id': sectionId,
      'symbol': symbol,
      'sort_order': maxOrder + 1,
    });
  }

  @override
  Future<void> removeSymbol(String sectionId, String symbol) async {
    final db = await _db.sqlite;
    await db.delete(
      'watchlist_symbols',
      where: 'section_id = ? AND symbol = ?',
      whereArgs: [sectionId, symbol],
    );
  }

  @override
  Future<void> reorderSymbols(
    String sectionId,
    List<String> orderedSymbols,
  ) async {
    final db = await _db.sqlite;
    final batch = db.batch();
    for (int i = 0; i < orderedSymbols.length; i++) {
      batch.update(
        'watchlist_symbols',
        {'sort_order': i},
        where: 'section_id = ? AND symbol = ?',
        whereArgs: [sectionId, orderedSymbols[i]],
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> moveSymbol(
    String symbol,
    String fromSectionId,
    String toSectionId,
  ) async {
    final db = await _db.sqlite;
    await db.delete(
      'watchlist_symbols',
      where: 'section_id = ? AND symbol = ?',
      whereArgs: [fromSectionId, symbol],
    );
    await addSymbol(toSectionId, symbol);
  }
}
