import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import '../state/approval_controller.dart';

class ApprovalEditDrawer extends ConsumerStatefulWidget {
  final int? ruleId;
  final int churchId;
  final Future<void> Function(ApprovalRule) onSave;
  final Future<void> Function()? onDelete;
  final VoidCallback onClose;

  const ApprovalEditDrawer({
    super.key,
    this.ruleId,
    required this.churchId,
    required this.onSave,
    this.onDelete,
    required this.onClose,
  });

  @override
  ConsumerState<ApprovalEditDrawer> createState() => _ApprovalEditDrawerState();
}

class _ApprovalEditDrawerState extends ConsumerState<ApprovalEditDrawer> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _active = true;
  final List<MemberPosition> _selectedPositions = [];
  List<MemberPosition> _allPositions = [];
  ApprovalRule? _fetchedRule; // Latest rule copy (fetched)

  // New fields for activity type and financial filtering
  ActivityType? _selectedActivityType;
  FinanceType? _selectedFinancialType;
  FinancialAccountNumber? _selectedFinancialAccount;
  List<FinancialAccountNumber> _financialAccounts = [];
  bool _loadingFinancialAccounts = false;

  bool _loading = false;
  bool _deleting = false;
  bool _saving = false;
  String? _errorMessage;

  // Inline validation errors
  String? _nameError;
  String? _positionsError;
  String? _financialAccountError;

  bool get _isNew => widget.ruleId == null;

  @override
  void initState() {
    super.initState();
    // Fetch data when drawer opens
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      // Fetch positions for the church
      final positions = await ref
          .read(approvalControllerProvider.notifier)
          .fetchPositionsByChurch(widget.churchId);

      // If editing, fetch rule details
      ApprovalRule? rule;
      if (widget.ruleId != null) {
        rule = await ref
            .read(approvalControllerProvider.notifier)
            .fetchRuleDetail(widget.ruleId!);
      }

      setState(() {
        _loading = false;
        _errorMessage = null;
        _allPositions = positions;
        _fetchedRule = rule;

        if (rule != null) {
          _nameController.text = rule.name;
          _descriptionController.text = rule.description ?? '';
          _active = rule.active;
          _selectedPositions.clear();
          _selectedPositions.addAll(rule.positions);
          _selectedActivityType = rule.activityType;
          _selectedFinancialType = rule.financialType;
        }
      });

      // Fetch financial accounts if financial type is set (outside setState)
      if (rule?.financialType != null) {
        await _fetchFinancialAccounts(rule!.financialType!);
        // Resolve the account ID to the full object
        final accountId = rule.financialAccountNumberId;
        if (accountId != null && _financialAccounts.isNotEmpty) {
          setState(() {
            _selectedFinancialAccount = _financialAccounts
                .where((a) => a.id == accountId)
                .firstOrNull;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    // Clear previous errors
    setState(() {
      _nameError = null;
      _positionsError = null;
      _financialAccountError = null;
    });

    // Validate fields
    bool hasError = false;

    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = 'Rule name is required';
      });
      hasError = true;
    }

    if (_selectedPositions.isEmpty) {
      setState(() {
        _positionsError = 'At least one position must be selected';
      });
      hasError = true;
    }

    // Validate financial account is required when financial type is selected
    if (_selectedFinancialType != null && _selectedFinancialAccount == null) {
      setState(() {
        _financialAccountError =
            'Financial account number is required when financial type is selected';
      });
      hasError = true;
    }

    if (hasError) return;

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final nameTrimmed = _nameController.text.trim();
      final descTrimmed = _descriptionController.text.trim();
      final formattedName =
          '${nameTrimmed.substring(0, 1).toUpperCase()}${nameTrimmed.substring(1)}';
      final formattedDesc = descTrimmed.isEmpty
          ? null
          : '${descTrimmed.substring(0, 1).toUpperCase()}${descTrimmed.substring(1)}';

      final updated =
          _fetchedRule?.copyWith(
            name: formattedName,
            description: formattedDesc,
            active: _active,
            positions: _selectedPositions,
            activityType: _selectedActivityType,
            financialType: _selectedFinancialType,
            financialAccountNumberId: _selectedFinancialAccount?.id,
          ) ??
          ApprovalRule(
            name: formattedName,
            description: formattedDesc,
            churchId: widget.churchId,
            positions: _selectedPositions,
            active: _active,
            activityType: _selectedActivityType,
            financialType: _selectedFinancialType,
            financialAccountNumberId: _selectedFinancialAccount?.id,
          );

      await widget.onSave(updated);
      if (!mounted) return;
      widget.onClose();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e is AppError ? e.userMessage : 'Failed to save rule';
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteRule() async {
    if (widget.onDelete == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rule'),
        content: const Text(
          'Are you sure you want to delete this approval rule?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _deleting = true;
      _errorMessage = null;
    });

    try {
      await widget.onDelete!();
      if (!mounted) return;
      widget.onClose();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e is AppError ? e.userMessage : 'Failed to delete rule';
      });
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  void _onRetry() {
    _fetchData();
  }

  Future<void> _fetchFinancialAccounts(FinanceType type) async {
    setState(() {
      _loadingFinancialAccounts = true;
    });

    try {
      final accounts = await ref
          .read(approvalControllerProvider.notifier)
          .fetchFinancialAccountNumbers(
            churchId: widget.churchId,
            type: type.value,
            currentRuleId: widget.ruleId,
          );

      if (mounted) {
        setState(() {
          _financialAccounts = accounts;
          _loadingFinancialAccounts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _financialAccounts = [];
          _loadingFinancialAccounts = false;
        });
      }
    }
  }

  void _onActivityTypeChanged(ActivityType? value) {
    setState(() {
      _selectedActivityType = value;
    });
  }

  void _onFinancialTypeChanged(FinanceType? value) {
    setState(() {
      _selectedFinancialType = value;
      _selectedFinancialAccount = null;
      _financialAccounts = [];
    });

    if (value != null) {
      _fetchFinancialAccounts(value);
    }
  }

  void _onFinancialAccountSelected(FinancialAccountNumber account) {
    setState(() {
      _selectedFinancialAccount = account;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SideDrawer(
      title: _isNew ? 'Add Approval Rule' : 'Edit Approval Rule',
      subtitle: _isNew
          ? 'Create a new approval rule'
          : 'Update approval rule information',
      onClose: widget.onClose,
      isLoading: _loading || _deleting || _saving,
      loadingMessage: _deleting
          ? 'Deleting rule...'
          : _saving
          ? 'Saving rule...'
          : 'Loading rule details...',
      errorMessage: _errorMessage,
      onRetry: _onRetry,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rule Information Section
          InfoSection(
            title: 'Rule Information',
            titleSpacing: 16,
            children: [
              if (!_isNew && _fetchedRule != null) ...[
                LabeledField(
                  label: 'Rule ID',
                  child: Text(
                    "# ${_fetchedRule!.id}",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              LabeledField(
                label: 'Rule Name',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Financial Transactions',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        errorBorder: _nameError != null
                            ? OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.error,
                                  width: 1,
                                ),
                              )
                            : null,
                      ),
                      onChanged: (_) {
                        // Clear error when user types
                        if (_nameError != null) {
                          setState(() {
                            _nameError = null;
                          });
                        }
                      },
                    ),
                    if (_nameError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _nameError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Description (Optional)',
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Describe when this approval is required',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  maxLines: 3,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Status Section
          InfoSection(
            title: 'Status',
            titleSpacing: 16,
            children: [
              SwitchListTile(
                value: _active,
                onChanged: (value) {
                  setState(() {
                    _active = value;
                  });
                },
                title: const Text('Active'),
                subtitle: Text(
                  _active
                      ? 'This rule is currently active'
                      : 'This rule is inactive and will not be enforced',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Activity Type Section
          InfoSection(
            title: 'Activity Type Filter',
            titleSpacing: 16,
            children: [
              LabeledField(
                label: 'Activity Type (Optional)',
                child: DropdownButtonFormField<ActivityType?>(
                  value: _selectedActivityType,
                  decoration: InputDecoration(
                    hintText: 'All activity types',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  items: [
                    const DropdownMenuItem<ActivityType?>(
                      value: null,
                      child: Text('All activity types'),
                    ),
                    ...ActivityType.values.map((type) {
                      return DropdownMenuItem<ActivityType?>(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }),
                  ],
                  onChanged: _onActivityTypeChanged,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'When set, this rule only applies to activities of the selected type.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Financial Type Section
          InfoSection(
            title: 'Financial Filter',
            titleSpacing: 16,
            children: [
              LabeledField(
                label: 'Financial Type (Optional)',
                child: DropdownButtonFormField<FinanceType?>(
                  value: _selectedFinancialType,
                  decoration: InputDecoration(
                    hintText: 'No financial filter',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  items: [
                    const DropdownMenuItem<FinanceType?>(
                      value: null,
                      child: Text('No financial filter'),
                    ),
                    ...FinanceType.values.map((type) {
                      return DropdownMenuItem<FinanceType?>(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }),
                  ],
                  onChanged: _onFinancialTypeChanged,
                ),
              ),
              if (_selectedFinancialType != null) ...[
                const SizedBox(height: 16),
                FinancialAccountPicker(
                  financeType: _selectedFinancialType!,
                  selectedAccount: _selectedFinancialAccount,
                  accounts: _financialAccounts,
                  isLoading: _loadingFinancialAccounts,
                  label: 'Financial Account Number *',
                  onSelected: (account) {
                    _onFinancialAccountSelected(account);
                    // Clear error when user selects an account
                    if (_financialAccountError != null) {
                      setState(() {
                        _financialAccountError = null;
                      });
                    }
                  },
                ),
                if (_financialAccountError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _financialAccountError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 8),
              Text(
                'When set, this rule only applies to activities with matching financial data.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Positions Section
          InfoSection(
            title: 'Required Approvers',
            titleSpacing: 16,
            children: [
              LabeledField(
                label: 'Positions',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _allPositions.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'No positions available',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : PositionSelector(
                            selectedPositions: _selectedPositions,
                            onPositionsChanged: (positions) {
                              setState(() {
                                _selectedPositions.clear();
                                _selectedPositions.addAll(positions);
                                // Clear error when user selects positions
                                if (_positionsError != null) {
                                  _positionsError = null;
                                }
                              });
                            },
                            availablePositions: _allPositions,
                            hintText: 'Select positions to approve...',
                            enabled: true,
                          ),
                    if (_positionsError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _positionsError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      footer: Row(
        children: [
          if (!_isNew && widget.onDelete != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _deleteRule,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                ),
                child: const Text('Delete'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: Text(_isNew ? 'Create' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }
}
