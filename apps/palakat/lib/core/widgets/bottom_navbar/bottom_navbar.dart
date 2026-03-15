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
    ref.watch(authMembershipChangeSignalProvider);
    final storage = ref.watch(localStorageServiceProvider);
    final hasAuth = storage.currentAuth?.account != null;
    final hasMembership =
        storage.currentMembership?.id != null ||
        storage.currentAuth?.account.membership?.id != null;
    final showProtectedDestinations = hasAuth && hasMembership;

    final visibleIndices = showProtectedDestinations
        ? [0, 1, 4, 2, 3]
        : [0, 1, 4];

    final selectedVisualIndex = visibleIndices.indexOf(currentIndex);
    final safeSelectedIndex = selectedVisualIndex >= 0
        ? selectedVisualIndex
        : 0;

    final media = MediaQuery.of(context);
    final useCompactLabels =
        media.size.width < (showProtectedDestinations ? 460 : 360) ||
        MediaQuery.textScalerOf(context).scale(1) > 1.1;
    final navigationBarHeight = MediaQuery.textScalerOf(context).scale(1) > 1.15
        ? 76.0
        : 70.0;

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
              height: navigationBarHeight,
            ),
            child: NavigationBar(
              animationDuration: const Duration(milliseconds: 400),
              selectedIndex: safeSelectedIndex,
              onDestinationSelected: (visualIndex) {
                final logicalIndex = visibleIndices[visualIndex];
                onPressedItem(logicalIndex);
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: selectedColor.withValues(alpha: 0.15),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              labelBehavior: useCompactLabels
                  ? NavigationDestinationLabelBehavior.onlyShowSelected
                  : NavigationDestinationLabelBehavior.alwaysShow,
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
      2: _DestinationData(
        icon: AppIcons.church,
        label: context.l10n.nav_church,
      ),
      3: _DestinationData(
        icon: AppIcons.reader,
        label: context.l10n.nav_approval,
      ),
    };

    // Build destinations for visible indices
    return visibleIndices.map((logicalIndex) {
      final data = allDestinations[logicalIndex]!;
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
