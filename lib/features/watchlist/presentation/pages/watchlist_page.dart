import 'package:chartview/core/widgets/app_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/watchlist_bloc.dart';
import '../../domain/entities/watchlist.dart';
import '../widgets/section_list.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  @override
  void initState() {
    super.initState();
    context.read<WatchlistBloc>().add(const LoadWatchlistEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (ctx, state) {
        if (state.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        }
        if (state.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(
                state.message,
                style: GoogleFonts.inter(color: AppColors.textMuted),
              ),
            ),
          );
        }

        final activeFolder = state.activeFolder;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            titleSpacing: 16,
            leading: IconButton(
              icon: const Icon(
                Icons.more_horiz,
                color: AppColors.textSecondary,
              ),
              onPressed: activeFolder != null
                  ? () => _showFolderMenu(ctx, activeFolder, state)
                  : null,
            ),
            centerTitle: true,
            title: Text(
              'Watchlists',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _showCreateDialog(ctx),
                icon: const Icon(Symbols.add_2, color: AppColors.textSecondary),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: AppTabbar(
                tabs: state.folders
                    .map((e) => AppTabbarItem(id: e.id, label: e.name))
                    .toList(),
                activeIndex: state.activeIndex,
                onTabChanged: (i) =>
                    ctx.read<WatchlistBloc>().add(SetActiveIndexEvent(i)),
                onReorder: (oldIdx, newIdx) {
                  ctx.read<WatchlistBloc>().add(
                    ReorderWatchlistsEvent(oldIdx, newIdx),
                  );
                },
                onTabLongPress: (e) {},
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: state.folders.isEmpty || activeFolder == null
                    ? _EmptyState(onAdd: () => _showCreateDialog(ctx))
                    : SectionList(
                        sections: activeFolder.sections,
                        stockMap: state.stockMap,
                        folderId: activeFolder.id,
                        onToggleCollapse: (id) => ctx.read<WatchlistBloc>().add(
                          ToggleSectionCollapsed(id),
                        ),
                        onRenameSection: (id) => _showRenameSection(
                          ctx,
                          id,
                          activeFolder.sections
                              .firstWhere((s) => s.id == id)
                              .name,
                        ),
                        onDeleteSection: (id) => _confirmDeleteSection(ctx, id),
                        onReorder: (sectionId, oldIdx, newIdx) =>
                            ctx.read<WatchlistBloc>().add(
                              ReorderSymbolsInSection(
                                sectionId,
                                oldIdx,
                                newIdx,
                              ),
                            ),
                        onRemoveSymbol: (symbol, sectionId) => ctx
                            .read<WatchlistBloc>()
                            .add(RemoveSymbolFromSection(sectionId, symbol)),
                        onAddSection: () =>
                            _showAddSection(ctx, activeFolder.id),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFolderMenu(
    BuildContext ctx,
    Watchlist folder,
    WatchlistState state,
  ) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text(
                  folder.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${folder.allSymbols.length} symbols',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ListTile(
            leading: const Icon(
              Icons.drive_file_rename_outline,
              color: AppColors.textSecondary,
              size: 20,
            ),
            title: Text(
              'Rename watchlist',
              style: GoogleFonts.inter(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(ctx);
              _showRenameFolder(ctx, folder);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.create_new_folder_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            title: Text(
              'Add section',
              style: GoogleFonts.inter(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(ctx);
              _showAddSection(ctx, folder.id);
            },
          ),
          if (state.folders.length > 1)
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: AppColors.bearish,
                size: 20,
              ),
              title: Text(
                'Delete watchlist',
                style: GoogleFonts.inter(color: AppColors.bearish),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteFolder(ctx, folder);
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext ctx) => _showNameDialog(
    ctx,
    title: 'New Watchlist',
    hint: 'e.g. India Market',
    onConfirm: (name) {
      ctx.read<WatchlistBloc>().add(CreateWatchlistEvent(name));
    },
  );

  void _showRenameFolder(BuildContext ctx, Watchlist folder) => _showNameDialog(
    ctx,
    title: 'Rename Watchlist',
    initial: folder.name,
    onConfirm: (name) {
      ctx.read<WatchlistBloc>().add(RenameWatchlistEvent(folder.id, name));
    },
  );

  void _showAddSection(BuildContext ctx, String folderId) => _showNameDialog(
    ctx,
    title: 'New Section',
    hint: 'e.g. FUTURES',
    onConfirm: (name) {
      ctx.read<WatchlistBloc>().add(
        AddSectionEvent(folderId, name.toUpperCase()),
      );
    },
  );

  void _showRenameSection(BuildContext ctx, String sectionId, String current) =>
      _showNameDialog(
        ctx,
        title: 'Rename Section',
        initial: current,
        onConfirm: (name) {
          ctx.read<WatchlistBloc>().add(
            RenameSectionEvent(sectionId, name.toUpperCase()),
          );
        },
      );

  void _showNameDialog(
    BuildContext ctx, {
    required String title,
    String? initial,
    String hint = '',
    required void Function(String) onConfirm,
  }) {
    final ctrl = TextEditingController(text: initial);
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: GoogleFonts.inter(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final v = ctrl.text.trim();
              if (v.isNotEmpty) {
                onConfirm(v);
                Navigator.pop(ctx);
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFolder(BuildContext ctx, Watchlist folder) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Delete "${folder.name}"?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This will delete the watchlist and all ${folder.allSymbols.length} symbols inside it.',
          style: GoogleFonts.inter(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bearish,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ctx.read<WatchlistBloc>().add(DeleteWatchlistEvent(folder.id));
              Navigator.pop(ctx);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSection(BuildContext ctx, String sectionId) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Delete section?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'All symbols in this section will be removed.',
          style: GoogleFonts.inter(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bearish,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ctx.read<WatchlistBloc>().add(DeleteSectionEvent(sectionId));
              Navigator.pop(ctx);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.bookmarks_outlined,
          color: AppColors.textMuted,
          size: 56,
        ),
        const SizedBox(height: 14),
        Text(
          'No watchlists',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tap + to create your first watchlist',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 16),
          label: Text(
            'Create Watchlist',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}
