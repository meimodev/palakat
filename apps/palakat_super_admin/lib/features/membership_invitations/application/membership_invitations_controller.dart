import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/palakat_shared.dart';

import '../data/membership_invitations_repository.dart';

final membershipInvitationsControllerProvider =
    NotifierProvider<
      MembershipInvitationsController,
      MembershipInvitationsState
    >(MembershipInvitationsController.new);

class MembershipInvitationsState {
  static const Object _notProvided = Object();

  const MembershipInvitationsState({
    this.items = const AsyncValue.loading(),
    this.page = 1,
    this.pageSize = 10,
    this.search = '',
    this.status,
    this.dateRangePreset = DateRangePreset.allTime,
    this.customDateRange,
  });

  final AsyncValue<PaginationResponseWrapper<MembershipInvitation>> items;
  final int page;
  final int pageSize;
  final String search;
  final MembershipInvitationStatus? status;
  final DateRangePreset dateRangePreset;
  final DateTimeRange? customDateRange;

  MembershipInvitationsState copyWith({
    AsyncValue<PaginationResponseWrapper<MembershipInvitation>>? items,
    int? page,
    int? pageSize,
    String? search,
    DateRangePreset? dateRangePreset,
    Object? status = _notProvided,
    Object? customDateRange = _notProvided,
  }) {
    return MembershipInvitationsState(
      items: items ?? this.items,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      dateRangePreset: dateRangePreset ?? this.dateRangePreset,
      status: status == _notProvided
          ? this.status
          : status as MembershipInvitationStatus?,
      customDateRange: customDateRange == _notProvided
          ? this.customDateRange
          : customDateRange as DateTimeRange?,
    );
  }
}

class MembershipInvitationsController
    extends Notifier<MembershipInvitationsState> {
  late final MembershipInvitationsRepository _repository;

  @override
  MembershipInvitationsState build() {
    _repository = ref.read(membershipInvitationsRepositoryProvider);
    Future.microtask(() => refresh());
    return const MembershipInvitationsState();
  }

  String? _statusToApi(MembershipInvitationStatus? status) {
    if (status == null) return null;
    switch (status) {
      case MembershipInvitationStatus.pending:
        return 'PENDING';
      case MembershipInvitationStatus.approved:
        return 'APPROVED';
      case MembershipInvitationStatus.rejected:
        return 'REJECTED';
    }
  }

  DateTimeRange? _effectiveDateRange() {
    if (state.dateRangePreset == DateRangePreset.custom) {
      return state.customDateRange;
    }
    if (state.dateRangePreset != DateRangePreset.allTime) {
      return state.dateRangePreset.getDateRange();
    }
    return null;
  }

  Future<void> refresh() async {
    state = state.copyWith(items: const AsyncValue.loading());
    try {
      final range = _effectiveDateRange();
      final res = await _repository.fetchMembershipInvitations(
        page: state.page,
        pageSize: state.pageSize,
        search: state.search.isEmpty ? null : state.search,
        status: _statusToApi(state.status),
        startDate: range?.start,
        endDate: range?.end,
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

  void onChangedStatus(MembershipInvitationStatus? value) {
    state = state.copyWith(status: value, page: 1);
    Future.microtask(() => refresh());
  }

  void onChangedDateRangePreset(DateRangePreset preset) {
    state = state.copyWith(
      dateRangePreset: preset,
      customDateRange: preset == DateRangePreset.custom
          ? state.customDateRange
          : null,
      page: 1,
    );
    Future.microtask(() => refresh());
  }

  void onCustomDateRangeSelected(DateTimeRange? dateRange) {
    state = state.copyWith(
      dateRangePreset: DateRangePreset.custom,
      customDateRange: dateRange,
      page: 1,
    );
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

  Future<void> approve(int id) async {
    await _repository.approve(id: id);
    await refresh();
  }

  Future<void> reject(int id, {String? rejectedReason}) async {
    await _repository.reject(id: id, rejectedReason: rejectedReason);
    await refresh();
  }

  Future<void> delete(int id) async {
    await _repository.delete(id: id);
    await refresh();
  }
}
