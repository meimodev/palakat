import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import '../loading/loading_wrapper.dart';

/// A customizable scaffold widget for mobile applications.
///
/// This widget provides a consistent layout structure with support for:
/// - Custom app bar
/// - Loading states with shimmer animation
/// - Bottom navigation bar
/// - Persistent bottom widgets
/// - Optional scrolling behavior
///
/// This is an app-specific implementation that uses the local LoadingWrapper
/// with PalakatShimmerPlaceholders for consistent loading states.
class ScaffoldWidget extends StatelessWidget {
  const ScaffoldWidget({
    super.key,
    required this.child,
    this.appBar,
    this.resizeToAvoidBottomInset = false,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.disableSingleChildScrollView = false,
    this.disablePadding = false,
    this.persistBottomWidget,
    this.loading = false,
    this.shimmerPlaceholder,
    this.hasError = false,
    this.errorMessage,
    this.onRetry,
  });

  /// The main content widget
  final Widget child;

  /// Optional app bar widget
  final PreferredSizeWidget? appBar;

  /// Whether to resize the body when the keyboard appears
  final bool resizeToAvoidBottomInset;

  /// Background color for the scaffold. Defaults to white
  final Color? backgroundColor;

  /// Optional bottom navigation bar widget
  final Widget? bottomNavigationBar;

  /// Whether to disable the SingleChildScrollView wrapper
  final bool disableSingleChildScrollView;

  /// Whether to disable horizontal padding
  final bool disablePadding;

  /// Whether the content is in a loading state
  final bool loading;

  /// Custom shimmer placeholder widget for loading state
  final Widget? shimmerPlaceholder;

  /// Whether there's an error to display
  final bool hasError;

  /// Error message to display when hasError is true
  final String? errorMessage;

  /// Callback when retry button is pressed in error state
  final VoidCallback? onRetry;

  /// Widget that persists at the bottom of the screen
  final Widget? persistBottomWidget;

  @override
  Widget build(BuildContext context) {
    final topSpace = BaseSize.h8;

    final Widget childWrapper = AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: LoadingWrapper(
        loading: loading,
        hasError: hasError,
        errorMessage: errorMessage,
        onRetry: onRetry,
        shimmerPlaceholder: shimmerPlaceholder,
        child: child,
      ),
    );

    final Widget bodyContent = disableSingleChildScrollView
        ? Padding(
            padding: EdgeInsets.only(top: topSpace),
            child: childWrapper,
          )
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(top: topSpace),
              child: Column(children: [childWrapper, Gap.h64]),
            ),
          );

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: appBar,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = disablePadding
                ? 0.0
                : constraints.maxWidth >= 768
                ? BaseSize.w24
                : BaseSize.w12;
            final contentMaxWidth = disablePadding
                ? constraints.maxWidth
                : constraints.maxWidth >= 1024
                ? 840.0
                : constraints.maxWidth >= 768
                ? 720.0
                : constraints.maxWidth;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                  ),
                  child: Column(
                    children: [
                      Expanded(child: bodyContent),
                      persistBottomWidget ?? const SizedBox(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        backgroundColor: backgroundColor ?? BaseColor.white,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
