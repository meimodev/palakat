import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat_admin/core/services/local_storage_service_provider.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onPressedItem,
  });

  final int currentIndex;
  final Function(int) onPressedItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check auth state to determine which items to show
    final storage = ref.watch(localStorageServiceProvider);
    final hasAuth = storage.currentAuth?.account != null;

    // Define visible indices: [0: Home, 1: Songs, 2: Ops, 3: Approval]
    // Without auth: only show Home and Songs
    final visibleIndices = hasAuth ? [0, 1, 2, 3] : [0, 1];

    // Map currentIndex to visual position in the filtered list
    final selectedVisualIndex = visibleIndices.indexOf(currentIndex);
    final safeSelectedIndex = selectedVisualIndex >= 0 ? selectedVisualIndex : 0;

    final double iconSize = BaseSize.w24;
    // Per-tab selected color palette aligned with Operations accents
    final List<Color> allSelectedColors = <Color>[
      BaseColor.primary4,               // Home - Green
      BaseColor.yellow.shade600,        // Songs - Yellow/Orange
      BaseColor.red.shade600,           // Ops - Red
      BaseColor.teal.shade600,          // Approval - Teal
    ];

    // Filter colors based on visible indices
    final List<Color> selectedPalette = visibleIndices
        .map((i) => allSelectedColors[i])
        .toList();

    final Color selectedColor = selectedPalette[safeSelectedIndex];

    // Per-tab unselected palette using lighter opacity of each accent
    final List<Color> unselectedPalette = selectedPalette
        .map((color) => color.withValues(alpha: 0.5))
        .toList();

    // Keep unselected label neutral for readability
    final Color unselectedColor = BaseColor.secondaryText;

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
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return selectedLabelStyle;
                return unselectedLabelStyle;
              }),
              height: 70,
            ),
            child: NavigationBar(
              animationDuration: const Duration(milliseconds: 400),
              selectedIndex: safeSelectedIndex,
              onDestinationSelected: (visualIndex) {
                // Map visual index back to logical index
                final logicalIndex = visibleIndices[visualIndex];
                onPressedItem(logicalIndex);
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              // Stronger indicator with per-tab accent color
              indicatorColor: selectedColor.withValues(alpha: 0.15),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: _buildDestinations(
                visibleIndices,
                iconSize,
                unselectedPalette,
                selectedColor,
              ),
        ),
      ),
    ),
  ),
    );
  }

  /// Builds navigation destinations based on visible indices
  List<NavigationDestination> _buildDestinations(
    List<int> visibleIndices,
    double iconSize,
    List<Color> unselectedPalette,
    Color selectedColor,
  ) {
    // Map of all possible destinations
    final allDestinations = <int, _DestinationData>{
      0: _DestinationData(
        icon: Assets.icons.line.gridOutline,
        label: 'Home',
      ),
      1: _DestinationData(
        icon: Assets.icons.line.musicalNotes,
        label: 'Songs',
      ),
      2: _DestinationData(
        icon: Assets.icons.line.documentOutline,
        label: 'Ops',
      ),
      3: _DestinationData(
        icon: Assets.icons.line.readerOutline,
        label: 'Approval',
      ),
    };

    // Build destinations for visible indices
    return visibleIndices.asMap().entries.map((entry) {
      final visualIndex = entry.key;
      final logicalIndex = entry.value;
      final data = allDestinations[logicalIndex]!;

      return NavigationDestination(
        icon: data.icon.svg(
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(
            unselectedPalette[visualIndex],
            BlendMode.srcIn,
          ),
        ),
        selectedIcon: data.icon.svg(
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(selectedColor, BlendMode.srcIn),
        ),
        label: data.label,
      );
    }).toList();
  }
}

/// Helper class to store destination data
class _DestinationData {
  final SvgGenImage icon;
  final String label;

  const _DestinationData({
    required this.icon,
    required this.label,
  });
}
