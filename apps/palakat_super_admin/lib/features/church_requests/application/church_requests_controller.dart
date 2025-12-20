import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/church_request.dart';
import 'package:palakat_shared/core/models/response/pagination_response_wrapper.dart';

import '../data/church_requests_repository.dart';

final churchRequestsControllerProvider =
    NotifierProvider<ChurchRequestsController, ChurchRequestsState>(
      ChurchRequestsController.new,
    );

class ChurchRequestsState {
  static const Object _notProvided = Object();

  const ChurchRequestsState({
    this.items = const AsyncValue.loading(),
    this.page = 1,
    this.pageSize = 10,
    this.search = '',
    this.status,
  });

  final AsyncValue<PaginationResponseWrapper<ChurchRequest>> items;
  final int page;
  final int pageSize;
  final String search;
  final RequestStatus? status;

  ChurchRequestsState copyWith({
    AsyncValue<PaginationResponseWrapper<ChurchRequest>>? items,
    int? page,
    int? pageSize,
    String? search,
    Object? status = _notProvided,
  }) {
    return ChurchRequestsState(
      items: items ?? this.items,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      status: status == _notProvided ? this.status : status as RequestStatus?,
    );
  }
}

class ChurchRequestsController extends Notifier<ChurchRequestsState> {
  late final ChurchRequestsRepository _repository;

  @override
  ChurchRequestsState build() {
    _repository = ref.read(churchRequestsRepositoryProvider);
    Future.microtask(() => refresh());
    return const ChurchRequestsState();
  }

  Future<void> refresh() async {
    state = state.copyWith(items: const AsyncValue.loading());
    try {
      final res = await _repository.fetchChurchRequests(
        page: state.page,
        pageSize: state.pageSize,
        search: state.search.isEmpty ? null : state.search,
        status: state.status,
        sortBy: 'createdAt',
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

  void onChangedStatus(RequestStatus? value) {
    state = state.copyWith(status: value, page: 1);
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
