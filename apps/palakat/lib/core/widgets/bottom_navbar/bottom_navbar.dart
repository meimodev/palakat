import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/services/local_storage_service_provider.dart';

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
    final visibleIndices = hasAuth ? [0, 1, 2, 3, 4] : [0, 1, 4];

    // Map currentIndex to visual position in the filtered list
    final selectedVisualIndex = visibleIndices.indexOf(currentIndex);
    final safeSelectedIndex = selectedVisualIndex >= 0
        ? selectedVisualIndex
        : 0;

    // Unified teal primary color for all selected states (Requirements 5.1)
    const Color selectedColor = BaseColor.primary;
    // Neutral color for unselected states (Requirements 5.2)
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
              // Top border using primary color at 12% opacity (Requirements 5.5)
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
                if (states.contains(WidgetState.selected)) {
                  return selectedLabelStyle;
                }
                return unselectedLabelStyle;
              }),
              height: 70,
            ),
            child: NavigationBar(
              // 400ms animation duration (Requirements 6.1)
              animationDuration: const Duration(milliseconds: 400),
              selectedIndex: safeSelectedIndex,
              onDestinationSelected: (visualIndex) {
                // Map visual index back to logical index
                final logicalIndex = visibleIndices[visualIndex];
                onPressedItem(logicalIndex);
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              // Indicator using primary color at 15% opacity (Requirements 5.3)
              indicatorColor: selectedColor.withValues(alpha: 0.15),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              // Always show labels (Requirements 6.2)
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: _buildDestinations(
                context,
                visibleIndices,
                selectedColor,
                unselectedColor,
              ),
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
    Color selectedColor,
    Color unselectedColor,
  ) {
    // Consistent icon sizing at 24px (Requirements 5.4)
    const double iconSize = 24.0;

    // Map of all possible destinations with localized labels
    final allDestinations = <int, _DestinationData>{
      0: _DestinationData(icon: AppIcons.grid, label: context.l10n.nav_home),
      1: _DestinationData(icon: AppIcons.music, label: context.l10n.nav_songs),
      2: _DestinationData(
        icon: AppIcons.document,
        label: context.l10n.nav_operations,
      ),
      3: _DestinationData(
        icon: AppIcons.reader,
        label: context.l10n.nav_approval,
      ),
      4: _DestinationData(
        icon: AppIcons.article,
        label: context.l10n.nav_articles,
      ),
    };

    // Build destinations for visible indices
    return visibleIndices.map((logicalIndex) {
      final data = allDestinations[logicalIndex]!;

      return NavigationDestination(
        icon: FaIcon(data.icon, size: iconSize, color: unselectedColor),
        selectedIcon: FaIcon(data.icon, size: iconSize, color: selectedColor),
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
