import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/finance/data/financial_account_repository.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/models/finance_type.dart';
import 'package:palakat_shared/core/models/financial_account_number.dart';
import 'package:palakat_shared/core/services/local_storage_service_provider.dart';
import 'package:palakat_shared/core/widgets/search_field.dart';

/// Shows the account number picker dialog
/// [financeType] filters accounts by type (revenue or expense)
Future<FinancialAccountNumber?> showAccountNumberPickerDialog({
  required BuildContext context,
  required FinanceType financeType,
  FinancialAccountNumber? initialSelection,
}) {
  return showDialogCustomWidget<FinancialAccountNumber?>(
    context: context,
    title: context.l10n.lbl_selectAccount(financeType.displayName),
    scrollControlled: false,
    content: Expanded(
      child: _AccountNumberPickerDialogContent(
        financeType: financeType,
        initialSelection: initialSelection,
      ),
    ),
  );
}

class _AccountNumberPickerDialogContent extends ConsumerStatefulWidget {
  const _AccountNumberPickerDialogContent({
    required this.financeType,
    this.initialSelection,
  });

  final FinanceType financeType;
  final FinancialAccountNumber? initialSelection;

  @override
  ConsumerState<_AccountNumberPickerDialogContent> createState() =>
      _AccountNumberPickerDialogContentState();
}

class _AccountNumberPickerDialogContentState
    extends ConsumerState<_AccountNumberPickerDialogContent> {
  static const int _pageSize = 20;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<FinancialAccountNumber> _accounts = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMorePages = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchAccounts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMore();
    }
  }

  Future<void> _fetchAccounts({bool refresh = true}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 1;
        _hasMorePages = true;
      });
    }

    // Get churchId from localStorage
    final localStorage = ref.read(localStorageServiceProvider);
    final churchId = localStorage.currentMembership?.church?.id;

    if (churchId == null) {
      if (mounted) {
        setState(() {
          _errorMessage = context.l10n.lbl_churchNotAvailable;
          _isLoading = false;
        });
      }
      return;
    }

    final repository = ref.read(financialAccountRepositoryProvider);
    final result = await repository.getAll(
      churchId: churchId,
      page: 1,
      pageSize: _pageSize,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      type: widget.financeType,
    );

    if (mounted) {
      result.when(
        onSuccess: (response) {
          setState(() {
            _accounts = response.data;
            _currentPage = response.pagination.page;
            _hasMorePages = response.pagination.hasNext;
            _isLoading = false;
          });
        },
        onFailure: (failure) {
          setState(() {
            _errorMessage = failure.message;
            _isLoading = false;
          });
        },
      );
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMorePages) return;

    setState(() => _isLoadingMore = true);

    final localStorage = ref.read(localStorageServiceProvider);
    final churchId = localStorage.currentMembership?.church?.id;

    if (churchId == null) {
      setState(() => _isLoadingMore = false);
      return;
    }

    final repository = ref.read(financialAccountRepositoryProvider);
    final result = await repository.getAll(
      churchId: churchId,
      page: _currentPage + 1,
      pageSize: _pageSize,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      type: widget.financeType,
    );

    if (mounted) {
      result.when(
        onSuccess: (response) {
          setState(() {
            _accounts = [..._accounts, ...response.data];
            _currentPage = response.pagination.page;
            _hasMorePages = response.pagination.hasNext;
            _isLoadingMore = false;
          });
        },
        onFailure: (failure) {
          setState(() => _isLoadingMore = false);
        },
      );
    }
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _fetchAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search field
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SearchField(
            controller: _searchController,
            hint: context.l10n.lbl_searchAccountNumber,
            debounceMilliseconds: 500,
            unfocusOnSearch: true,
            prefixIcon: FaIcon(AppIcons.search),
            clearIcon: FaIcon(AppIcons.clear),
            onSearch: _onSearchChanged,
            onChanged: null,
          ),
        ),
        Gap.h8,
        // Account list
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: LoadingShimmer(
            isLoading: true,
            child: PalakatShimmerPlaceholders.listSection(),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return ErrorDisplayWidget(
        message: _errorMessage!,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        onRetry: () => _fetchAccounts(),
      );
    }

    if (_accounts.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(SanctuaryLayout.radiusLarge),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    border: Border.all(color: AppColors.ghostBorder(0.06)),
                    borderRadius: BorderRadius.circular(
                      SanctuaryLayout.radiusLarge,
                    ),
                    boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.search_off_rounded,
                    size: 24.0,
                    color: AppColors.primary,
                  ),
                ),
                Gap.h12,
                Text(
                  _searchQuery.isNotEmpty
                      ? context.l10n.lbl_noResultsFor(_searchQuery)
                      : context.l10n.lbl_noAccountNumbers,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: _accounts.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => Gap.h6,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        if (index == _accounts.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: LoadingShimmer(
              isLoading: true,
              child: PalakatShimmerPlaceholders.listItemCard(),
            ),
          );
        }

        final account = _accounts[index];
        final isSelected = widget.initialSelection?.id == account.id;

        return _AccountNumberCard(
          account: account,
          isSelected: isSelected,
          onPressed: () => context.pop<FinancialAccountNumber>(account),
        );
      },
    );
  }
}

class _AccountNumberCard extends StatelessWidget {
  const _AccountNumberCard({
    required this.account,
    required this.onPressed,
    this.isSelected = false,
  });

  final FinancialAccountNumber account;
  final VoidCallback onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: SanctuaryDepth.ambient(opacity: 0.015, blur: 8),
        borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
      ),
      child: Material(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SanctuaryLayout.radius),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.ghostBorder(0.08),
            width: isSelected ? 2 : 1,
          ),
        ),
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.surfaceContainerLowest,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.accountNumber,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      if (account.description != null &&
                          account.description!.isNotEmpty) ...[
                        Gap.h4,
                        Text(
                          account.description!,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: AppColors.tertiary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected) ...[
                  Gap.w8,
                  FaIcon(
                    AppIcons.successSolid,
                    color: AppColors.primary,
                    size: 20.0,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
