import 'package:palakat_admin/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'approval_screen_state.dart';

part 'approval_controller.g.dart';

@riverpod
class ApprovalController extends _$ApprovalController {
  late final Debouncer _searchDebouncer;

  @override
  ApprovalScreenState build() {
    _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));
    ref.onDispose(() => _searchDebouncer.dispose());

    final initial = const ApprovalScreenState();
    Future.microtask(() {
      _fetchRules();
      _fetchPositions();
    });
    return initial;
  }

  Church get church =>
      ref.read(authControllerProvider).value!.account.membership!.church!;

  Future<void> _fetchRules() async {
    state = state.copyWith(rules: const AsyncValue.loading());
    try {
      final repository = ref.read(approvalRepositoryProvider);

      final result = await repository.fetchApprovalRules(
        paginationRequest: PaginationRequestWrapper(
          data: GetFetchApprovalRulesRequest(
            churchId: church.id!,
            search: state.searchQuery.isEmpty ? null : state.searchQuery,
            active: state.activeOnly,
            positionId: state.selectedPositionId,
          ),
          page: state.currentPage,
          pageSize: state.pageSize,
        ),
      );
      result.when(
        onSuccess: (rules) =>
            state = state.copyWith(rules: AsyncValue.data(rules)),
        onFailure: (failure) => state = state.copyWith(
          rules: AsyncValue.error(failure.message, StackTrace.current),
        ),
      );
    } catch (e, st) {
      state = state.copyWith(rules: AsyncValue.error(e, st));
    }
  }

  Future<void> _fetchPositions() async {
    state = state.copyWith(positions: const AsyncValue.loading());
    try {
      final repository = ref.read(approvalRepositoryProvider);

      // Fetch all positions for the church (no pagination needed for positions dropdown)
      final result = await repository.fetchMembershipPositions(
        paginationRequest: PaginationRequestWrapper(
          data: GetFetchPositionsRequest(churchId: church.id!),
          page: 1,
          pageSize: 100, // Get all positions
        ),
      );
      result.when(
        onSuccess: (positions) =>
            state = state.copyWith(positions: AsyncValue.data(positions)),
        onFailure: (failure) => state = state.copyWith(
          positions: AsyncValue.error(failure.message, StackTrace.current),
        ),
      );
    } catch (e, st) {
      state = state.copyWith(positions: AsyncValue.error(e, st));
    }
  }

  void onChangedSearch(String value) {
    state = state.copyWith(
      searchQuery: value,
      currentPage: 1, // Reset to first page on search
    );
    _searchDebouncer(() => _fetchRules());
  }

  void onChangedActiveFilter(bool? activeOnly) {
    state = state.copyWith(
      activeOnly: activeOnly,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchRules();
  }

  void onChangedPositionFilter(int? positionId) {
    state = state.copyWith(
      selectedPositionId: positionId,
      currentPage: 1, // Reset to first page on filter change
    );
    _fetchRules();
  }

  void onChangedPage(int page) {
    state = state.copyWith(currentPage: page);
    _fetchRules();
  }

  void onChangedPageSize(int pageSize) {
    state = state.copyWith(
      pageSize: pageSize,
      currentPage: 1, // Reset to first page on page size change
    );
    _fetchRules();
  }

  void onPrevPage() {
    if (state.currentPage > 1) {
      onChangedPage(state.currentPage - 1);
    }
  }

  void onNextPage() {
    final pagination = state.rules.value?.pagination;
    if (pagination != null && pagination.hasNext) {
      onChangedPage(state.currentPage + 1);
    }
  }

  Future<void> saveRule(ApprovalRule rule) async {
    try {
      final repository = ref.read(approvalRepositoryProvider);
      final data = rule.toJson();

      final result = rule.id == null || rule.id == 0
          ? await repository.createApprovalRule(data..remove('id'))
          : await repository.updateApprovalRule(ruleId: rule.id!, data: data);

      result.when(
        onSuccess: (_) => _fetchRules(),
        onFailure: (failure) => throw Exception(failure.message),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRule(int ruleId) async {
    try {
      final repository = ref.read(approvalRepositoryProvider);
      final result = await repository.deleteApprovalRule(ruleId);

      result.when(
        onSuccess: (_) => _fetchRules(),
        onFailure: (failure) => throw Exception(failure.message),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch a single approval rule by ID (for drawer detail view)
  Future<ApprovalRule> fetchRuleDetail(int ruleId) async {
    try {
      final repository = ref.read(approvalRepositoryProvider);
      final result = await repository.fetchApprovalRuleById(ruleId);
      final value = result.when<ApprovalRule>(
        onSuccess: (rule) => rule,
        onFailure: (failure) => throw Exception(failure.message),
      );
      return value!;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch positions for a specific church (for drawer selector)
  Future<List<MemberPosition>> fetchPositionsByChurch(int churchId) async {
    try {
      final repository = ref.read(approvalRepositoryProvider);

      final result = await repository.fetchMembershipPositions(
        paginationRequest: PaginationRequestWrapper(
          data: GetFetchPositionsRequest(churchId: churchId),
          page: 1,
          pageSize: 100, // Get all positions
        ),
      );

      final value = result.when<List<MemberPosition>>(
        onSuccess: (positions) => positions.data,
        onFailure: (failure) => throw Exception(failure.message),
      );
      return value!;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch available financial account numbers for a specific church and optional type
  ///
  /// Used for populating the financial account dropdown in approval rule forms.
  /// [type] should be 'REVENUE' or 'EXPENSE' to filter by financial type.
  /// [currentRuleId] should be provided when editing an existing rule to include
  /// the currently assigned account in the available options.
  Future<List<FinancialAccountNumber>> fetchFinancialAccountNumbers({
    required int churchId,
    String? type,
    int? currentRuleId,
  }) async {
    state = state.copyWith(financialAccounts: const AsyncValue.loading());
    try {
      final repository = ref.read(approvalRepositoryProvider);

      final result = await repository.getAvailableAccounts(
        churchId: churchId,
        type: type,
        currentRuleId: currentRuleId,
      );

      final value = result.when<List<FinancialAccountNumber>>(
        onSuccess: (accounts) {
          state = state.copyWith(financialAccounts: AsyncValue.data(accounts));
          return accounts;
        },
        onFailure: (failure) {
          state = state.copyWith(
            financialAccounts: AsyncValue.error(
              failure.message,
              StackTrace.current,
            ),
          );
          throw Exception(failure.message);
        },
      );
      return value!;
    } catch (e, st) {
      state = state.copyWith(financialAccounts: AsyncValue.error(e, st));
      rethrow;
    }
  }

  /// Clear financial accounts state (e.g., when financial type is deselected)
  void clearFinancialAccounts() {
    state = state.copyWith(financialAccounts: const AsyncValue.data([]));
  }

  void refresh() {
    _fetchRules();
    _fetchPositions();
  }
}
