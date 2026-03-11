import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class AppTabbarItem {
  const AppTabbarItem({required this.id, required this.label});

  final String id;
  final String label;
}

class AppTabbar extends StatefulWidget {
  const AppTabbar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onTabChanged,
    required this.onReorder,
    required this.onTabLongPress,
    this.height = 44,
    this.horizontalPadding = 14,
    this.tabHorizontalMargin = 2,
    this.tabVerticalMargin = 6,
    this.tabHorizontalPadding = 14,
    this.tabVerticalPadding = 4,
    this.borderRadius = 8,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w700,
  });

  final List<AppTabbarItem> tabs;
  final int activeIndex;
  final ValueChanged<int> onTabChanged;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(AppTabbarItem tab) onTabLongPress;
  final double height;
  final double horizontalPadding;
  final double tabHorizontalMargin;
  final double tabVerticalMargin;
  final double tabHorizontalPadding;
  final double tabVerticalPadding;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  State<AppTabbar> createState() => _AppTabbarState();
}

class _AppTabbarState extends State<AppTabbar> {
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
      height: widget.height,
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
        itemCount: widget.tabs.length,
        padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
        itemBuilder: (_, i) {
          final tab = widget.tabs[i];
          final isActive = i == widget.activeIndex;
          final isDragging = i == _draggingIndex;

          return ReorderableDragStartListener(
            key: ValueKey(tab.id),
            index: i,
            child: GestureDetector(
              onTap: () => widget.onTabChanged(i),
              onLongPress: () {
                HapticFeedback.heavyImpact();
                widget.onTabLongPress(tab);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: EdgeInsets.symmetric(
                  horizontal: widget.tabHorizontalMargin,
                  vertical: widget.tabVerticalMargin,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: widget.tabHorizontalPadding,
                  vertical: widget.tabVerticalPadding,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withAlpha(50)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                alignment: Alignment.center,
                child: Opacity(
                  opacity: isDragging ? 0.4 : 1.0,
                  child: Text(
                    tab.label,
                    style: GoogleFonts.inter(
                      fontSize: widget.fontSize,
                      fontWeight: widget.fontWeight,
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
    );
  }
}
