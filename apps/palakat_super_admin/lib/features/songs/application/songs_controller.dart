import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/models/response/pagination_response_wrapper.dart';

import '../data/admin_song_model.dart';
import '../data/songs_repository.dart';

final songsControllerProvider = NotifierProvider<SongsController, SongsState>(
  SongsController.new,
);

class SongsState {
  const SongsState({
    this.items = const AsyncValue.loading(),
    this.page = 1,
    this.pageSize = 10,
    this.search = '',
  });

  final AsyncValue<PaginationResponseWrapper<AdminSongModel>> items;
  final int page;
  final int pageSize;
  final String search;

  SongsState copyWith({
    AsyncValue<PaginationResponseWrapper<AdminSongModel>>? items,
    int? page,
    int? pageSize,
    String? search,
  }) {
    return SongsState(
      items: items ?? this.items,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
    );
  }
}

class SongsController extends Notifier<SongsState> {
  late final SongsRepository _repository;

  @override
  SongsState build() {
    _repository = ref.read(songsRepositoryProvider);
    Future.microtask(() => refresh());
    return const SongsState();
  }

  Future<void> refresh() async {
    state = state.copyWith(items: const AsyncValue.loading());
    try {
      final res = await _repository.fetchSongs(
        page: state.page,
        pageSize: state.pageSize,
        search: state.search.isEmpty ? null : state.search,
        sortBy: 'id',
        sortOrder: 'desc',
      );
      state = state.copyWith(items: AsyncValue.data(res));
    } catch (e, st) {
      state = state.copyWith(items: AsyncValue.error(e, st));
    }
  }

  void onChangedSearch(String value) {
    state = state.copyWith(search: value, page: 1);
    Future.microtask(() => refresh());
  }

  void onChangedPageSize(int value) {
    state = state.copyWith(pageSize: value, page: 1);
    Future.microtask(() => refresh());
  }

  void onChangedPage(int value) {
    state = state.copyWith(page: value);
    Future.microtask(() => refresh());
  }

  void onPrev() {
    if (state.page > 1) {
      state = state.copyWith(page: state.page - 1);
      Future.microtask(() => refresh());
    }
  }

  void onNext() {
    final pagination = state.items.asData?.value.pagination;
    if (pagination != null && pagination.hasNext) {
      state = state.copyWith(page: state.page + 1);
      Future.microtask(() => refresh());
    }
  }
}
