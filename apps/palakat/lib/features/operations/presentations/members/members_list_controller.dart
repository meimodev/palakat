import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:palakat_shared/services.dart';

@immutable
class MembersListState {
  final int? churchId;
  final int? columnId;
  final String? churchName;
  final String? columnName;
  final bool isLoading;
  final String? errorMessage;
  final List<Membership> memberships;
  final String searchQuery;

  const MembersListState({
    required this.churchId,
    required this.columnId,
    required this.churchName,
    required this.columnName,
    required this.isLoading,
    required this.errorMessage,
    required this.memberships,
    required this.searchQuery,
  });

  const MembersListState.initial()
    : churchId = null,
      columnId = null,
      churchName = null,
      columnName = null,
      isLoading = true,
      errorMessage = null,
      memberships = const [],
      searchQuery = '';

  MembersListState copyWith({
    int? churchId,
    int? columnId,
    String? churchName,
    String? columnName,
    bool? isLoading,
    String? errorMessage,
    List<Membership>? memberships,
    String? searchQuery,
    bool clearErrorMessage = false,
  }) {
    return MembersListState(
      churchId: churchId ?? this.churchId,
      columnId: columnId ?? this.columnId,
      churchName: churchName ?? this.churchName,
      columnName: columnName ?? this.columnName,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      memberships: memberships ?? this.memberships,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  String? get scopeLabel {
    final c = churchName?.trim();
    final col = columnName?.trim();
    if (c == null || c.isEmpty) return col?.isNotEmpty == true ? col : null;
    if (col == null || col.isEmpty) return c;
    return '$c • $col';
  }

  List<Membership> get filteredMemberships {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return memberships;
    return memberships.where((m) {
      final name = m.account?.name.toLowerCase() ?? '';
      final phone = m.account?.phone.toLowerCase() ?? '';
      return name.contains(q) || phone.contains(q);
    }).toList();
  }
}

final membersListControllerProvider =
    NotifierProvider<MembersListController, MembersListState>(
      MembersListController.new,
    );

class MembersListController extends Notifier<MembersListState> {
  static const int _pageSize = 200;

  MembershipRepository get _membershipRepository =>
      ref.read(membershipRepositoryProvider);

  @override
  MembersListState build() {
    final local = ref.read(localStorageServiceProvider);
    final membership =
        local.currentMembership ?? local.currentAuth?.account.membership;

    final churchId = membership?.church?.id ?? membership?.column?.churchId;
    final columnId = membership?.column?.id;

    final initial = MembersListState(
      churchId: churchId,
      columnId: columnId,
      churchName: membership?.church?.name,
      columnName: membership?.column?.name,
      isLoading: true,
      errorMessage: null,
      memberships: const [],
      searchQuery: '',
    );

    Future.microtask(fetchMembers);
    return initial;
  }

  void setSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
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
