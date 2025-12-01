import 'package:flutter/material.dart';
import 'package:palakat_shared/core/theme/theme.dart';

/// Data class representing a navigation destination in the bottom navbar.
class NavDestination {
  /// The icon widget to display when not selected
  final Widget icon;

  /// The icon widget to display when selected
  final Widget selectedIcon;

  /// The label text for this destination
  final String label;

  /// The logical index for this destination (used for routing)
  final int logicalIndex;

  const NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.logicalIndex,
  });
}

/// A customizable bottom navigation bar widget for mobile applications.
///
/// This widget provides a Material 3 styled navigation bar with support
/// for dynamic destinations and consistent theming.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onPressedItem,
    required this.destinations,
    this.selectedColor,
    this.unselectedColor,
  });

  /// The currently selected logical index
  final int currentIndex;

  /// Callback when a navigation item is pressed, receives the logical index
  final Function(int) onPressedItem;

  /// List of navigation destinations to display
  final List<NavDestination> destinations;

  /// Color for selected items. Defaults to primary teal
  final Color? selectedColor;

  /// Color for unselected items. Defaults to secondary text color
  final Color? unselectedColor;

  @override
  Widget build(BuildContext context) {
    // Unified teal primary color for all selected states
    final effectiveSelectedColor = selectedColor ?? BaseColor.primary;
    // Neutral color for unselected states
    final effectiveUnselectedColor = unselectedColor ?? BaseColor.textSecondary;

    // Map currentIndex to visual position in the destinations list
    final selectedVisualIndex = destinations.indexWhere(
      (d) => d.logicalIndex == currentIndex,
    );
    final safeSelectedIndex = selectedVisualIndex >= 0
        ? selectedVisualIndex
        : 0;

    final selectedLabelStyle = BaseTypography.labelMedium.copyWith(
      color: effectiveSelectedColor,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    );
    final unselectedLabelStyle = BaseTypography.labelMedium.copyWith(
      color: effectiveUnselectedColor,
      fontWeight: FontWeight.w500,
    );

    return Material(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: effectiveSelectedColor.withValues(alpha: 0.02),
      child: Container(
        decoration: BoxDecoration(
          color: BaseColor.white,
          border: Border(
            top: BorderSide(
              // Top border using primary color at 12% opacity
              color: effectiveSelectedColor.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return selectedLabelStyle;
                }
                return unselectedLabelStyle;
              }),
              height: 70,
            ),
            child: NavigationBar(
              // 400ms animation duration
              animationDuration: const Duration(milliseconds: 400),
              selectedIndex: safeSelectedIndex,
              onDestinationSelected: (visualIndex) {
                // Map visual index back to logical index
                final logicalIndex = destinations[visualIndex].logicalIndex;
                onPressedItem(logicalIndex);
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              // Indicator using primary color at 15% opacity
              indicatorColor: effectiveSelectedColor.withValues(alpha: 0.15),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              // Always show labels
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: destinations
                  .map(
                    (d) => NavigationDestination(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon,
                      label: d.label,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
