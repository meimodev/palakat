import 'package:flutter/material.dart';

import '../models/finance_type.dart';
import '../models/financial_account_number.dart';
import 'divider_widget.dart';

/// A theme-aware picker widget for selecting financial account numbers.
///
/// Displays the selected account number prominently with description below.
/// Uses [Theme.of(context)] for styling instead of hardcoded constants,
/// making it compatible with both palakat and palakat_admin apps.
///
/// This widget accepts an accounts list as a parameter and does not perform
/// internal data fetching. For dialog-based selection with data fetching,
/// use the app-specific implementation (e.g., AccountNumberPickerDialog in palakat).
///
/// Features:
/// - Search functionality to filter accounts by description or account number
/// - Scrollable list for large account sets
/// - Empty state handling when all accounts are assigned
///
/// Example usage:
/// ```dart
/// FinancialAccountPicker(
///   financeType: FinanceType.revenue,
///   accounts: myAccountsList,
///   selectedAccount: currentAccount,
///   onSelected: (account) => setState(() => currentAccount = account),
///   label: 'Account Number',
///   searchable: true,
/// )
/// ```
class FinancialAccountPicker extends StatefulWidget {
  /// Creates a financial account picker widget.
  ///
  /// [financeType] specifies whether this picker is for revenue or expense accounts.
  /// [onSelected] is called when an account is selected from the dropdown.
  /// [accounts] is the list of available accounts to choose from.
  /// [isLoading] shows a loading indicator when true.
  /// [searchable] enables search functionality in the dropdown (default: true).
  const FinancialAccountPicker({
    super.key,
    required this.financeType,
    this.selectedAccount,
    required this.onSelected,
    this.errorText,
    this.label,
    this.accounts,
    this.isLoading = false,
    this.onTap,
    this.searchable = true,
  });

  /// The type of financial account (revenue or expense).
  final FinanceType financeType;

  /// The currently selected financial account number.
  final FinancialAccountNumber? selectedAccount;

  /// Callback when an account number is selected.
  final ValueChanged<FinancialAccountNumber> onSelected;

  /// Error text to display below the picker.
  final String? errorText;

  /// Optional label to display above the picker.
  final String? label;

  /// List of available accounts to choose from.
  /// If null, the picker will show a disabled state.
  final List<FinancialAccountNumber>? accounts;

  /// Whether the accounts are currently being loaded.
  final bool isLoading;

  /// Optional callback when the picker is tapped.
  /// If provided, this will be called instead of showing the built-in dropdown.
  /// Use this to show a custom dialog or bottom sheet.
  final VoidCallback? onTap;

  /// Whether to enable search functionality in the dropdown.
  /// When true, a search input field is shown at the top of the dropdown.
  /// Defaults to true.
  final bool searchable;

  @override
  State<FinancialAccountPicker> createState() => _FinancialAccountPickerState();
}

class _FinancialAccountPickerState extends State<FinancialAccountPicker> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final borderColor = hasError
        ? theme.colorScheme.error
        : theme.colorScheme.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          Text(
            widget.label!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
        IntrinsicHeight(
          child: Material(
            clipBehavior: Clip.hardEdge,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: borderColor, width: 1.5),
            ),
            color: theme.colorScheme.surface,
            shadowColor: theme.shadowColor.withValues(alpha: 0.04),
            elevation: 1,
            child: InkWell(
              onTap: _isEnabled ? () => _handleTap(context) : null,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildDisplayContent(context)),
                    const SizedBox(width: 8),
                    DividerWidget(
                      height: double.infinity,
                      color: theme.colorScheme.outlineVariant,
                    ),
                    const SizedBox(width: 8),
                    _buildTrailingIcon(context),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              widget.errorText!,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }

  bool get _isEnabled =>
      !widget.isLoading &&
      widget.accounts != null &&
      widget.accounts!.isNotEmpty;

  Widget _buildDisplayContent(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isLoading) {
      return Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading accounts...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    }

    // Show empty state message when accounts list is empty
    if (widget.accounts != null && widget.accounts!.isEmpty) {
      return Text(
        'All accounts are assigned to other rules',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (widget.selectedAccount == null) {
      return Text(
        'Select account number',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    return _FinancialAccountDisplay(account: widget.selectedAccount!);
  }

  Widget _buildTrailingIcon(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isLoading) {
      return const SizedBox(width: 12, height: 12);
    }

    return Icon(
      Icons.keyboard_arrow_down,
      size: 20,
      color: theme.colorScheme.onSurfaceVariant,
    );
  }

  void _handleTap(BuildContext context) {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    // Show searchable dropdown dialog if searchable is enabled
    if (widget.searchable) {
      _showSearchableDropdown(context);
    } else {
      _showDropdownMenu(context);
    }
  }

  void _showSearchableDropdown(BuildContext context) {
    if (widget.accounts == null || widget.accounts!.isEmpty) return;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final buttonWidth = button.size.width;

    showDialog<FinancialAccountNumber>(
      context: context,
      builder: (dialogContext) => _SearchableAccountDropdown(
        accounts: widget.accounts!,
        selectedAccount: widget.selectedAccount,
        buttonWidth: buttonWidth,
      ),
    ).then((value) {
      if (value != null) {
        widget.onSelected(value);
      }
    });
  }

  void _showDropdownMenu(BuildContext context) {
    if (widget.accounts == null || widget.accounts!.isEmpty) return;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<FinancialAccountNumber>(
      context: context,
      position: position,
      constraints: BoxConstraints(
        maxHeight: 300,
        minWidth: button.size.width,
        maxWidth: button.size.width,
      ),
      items: widget.accounts!.map((account) {
        return PopupMenuItem<FinancialAccountNumber>(
          value: account,
          child: _FinancialAccountDisplay(account: account),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        widget.onSelected(value);
      }
    });
  }
}

/// Searchable dropdown dialog for financial accounts.
///
/// Provides a search input field that filters accounts by:
/// 1. Description match (case-insensitive) - primary
/// 2. Account number match (case-insensitive) - fallback when no description matches
class _SearchableAccountDropdown extends StatefulWidget {
  const _SearchableAccountDropdown({
    required this.accounts,
    required this.selectedAccount,
    required this.buttonWidth,
  });

  final List<FinancialAccountNumber> accounts;
  final FinancialAccountNumber? selectedAccount;
  final double buttonWidth;

  @override
  State<_SearchableAccountDropdown> createState() =>
      _SearchableAccountDropdownState();
}

class _SearchableAccountDropdownState
    extends State<_SearchableAccountDropdown> {
  late TextEditingController _searchController;
  late List<FinancialAccountNumber> _filteredAccounts;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredAccounts = widget.accounts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filters accounts based on the search query.
  ///
  /// Search strategy:
  /// 1. First, filter by description match (case-insensitive)
  /// 2. If no description matches, fallback to account number match
  List<FinancialAccountNumber> _filterAccounts(String query) {
    if (query.isEmpty) {
      return widget.accounts;
    }

    final lowerQuery = query.toLowerCase();

    // First, try to filter by description
    final descriptionMatches = widget.accounts.where((account) {
      final description = account.description?.toLowerCase() ?? '';
      return description.contains(lowerQuery);
    }).toList();

    // If we have description matches, return them
    if (descriptionMatches.isNotEmpty) {
      return descriptionMatches;
    }

    // Fallback: filter by account number
    return widget.accounts.where((account) {
      final accountNumber = account.accountNumber.toLowerCase();
      return accountNumber.contains(lowerQuery);
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredAccounts = _filterAccounts(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.buttonWidth.clamp(300, 500),
          maxHeight: screenSize.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Select Account',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Search input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search by description or account number',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Divider
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            // Scrollable list of accounts
            Flexible(
              child: _filteredAccounts.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filteredAccounts.length,
                      itemBuilder: (context, index) {
                        final account = _filteredAccounts[index];
                        final isSelected =
                            widget.selectedAccount?.id == account.id;

                        return _AccountListTile(
                          account: account,
                          isSelected: isSelected,
                          onTap: () => Navigator.of(context).pop(account),
                        );
                      },
                    ),
            ),
            // Cancel button
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No accounts found',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search term',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// List tile for displaying a financial account in the dropdown.
class _AccountListTile extends StatelessWidget {
  const _AccountListTile({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  final FinancialAccountNumber account;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(
        alpha: 0.3,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: _FinancialAccountDisplay(account: account),
      trailing: isSelected
          ? Icon(Icons.check, color: theme.colorScheme.primary, size: 20)
          : null,
    );
  }
}

/// Internal widget for displaying a financial account with proper styling.
///
/// Shows the account number prominently (semi-bold) with the description
/// in a secondary style below it.
class _FinancialAccountDisplay extends StatelessWidget {
  const _FinancialAccountDisplay({required this.account});

  final FinancialAccountNumber account;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDescription =
        account.description != null && account.description!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          account.accountNumber,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            // Use monospace-like font feature for account numbers
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (hasDescription) ...[
          const SizedBox(height: 4),
          Text(
            account.description!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
