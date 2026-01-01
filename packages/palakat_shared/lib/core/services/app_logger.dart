import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class _DebugPrintLogOutput extends LogOutput {
  _DebugPrintLogOutput({this.tag});

  final String? tag;

  @override
  void output(OutputEvent event) {
    final prefix = tag == null || tag!.trim().isEmpty ? '' : '[$tag] ';
    for (final line in event.lines) {
      debugPrint('$prefix$line');
    }
  }
}

Logger createAppLogger({String tag = 'Palakat'}) {
  return Logger(
    filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 60,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    output: _DebugPrintLogOutput(tag: tag),
  );
}

final appLoggerProvider = Provider<Logger>((ref) {
  ref.keepAlive();
  return createAppLogger();
});

final namedLoggerProvider = Provider.family<Logger, String>((ref, tag) {
  ref.keepAlive();
  return createAppLogger(tag: tag);
});
