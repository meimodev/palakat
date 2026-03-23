import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SectionedEnvLoader {
  static const String defaultEnvironment = String.fromEnvironment(
    'PALAKAT_ENV',
    defaultValue: 'local',
  );

  static Future<void> load({
    String environment = defaultEnvironment,
    String fileName = '.env',
  }) async {
    final normalizedEnvironment = environment.trim().toLowerCase();

    if (!_supportedEnvironments.contains(normalizedEnvironment)) {
      throw StateError(
        'Unsupported PALAKAT_ENV: $environment. Supported values: ${_supportedEnvironments.join(', ')}',
      );
    }

    final rawFile = await rootBundle.loadString(fileName);
    final selectedFile = _extractSection(
      rawFile,
      normalizedEnvironment,
      fileName,
    );

    dotenv.loadFromString(envString: selectedFile);
  }

  static const Set<String> _supportedEnvironments = {
    'local',
    'staging',
    'production',
  };

  static String _extractSection(
    String rawFile,
    String environment,
    String fileName,
  ) {
    final normalizedContent = rawFile.replaceAll('\r\n', '\n');
    final lines = normalizedContent.split('\n');

    final selectedLines = <String>[];
    final fallbackLines = <String>[];
    String? currentSection;
    var sawSections = false;
    var foundSection = false;

    for (final line in lines) {
      final trimmed = line.trim();
      final isSection = trimmed.startsWith('[') && trimmed.endsWith(']');

      if (isSection) {
        sawSections = true;
        currentSection = trimmed
            .substring(1, trimmed.length - 1)
            .trim()
            .toLowerCase();
        if (!_supportedEnvironments.contains(currentSection)) {
          throw StateError(
            'Unsupported environment section in $fileName: $trimmed',
          );
        }
        if (currentSection == environment) {
          foundSection = true;
        }
        continue;
      }

      if (!sawSections) {
        fallbackLines.add(line);
      }

      if (currentSection == environment) {
        selectedLines.add(line);
      }
    }

    if (!sawSections) {
      if (environment != 'local') {
        throw FlutterError(
          'Missing [$environment] section in $fileName. Flat env files only support local.',
        );
      }

      return fallbackLines.join('\n');
    }

    if (!foundSection) {
      throw FlutterError('Missing [$environment] section in $fileName');
    }

    return selectedLines.join('\n');
  }
}
