import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class LocalDatabase {
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();
  static final LocalDatabase _instance = LocalDatabase._internal();
  static Database? _sqliteDatabase;

  Future<Database> get sqlite async {
    if (_sqliteDatabase != null && _sqliteDatabase!.isOpen) {
      return _sqliteDatabase!;
    }
    _sqliteDatabase = await _initDatabase();
    return _sqliteDatabase!;
  }

  String generateId() => _uuid.v4();

  static Future<void> init() async {
    await _instance._initDatabase();
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'watchlist.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      singleInstance: true,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE watchlist_folders (
        id        TEXT PRIMARY KEY,
        name      TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE watchlist_sections (
        id         TEXT PRIMARY KEY,
        folder_id  TEXT NOT NULL,
        name       TEXT NOT NULL,
        collapsed  INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (folder_id) REFERENCES watchlist_folders(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE watchlist_symbols (
        id         TEXT PRIMARY KEY,
        section_id TEXT NOT NULL,
        symbol     TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (section_id) REFERENCES watchlist_sections(id) ON DELETE CASCADE
      )
    ''');

    await _seedDefaults(db);
  }

  Future<void> _seedDefaults(Database db) async {
    final seed = [
      (
        name: 'Global Market',
        sections: [
          (name: 'TECH', symbols: ['AAPL', 'NVDA', 'MSFT', 'GOOGL', 'META']),
          (name: 'CRYPTO', symbols: ['BTC', 'ETH', 'SOL']),
          (name: 'INDICES', symbols: ['SPY', 'QQQ']),
        ],
      ),
      (
        name: 'My Picks',
        sections: [
          (name: 'WATCHLIST', symbols: ['TSLA', 'AMD', 'AMZN', 'JPM']),
        ],
      ),
    ];

    final batch = db.batch();
    for (int fi = 0; fi < seed.length; fi++) {
      final folder = seed[fi];
      final folderId = _uuid.v4();
      batch.insert('watchlist_folders', {
        'id': folderId,
        'name': folder.name,
        'sort_order': fi,
      });
      for (int si = 0; si < folder.sections.length; si++) {
        final section = folder.sections[si];
        final sectionId = _uuid.v4();
        batch.insert('watchlist_sections', {
          'id': sectionId,
          'folder_id': folderId,
          'name': section.name,
          'collapsed': 0,
          'sort_order': si,
        });
        for (int symi = 0; symi < section.symbols.length; symi++) {
          batch.insert('watchlist_symbols', {
            'id': _uuid.v4(),
            'section_id': sectionId,
            'symbol': section.symbols[symi],
            'sort_order': symi,
          });
        }
      }
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    if (_sqliteDatabase != null && _sqliteDatabase!.isOpen) {
      await _sqliteDatabase!.close();
    }
    _sqliteDatabase = null;
  }
}