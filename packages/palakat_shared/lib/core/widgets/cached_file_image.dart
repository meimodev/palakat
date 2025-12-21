import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/file_manager_repository.dart';

/// A widget that displays an image from a file ID with caching support
/// Uses signed URLs for better performance on Flutter Web
class CachedFileImage extends ConsumerStatefulWidget {
  const CachedFileImage({
    super.key,
    required this.fileId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  final int fileId;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  ConsumerState<CachedFileImage> createState() => _CachedFileImageState();
}

class _CachedFileImageState extends ConsumerState<CachedFileImage> {
  String? _imageUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImageUrl();
  }

  @override
  void didUpdateWidget(covariant CachedFileImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fileId != widget.fileId) {
      _loadImageUrl();
    }
  }

  Future<void> _loadImageUrl() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final fileRepo = ref.read(fileManagerRepositoryProvider);
      final result = await fileRepo.resolveDownloadUrl(fileId: widget.fileId);

      if (!mounted) return;

      result.when(
        onSuccess: (url) {
          setState(() {
            _imageUrl = url;
            _isLoading = false;
            _hasError = false;
          });
        },
        onFailure: (_) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return widget.placeholder ??
          SizedBox(
            width: widget.width,
            height: widget.height,
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
          );
    }

    if (_hasError || _imageUrl == null) {
      return widget.errorWidget ??
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 32,
                color: theme.colorScheme.error.withValues(alpha: 0.7),
              ),
            ),
          );
    }

    return Image.network(
      _imageUrl!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return widget.placeholder ??
            SizedBox(
              width: widget.width,
              height: widget.height,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ??
            SizedBox(
              width: widget.width,
              height: widget.height,
              child: Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 32,
                  color: theme.colorScheme.error.withValues(alpha: 0.7),
                ),
              ),
            );
      },
    );
  }
}
