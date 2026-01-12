import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TimeZoneService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    try {
      final dynamic timezone = await FlutterTimezone.getLocalTimezone();
      String? name;

      if (timezone is String) {
        name = timezone;
      } else {
        try {
          name = (timezone as dynamic).identifier as String?;
        } catch (_) {}
        try {
          name ??= (timezone as dynamic).name as String?;
        } catch (_) {}
        try {
          name ??= (timezone as dynamic).timezone as String?;
        } catch (_) {}
        name ??= timezone.toString();
      }

      final trimmedName = name.trim();
      final resolvedName = trimmedName.isNotEmpty ? trimmedName : 'UTC';
      tz.setLocalLocation(tz.getLocation(resolvedName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    _initialized = true;
  }
}
