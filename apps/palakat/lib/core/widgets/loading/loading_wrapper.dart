import 'package:palakat_shared/core/widgets/loading/loading_wrapper.dart'
    as shared;

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
class LoadingWrapper extends shared.LoadingWrapper {
  const LoadingWrapper({
    super.key,
    required super.loading,
    required super.child,
    super.hasError = false,
    super.errorMessage,
    super.onRetry,
    super.paddingTop,
    super.paddingBottom,
    super.shimmerPlaceholder,
  });
}
