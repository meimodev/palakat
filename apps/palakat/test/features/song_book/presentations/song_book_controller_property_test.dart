import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:mocktail/mocktail.dart';
import 'package:palakat/features/song_book/presentations/song_book_controller.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/repositories/song_repository.dart';
import 'package:riverpod/riverpod.dart';

// Mock classes
class MockSongRepository extends Mock implements SongRepository {}

class FakeGetFetchSongsRequest extends Fake implements GetFetchSongsRequest {}

class FakePaginationRequestWrapper extends Fake
    implements PaginationRequestWrapper<GetFetchSongsRequest> {}

void main() {
  KiriCheck.verbosity = Verbosity.verbose;

  setUpAll(() {
    registerFallbackValue(FakeGetFetchSongsRequest());
    registerFallbackValue(FakePaginationRequestWrapper());
    registerFallbackValue(
      PaginationRequestWrapper<GetFetchSongsRequest>(
        page: 1,
        pageSize: 50,
        data: GetFetchSongsRequest(),
      ),
    );
  });

  /// **Feature: songbook-backend-integration, Property 1: Search triggers repository call with correct query**
  ///
  /// *For any* non-empty search query string, when `searchSongs(query)` is called
  /// on the SongBookController, the SongRepository's `searchSongs` method SHALL
  /// be invoked with that exact query string.
  ///
  /// **Validates: Requirements 1.1, 2.1**
  group('Property 1: Search triggers repository call with correct query', () {
    // Generator for non-empty search query strings
    // Excludes whitespace-only strings since those are handled differently
    Arbitrary<String> nonEmptyQueryArb() {
      return string(
        minLength: 1,
        maxLength: 50,
      ).filter((s) => s.trim().isNotEmpty);
    }

    property('searchSongs calls repository with exact query string', () {
      forAll(nonEmptyQueryArb(), (query) async {
        // Arrange
        final mockRepo = MockSongRepository();
        final container = ProviderContainer(
          overrides: [songRepositoryProvider.overrideWithValue(mockRepo)],
        );

        // Mock getSongs for initial fetch in build()
        when(
          () => mockRepo.getSongs(
            paginationRequest: any(named: 'paginationRequest'),
          ),
        ).thenAnswer(
          (_) async => Result.success(
            PaginationResponseWrapper<Song>(
              message: 'Success',
              pagination: const PaginationResponseWrapperResponse(
                page: 1,
                pageSize: 50,
                total: 0,
                totalPages: 1,
                hasNext: false,
                hasPrev: false,
              ),
              data: [],
            ),
          ),
        );

        // Mock searchSongs to capture the query parameter
        when(
          () => mockRepo.searchSongs(
            query: any(named: 'query'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer(
          (_) async => Result.success(
            PaginationResponseWrapper<Song>(
              message: 'Success',
              pagination: const PaginationResponseWrapperResponse(
                page: 1,
                pageSize: 20,
                total: 0,
                totalPages: 1,
                hasNext: false,
                hasPrev: false,
              ),
              data: [],
            ),
          ),
        );

        // Act - Initialize controller and wait for initial fetch
        final controller = container.read(songBookControllerProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 100));

        // Call searchSongs with the generated query
        await controller.searchSongs(query);

        // Assert - Verify searchSongs was called with the exact query
        verify(() => mockRepo.searchSongs(query: query)).called(1);

        container.dispose();
      });
    });

    property(
      'searchSongs preserves query string exactly without modification',
      () {
        // Test with various special characters and unicode
        final specialQueryArb = oneOf([
          constant('KJ'),
          constant('NNBT'),
          constant('NKB'),
          constant('DSL'),
          constant('Tuhan'),
          constant('123'),
          string(
            minLength: 1,
            maxLength: 30,
          ).filter((s) => s.trim().isNotEmpty),
        ]);

        forAll(specialQueryArb, (query) async {
          // Arrange
          final mockRepo = MockSongRepository();
          final container = ProviderContainer(
            overrides: [songRepositoryProvider.overrideWithValue(mockRepo)],
          );

          String? capturedQuery;

          when(
            () => mockRepo.getSongs(
              paginationRequest: any(named: 'paginationRequest'),
            ),
          ).thenAnswer(
            (_) async => Result.success(
              PaginationResponseWrapper<Song>(
                message: 'Success',
                pagination: const PaginationResponseWrapperResponse(
                  page: 1,
                  pageSize: 50,
                  total: 0,
                  totalPages: 1,
                  hasNext: false,
                  hasPrev: false,
                ),
                data: [],
              ),
            ),
          );

          when(
            () => mockRepo.searchSongs(
              query: any(named: 'query'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            ),
          ).thenAnswer((invocation) async {
            capturedQuery = invocation.namedArguments[#query] as String;
            return Result.success(
              PaginationResponseWrapper<Song>(
                message: 'Success',
                pagination: const PaginationResponseWrapperResponse(
                  page: 1,
                  pageSize: 20,
                  total: 0,
                  totalPages: 1,
                  hasNext: false,
                  hasPrev: false,
                ),
                data: [],
              ),
            );
          });

          // Act
          final controller = container.read(
            songBookControllerProvider.notifier,
          );
          await Future.delayed(const Duration(milliseconds: 100));
          await controller.searchSongs(query);

          // Assert - The captured query should be exactly the input query
          expect(capturedQuery, equals(query));

          container.dispose();
        });
      },
    );
  });

  /// **Feature: songbook-backend-integration, Property 2: Successful response updates state with songs**
  ///
  /// *For any* successful API response containing a list of songs, the SongBookController
  /// state SHALL contain exactly those songs in the `filteredSongs` list with `isLoading`
  /// set to false and `errorMessage` set to null.
  ///
  /// **Validates: Requirements 1.2, 2.2, 4.2**
  group('Property 2: Successful response updates state with songs', () {
    // Valid SongPartType values for generating test data
    final validPartTypes = SongPartType.values;

    // Generator for a single SongPart
    Arbitrary<SongPart> songPartArb() {
      return combine2(
        integer(min: 0, max: validPartTypes.length - 1),
        string(minLength: 1, maxLength: 100),
      ).map((values) {
        return SongPart(type: validPartTypes[values.$1], content: values.$2);
      });
    }

    // Generator for a single Song
    Arbitrary<Song> songArb() {
      return combine5(
        string(minLength: 1, maxLength: 20), // id
        string(minLength: 1, maxLength: 50), // title
        string(minLength: 0, maxLength: 50), // subTitle
        list(songPartArb(), minLength: 0, maxLength: 5), // parts
        string(minLength: 0, maxLength: 100), // urlImage
      ).map((values) {
        final parts = values.$4;
        return Song(
          id: values.$1,
          title: values.$2,
          subTitle: values.$3,
          composition: parts.map((p) => p.type).toList(),
          definition: parts,
          urlImage: values.$5,
          urlVideo: '',
        );
      });
    }

    // Generator for a list of songs
    Arbitrary<List<Song>> songListArb() {
      return list(songArb(), minLength: 0, maxLength: 10);
    }

    property(
      'filteredSongs contains exactly the songs from successful response',
      () {
        forAll(songListArb(), (songs) async {
          // Arrange
          final mockRepo = MockSongRepository();
          final container = ProviderContainer(
            overrides: [songRepositoryProvider.overrideWithValue(mockRepo)],
          );

          // Create a successful response with the generated songs
          final response = PaginationResponseWrapper<Song>(
            message: 'Success',
            pagination: const PaginationResponseWrapperResponse(
              page: 1,
              pageSize: 50,
              total: 0,
              totalPages: 1,
              hasNext: false,
              hasPrev: false,
            ),
            data: songs,
          );

          when(
            () => mockRepo.getSongs(
              paginationRequest: any(named: 'paginationRequest'),
            ),
          ).thenAnswer((_) async => Result.success(response));

          // Act - Read the controller to trigger build() which calls fetchSongs()
          container.read(songBookControllerProvider);

          // Wait for the async fetchSongs to complete
          await Future.delayed(const Duration(milliseconds: 100));

          // Assert
          final state = container.read(songBookControllerProvider);

          // filteredSongs should contain exactly the songs from the response
          expect(state.filteredSongs.length, equals(songs.length));
          for (var i = 0; i < songs.length; i++) {
            expect(state.filteredSongs[i].id, equals(songs[i].id));
            expect(state.filteredSongs[i].title, equals(songs[i].title));
          }

          container.dispose();
        });
      },
    );

    property('isLoading is false after successful response', () {
      forAll(songListArb(), (songs) async {
        // Arrange
        final mockRepo = MockSongRepository();
        final container = ProviderContainer(
          overrides: [songRepositoryProvider.overrideWithValue(mockRepo)],
        );

        final response = PaginationResponseWrapper<Song>(
          message: 'Success',
          pagination: const PaginationResponseWrapperResponse(
            page: 1,
            pageSize: 50,
            total: 0,
            totalPages: 1,
            hasNext: false,
            hasPrev: false,
          ),
          data: songs,
        );

        when(
          () => mockRepo.getSongs(
            paginationRequest: any(named: 'paginationRequest'),
          ),
        ).thenAnswer((_) async => Result.success(response));

        // Act
        container.read(songBookControllerProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        final state = container.read(songBookControllerProvider);
        expect(state.isLoading, isFalse);

        container.dispose();
      });
    });

    property('errorMessage is null after successful response', () {
      forAll(songListArb(), (songs) async {
        // Arrange
        final mockRepo = MockSongRepository();
        final container = ProviderContainer(
          overrides: [songRepositoryProvider.overrideWithValue(mockRepo)],
        );

        final response = PaginationResponseWrapper<Song>(
          message: 'Success',
          pagination: const PaginationResponseWrapperResponse(
            page: 1,
            pageSize: 50,
            total: 0,
            totalPages: 1,
            hasNext: false,
            hasPrev: false,
          ),
          data: songs,
        );

        when(
          () => mockRepo.getSongs(
            paginationRequest: any(named: 'paginationRequest'),
          ),
        ).thenAnswer((_) async => Result.success(response));

        // Act
        container.read(songBookControllerProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        final state = container.read(songBookControllerProvider);
        expect(state.errorMessage, isNull);

        container.dispose();
      });
    });

    property('songs list is also updated with the response data', () {
      forAll(songListArb(), (songs) async {
        // Arrange
        final mockRepo = MockSongRepository();
        final container = ProviderContainer(
          overrides: [songRepositoryProvider.overrideWithValue(mockRepo)],
        );

        final response = PaginationResponseWrapper<Song>(
          message: 'Success',
          pagination: const PaginationResponseWrapperResponse(
            page: 1,
            pageSize: 50,
            total: 0,
            totalPages: 1,
            hasNext: false,
            hasPrev: false,
          ),
          data: songs,
        );

        when(
          () => mockRepo.getSongs(
            paginationRequest: any(named: 'paginationRequest'),
          ),
        ).thenAnswer((_) async => Result.success(response));

        // Act
        container.read(songBookControllerProvider);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        final state = container.read(songBookControllerProvider);

        // Both songs and filteredSongs should have the same data
        expect(state.songs.length, equals(songs.length));
        expect(state.songs.length, equals(state.filteredSongs.length));

        container.dispose();
      });
    });
  });

  /// **Feature: songbook-backend-integration, Property 3: Empty query clears search state**
  ///
  /// *For any* empty or whitespace-only search query, the SongBookController SHALL
  /// set `isSearching` to false, `searchQuery` to empty string, and `filteredSongs`
  /// to the full `songs` list.
  ///
  /// **Validates: Requirements 1.3**
  group('Property 3: Empty query clears search state', () {
    // Valid SongPartType values for generating test data
    final validPartTypes = SongPartType.values;

    // Generator for a single SongPart
    Arbitrary<SongPart> songPartArb() {
      return combine2(
        integer(min: 0, max: validPartTypes.length - 1),
        string(minLength: 1, maxLength: 100),
      ).map((values) {
        return SongPart(type: validPartTypes[values.$1], content: values.$2);
      });
    }

    // Generator for a single Song
    Arbitrary<Song> songArb() {
      return combine5(
        string(minLength: 1, maxLength: 20), // id
        string(minLength: 1, maxLength: 50), // title
        string(minLength: 0, maxLength: 50), // subTitle
        list(songPartArb(), minLength: 0, maxLength: 5), // parts
        string(minLength: 0, maxLength: 100), // urlImage
      ).map((values) {
        final parts = values.$4;
        return Song(
          id: values.$1,
          title: values.$2,
          subTitle: values.$3,
          composition: parts.map((p) => p.type).toList(),
          definition: parts,
          urlImage: values.$5,
          urlVideo: '',
        );
      });
    }

    // Generator for a list of songs (at least 1 song to verify state restoration)
    Arbitrary<List<Song>> songListArb() {
      return list(songArb(), minLength: 1, maxLength: 10);
    }

    // Generator for empty or whitespace-only strings
    // Using integer to select from a list of whitespace strings
    Arbitrary<String> emptyOrWhitespaceQueryArb() {
      final whitespaceStrings = ['', ' ', '  ', '\t', '\n', '   \t  ', '\n\t '];
      return integer(
        min: 0,
        max: whitespaceStrings.length - 1,
      ).map((index) => whitespaceStrings[index]);
    }

    property('empty query sets isSearching to false', () {
      forAll(combine2(songListArb(), emptyOrWhitespaceQueryArb()), (
        values,
      ) async {
        final songs = values.$1;
        final emptyQuery = values.$2;

        // Arrange
        final mockRepo = MockSongRepository();
        final container = ProviderContainer(
          overrides: [songRepositoryProvider.overrideWithValue(mockRepo)],
        );

        // Mock getSongs for initial fetch
        when(
          () => mockRepo.getSongs(
            paginationRequest: any(named: 'paginationRequest'),
          ),
        ).thenAnswer(
          (_) async => Result.success(
            PaginationResponseWrapper<Song>(
              message: 'Success',
              pagination: const PaginationResponseWrapperResponse(
                page: 1,
                pageSize: 50,
                total: 0,
                totalPages: 1,
                hasNext: false,
                hasPrev: false,
              ),
              data: songs,
            ),
          ),
        );

        // Act - Initialize controller and wait for initial fetch
        final controller = container.read(songBookControllerProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 100));

        // Call searchSongs with empty/whitespace query
        await controller.searchSongs(emptyQuery);

        // Assert
        final state = container.read(songBookControllerProvider);
        expect(state.isSearching, isFalse);

        container.dispose();
      });
    });

    property('empty query sets searchQuery to empty string', () {
      forAll(combine2(songListArb(), emptyOrWhitespaceQueryArb()), (
        values,
      ) async {
        final songs = values.$1;
        final emptyQuery = values.$2;

        // Arrange
        final mockRepo = MockSongRepository();
        final container = ProviderContainer(
          overrides: [songRepositoryProvider.overrideWithValue(mockRepo)],
        );

        when(
          () => mockRepo.getSongs(
            paginationRequest: any(named: 'paginationRequest'),
          ),
        ).thenAnswer(
          (_) async => Result.success(
            PaginationResponseWrapper<Song>(
              message: 'Success',
              pagination: const PaginationResponseWrapperResponse(
                page: 1,
                pageSize: 50,
                total: 0,
                totalPages: 1,
                hasNext: false,
                hasPrev: false,
              ),
              data: songs,
            ),
          ),
        );

        // Act
        final controller = container.read(songBookControllerProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 100));
        await controller.searchSongs(emptyQuery);

        // Assert
        final state = container.read(songBookControllerProvider);
        expect(state.searchQuery, equals(''));

        container.dispose();
      });
    });

    property('empty query restores filteredSongs to full songs list', () {
      forAll(combine2(songListArb(), emptyOrWhitespaceQueryArb()), (
        values,
      ) async {
        final songs = values.$1;
        final emptyQuery = values.$2;

        // Arrange
        final mockRepo = MockSongRepository();
        final container = ProviderContainer(
          overrides: [songRepositoryProvider.overrideWithValue(mockRepo)],
        );

        when(
          () => mockRepo.getSongs(
            paginationRequest: any(named: 'paginationRequest'),
          ),
        ).thenAnswer(
          (_) async => Result.success(
            PaginationResponseWrapper<Song>(
              message: 'Success',
              pagination: const PaginationResponseWrapperResponse(
                page: 1,
                pageSize: 50,
                total: 0,
                totalPages: 1,
                hasNext: false,
                hasPrev: false,
              ),
              data: songs,
            ),
          ),
        );

        // Act
        final controller = container.read(songBookControllerProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 100));
        await controller.searchSongs(emptyQuery);

        // Assert
        final state = container.read(songBookControllerProvider);

        // filteredSongs should equal the full songs list
        expect(state.filteredSongs.length, equals(songs.length));
        for (var i = 0; i < songs.length; i++) {
          expect(state.filteredSongs[i].id, equals(songs[i].id));
          expect(state.filteredSongs[i].title, equals(songs[i].title));
        }

        container.dispose();
      });
    });

    property('empty query does not trigger repository searchSongs call', () {
      forAll(combine2(songListArb(), emptyOrWhitespaceQueryArb()), (
        values,
      ) async {
        final songs = values.$1;
        final emptyQuery = values.$2;

        // Arrange
        final mockRepo = MockSongRepository();
        final container = ProviderContainer(
          overrides: [songRepositoryProvider.overrideWithValue(mockRepo)],
        );

        when(
          () => mockRepo.getSongs(
            paginationRequest: any(named: 'paginationRequest'),
          ),
        ).thenAnswer(
          (_) async => Result.success(
            PaginationResponseWrapper<Song>(
              message: 'Success',
              pagination: const PaginationResponseWrapperResponse(
                page: 1,
                pageSize: 50,
                total: 0,
                totalPages: 1,
                hasNext: false,
                hasPrev: false,
              ),
              data: songs,
            ),
          ),
        );

        // Mock searchSongs - should NOT be called
        when(
          () => mockRepo.searchSongs(
            query: any(named: 'query'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer(
          (_) async => Result.success(
            PaginationResponseWrapper<Song>(
              message: 'Success',
              pagination: const PaginationResponseWrapperResponse(
                page: 1,
                pageSize: 20,
                total: 0,
                totalPages: 1,
                hasNext: false,
                hasPrev: false,
              ),
              data: [],
            ),
          ),
        );

        // Act
        final controller = container.read(songBookControllerProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 100));
        await controller.searchSongs(emptyQuery);

        // Assert - searchSongs should NOT have been called
        verifyNever(
          () => mockRepo.searchSongs(
            query: any(named: 'query'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        );

        container.dispose();
      });
    });
  });
}
