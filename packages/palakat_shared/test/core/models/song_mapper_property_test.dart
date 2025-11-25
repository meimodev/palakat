import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat_shared/core/models/song.dart';

/// **Feature: songbook-backend-integration, Property 8: Backend response to Song model mapping**
///
/// *For any* valid backend song response JSON containing id, title, index, book, and parts array,
/// the mapping function SHALL produce a Song model where:
/// - `id` equals the string representation of the backend id
/// - `title` equals "{book} NO.{index}"
/// - `subTitle` equals the backend title
/// - `definition` contains SongPart objects for each backend part
/// - `composition` contains the types of all parts in order
///
/// **Validates: Requirements 5.3**
void main() {
  KiriCheck.verbosity = Verbosity.verbose;

  group('Property 8: Backend response to Song model mapping', () {
    // Valid book types
    final validBooks = ['KJ', 'NNBT', 'NKB', 'DSL'];

    // Valid part names
    final validPartNames = [
      'Verse 1',
      'Verse 2',
      'Verse 3',
      'Verse 4',
      'Verse 5',
      'Verse 6',
      'Verse 7',
      'Verse 8',
      'Chorus',
      'Chorus 2',
      'Chorus 3',
      'Chorus 4',
      'Refrain',
      'Pre-Chorus',
      'Bridge',
      'Intro',
      'Outro',
      'Hook',
    ];

    property('id equals string representation of backend id', () {
      forAll(integer(min: 1, max: 10000), (backendId) {
        final json = {
          'id': backendId,
          'title': 'Test Song',
          'index': 1,
          'book': 'KJ',
          'link': '',
          'parts': <Map<String, dynamic>>[],
        };

        final song = json.toSong();

        expect(song.id, equals(backendId.toString()));
      });
    });

    property('title equals "{book} NO.{index}"', () {
      forAll(
        combine2(
          integer(min: 0, max: validBooks.length - 1),
          integer(min: 1, max: 1000),
        ),
        (values) {
          final book = validBooks[values.$1];
          final index = values.$2;

          final json = {
            'id': 1,
            'title': 'Test Song',
            'index': index,
            'book': book,
            'link': '',
            'parts': <Map<String, dynamic>>[],
          };

          final song = json.toSong();

          expect(song.title, equals('$book NO.$index'));
        },
      );
    });

    property('subTitle equals backend title', () {
      forAll(string(minLength: 1, maxLength: 100), (backendTitle) {
        final json = {
          'id': 1,
          'title': backendTitle,
          'index': 1,
          'book': 'KJ',
          'link': '',
          'parts': <Map<String, dynamic>>[],
        };

        final song = json.toSong();

        expect(song.subTitle, equals(backendTitle));
      });
    });

    property('definition contains SongPart for each backend part', () {
      forAll(
        combine2(
          integer(min: 0, max: validPartNames.length - 1),
          string(minLength: 1, maxLength: 200),
        ),
        (values) {
          final partName = validPartNames[values.$1];
          final content = values.$2;

          final json = {
            'id': 1,
            'title': 'Test Song',
            'index': 1,
            'book': 'KJ',
            'link': '',
            'parts': [
              {'id': 1, 'index': 1, 'name': partName, 'content': content},
            ],
          };

          final song = json.toSong();

          expect(song.definition.length, equals(1));
          expect(song.definition.first.content, equals(content));
        },
      );
    });

    property('composition contains types of all parts in order', () {
      forAll(
        list(
          integer(min: 0, max: validPartNames.length - 1),
          minLength: 1,
          maxLength: 5,
        ),
        (partIndices) {
          final parts = partIndices.asMap().entries.map((entry) {
            return {
              'id': entry.key + 1,
              'index': entry.key + 1,
              'name': validPartNames[entry.value],
              'content': 'Content for part ${entry.key + 1}',
            };
          }).toList();

          final json = {
            'id': 1,
            'title': 'Test Song',
            'index': 1,
            'book': 'KJ',
            'link': '',
            'parts': parts,
          };

          final song = json.toSong();

          // Composition should have same length as definition
          expect(song.composition.length, equals(song.definition.length));

          // Each composition type should match corresponding definition type
          for (var i = 0; i < song.composition.length; i++) {
            expect(song.composition[i], equals(song.definition[i].type));
          }
        },
      );
    });

    property('urlImage equals backend link', () {
      forAll(string(minLength: 0, maxLength: 200), (link) {
        final json = {
          'id': 1,
          'title': 'Test Song',
          'index': 1,
          'book': 'KJ',
          'link': link,
          'parts': <Map<String, dynamic>>[],
        };

        final song = json.toSong();

        expect(song.urlImage, equals(link));
      });
    });

    property('parts are sorted by index', () {
      forAll(
        list(
          combine2(
            integer(min: 1, max: 100),
            integer(min: 0, max: validPartNames.length - 1),
          ),
          minLength: 2,
          maxLength: 5,
        ),
        (partData) {
          // Create parts with random indices
          final parts = partData.asMap().entries.map((entry) {
            return {
              'id': entry.key + 1,
              'index': entry.value.$1, // Random index
              'name': validPartNames[entry.value.$2],
              'content': 'Content ${entry.key}',
            };
          }).toList();

          final json = {
            'id': 1,
            'title': 'Test Song',
            'index': 1,
            'book': 'KJ',
            'link': '',
            'parts': parts,
          };

          final song = json.toSong();

          // Verify parts are sorted by checking content matches sorted order
          final sortedParts = List<Map<String, dynamic>>.from(parts)
            ..sort((a, b) => (a['index'] as int).compareTo(b['index'] as int));

          for (var i = 0; i < song.definition.length; i++) {
            expect(
              song.definition[i].content,
              equals(sortedParts[i]['content']),
            );
          }
        },
      );
    });

    property('handles missing optional fields gracefully', () {
      forAll(integer(min: 1, max: 10000), (backendId) {
        // Minimal JSON with only required fields
        final json = <String, dynamic>{'id': backendId};

        final song = json.toSong();

        // Should not throw and should have default values
        expect(song.id, equals(backendId.toString()));
        expect(song.title, equals(' NO.0'));
        expect(song.subTitle, equals(''));
        expect(song.definition, isEmpty);
        expect(song.composition, isEmpty);
        expect(song.urlImage, equals(''));
        expect(song.urlVideo, equals(''));
      });
    });
  });
}
