import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/watchlist.dart';

class PrimaryTabBar extends StatefulWidget {
  final List<Watchlist> folders;
  final int activeIndex;
  final ValueChanged<int> onTabChanged;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(Watchlist folder) onTabLongPress;

  const PrimaryTabBar({
    super.key,
    required this.folders,
    required this.activeIndex,
    required this.onTabChanged,
    required this.onReorder,
    required this.onTabLongPress,
  });

  @override
  State<PrimaryTabBar> createState() => _PrimaryTabBarState();
}

class _PrimaryTabBarState extends State<PrimaryTabBar> {
  int? _draggingIndex;
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              scrollController: _scrollCtrl,
              scrollDirection: Axis.horizontal,
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) =>
                  Material(color: Colors.transparent, child: child),
              onReorderStart: (i) {
                setState(() => _draggingIndex = i);
                HapticFeedback.mediumImpact();
              },
              onReorderEnd: (_) => setState(() => _draggingIndex = null),
              onReorder: widget.onReorder,
              itemCount: widget.folders.length,
              padding: EdgeInsets.symmetric(horizontal: 14),
              itemBuilder: (_, i) {
                final folder = widget.folders[i];
                final isActive = i == widget.activeIndex;
                final isDragging = i == _draggingIndex;
                return ReorderableDragStartListener(
                  key: ValueKey(folder.id),
                  index: i,
                  child: GestureDetector(
                    onTap: () => widget.onTabChanged(i),
                    onLongPress: () {
                      HapticFeedback.heavyImpact();
                      widget.onTabLongPress(folder);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary.withAlpha(50)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: isDragging ? 0.4 : 1.0,
                        child: Text(
                          folder.name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
