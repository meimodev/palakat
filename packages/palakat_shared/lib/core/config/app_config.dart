import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config.freezed.dart';

part 'app_config.g.dart';

/// Centralized configuration loaded from .env
@freezed
abstract class AppConfig with _$AppConfig {

  const factory AppConfig({required String apiBaseUrl, String? apiKey}) =
      _AppConfig;

  factory AppConfig.fromEnv() {
    final baseUrl = dotenv.env['API_BASE_URL']?.trim() ?? '';
    final baseUrlPort = dotenv.env['API_BASE_PORT']?.trim() ?? '';
    final baseUrlVersion = dotenv.env['API_BASE_VERSION']?.trim() ?? '';
    if (baseUrl.isEmpty || baseUrlPort.isEmpty || baseUrlVersion.isEmpty) {
      throw StateError(
        'Missing required env var: API_BASE_URL, API_BASE_PORT, API_BASE_VERSION',
      );
    }

    final key = dotenv.env['API_KEY'];

    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.replaceAll('/', '')
        : baseUrl;

    return AppConfig(
      apiBaseUrl: "$normalizedBaseUrl:$baseUrlPort/$baseUrlVersion/",
      apiKey: key?.isEmpty == true ? null : key,
    );
  }
}

/// Riverpod provider exposing the configuration
@riverpod
AppConfig appConfig(Ref ref) {
  // In debug, log configuration for quick verification (without secrets)
  final config = AppConfig.fromEnv();
  if (kDebugMode) {
    dev.log('Loaded ${config.toString()}', name: 'AppConfig');
  }
  return config;
}
