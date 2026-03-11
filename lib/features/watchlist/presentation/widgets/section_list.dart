import 'package:chartview/features/chart/presentation/pages/chart_page.dart';
import 'package:chartview/features/market/domain/entities/stock_entity.dart';
import 'package:chartview/core/widgets/stock_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/watchlist.dart';

class SectionList extends StatelessWidget {
  final List<ListSection> sections;
  final Map<String, StockEntity> stockMap;
  final String folderId;
  final void Function(String sectionId) onToggleCollapse;
  final void Function(String sectionId) onRenameSection;
  final void Function(String sectionId) onDeleteSection;
  final void Function(String sectionId, int oldIndex, int newIndex) onReorder;
  final void Function(String symbol, String sectionId) onRemoveSymbol;
  final VoidCallback onAddSection;

  const SectionList({
    super.key,
    required this.sections,
    required this.stockMap,
    required this.folderId,
    required this.onToggleCollapse,
    required this.onRenameSection,
    required this.onDeleteSection,
    required this.onReorder,
    required this.onRemoveSymbol,
    required this.onAddSection,
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return _EmptyFolder(onAdd: onAddSection);
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: sections.length + 1,
      itemBuilder: (_, i) {
        if (i == sections.length) {
          return _AddSectionButton(onTap: onAddSection);
        }
        final sec = sections[i];
        return _SectionBlock(
          key: ValueKey(sec.id),
          section: sec,
          stockMap: stockMap,
          onToggleCollapse: () => onToggleCollapse(sec.id),
          onRename: () => onRenameSection(sec.id),
          onDelete: () => onDeleteSection(sec.id),
          onReorder: (oldIdx, newIdx) => onReorder(sec.id, oldIdx, newIdx),
          onRemoveSymbol: (sym) => onRemoveSymbol(sym, sec.id),
        );
      },
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final ListSection section;
  final Map<String, StockEntity> stockMap;
  final VoidCallback onToggleCollapse;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final void Function(int, int) onReorder;
  final void Function(String) onRemoveSymbol;

  const _SectionBlock({
    super.key,
    required this.section,
    required this.stockMap,
    required this.onToggleCollapse,
    required this.onRename,
    required this.onDelete,
    required this.onReorder,
    required this.onRemoveSymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SectionHeader(
          section: section,
          onToggle: onToggleCollapse,
          onRename: onRename,
          onDelete: onDelete,
        ),
        if (!section.collapsed)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            proxyDecorator: (child, _, _) =>
                Material(color: Colors.transparent, child: child),
            onReorder: onReorder,
            itemCount: section.symbols.length,
            itemBuilder: (_, i) {
              final sym = section.symbols[i];
              final stock = stockMap[sym];
              return StockTile(
                key: ValueKey('$sym-${section.id}'),
                onLongPress: () => onRemoveSymbol(sym),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChartPage(
                      symbol: stock?.symbol ?? '',
                      name: stock?.name ?? '',
                      price: stock?.price ?? 0.0,
                      changePercent: stock?.changePercent ?? 0.0,
                    ),
                  ),
                ),
                showVolume: false,
                stock:
                    stock ??
                    StockEntity(
                      symbol: stock?.symbol ?? '',
                      name: stock?.name ?? '',
                      price: stock?.price ?? 0.0,
                      change: stock?.change ?? 0.0,
                      changePercent: stock?.changePercent ?? 0.0,
                      high: stock?.high ?? 0.0,
                      low: stock?.low ?? 0.0,
                      open: stock?.open ?? 0.0,
                      volume: stock?.volume ?? 0.0,
                      marketCap: stock?.marketCap ?? 0.0,
                      type: stock?.type ?? '',
                    ),
              );
            },
          ),
        if (!section.collapsed && section.symbols.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No symbols yet',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final ListSection section;
  final VoidCallback onToggle;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _SectionHeader({
    required this.section,
    required this.onToggle,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            AnimatedRotation(
              turns: section.collapsed ? -0.25 : 0,
              duration: const Duration(milliseconds: 180),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              section.name,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${section.symbols.length}',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showSectionMenu(context),
              child: const Icon(
                Icons.more_horiz,
                color: AppColors.textMuted,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSectionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.edit_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            title: Text(
              'Rename section',
              style: GoogleFonts.inter(color: AppColors.textPrimary),
            ),
            onTap: () {
              Navigator.pop(context);
              onRename();
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_outline,
              color: AppColors.bearish,
              size: 20,
            ),
            title: Text(
              'Delete section',
              style: GoogleFonts.inter(color: AppColors.bearish),
            ),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _AddSectionButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddSectionButton({required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Symbols.add, size: 20),
      label: Text(
        'Add Section',
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}

class _EmptyFolder extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyFolder({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.folder_open_outlined,
          color: AppColors.textMuted,
          size: 56,
        ),
        const SizedBox(height: 14),
        Text(
          'No sections yet',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Create a section to start adding symbols',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 16),
          label: Text(
            'Add Section',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
