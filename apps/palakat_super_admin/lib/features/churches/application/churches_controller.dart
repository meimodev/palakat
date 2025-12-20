import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/models/church.dart';
import 'package:palakat_shared/core/models/response/pagination_response_wrapper.dart';

import '../data/churches_repository.dart';

final churchesControllerProvider =
    NotifierProvider<ChurchesController, ChurchesState>(ChurchesController.new);

class ChurchesState {
  const ChurchesState({
    this.items = const AsyncValue.loading(),
    this.page = 1,
    this.pageSize = 10,
    this.search = '',
  });

  final AsyncValue<PaginationResponseWrapper<Church>> items;
  final int page;
  final int pageSize;
  final String search;

  ChurchesState copyWith({
    AsyncValue<PaginationResponseWrapper<Church>>? items,
    int? page,
    int? pageSize,
    String? search,
  }) {
    return ChurchesState(
      items: items ?? this.items,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
    );
  }
}

class ChurchesController extends Notifier<ChurchesState> {
  late final ChurchesRepository _repository;

  @override
  ChurchesState build() {
    _repository = ref.read(churchesRepositoryProvider);
    Future.microtask(() => refresh());
    return const ChurchesState();
  }

  Future<void> refresh() async {
    state = state.copyWith(items: const AsyncValue.loading());
    try {
      final res = await _repository.fetchChurches(
        page: state.page,
        pageSize: state.pageSize,
        search: state.search.isEmpty ? null : state.search,
        sortBy: 'name',
        sortOrder: 'asc',
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
