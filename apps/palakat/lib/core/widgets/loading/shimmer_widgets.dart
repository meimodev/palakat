import 'package:flutter/material.dart';
import 'package:palakat_shared/core/widgets/loading_shimmer.dart';

/// Shimmer placeholder widgets specifically for Palakat app components
class PalakatShimmerPlaceholders {
  static Widget text({
    double width = 100,
    double height = 16,
    BorderRadius? borderRadius,
  }) {
    return ShimmerPlaceholders.text(
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }

  static Widget button({
    double? width,
    double height = 48,
    BorderRadius? borderRadius,
    bool expanded = false,
  }) {
    return ShimmerPlaceholders.button(
      width: width,
      height: height,
      borderRadius: borderRadius,
      expanded: expanded,
    );
  }

  static Widget input({
    double? width,
    double height = 48,
    bool includeLabel = false,
    double labelWidth = 96,
    BorderRadius? borderRadius,
  }) {
    return ShimmerPlaceholders.input(
      width: width,
      height: height,
      includeLabel: includeLabel,
      labelWidth: labelWidth,
      borderRadius: borderRadius,
    );
  }

  static Widget listItemCard() => ShimmerPlaceholders.listItemCard();

  static Widget activityCard({double? height}) =>
      ShimmerPlaceholders.activityCard(height: height);

  static Widget membershipCard() => ShimmerPlaceholders.membershipCard();

  static Widget announcementCard() => ShimmerPlaceholders.announcementCard();

  static Widget approvalCard() => ShimmerPlaceholders.approvalCard();

  static Widget infoCard() => ShimmerPlaceholders.infoCard();

  static Widget simpleCard({
    double? width,
    double height = 120,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return ShimmerPlaceholders.simpleCard(
      width: width,
      height: height,
      padding: padding,
    );
  }

  static Widget listSection({int count = 3, double gap = 8}) =>
      ShimmerPlaceholders.listSection(count: count, gap: gap);

  static Widget activitySection({int count = 3, double gap = 8}) =>
      ShimmerPlaceholders.activitySection(count: count, gap: gap);

  static Widget approvalSection({int count = 3, double gap = 20}) =>
      ShimmerPlaceholders.approvalSection(count: count, gap: gap);

  static Widget infoSection({int count = 3, double gap = 12}) =>
      ShimmerPlaceholders.infoSection(count: count, gap: gap);

  static Widget listTileSection({int count = 3, double gap = 6}) =>
      ShimmerPlaceholders.listTileSection(count: count, gap: gap);

  static Widget operationsOverview() =>
      ShimmerPlaceholders.operationsOverview();

  static Widget approvalDetailLayout() =>
      ShimmerPlaceholders.approvalDetailLayout();

  static Widget activityDetailLayout() =>
      ShimmerPlaceholders.activityDetailLayout();
}
