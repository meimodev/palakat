import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/services/local_storage_service_provider.dart';

class BottomNavBar extends ConsumerStatefulWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onPressedItem,
  });

  final int currentIndex;
  final Function(int) onPressedItem;

  @override
  ConsumerState<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBar>
    with SingleTickerProviderStateMixin {
  static const int _specialMenuIndex = 5;
  static const double _menuMinWidth = 220;
  static const double _menuMaxWidth = 260;
  static const double _menuEstimatedHeight = 120;

  final LayerLink _specialMenuLink = LayerLink();
  final GlobalKey _specialMenuKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  late final AnimationController _menuController;
  late final Animation<double> _barrierOpacity;
  late final Animation<double> _menuOpacity;
  late final Animation<double> _menuScale;
  late final Animation<Offset> _menuOffset;

  bool get _isMenuOpen => _overlayEntry != null;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _barrierOpacity = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _menuOpacity = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _menuScale = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(
        parent: _menuController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
    _menuOffset = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _menuController,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );
  }

  @override
  void didUpdateWidget(covariant BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex &&
        _overlayEntry != null) {
      _overlayEntry?.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _menuController.dispose();
    super.dispose();
  }

  Future<void> _openMenu() async {
    if (_isMenuOpen) return;

    final overlay = Overlay.of(context, rootOverlay: true);

    _overlayEntry = _buildOverlayEntry();
    overlay.insert(_overlayEntry!);
    if (mounted) setState(() {});
    await _menuController.forward(from: 0);
  }

  Future<void> _closeMenu() async {
    if (!_isMenuOpen) return;
    await _menuController.reverse();
    _removeOverlay();
    if (mounted) setState(() {});
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _toggleMenu() async {
    if (_isMenuOpen) {
      await _closeMenu();
      return;
    }
    await _openMenu();
  }

  Future<void> _onPickMenuItem(int index) async {
    await _closeMenu();
    widget.onPressedItem(index);
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (overlayContext) {
        final renderBox =
            _specialMenuKey.currentContext?.findRenderObject() as RenderBox?;
        final iconRect = renderBox != null
            ? renderBox.localToGlobal(Offset.zero) & renderBox.size
            : Rect.zero;

        final media = MediaQuery.of(overlayContext);
        final safePadding = media.padding;
        const horizontalMargin = 12.0;
        const verticalMargin = 12.0;

        final screenSize = media.size;

        final maxRight = (screenSize.width - _menuMaxWidth - horizontalMargin);
        final safeMaxRight = maxRight > horizontalMargin
            ? maxRight
            : horizontalMargin;
        final right = (screenSize.width - iconRect.right)
            .clamp(horizontalMargin, safeMaxRight)
            .toDouble();

        final maxBottom =
            (screenSize.height -
            safePadding.top -
            verticalMargin -
            _menuEstimatedHeight);
        final safeMaxBottom = maxBottom > (safePadding.bottom + verticalMargin)
            ? maxBottom
            : (safePadding.bottom + verticalMargin);
        final bottom = (screenSize.height - iconRect.top)
            .clamp(safePadding.bottom + verticalMargin, safeMaxBottom)
            .toDouble();

        String currentPath;
        try {
          currentPath = GoRouterState.of(context).uri.path;
        } catch (_) {
          currentPath = '';
        }
        final isInOperationsRoute = currentPath.startsWith('/operations');
        final isInApprovalsRoute = currentPath.startsWith('/approvals');
        final isOperationsSelected =
            widget.currentIndex == 2 || isInOperationsRoute;
        final isApprovalSelected =
            widget.currentIndex == 3 || isInApprovalsRoute;

        return Stack(
          children: [
            Positioned.fill(
              child: FadeTransition(
                opacity: _barrierOpacity,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _closeMenu,
                  child: Container(color: Colors.black.withValues(alpha: 0.14)),
                ),
              ),
            ),
            Positioned(
              right: right,
              bottom: bottom,
              child: FadeTransition(
                opacity: _menuOpacity,
                child: SlideTransition(
                  position: _menuOffset,
                  child: ScaleTransition(
                    scale: _menuScale,
                    alignment: Alignment.bottomRight,
                    child: Material(
                      color: BaseColor.white,
                      elevation: 16,
                      borderRadius: BorderRadius.circular(16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: _menuMinWidth,
                          maxWidth: _menuMaxWidth,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _menuItem(
                                icon: AppIcons.document,
                                label: overlayContext.l10n.operations_title,
                                selected: isOperationsSelected,
                                onTap: () => _onPickMenuItem(2),
                              ),
                              _menuItem(
                                icon: AppIcons.reader,
                                label: overlayContext.l10n.nav_approval,
                                selected: isApprovalSelected,
                                onTap: () => _onPickMenuItem(3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final bgColor = selected
        ? BaseColor.primary.withValues(alpha: 0.10)
        : Colors.transparent;
    final iconColor = selected ? BaseColor.primary : BaseColor.textSecondary;
    final textColor = selected ? BaseColor.primary : BaseColor.black;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              FaIcon(icon, size: 18, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: BaseTypography.titleMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _specialMenuIcon() {
    const double iconSize = 24.0;
    final icon = _isMenuOpen ? AppIcons.close : AppIcons.church;

    return CompositedTransformTarget(
      link: _specialMenuLink,
      child: Container(
        key: _specialMenuKey,
        child: AnimatedRotation(
          turns: _isMenuOpen ? 0.125 : 0.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: FaIcon(
              icon,
              key: ValueKey<bool>(_isMenuOpen),
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authMembershipChangeSignalProvider);
    final storage = ref.watch(localStorageServiceProvider);
    final hasAuth = storage.currentAuth?.account != null;
    final hasMembership =
        storage.currentMembership?.id != null ||
        storage.currentAuth?.account.membership?.id != null;
    final showSpecialMenu = hasAuth && hasMembership;

    if (!showSpecialMenu && _isMenuOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _closeMenu();
      });
    }

    final visibleIndices = showSpecialMenu ? [0, 1, 4, 5] : [0, 1, 4];

    final currentPath = GoRouterState.of(context).uri.path;
    final isInOperationsRoute = currentPath.startsWith('/operations');
    final isInApprovalsRoute = currentPath.startsWith('/approvals');

    final shouldHighlightSpecialMenu =
        showSpecialMenu &&
        (widget.currentIndex == 2 ||
            widget.currentIndex == 3 ||
            isInOperationsRoute ||
            isInApprovalsRoute);
    final effectiveCurrentIndex = shouldHighlightSpecialMenu
        ? _specialMenuIndex
        : widget.currentIndex;

    final selectedVisualIndex = visibleIndices.indexOf(effectiveCurrentIndex);
    final safeSelectedIndex = selectedVisualIndex >= 0
        ? selectedVisualIndex
        : 0;

    const Color selectedColor = BaseColor.primary;
    const Color unselectedColor = BaseColor.textSecondary;

    final selectedLabelStyle = BaseTypography.labelMedium.copyWith(
      color: selectedColor,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    );
    final unselectedLabelStyle = BaseTypography.labelMedium.copyWith(
      color: unselectedColor,
      fontWeight: FontWeight.w500,
    );

    return Material(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: selectedColor.withValues(alpha: 0.02),
      child: Container(
        decoration: BoxDecoration(
          color: BaseColor.white,
          border: Border(
            top: BorderSide(
              color: selectedColor.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: selectedColor);
                }
                return const IconThemeData(color: unselectedColor);
              }),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return selectedLabelStyle;
                }
                return unselectedLabelStyle;
              }),
              height: 70,
            ),
            child: NavigationBar(
              animationDuration: const Duration(milliseconds: 400),
              selectedIndex: safeSelectedIndex,
              onDestinationSelected: (visualIndex) {
                final logicalIndex = visibleIndices[visualIndex];
                if (logicalIndex == _specialMenuIndex) {
                  _toggleMenu();
                  return;
                }

                if (_isMenuOpen) {
                  _closeMenu();
                }
                widget.onPressedItem(logicalIndex);
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: selectedColor.withValues(alpha: 0.15),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: _buildDestinations(context, visibleIndices),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds navigation destinations based on visible indices
  List<NavigationDestination> _buildDestinations(
    BuildContext context,
    List<int> visibleIndices,
  ) {
    // Consistent icon sizing at 24px (Requirements 5.4)
    const double iconSize = 24.0;

    // Map of all possible destinations with localized labels
    final allDestinations = <int, _DestinationData>{
      0: _DestinationData(icon: AppIcons.grid, label: context.l10n.nav_home),
      1: _DestinationData(icon: AppIcons.music, label: context.l10n.nav_songs),
      4: _DestinationData(
        icon: AppIcons.article,
        label: context.l10n.nav_articles,
      ),
      5: _DestinationData(
        icon: AppIcons.church,
        label: context.l10n.nav_church,
      ),
    };

    // Build destinations for visible indices
    return visibleIndices.map((logicalIndex) {
      final data = allDestinations[logicalIndex]!;

      if (logicalIndex == _specialMenuIndex) {
        return NavigationDestination(
          icon: _specialMenuIcon(),
          label: data.label,
        );
      }

      return NavigationDestination(
        icon: FaIcon(data.icon, size: iconSize),
        label: data.label,
      );
    }).toList();
  }
}

/// Helper class to store destination data
class _DestinationData {
  final IconData icon;
  final String label;

  const _DestinationData({required this.icon, required this.label});
}
