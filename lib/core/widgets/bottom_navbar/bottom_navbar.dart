import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/assets/assets.gen.dart';

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
    final double iconSize = BaseSize.w24;
    // Per-tab selected color palette aligned with Operations accents
    final List<Color> selectedPalette = <Color>[
      BaseColor.primary4,               // Home - Green
      BaseColor.blue.shade600,          // Explore - Blue
      BaseColor.yellow.shade600,        // Songs - Yellow/Orange
      BaseColor.red.shade600,           // Ops - Red
      BaseColor.teal.shade600,          // Approval - Teal
    ];
    final Color selectedColor = selectedPalette[currentIndex];
    // Per-tab unselected palette using lighter opacity of each accent
    final List<Color> unselectedPalette = <Color>[
      selectedPalette[0].withValues(alpha: 0.5),
      selectedPalette[1].withValues(alpha: 0.5),
      selectedPalette[2].withValues(alpha: 0.5),
      selectedPalette[3].withValues(alpha: 0.5),
      selectedPalette[4].withValues(alpha: 0.5),
    ];
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
              selectedIndex: currentIndex,
              onDestinationSelected: (index) => onPressedItem(index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              // Stronger indicator with per-tab accent color
              indicatorColor: selectedColor.withValues(alpha: 0.15),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
            NavigationDestination(
              icon: Assets.icons.line.gridOutline.svg(
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(unselectedPalette[0], BlendMode.srcIn),
              ),
              selectedIcon: Assets.icons.line.gridOutline.svg(
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(selectedColor, BlendMode.srcIn),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Assets.icons.line.globeOutline.svg(
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(unselectedPalette[1], BlendMode.srcIn),
              ),
              selectedIcon: Assets.icons.line.globeOutline.svg(
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(selectedColor, BlendMode.srcIn),
              ),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Assets.icons.line.musicalNotes.svg(
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(unselectedPalette[2], BlendMode.srcIn),
              ),
              selectedIcon: Assets.icons.line.musicalNotes.svg(
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(selectedColor, BlendMode.srcIn),
              ),
              label: 'Songs',
            ),
            NavigationDestination(
              icon: Assets.icons.line.documentOutline.svg(
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(unselectedPalette[3], BlendMode.srcIn),
              ),
              selectedIcon: Assets.icons.line.documentOutline.svg(
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(selectedColor, BlendMode.srcIn),
              ),
              label: 'Ops',
            ),
            NavigationDestination(
              // No dedicated settings icon in line set; using reader_outline for Approval for now.
              icon: Assets.icons.line.readerOutline.svg(
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(unselectedPalette[4], BlendMode.srcIn),
              ),
              selectedIcon: Assets.icons.line.readerOutline.svg(
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(selectedColor, BlendMode.srcIn),
              ),
              label: 'Approval',
            ),
          ],
        ),
      ),
    ),
  ),
    );
  }
}
