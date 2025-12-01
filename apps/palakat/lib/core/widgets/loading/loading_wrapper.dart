import 'package:flutter/material.dart';
import 'package:palakat/core/widgets/loading/shimmer_widgets.dart';
import 'package:palakat_shared/widgets.dart';

/// Wrapper widget that handles three states: loading, error, and content
///
/// Displays:
/// - Error widget with retry button when hasError is true
/// - Loading shimmer when loading is true
/// - Child content when neither error nor loading
///
/// Usage:
/// ```dart
/// LoadingWrapper(
///   loading: state.isLoading,
///   hasError: state.errorMessage != null,
///   errorMessage: state.errorMessage,
///   onRetry: () => controller.fetchData(),
///   shimmerPlaceholder: PalakatShimmerPlaceholders.activityCard(),
///   child: ActualContent(),
/// )
/// ```
class LoadingWrapper extends StatelessWidget {
  const LoadingWrapper({
    super.key,
    required this.loading,
    required this.child,
    this.hasError = false,
    this.errorMessage,
    this.onRetry,
    this.paddingTop,
    this.paddingBottom,
    this.shimmerPlaceholder,
  });

  final bool loading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget child;
  final double? paddingTop;
  final double? paddingBottom;
  final Widget? shimmerPlaceholder;

  @override
  Widget build(BuildContext context) {
    // Priority 1: Show error if present
    if (hasError && errorMessage != null) {
      return ErrorDisplayWidget(
        message: errorMessage!,
        onRetry: onRetry,
        padding: EdgeInsets.only(
          top: paddingTop ?? 0,
          bottom: paddingBottom ?? 0,
        ),
      );
    }

    // Priority 2: Show loading shimmer
    if (loading) {
      return Padding(
        padding: EdgeInsets.only(
          top: paddingTop ?? 0,
          bottom: paddingBottom ?? 0,
        ),
        child: LoadingShimmer(
          isLoading: true,
          child: shimmerPlaceholder ?? _defaultShimmerPlaceholder(),
        ),
      );
    }

    // Priority 3: Show content
    return child;
  }

  Widget _defaultShimmerPlaceholder() {
    return PalakatShimmerPlaceholders.simpleCard(height: 120);
  }
}
