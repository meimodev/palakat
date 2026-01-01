import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/features/member/presentation/state/member_screen_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'member_controller.g.dart';

@riverpod
class MemberController extends _$MemberController {
  late final Debouncer _searchDebouncer;
  bool _isDisposed = false;

  @override
  MemberScreenState build() {
    _isDisposed = false;
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
    ref.onDispose(() {
      _isDisposed = true;
      _searchDebouncer.dispose();
    });

    final initial = const MemberScreenState();
    Future.microtask(() {
      if (_isDisposed) return;
      _fetchMemberPositions();
      _fetchCounts();
      _fetchAccounts();
    });
    return initial;
  }

  Church get church =>
      ref.read(authControllerProvider).value!.account.membership!.church!;

  Future<void> _fetchAccounts() async {
    if (_isDisposed) return;
    state = state.copyWith(accounts: const AsyncLoading());
    try {
      final repository = ref.read(membershipRepositoryProvider);
      final result = await repository.fetchAccounts(
        paginationRequest: PaginationRequestWrapper(
          data: GetFetchAccountsRequest(
            churchId: church.id,
            search: state.searchQuery.isEmpty ? null : state.searchQuery,
            position: state.selectedPosition?.name.toLowerCase(),
          ),
          page: state.currentPage,
          pageSize: state.pageSize,
          sortBy: 'name',
          sortOrder: 'asc',
        ),
      );
      if (_isDisposed) return;
      result.when(
        onSuccess: (accounts) {
          if (_isDisposed) return;
          state = state.copyWith(accounts: AsyncData(accounts));
        },
        onFailure: (failure) {
          if (_isDisposed) return;
          state = state.copyWith(
            accounts: AsyncError(failure.message, StackTrace.current),
          );
        },
      );
    } catch (e, st) {
      if (_isDisposed) return;
      state = state.copyWith(accounts: AsyncError(e, st));
    }
  }

  Future<void> _fetchCounts() async {
    if (_isDisposed) return;
    state = state.copyWith(counts: const AsyncLoading());
    try {
      final repository = ref.read(membershipRepositoryProvider);
      final result = await repository.fetchCounts(
        GetFetchAccountsRequest(churchId: church.id),
      );
      if (_isDisposed) return;
      result.when(
        onSuccess: (data) {
          if (_isDisposed) return;
          final counts = MemberScreenStateCounts(
            total: data['total'] ?? 0,
            claimed: data['claimed'] ?? 0,
            baptized: data['baptized'] ?? 0,
            sidi: data['sidi'] ?? 0,
          );
          state = state.copyWith(counts: AsyncData(counts));
        },
        onFailure: (failure) {
          if (_isDisposed) return;
          state = state.copyWith(
            counts: AsyncError(failure.message, StackTrace.current),
          );
        },
      );
    } catch (e, st) {
      if (_isDisposed) return;
      state = state.copyWith(counts: AsyncError(e, st));
    }
  }

  Future<void> _fetchMemberPositions() async {
    if (_isDisposed) return;
    state = state.copyWith(positions: const AsyncLoading());
    try {
      final churchRepo = ref.read(churchRepositoryProvider);
      final result = await churchRepo.fetchPositions(churchId: church.id!);
      if (_isDisposed) return;
      result.when(
        onSuccess: (positions) {
          if (_isDisposed) return;
          state = state.copyWith(positions: AsyncData(positions));
        },
        onFailure: (failure) {
          if (_isDisposed) return;
          state = state.copyWith(
            positions: AsyncError(failure.message, StackTrace.current),
          );
        },
      );
    } catch (e, st) {
      if (_isDisposed) return;
      state = state.copyWith(positions: AsyncError(e, st));
    }
  }

  void onChangedSearch(String value) {
    state = state.copyWith(
      searchQuery: value,
      currentPage: 1, // Reset to first page on search
    );
    _searchDebouncer(() => _fetchAccounts());
  }

  void onChangedPosition(MemberPosition? position) {
    state = state.copyWith(
      selectedPosition: position,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchAccounts();
  }

  void onChangedPageSize(int pageSize) {
    state = state.copyWith(
      pageSize: pageSize,
      currentPage: 1, // Reset to first page on page size change
    );
    _fetchAccounts();
  }

  void onChangedPage(int page) {
    state = state.copyWith(currentPage: page);
    _fetchAccounts();
  }

  void onPressedNextPage() {
    state = state.copyWith(currentPage: state.currentPage + 1);
    _fetchAccounts();
  }

  void onPressedPrevPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
      _fetchAccounts();
    }
  }

  Future<void> refresh() async {
    await _fetchAccounts();
  }

  // Fetch single member detail (doesn't mutate state)
  Future<Account> fetchMember(int memberId) async {
    final repository = ref.read(membershipRepositoryProvider);
    final result = await repository.fetchAccount(accountId: memberId);
    final value = result.when<Account>(
      onSuccess: (account) => account,
      onFailure: (failure) => throw Exception(failure.message),
    );
    return value!;
  }

  // Save member (create or update)
  Future<void> saveMember(Account account) async {
    if (_isDisposed) return;
    final repository = ref.read(membershipRepositoryProvider);

    final payload = account.toJson();
    final result = account.id != null
        ? await repository.updateAccount(
            accountId: account.id!,
            update: payload,
          )
        : await repository.createAccount(data: payload);

    if (_isDisposed) return;
    result.when(
      onSuccess: (_) async {
        await _fetchAccounts();
        await _fetchCounts();
      },
      onFailure: (failure) => throw Exception(failure.message),
    );
  }

  // Delete member
  Future<void> deleteMember(int memberId) async {
    if (_isDisposed) return;
    final repository = ref.read(membershipRepositoryProvider);
    final result = await repository.deleteAccount(accountId: memberId);

    if (_isDisposed) return;
    result.when(
      onSuccess: (_) async {
        // Refresh the list after delete
        await _fetchAccounts();
        await _fetchCounts();
      },
      onFailure: (failure) => throw Exception(failure.message),
    );
  }
}
