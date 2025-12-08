import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Migration verification tests for icon consolidation.
/// These tests verify that all icon usages have been migrated to AppIcons.
///
/// **Feature: icon-consolidation**
/// **Validates: Requirements 3.1, 3.2, 3.3**
void main() {
  group('Icon Migration Verification Tests', () {
    late List<File> featureFiles;

    setUpAll(() {
      // Get all Dart files in the features directory
      final featuresDir = Directory('lib/features');
      if (featuresDir.existsSync()) {
        featureFiles = featuresDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .toList();
      } else {
        featureFiles = [];
      }
    });

    /// Verifies no direct Icons.* usage in feature code.
    /// **Validates: Requirements 3.1, 3.3**
    test('No direct Icons.* usage in feature code', () {
      final violations = <String>[];
      final iconPattern = RegExp(r'(?<![Ap])Icons\.');

      for (final file in featureFiles) {
        final content = file.readAsStringSync();
        final lines = content.split('\n');

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          // Skip import statements
          if (line.trimLeft().startsWith('import ')) continue;
          // Skip comments
          if (line.trimLeft().startsWith('//')) continue;

          if (iconPattern.hasMatch(line)) {
            violations.add('${file.path}:${i + 1}: $line');
          }
        }
      }

      if (violations.isNotEmpty) {
        fail(
          'Found ${violations.length} direct Icons.* usages in feature code:\n'
          '${violations.take(10).join('\n')}'
          '${violations.length > 10 ? '\n... and ${violations.length - 10} more' : ''}',
        );
      }
    });

    /// Verifies no Assets.icons.* usage in feature code.
    /// **Validates: Requirements 3.2, 3.3**
    test('No Assets.icons.* usage in feature code', () {
      final violations = <String>[];
      final assetIconPattern = RegExp(r'Assets\.icons\.');

      for (final file in featureFiles) {
        final content = file.readAsStringSync();
        final lines = content.split('\n');

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          // Skip import statements
          if (line.trimLeft().startsWith('import ')) continue;
          // Skip comments
          if (line.trimLeft().startsWith('//')) continue;

          if (assetIconPattern.hasMatch(line)) {
            violations.add('${file.path}:${i + 1}: $line');
          }
        }
      }

      if (violations.isNotEmpty) {
        fail(
          'Found ${violations.length} Assets.icons.* usages in feature code:\n'
          '${violations.take(10).join('\n')}'
          '${violations.length > 10 ? '\n... and ${violations.length - 10} more' : ''}',
        );
      }
    });

    /// Verifies that AppIcons is being used in feature code.
    /// This is a sanity check to ensure the migration has been applied.
    test('AppIcons is used in feature code', () {
      var appIconsUsageCount = 0;
      final appIconsPattern = RegExp(r'AppIcons\.');

      for (final file in featureFiles) {
        final content = file.readAsStringSync();
        appIconsUsageCount += appIconsPattern.allMatches(content).length;
      }

      expect(
        appIconsUsageCount,
        greaterThan(0),
        reason: 'AppIcons should be used in feature code after migration',
      );
    });
  });
}
