import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat_shared/l10n/generated/app_localizations.dart';

/// Property-based tests for time pluralization and unit selection.
/// **Feature: palakat-consolidated**
void main() {
  group('Time Pluralization Property Tests', () {
    late AppLocalizations enL10n;
    late AppLocalizations idL10n;

    setUpAll(() async {
      // Initialize localizations for both English and Indonesian
      enL10n = await AppLocalizations.delegate.load(const Locale('en'));
      idL10n = await AppLocalizations.delegate.load(const Locale('id'));
    });

    /// **Feature: palakat-consolidated, Property 2: Time Pluralization Correctness**
    /// **Validates: Requirements 1.3, 7.2**
    ///
    /// *For any* time duration value N and time unit U (seconds, minutes, hours, days),
    /// the pluralized string SHALL use the correct plural form based on the value and locale rules.
    group('Property 2: Time Pluralization Correctness', () {
      property('English minutes pluralization uses correct forms', () {
        forAll(integer(min: 0, max: 1000), (count) {
          final result = enL10n.time_minutesAgo(count);

          if (count == 1) {
            // Singular form
            expect(
              result,
              equals('1 minute ago'),
              reason: 'Count of 1 should use singular form "1 minute ago"',
            );
          } else {
            // Plural form
            expect(
              result,
              equals('$count minutes ago'),
              reason:
                  'Count of $count should use plural form "$count minutes ago"',
            );
          }
        });
      });

      property('English hours pluralization uses correct forms', () {
        forAll(integer(min: 0, max: 1000), (count) {
          final result = enL10n.time_hoursAgo(count);

          if (count == 1) {
            expect(
              result,
              equals('1 hour ago'),
              reason: 'Count of 1 should use singular form "1 hour ago"',
            );
          } else {
            expect(
              result,
              equals('$count hours ago'),
              reason:
                  'Count of $count should use plural form "$count hours ago"',
            );
          }
        });
      });

      property('English days pluralization uses correct forms', () {
        forAll(integer(min: 0, max: 1000), (count) {
          final result = enL10n.time_daysAgo(count);

          if (count == 1) {
            expect(
              result,
              equals('1 day ago'),
              reason: 'Count of 1 should use singular form "1 day ago"',
            );
          } else {
            expect(
              result,
              equals('$count days ago'),
              reason:
                  'Count of $count should use plural form "$count days ago"',
            );
          }
        });
      });

      property('Indonesian minutes pluralization contains count', () {
        forAll(integer(min: 0, max: 1000), (count) {
          final result = idL10n.time_minutesAgo(count);

          // Indonesian doesn't have singular/plural distinction
          // but should always contain the count and "menit yang lalu"
          expect(
            result.contains('$count') || count == 1,
            isTrue,
            reason: 'Indonesian result should contain the count value',
          );
          expect(
            result.contains('menit yang lalu'),
            isTrue,
            reason: 'Indonesian result should contain "menit yang lalu"',
          );
        });
      });

      property('Indonesian hours pluralization contains count', () {
        forAll(integer(min: 0, max: 1000), (count) {
          final result = idL10n.time_hoursAgo(count);

          expect(
            result.contains('$count') || count == 1,
            isTrue,
            reason: 'Indonesian result should contain the count value',
          );
          expect(
            result.contains('jam yang lalu'),
            isTrue,
            reason: 'Indonesian result should contain "jam yang lalu"',
          );
        });
      });

      property('Indonesian days pluralization contains count', () {
        forAll(integer(min: 0, max: 1000), (count) {
          final result = idL10n.time_daysAgo(count);

          expect(
            result.contains('$count') || count == 1,
            isTrue,
            reason: 'Indonesian result should contain the count value',
          );
          expect(
            result.contains('hari yang lalu'),
            isTrue,
            reason: 'Indonesian result should contain "hari yang lalu"',
          );
        });
      });

      property('Pluralization is consistent across locales for same count', () {
        forAll(integer(min: 1, max: 100), (count) {
          // Both locales should produce non-empty strings for the same count
          final enMinutes = enL10n.time_minutesAgo(count);
          final idMinutes = idL10n.time_minutesAgo(count);

          expect(enMinutes.isNotEmpty, isTrue);
          expect(idMinutes.isNotEmpty, isTrue);

          // Both should contain the count value
          expect(
            enMinutes.contains('$count') || count == 1,
            isTrue,
            reason: 'English result should contain count or be singular',
          );
          expect(
            idMinutes.contains('$count') || count == 1,
            isTrue,
            reason: 'Indonesian result should contain count or be singular',
          );
        });
      });
    });

    /// **Feature: palakat-consolidated, Property 3: Time Unit Selection**
    /// **Validates: Requirements 1.3**
    ///
    /// *For any* time duration, the system SHALL select the most appropriate
    /// time unit (seconds → minutes → hours → days) based on the magnitude.
    group('Property 3: Time Unit Selection', () {
      /// Helper function that mimics the time formatting logic from dashboard
      String formatRelativeTime(AppLocalizations l10n, Duration diff) {
        if (diff.inDays > 0) {
          return l10n.time_daysAgo(diff.inDays);
        } else if (diff.inHours > 0) {
          return l10n.time_hoursAgo(diff.inHours);
        } else if (diff.inMinutes > 0) {
          return l10n.time_minutesAgo(diff.inMinutes);
        } else {
          return l10n.time_justNow;
        }
      }

      property('Durations under 1 minute return "just now"', () {
        forAll(integer(min: 0, max: 59), (seconds) {
          final diff = Duration(seconds: seconds);
          final result = formatRelativeTime(enL10n, diff);

          expect(
            result,
            equals(enL10n.time_justNow),
            reason: 'Duration of $seconds seconds should return "just now"',
          );
        });
      });

      property('Durations of 1-59 minutes return minutes format', () {
        forAll(integer(min: 1, max: 59), (minutes) {
          final diff = Duration(minutes: minutes);
          final result = formatRelativeTime(enL10n, diff);

          expect(
            result.contains('minute'),
            isTrue,
            reason: 'Duration of $minutes minutes should use minutes format',
          );
          expect(
            result.contains('hour'),
            isFalse,
            reason: 'Duration of $minutes minutes should not use hours format',
          );
          expect(
            result.contains('day'),
            isFalse,
            reason: 'Duration of $minutes minutes should not use days format',
          );
        });
      });

      property('Durations of 1-23 hours return hours format', () {
        forAll(integer(min: 1, max: 23), (hours) {
          final diff = Duration(hours: hours);
          final result = formatRelativeTime(enL10n, diff);

          expect(
            result.contains('hour'),
            isTrue,
            reason: 'Duration of $hours hours should use hours format',
          );
          expect(
            result.contains('day'),
            isFalse,
            reason: 'Duration of $hours hours should not use days format',
          );
        });
      });

      property('Durations of 1+ days return days format', () {
        forAll(integer(min: 1, max: 365), (days) {
          final diff = Duration(days: days);
          final result = formatRelativeTime(enL10n, diff);

          expect(
            result.contains('day'),
            isTrue,
            reason: 'Duration of $days days should use days format',
          );
        });
      });

      property(
        'Time unit selection is monotonic (larger durations use larger units)',
        () {
          forAll(integer(min: 1, max: 100), (multiplier) {
            // Test that as duration increases, we move to larger units
            final secondsDiff = Duration(seconds: multiplier);
            final minutesDiff = Duration(minutes: multiplier);
            final hoursDiff = Duration(hours: multiplier);
            final daysDiff = Duration(days: multiplier);

            final secondsResult = formatRelativeTime(enL10n, secondsDiff);
            final minutesResult = formatRelativeTime(enL10n, minutesDiff);
            final hoursResult = formatRelativeTime(enL10n, hoursDiff);
            final daysResult = formatRelativeTime(enL10n, daysDiff);

            // Verify unit hierarchy
            if (multiplier < 60) {
              expect(
                secondsResult,
                equals(enL10n.time_justNow),
                reason: 'Seconds should return just now',
              );
            }

            if (multiplier >= 1 && multiplier < 60) {
              expect(
                minutesResult.contains('minute'),
                isTrue,
                reason: 'Minutes should use minute unit',
              );
            }

            if (multiplier >= 1 && multiplier < 24) {
              expect(
                hoursResult.contains('hour'),
                isTrue,
                reason: 'Hours should use hour unit',
              );
            }

            expect(
              daysResult.contains('day'),
              isTrue,
              reason: 'Days should use day unit',
            );
          });
        },
      );

      property('Indonesian time unit selection follows same logic', () {
        forAll(integer(min: 1, max: 100), (value) {
          final minutesDiff = Duration(minutes: value);
          final hoursDiff = Duration(hours: value);
          final daysDiff = Duration(days: value);

          final minutesResult = formatRelativeTime(idL10n, minutesDiff);
          final hoursResult = formatRelativeTime(idL10n, hoursDiff);
          final daysResult = formatRelativeTime(idL10n, daysDiff);

          // Verify Indonesian uses correct units
          if (value < 60) {
            expect(
              minutesResult.contains('menit'),
              isTrue,
              reason: 'Indonesian minutes should contain "menit"',
            );
          }

          if (value < 24) {
            expect(
              hoursResult.contains('jam'),
              isTrue,
              reason: 'Indonesian hours should contain "jam"',
            );
          }

          expect(
            daysResult.contains('hari'),
            isTrue,
            reason: 'Indonesian days should contain "hari"',
          );
        });
      });

      property('Edge case: exactly 60 minutes uses hours', () {
        final diff = const Duration(minutes: 60);
        final result = formatRelativeTime(enL10n, diff);

        expect(
          result.contains('hour'),
          isTrue,
          reason: 'Exactly 60 minutes should use hours format (1 hour)',
        );
      });

      property('Edge case: exactly 24 hours uses days', () {
        final diff = const Duration(hours: 24);
        final result = formatRelativeTime(enL10n, diff);

        expect(
          result.contains('day'),
          isTrue,
          reason: 'Exactly 24 hours should use days format (1 day)',
        );
      });
    });
  });
}
