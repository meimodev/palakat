import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/cash_account.dart';
import 'package:palakat_shared/repositories.dart';

/// A picker for selecting the [CashAccount] the revenue/expense flows through.
///
/// The backend uses the selected cash account to keep the paired CashMutation
/// in sync, so selection is required before submitting a finance record.
class CashAccountPicker extends ConsumerStatefulWidget {
  const CashAccountPicker({
    super.key,
    this.selectedAccount,
    required this.onSelected,
    this.errorText,
    this.label,
  });

  final CashAccount? selectedAccount;
  final ValueChanged<CashAccount> onSelected;
  final String? errorText;
  final String? label;

  @override
  ConsumerState<CashAccountPicker> createState() => _CashAccountPickerState();
}

class _CashAccountPickerState extends ConsumerState<CashAccountPicker> {
  bool _loading = false;
  String? _loadError;
  List<CashAccount> _accounts = const <CashAccount>[];

  Future<void> _loadAccounts() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final repo = ref.read(cashAccountRepositoryProvider);
    final result = await repo.fetchAccounts();
    if (!mounted) return;
    result.when(
      onSuccess: (page) {
        setState(() {
          _accounts = page?.data ?? const <CashAccount>[];
          _loading = false;
        });
      },
      onFailure: (failure) {
        setState(() {
          _loadError = failure.message;
          _loading = false;
        });
      },
    );
  }

  Future<void> _showSheet() async {
    await _loadAccounts();
    if (!mounted) return;

    final result = await showModalBottomSheet<CashAccount>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Cash Account',
                  style: Theme.of(ctx).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap.h12,
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_loadError != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _loadError!,
                      style: Theme.of(
                        ctx,
                      ).textTheme.bodyMedium!.copyWith(color: AppColors.error),
                    ),
                  )
                else if (_accounts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No cash accounts available. Ask an admin to add one.',
                      style: Theme.of(ctx).textTheme.bodyMedium,
                    ),
                  )
                else
                  ..._accounts.map(
                    (a) => ListTile(
                      dense: true,
                      leading: Icon(
                        AppIcons.accountBalanceWalletOutlined,
                        color: AppColors.primary,
                      ),
                      title: Text(a.name),
                      subtitle: a.balance != null
                          ? Text(
                              '${a.currency} ${a.balance}',
                              style: Theme.of(ctx).textTheme.bodySmall,
                            )
                          : null,
                      trailing: widget.selectedAccount?.id == a.id
                          ? Icon(Icons.check_circle, color: AppColors.primary)
                          : null,
                      onTap: () => Navigator.of(ctx).pop(a),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      widget.onSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final hasSelection = widget.selectedAccount != null;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          Text(
            widget.label!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium!.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          Gap.h6,
        ],
        GestureDetector(
          onTap: _showSheet,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: hasSelection
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: hasError
                    ? AppColors.error.withValues(alpha: 0.5)
                    : hasSelection
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : AppColors.outlineVariant,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: hasSelection
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.surfaceContainerLow,
                    border: Border.all(
                      color: hasSelection
                          ? AppColors.primary.withValues(alpha: 0.18)
                          : AppColors.ghostBorder(0.08),
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Icon(
                    AppIcons.accountBalanceWalletOutlined,
                    size: 20.0,
                    color: hasSelection
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                Gap.w12,
                Expanded(
                  child: Text(
                    hasSelection
                        ? widget.selectedAccount!.name.isNotEmpty
                              ? widget.selectedAccount!.name
                              : 'Cash Account #${widget.selectedAccount!.id}'
                        : 'Select cash account',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: hasSelection
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant,
                      fontWeight: hasSelection
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  hasSelection ? AppIcons.edit : AppIcons.forward,
                  size: 20.0,
                  color: hasSelection
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              widget.errorText!,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }
}
