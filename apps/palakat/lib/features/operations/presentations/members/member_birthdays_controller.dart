import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:palakat_shared/services.dart';

@immutable
class MemberBirthdaysState {
  final int? churchId;
  final int? columnId;
  final String? churchName;
  final String? columnName;
  final bool isLoading;
  final String? errorMessage;
  final List<Membership> memberships;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  const MemberBirthdaysState({
    required this.churchId,
    required this.columnId,
    required this.churchName,
    required this.columnName,
    required this.isLoading,
    required this.errorMessage,
    required this.memberships,
    required this.filterStartDate,
    required this.filterEndDate,
  });

  const MemberBirthdaysState.initial()
    : churchId = null,
      columnId = null,
      churchName = null,
      columnName = null,
      isLoading = true,
      errorMessage = null,
      memberships = const [],
      filterStartDate = null,
      filterEndDate = null;

  MemberBirthdaysState copyWith({
    int? churchId,
    int? columnId,
    String? churchName,
    String? columnName,
    bool? isLoading,
    String? errorMessage,
    List<Membership>? memberships,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool clearErrorMessage = false,
  }) {
    return MemberBirthdaysState(
      churchId: churchId ?? this.churchId,
      columnId: columnId ?? this.columnId,
      churchName: churchName ?? this.churchName,
      columnName: columnName ?? this.columnName,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      memberships: memberships ?? this.memberships,
      filterStartDate: filterStartDate ?? this.filterStartDate,
      filterEndDate: filterEndDate ?? this.filterEndDate,
    );
  }

  String? get scopeLabel {
    final c = churchName?.trim();
    final col = columnName?.trim();
    if (c == null || c.isEmpty) return col?.isNotEmpty == true ? col : null;
    if (col == null || col.isEmpty) return c;
    return '$c • $col';
  }
}

final memberBirthdaysControllerProvider =
    NotifierProvider<MemberBirthdaysController, MemberBirthdaysState>(
      MemberBirthdaysController.new,
    );

class MemberBirthdaysController extends Notifier<MemberBirthdaysState> {
  static const int _pageSize = 200;

  MembershipRepository get _membershipRepository =>
      ref.read(membershipRepositoryProvider);

  @override
  MemberBirthdaysState build() {
    final local = ref.read(localStorageServiceProvider);
    final membership =
        local.currentMembership ?? local.currentAuth?.account.membership;

    final churchId = membership?.church?.id ?? membership?.column?.churchId;
    final columnId = membership?.column?.id;

    final initial = MemberBirthdaysState(
      churchId: churchId,
      columnId: columnId,
      churchName: membership?.church?.name,
      columnName: membership?.column?.name,
      isLoading: true,
      errorMessage: null,
      memberships: const [],
      filterStartDate: null,
      filterEndDate: null,
    );

    Future.microtask(fetchMembers);
    return initial;
  }

  void setDateRange({DateTime? start, DateTime? end}) {
    state = state.copyWith(filterStartDate: start, filterEndDate: end);
  }

  void clearDateFilter() {
    state = state.copyWith(filterStartDate: null, filterEndDate: null);
  }

  Future<void> fetchMembers() async {
    final churchId = state.churchId;
    final columnId = state.columnId;

    if (churchId == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Membership scope not found',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    final request = PaginationRequestWrapper<GetFetchMemberPosition>(
      page: 1,
      pageSize: _pageSize,
      sortBy: 'id',
      sortOrder: 'desc',
      data: GetFetchMemberPosition(churchId: churchId, columnId: columnId),
    );

    final Result<PaginationResponseWrapper<Membership>, Failure> result =
        await _membershipRepository.fetchMemberPositionsPagination(
          paginationRequest: request,
        );

    result.when(
      onSuccess: (res) {
        state = state.copyWith(
          isLoading: false,
          memberships: res.data,
          clearErrorMessage: true,
        );
        return null;
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }
}
