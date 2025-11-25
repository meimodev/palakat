# Song Repository Usage

The `SongRepository` provides methods to interact with the song API endpoints.

## Methods

### 1. getSongs
Fetches a paginated list of songs with optional search filtering.

```dart
final repository = ref.read(songRepositoryProvider);

final request = PaginationRequestWrapper(
  page: 1,
  pageSize: 20,
  data: GetFetchSongsRequest(search: 'Tuhan'),
);

final result = await repository.getSongs(paginationRequest: request);

result.when(
  success: (data) {
    // data.data contains List<Song>
    // data.pagination contains pagination metadata
    print('Total songs: ${data.pagination.total}');
    print('Songs: ${data.data}');
  },
  failure: (error) {
    print('Error: ${error.message}');
  },
);
```

### 2. searchSongs
Convenience method to search songs by title or index.

```dart
final repository = ref.read(songRepositoryProvider);

final result = await repository.searchSongs(
  query: 'Kasih Allah',
  page: 1,
  pageSize: 20,
);

result.when(
  success: (data) {
    print('Found ${data.data.length} songs');
  },
  failure: (error) {
    print('Error: ${error.message}');
  },
);
```

### 3. getSongById
Fetches a single song with all its parts.

```dart
final repository = ref.read(songRepositoryProvider);

final result = await repository.getSongById(songId: '123');

result.when(
  success: (song) {
    print('Song: ${song.title}');
    print('Parts: ${song.definition.length}');
  },
  failure: (error) {
    print('Error: ${error.message}');
  },
);
```

## Integration Example

Here's how to integrate the repository into a controller:

```dart
@riverpod
class SongBookController extends _$SongBookController {
  @override
  SongBookState build() {
    fetchSongs();
    return SongBookState.initial();
  }

  Future<void> fetchSongs({int page = 1}) async {
    state = state.copyWith(isLoading: true);
    
    final repository = ref.read(songRepositoryProvider);
    final request = PaginationRequestWrapper(
      page: page,
      pageSize: 20,
      data: GetFetchSongsRequest(),
    );
    
    final result = await repository.getSongs(paginationRequest: request);
    
    result.when(
      success: (data) {
        state = state.copyWith(
          songs: data.data,
          isLoading: false,
        );
      },
      failure: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        );
      },
    );
  }

  Future<void> searchSongs(String query) async {
    if (query.isEmpty) {
      await fetchSongs();
      return;
    }
    
    state = state.copyWith(isLoading: true);
    
    final repository = ref.read(songRepositoryProvider);
    final result = await repository.searchSongs(query: query);
    
    result.when(
      success: (data) {
        state = state.copyWith(
          songs: data.data,
          isLoading: false,
        );
      },
      failure: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        );
      },
    );
  }
}
```

## Requirements Validation

This repository implementation satisfies:
- **Requirement 7.1**: Display songs organized by book and index
- **Requirement 7.2**: Display song with all parts
- **Requirement 7.3**: Search songs by title or index
