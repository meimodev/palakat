import 'package:flutter/material.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';

import '../models/finance_type.dart';
import '../models/financial_account_number.dart';
import 'searchable_dialog_picker.dart';
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
      (widget.onTap != null ||
          (widget.accounts != null && widget.accounts!.isNotEmpty));

  Widget _buildDisplayContent(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

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
            l10n.loading_data,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    }

    // Show empty state message when accounts list is empty
    // Skip this message if onTap is provided (accounts will be fetched in dialog)
    if (widget.onTap == null &&
        widget.accounts != null &&
        widget.accounts!.isEmpty) {
      return Text(
        l10n.noData_financial,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (widget.selectedAccount == null) {
      return Text(
        l10n.lbl_selectAccount(widget.financeType.displayName),
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
        financeTypeLabel: widget.financeType.displayName,
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
class _SearchableAccountDropdown extends StatelessWidget {
  const _SearchableAccountDropdown({
    required this.accounts,
    required this.selectedAccount,
    required this.financeTypeLabel,
    required this.buttonWidth,
  });

  final List<FinancialAccountNumber> accounts;
  final FinancialAccountNumber? selectedAccount;
  final String financeTypeLabel;
  final double buttonWidth;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SearchableDialogPicker<FinancialAccountNumber>(
      title: l10n.lbl_selectAccount(financeTypeLabel),
      searchHint: l10n.lbl_searchAccountNumber,
      items: accounts,
      selectedItem: selectedAccount,
      itemBuilder: (account) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            account.accountNumber,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (account.description != null && account.description!.isNotEmpty)
            Text(
              account.description!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
        ],
      ),
      onFilter: (account, query) {
        // First, try to filter by description
        final description = account.description?.toLowerCase() ?? '';
        if (description.contains(query)) return true;

        // Fallback: filter by account number
        return account.accountNumber.toLowerCase().contains(query);
      },
      emptyStateMessage: l10n.noData_matchingCriteria,
      maxWidth: buttonWidth.clamp(300, 500),
      maxHeightFactor: 0.6,
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
