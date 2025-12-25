import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat_shared/core/utils/interest_builder.dart';

void main() {
  KiriCheck.verbosity = Verbosity.verbose;

  group('InterestBuilder', () {
    group('Property Tests', () {
      final churchIdArb = integer(min: 1, max: 999999);
      final columnIdArb = integer(min: 1, max: 999999);
      final membershipIdArb = integer(min: 1, max: 999999);
      final bipraValues = ['PKB', 'WKI', 'PMD', 'RMJ', 'ASM'];

      property('church interest should match pattern church.{churchId}', () {
        forAll(churchIdArb, (churchId) {
          final interest = InterestBuilder.church(churchId);
          expect(interest, equals('church.$churchId'));
        });
      });

      property(
        'churchBipra interest should match pattern church.{churchId}_bipra.{BIPRA} with uppercase BIPRA',
        () {
          forAll(churchIdArb, (churchId) {
            for (final bipra in bipraValues) {
              // Test with lowercase
              final interestLower = InterestBuilder.churchBipra(
                churchId,
                bipra.toLowerCase(),
              );
              expect(interestLower, equals('church.${churchId}_bipra.$bipra'));

              // Test with uppercase
              final interestUpper = InterestBuilder.churchBipra(
                churchId,
                bipra,
              );
              expect(interestUpper, equals('church.${churchId}_bipra.$bipra'));

              // Test with mixed case
              final interestMixed = InterestBuilder.churchBipra(
                churchId,
                'pKb',
              );
              expect(interestMixed, equals('church.${churchId}_bipra.PKB'));
            }
          });
        },
      );

      property(
        'churchColumn interest should match pattern church.{churchId}_column.{columnId}',
        () {
          forAll(combine2(churchIdArb, columnIdArb), (pair) {
            final churchId = pair.$1;
            final columnId = pair.$2;
            final interest = InterestBuilder.churchColumn(churchId, columnId);
            expect(interest, equals('church.${churchId}_column.$columnId'));
          });
        },
      );

      property(
        'churchColumnBipra interest should match pattern church.{churchId}_column.{columnId}_bipra.{BIPRA} with uppercase BIPRA',
        () {
          forAll(combine2(churchIdArb, columnIdArb), (pair) {
            final churchId = pair.$1;
            final columnId = pair.$2;
            for (final bipra in bipraValues) {
              final interest = InterestBuilder.churchColumnBipra(
                churchId,
                columnId,
                bipra.toLowerCase(),
              );
              expect(
                interest,
                equals('church.${churchId}_column.${columnId}_bipra.$bipra'),
              );
            }
          });
        },
      );

      property(
        'membership interest should match pattern membership.{membershipId}',
        () {
          forAll(membershipIdArb, (membershipId) {
            final interest = InterestBuilder.membership(membershipId);
            expect(interest, equals('membership.$membershipId'));
          });
        },
      );

      final accountIdArb = integer(min: 1, max: 999999);

      property(
        'buildUserInterests without columnId should return 7 interests',
        () {
          forAll(combine3(membershipIdArb, churchIdArb, accountIdArb), (triple) {
            final membershipId = triple.$1;
            final churchId = triple.$2;
            final accountId = triple.$3;
            for (final bipra in bipraValues) {
              final interests = InterestBuilder.buildUserInterests(
                membershipId: membershipId,
                churchId: churchId,
                bipra: bipra,
                accountId: accountId,
              );

              expect(interests.length, equals(7));
              expect(interests[0], equals('palakat'));
              expect(interests[1], equals('debug-palakat'));
              expect(interests[2], equals('church.$churchId'));
              expect(
                interests[3],
                equals('church.${churchId}_bipra.GENERAL'),
              );
              expect(
                interests[4],
                equals('church.${churchId}_bipra.${bipra.toUpperCase()}'),
              );
              expect(interests[5], equals('account.$accountId'));
              expect(interests[6], equals('membership.$membershipId'));
            }
          });
        },
      );

      property('buildUserInterests with columnId should return 9 interests', () {
        forAll(
          combine4(membershipIdArb, churchIdArb, columnIdArb, accountIdArb),
          (quad) {
            final membershipId = quad.$1;
            final churchId = quad.$2;
            final columnId = quad.$3;
            final accountId = quad.$4;
            for (final bipra in bipraValues) {
              final interests = InterestBuilder.buildUserInterests(
                membershipId: membershipId,
                churchId: churchId,
                bipra: bipra,
                columnId: columnId,
                accountId: accountId,
              );

              expect(interests.length, equals(9));
              expect(interests[0], equals('palakat'));
              expect(interests[1], equals('debug-palakat'));
              expect(interests[2], equals('church.$churchId'));
              expect(
                interests[3],
                equals('church.${churchId}_bipra.GENERAL'),
              );
              expect(
                interests[4],
                equals('church.${churchId}_bipra.${bipra.toUpperCase()}'),
              );
              expect(interests[5], equals('account.$accountId'));
              expect(interests[6], equals('membership.$membershipId'));
              expect(
                interests[7],
                equals('church.${churchId}_column.$columnId'),
              );
              expect(
                interests[8],
                equals(
                  'church.${churchId}_column.${columnId}_bipra.${bipra.toUpperCase()}',
                ),
              );
            }
          },
        );
      });
    });

    group('Unit Tests', () {
      test('globalInterest constant should be "palakat"', () {
        expect(InterestBuilder.globalInterest, equals('palakat'));
      });

      test('church formats correctly', () {
        expect(InterestBuilder.church(123), equals('church.123'));
      });

      test('churchBipra formats correctly with uppercase conversion', () {
        expect(
          InterestBuilder.churchBipra(123, 'pkb'),
          equals('church.123_bipra.PKB'),
        );
        expect(
          InterestBuilder.churchBipra(123, 'PKB'),
          equals('church.123_bipra.PKB'),
        );
      });

      test('churchColumn formats correctly', () {
        expect(
          InterestBuilder.churchColumn(123, 456),
          equals('church.123_column.456'),
        );
      });

      test('churchColumnBipra formats correctly with uppercase conversion', () {
        expect(
          InterestBuilder.churchColumnBipra(123, 456, 'wki'),
          equals('church.123_column.456_bipra.WKI'),
        );
      });

      test('membership formats correctly', () {
        expect(InterestBuilder.membership(789), equals('membership.789'));
      });

      test('buildUserInterests without columnId returns correct interests', () {
        final interests = InterestBuilder.buildUserInterests(
          membershipId: 1,
          churchId: 2,
          bipra: 'pkb',
          accountId: 10,
        );

        expect(interests, hasLength(7));
        expect(interests, contains('palakat'));
        expect(interests, contains('debug-palakat'));
        expect(interests, contains('church.2'));
        expect(interests, contains('church.2_bipra.GENERAL'));
        expect(interests, contains('church.2_bipra.PKB'));
        expect(interests, contains('account.10'));
        expect(interests, contains('membership.1'));
      });

      test('buildUserInterests with columnId returns correct interests', () {
        final interests = InterestBuilder.buildUserInterests(
          membershipId: 1,
          churchId: 2,
          bipra: 'wki',
          columnId: 3,
          accountId: 10,
        );

        expect(interests, hasLength(9));
        expect(interests, contains('palakat'));
        expect(interests, contains('debug-palakat'));
        expect(interests, contains('church.2'));
        expect(interests, contains('church.2_bipra.GENERAL'));
        expect(interests, contains('church.2_bipra.WKI'));
        expect(interests, contains('account.10'));
        expect(interests, contains('membership.1'));
        expect(interests, contains('church.2_column.3'));
        expect(interests, contains('church.2_column.3_bipra.WKI'));
      });
    });
  });
}
