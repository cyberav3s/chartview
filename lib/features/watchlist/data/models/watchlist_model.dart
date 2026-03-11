import '../../domain/entities/watchlist.dart';

extension WatchlistFolderModel on Watchlist {
  static Watchlist fromRow(
    Map<String, dynamic> folderRow,
    List<ListSection> sections,
  ) => Watchlist(
    id: folderRow['id'] as String,
    name: folderRow['name'] as String,
    sections: sections,
  );
}

extension WatchlistSectionModel on ListSection {
  static ListSection fromRow(
    Map<String, dynamic> sectionRow,
    List<String> symbols,
  ) => ListSection(
    id: sectionRow['id'] as String,
    name: sectionRow['name'] as String,
    symbols: symbols,
    collapsed: (sectionRow['collapsed'] as int) == 1,
  );

  Map<String, dynamic> toRow(String folderId, int sortOrder) => {
    'id': id,
    'folder_id': folderId,
    'name': name,
    'collapsed': collapsed ? 1 : 0,
    'sort_order': sortOrder,
  };
}
