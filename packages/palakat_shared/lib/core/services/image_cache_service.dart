import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_cache_service.g.dart';

/// Simple in-memory image cache for Flutter Web
/// Caches image bytes by file ID to avoid repeated network requests
class ImageCacheService {
  final Map<int, Uint8List> _cache = {};
  final Map<int, Future<Uint8List?>> _pendingRequests = {};

  /// Maximum number of cached images
  static const int _maxCacheSize = 50;

  /// Get cached image bytes by file ID
  Uint8List? get(int fileId) => _cache[fileId];

  /// Check if image is cached
  bool has(int fileId) => _cache.containsKey(fileId);

  /// Store image bytes in cache
  void put(int fileId, Uint8List bytes) {
    // Evict oldest entries if cache is full
    if (_cache.length >= _maxCacheSize) {
      final keysToRemove = _cache.keys.take(_cache.length - _maxCacheSize + 1);
      for (final key in keysToRemove.toList()) {
        _cache.remove(key);
      }
    }
    _cache[fileId] = bytes;
  }

  /// Remove image from cache
  void remove(int fileId) {
    _cache.remove(fileId);
  }

  /// Clear all cached images
  void clear() {
    _cache.clear();
    _pendingRequests.clear();
  }

  /// Fetch image with deduplication of concurrent requests
  /// Returns cached bytes if available, otherwise fetches and caches
  Future<Uint8List?> fetchWithCache({
    required int fileId,
    required Future<Uint8List?> Function() fetcher,
  }) async {
    // Return cached if available
    if (_cache.containsKey(fileId)) {
      return _cache[fileId];
    }

    // Return pending request if one exists (deduplication)
    if (_pendingRequests.containsKey(fileId)) {
      return _pendingRequests[fileId];
    }

    // Create new request
    final future = _fetchAndCache(fileId, fetcher);
    _pendingRequests[fileId] = future;

    try {
      final result = await future;
      return result;
    } finally {
      _pendingRequests.remove(fileId);
    }
  }

  Future<Uint8List?> _fetchAndCache(
    int fileId,
    Future<Uint8List?> Function() fetcher,
  ) async {
    try {
      final bytes = await fetcher();
      if (bytes != null && bytes.isNotEmpty) {
        put(fileId, bytes);
      }
      return bytes;
    } catch (e) {
      debugPrint('ImageCacheService: Failed to fetch image $fileId: $e');
      return null;
    }
  }
}

@Riverpod(keepAlive: true)
ImageCacheService imageCacheService(Ref ref) {
  return ImageCacheService();
}
