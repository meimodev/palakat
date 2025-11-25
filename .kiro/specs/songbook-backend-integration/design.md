# Design Document

## Overview

This design describes the integration of the Palakat mobile app's songbook feature with the NestJS backend API. The integration replaces mock data with real API calls using the existing `SongRepository` from `palakat_shared`. The architecture follows the established Riverpod-based state management pattern with repository abstraction for data access.

## Architecture

The songbook integration follows a layered architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌─────────────────┐    ┌─────────────────────────────────┐ │
│  │ SongBookScreen  │    │ SongDetailScreen                │ │
│  └────────┬────────┘    └────────────┬────────────────────┘ │
│           │                          │                       │
│  ┌────────▼────────┐    ┌────────────▼────────────────────┐ │
│  │SongBookController│   │SongDetailController             │ │
│  └────────┬────────┘    └────────────┬────────────────────┘ │
└───────────┼──────────────────────────┼──────────────────────┘
            │                          │
┌───────────▼──────────────────────────▼──────────────────────┐
│                      Data Layer                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              SongRepository (palakat_shared)          │   │
│  │  - getSongs(paginationRequest)                        │   │
│  │  - searchSongs(query, page, pageSize)                 │   │
│  │  - getSongById(songId)                                │   │
│  └────────────────────────┬─────────────────────────────┘   │
└───────────────────────────┼─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                    Service Layer                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              HttpService (palakat_shared)             │   │
│  │  - GET /song?search=&skip=&take=                      │   │
│  │  - GET /song/:id                                      │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### SongBookController (Modified)

The existing controller will be updated to use `SongRepository` instead of mock data.

```dart
@riverpod
class SongBookController extends _$SongBookController {
  SongRepository get _songRepo => ref.read(songRepositoryProvider);

  @override
  SongBookState build() {
    fetchSongs();
    return SongBookState(
      songs: [],
      filteredSongs: [],
      isLoading: true,
      isSearching: false,
      searchQuery: '',
      errorMessage: null,
    );
  }

  Future<void> fetchSongs() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _songRepo.getSongs(
      paginationRequest: PaginationRequestWrapper(
        page: 1,
        pageSize: 50,
        data: GetFetchSongsRequest(),
      ),
    );

    result.when(
      success: (response) {
        state = state.copyWith(
          songs: response.data,
          filteredSongs: response.data,
          isLoading: false,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  Future<void> searchSongs(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(
        filteredSongs: state.songs,
        searchQuery: '',
        isSearching: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, searchQuery: query, isSearching: true);

    final result = await _songRepo.searchSongs(query: query);

    result.when(
      success: (response) {
        state = state.copyWith(
          filteredSongs: response.data,
          isLoading: false,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }
}
```

### SongRepository (Existing in palakat_shared)

The repository already exists with the required methods:
- `getSongs()` - Fetches paginated songs
- `searchSongs()` - Searches songs by query
- `getSongById()` - Fetches a single song with parts

### Song Model Mapping

The backend returns songs in this format:
```json
{
  "id": 1,
  "title": "KJ NO.1",
  "index": 1,
  "book": "KJ",
  "link": "...",
  "parts": [
    { "id": 1, "index": 1, "name": "Verse 1", "content": "..." }
  ]
}
```

The Flutter `Song` model expects:
```dart
Song(
  id: String,
  title: String,
  subTitle: String,
  composition: List<SongPartType>,
  definition: List<SongPart>,
  urlImage: String,
  urlVideo: String,
)
```

A mapping layer will transform backend responses to the Flutter model format.

## Data Models

### Backend Song Schema (Prisma)

```prisma
model Song {
  id        Int        @id @default(autoincrement())
  title     String
  index     Int        @unique
  book      Book       // enum: NKB, NNBT, KJ, DSL
  link      String
  parts     SongPart[]
}

model SongPart {
  id      Int    @id @default(autoincrement())
  index   Int
  name    String
  content String
  songId  Int
  song    Song   @relation(...)
}
```

### Flutter Song Model (Existing)

```dart
@freezed
abstract class Song with _$Song {
  const factory Song({
    required String id,
    required String title,
    required String subTitle,
    required List<SongPartType> composition,
    @ListSongPartConverter() required List<SongPart> definition,
    @Default("") String urlImage,
    @Default("") String urlVideo,
  }) = _Song;
}
```

### Response Mapping Strategy

Create a mapper to transform backend response to Flutter model:

```dart
extension SongMapper on Map<String, dynamic> {
  Song toSong() {
    final parts = (this['parts'] as List<dynamic>?)
        ?.map((p) => SongPart(
              type: _mapPartName(p['name']),
              content: p['content'] ?? '',
            ))
        .toList() ?? [];
    
    return Song(
      id: this['id'].toString(),
      title: '${this['book']} NO.${this['index']}',
      subTitle: this['title'] ?? '',
      composition: parts.map((p) => p.type).toList(),
      definition: parts,
      urlImage: this['link'] ?? '',
      urlVideo: '',
    );
  }
}
```



## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Search triggers repository call with correct query

*For any* non-empty search query string, when `searchSongs(query)` is called on the SongBookController, the SongRepository's `searchSongs` method SHALL be invoked with that exact query string.

**Validates: Requirements 1.1, 2.1**

### Property 2: Successful response updates state with songs

*For any* successful API response containing a list of songs, the SongBookController state SHALL contain exactly those songs in the `filteredSongs` list with `isLoading` set to false and `errorMessage` set to null.

**Validates: Requirements 1.2, 2.2, 4.2**

### Property 3: Empty query clears search state

*For any* empty or whitespace-only search query, the SongBookController SHALL set `isSearching` to false, `searchQuery` to empty string, and `filteredSongs` to the full `songs` list.

**Validates: Requirements 1.3**

### Property 4: Error response updates state with error message

*For any* failed API response with an error message, the SongBookController state SHALL have `isLoading` set to false and `errorMessage` containing the failure message.

**Validates: Requirements 1.4, 4.3**

### Property 5: Song detail receives complete song data with correct part ordering

*For any* Song with a composition list and definition list, the SongDetailController SHALL produce song parts in the exact order specified by the composition, where each part matches the corresponding type from the definition.

**Validates: Requirements 3.1, 3.2**

### Property 6: Loading state during fetch

*For any* fetch operation initiated on SongBookController, the state SHALL have `isLoading` set to true until the operation completes (success or failure).

**Validates: Requirements 4.1**

### Property 7: Retry triggers new fetch

*For any* state with an error, when `refreshSongs()` is called, the SongBookController SHALL initiate a new fetch operation setting `isLoading` to true.

**Validates: Requirements 4.4**

### Property 8: Backend response to Song model mapping

*For any* valid backend song response JSON containing id, title, index, book, and parts array, the mapping function SHALL produce a Song model where:
- `id` equals the string representation of the backend id
- `title` equals "{book} NO.{index}"
- `subTitle` equals the backend title
- `definition` contains SongPart objects for each backend part
- `composition` contains the types of all parts in order

**Validates: Requirements 5.3**

## Error Handling

### Network Errors

- Connection timeout: Display "Network error. Please check your connection" with retry option
- Server unavailable (5xx): Display "Server error. Please try again later" with retry option

### API Errors

- 401 Unauthorized: Handled by HttpService interceptor, triggers token refresh or logout
- 404 Not Found: Display "Song not found" message
- 400 Bad Request: Display validation error message from response

### Data Errors

- Invalid JSON response: Log error and display generic error message
- Missing required fields: Use default values where possible, log warning

## Testing Strategy

### Property-Based Testing Library

Use `fast_check` package for Dart property-based testing.

### Unit Tests

1. **SongBookController Tests**
   - Test initial state is loading
   - Test successful fetch updates state
   - Test failed fetch sets error message
   - Test search with query calls repository
   - Test empty search clears filter

2. **Song Mapping Tests**
   - Test backend JSON to Song model conversion
   - Test handling of missing optional fields
   - Test part type mapping (verse, chorus, bridge)

### Property-Based Tests

Each correctness property MUST be implemented as a property-based test with:
- Minimum 100 iterations per property
- Comment referencing the property: `// **Feature: songbook-backend-integration, Property {N}: {description}**`

**Generators Required:**
- `Arbitrary<String>` for search queries (including empty, whitespace, special characters)
- `Arbitrary<Song>` for song models with valid compositions
- `Arbitrary<Map<String, dynamic>>` for backend response JSON
- `Arbitrary<Failure>` for error responses

### Integration Tests

1. Test full flow: search → API call → state update → UI render
2. Test error flow: API error → error state → retry → success
3. Test category filter flow: select category → filtered results
