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
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.w16,
            vertical: BaseSize.h8,
          ),
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                style: BaseTypography.bodyMedium.toError,
                textAlign: TextAlign.center,
              ),
              Gap.h16,
              TextButton(
                onPressed: _fetchAccounts,
                child: Text(context.l10n.btn_retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_accounts.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w24),
          child: Text(
            _searchQuery.isNotEmpty
                ? context.l10n.lbl_noResultsFor(_searchQuery)
                : context.l10n.lbl_noAccountNumbers,
            style: BaseTypography.bodyMedium.toSecondary,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: _accounts.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => Gap.h6,
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w16),
      itemBuilder: (context, index) {
        if (index == _accounts.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: BaseSize.h16),
            child: const Center(child: CircularProgressIndicator()),
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
    return Material(
      clipBehavior: Clip.hardEdge,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        side: BorderSide(
          color: isSelected ? BaseColor.primary : BaseColor.neutral30,
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected
          ? BaseColor.primary.withValues(alpha: 0.05)
          : BaseColor.white,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.accountNumber,
                      style: BaseTypography.titleMedium.copyWith(
                        color: BaseColor.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (account.description != null &&
                        account.description!.isNotEmpty) ...[
                      Gap.h4,
                      Text(
                        account.description!,
                        style: BaseTypography.bodySmall.copyWith(
                          color: BaseColor.neutral60,
                        ),
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
                  color: BaseColor.primary,
                  size: BaseSize.w20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
