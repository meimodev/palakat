import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A widget for displaying network images with loading and error states.
///
/// Uses [CachedNetworkImage] for efficient caching and theme-aware styling
/// for compatibility with both palakat and palakat_admin apps.
///
/// Example usage:
/// ```dart
/// ImageNetworkWidget(
///   imageUrl: 'https://example.com/image.jpg',
///   height: 200,
///   width: 200,
///   fit: BoxFit.cover,
/// )
/// ```
class ImageNetworkWidget extends StatelessWidget {
  const ImageNetworkWidget({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit,
    this.errorIcon,
  });

  /// The URL of the image to display
  final String imageUrl;

  /// Optional height constraint
  final double? height;

  /// Optional width constraint
  final double? width;

  /// How the image should be inscribed into the space
  final BoxFit? fit;

  /// Optional custom error icon widget.
  /// If not provided, a default error icon will be shown.
  final Widget? errorIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child:
              errorIcon ??
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 24,
              ),
        ),
      ),
      width: width,
      height: height,
      fit: fit,
    );
  }
}
