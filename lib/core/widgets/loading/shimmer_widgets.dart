import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

/// Shimmer placeholder widgets specifically for Palakat app components
class PalakatShimmerPlaceholders {
  /// Shimmer placeholder for membership card
  static Widget membershipCard() {
    return Material(
      clipBehavior: Clip.hardEdge,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.teal[50],
      color: BaseColor.teal[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          width: 1,
          color: BaseColor.teal[100] ?? BaseColor.neutral20,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w16,
          vertical: BaseSize.h16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: BoxDecoration(
                    color: BaseColor.neutral20,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: BaseSize.h16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: BaseColor.neutral20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Gap.h8,
                      Container(
                        height: BaseSize.h12,
                        width: BaseSize.customWidth(120),
                        decoration: BoxDecoration(
                          color: BaseColor.neutral20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap.h16,
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: BaseSize.h40,
                    decoration: BoxDecoration(
                      color: BaseColor.neutral20,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Container(
                    height: BaseSize.h40,
                    decoration: BoxDecoration(
                      color: BaseColor.neutral20,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer placeholder for activity card
  static Widget activityCard({double? height}) {
    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.teal[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: height ?? BaseSize.customHeight(92),
        padding: EdgeInsets.all(BaseSize.w12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w32,
                  height: BaseSize.w32,
                  decoration: const BoxDecoration(
                    color: BaseColor.neutral20,
                    shape: BoxShape.circle,
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: BaseSize.h16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: BaseColor.neutral20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Gap.h6,
                      Container(
                        height: BaseSize.h12,
                        width: BaseSize.w80,
                        decoration: BoxDecoration(
                          color: BaseColor.neutral20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              height: BaseSize.h12,
              width: BaseSize.customWidth(100),
              decoration: BoxDecoration(
                color: BaseColor.neutral20,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer placeholder for list item card
  static Widget listItemCard() {
    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.teal[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w12),
        child: Row(
          children: [
            Container(
              width: BaseSize.w32,
              height: BaseSize.w32,
              decoration: const BoxDecoration(
                color: BaseColor.neutral20,
                shape: BoxShape.circle,
              ),
            ),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: BaseSize.h16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: BaseColor.neutral20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Gap.h6,
                  Container(
                    height: BaseSize.h12,
                    width: BaseSize.customWidth(120),
                    decoration: BoxDecoration(
                      color: BaseColor.neutral20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Gap.w12,
            Container(
              width: BaseSize.w20,
              height: BaseSize.w20,
              decoration: const BoxDecoration(
                color: BaseColor.neutral20,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer placeholder for announcement card
  static Widget announcementCard() {
    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.yellow[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: const BoxDecoration(
                    color: BaseColor.neutral20,
                    shape: BoxShape.circle,
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: BaseSize.h16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: BaseColor.neutral20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Gap.h6,
                      Container(
                        height: BaseSize.h12,
                        width: BaseSize.customWidth(100),
                        decoration: BoxDecoration(
                          color: BaseColor.neutral20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap.h12,
            Container(
              height: BaseSize.h12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: BaseColor.neutral20,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Gap.h6,
            Container(
              height: BaseSize.h12,
              width: BaseSize.customWidth(200),
              decoration: BoxDecoration(
                color: BaseColor.neutral20,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer placeholder for approval card
  static Widget approvalCard() {
    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.teal[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: const BoxDecoration(
                    color: BaseColor.neutral20,
                    shape: BoxShape.circle,
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: BaseSize.h16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: BaseColor.neutral20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Gap.h8,
                      Container(
                        height: BaseSize.h12,
                        width: BaseSize.customWidth(150),
                        decoration: BoxDecoration(
                          color: BaseColor.neutral20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap.h16,
            Container(
              height: BaseSize.h12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: BaseColor.neutral20,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Gap.h8,
            Container(
              height: BaseSize.h12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: BaseColor.neutral20,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Gap.h12,
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: BaseSize.h24,
                    decoration: BoxDecoration(
                      color: BaseColor.neutral20,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Gap.w8,
                Container(
                  height: BaseSize.h24,
                  width: BaseSize.w80,
                  decoration: BoxDecoration(
                    color: BaseColor.neutral20,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer placeholder for info card (used in detail screens)
  static Widget infoCard() {
    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.teal[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: BaseSize.w40,
                  height: BaseSize.w40,
                  decoration: const BoxDecoration(
                    color: BaseColor.neutral20,
                    shape: BoxShape.circle,
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Container(
                    height: BaseSize.h16,
                    decoration: BoxDecoration(
                      color: BaseColor.neutral20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            Gap.h16,
            ...List.generate(3, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: BaseSize.h12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: BaseSize.w20,
                      height: BaseSize.w20,
                      decoration: const BoxDecoration(
                        color: BaseColor.neutral20,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: BaseSize.h12,
                            width: BaseSize.w80,
                            decoration: BoxDecoration(
                              color: BaseColor.neutral20,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Gap.h6,
                          Container(
                            height: BaseSize.h16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: BaseColor.neutral20,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Generic shimmer card for simple use cases
  static Widget simpleCard({
    double? width,
    double height = 120,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.teal[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                color: BaseColor.neutral20,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Gap.h8,
            Container(
              height: 14,
              width: 200,
              decoration: BoxDecoration(
                color: BaseColor.neutral20,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Gap.h8,
            Container(
              height: 14,
              width: 150,
              decoration: BoxDecoration(
                color: BaseColor.neutral20,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: BaseColor.neutral20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 12,
                  width: 60,
                  decoration: BoxDecoration(
                    color: BaseColor.neutral20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
