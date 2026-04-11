import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;
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
  ApprovalRule? _fetchedRule;

  // Activity + financial type fields
  ActivityType? _selectedActivityType;
  Bipra? _selectedBipra;
  FinanceType? _selectedFinancialType;

  bool _loading = false;
  bool _deleting = false;
  bool _saving = false;
  String? _errorMessage;

  // Inline validation errors
  String? _nameError;
  String? _positionsError;

  bool get _isNew => widget.ruleId == null;

  // Bipra selector only relevant for SERVICE activities
  bool get _showBipra => _selectedActivityType == ActivityType.service;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final positions = await ref
          .read(approvalControllerProvider.notifier)
          .fetchPositionsByChurch(widget.churchId);

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
          _selectedBipra = rule.bipra;
          _selectedFinancialType = rule.financialType;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = context.l10n.error_loadingData;
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
    setState(() {
      _nameError = null;
      _positionsError = null;
    });

    bool hasError = false;

    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = context.l10n.validation_ruleNameRequired;
      });
      hasError = true;
    }

    if (_selectedPositions.isEmpty) {
      setState(() {
        _positionsError = context.l10n.validation_positionsRequired;
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

      // Clear bipra if activityType is no longer SERVICE
      final effectiveBipra = _showBipra ? _selectedBipra : null;

      final updated =
          _fetchedRule?.copyWith(
            name: formattedName,
            description: formattedDesc,
            active: _active,
            positions: _selectedPositions,
            activityType: _selectedActivityType,
            bipra: effectiveBipra,
            financialType: _selectedFinancialType,
          ) ??
          ApprovalRule(
            name: formattedName,
            description: formattedDesc,
            churchId: widget.churchId,
            positions: _selectedPositions,
            active: _active,
            activityType: _selectedActivityType,
            bipra: effectiveBipra,
            financialType: _selectedFinancialType,
          );

      await widget.onSave(updated);
      if (!mounted) return;
      widget.onClose();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e is AppError
            ? e.userMessage
            : context.l10n.msg_saveFailed;
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
        title: Text(context.l10n.dlg_deleteRule_title),
        content: Text(context.l10n.dlg_deleteRule_content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.btn_cancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.btn_delete),
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
        _errorMessage = e is AppError
            ? e.userMessage
            : context.l10n.msg_deleteFailed;
      });
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  void _onRetry() => _fetchData();

  void _onActivityTypeChanged(ActivityType? value) {
    setState(() {
      _selectedActivityType = value;
      // Reset bipra when activity type changes away from SERVICE
      if (value != ActivityType.service) {
        _selectedBipra = null;
      }
    });
  }

  void _onBipraChanged(Bipra? value) {
    setState(() => _selectedBipra = value);
  }

  void _onFinancialTypeChanged(FinanceType? value) {
    setState(() => _selectedFinancialType = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SideDrawer(
      title: _isNew
          ? context.l10n.drawer_addApprovalRule_title
          : context.l10n.drawer_editApprovalRule_title,
      subtitle: _isNew
          ? context.l10n.drawer_addApprovalRule_subtitle
          : context.l10n.drawer_editApprovalRule_subtitle,
      onClose: widget.onClose,
      isLoading: _loading || _deleting || _saving,
      loadingMessage: _deleting
          ? context.l10n.loading_deleting
          : _saving
          ? context.l10n.loading_saving
          : context.l10n.loading_approvals,
      errorMessage: _errorMessage,
      onRetry: _onRetry,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rule Information Section
          InfoSection(
            title: context.l10n.section_ruleInformation,
            titleSpacing: 16,
            children: [
              if (!_isNew && _fetchedRule != null) ...[
                LabeledField(
                  label: context.l10n.lbl_ruleId,
                  child: Text(
                    context.l10n.lbl_hashId(_fetchedRule!.id.toString()),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              LabeledField(
                label: context.l10n.lbl_ruleName,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: context.l10n.hint_approvalRuleExample,
                      ),
                      onChanged: (_) {
                        if (_nameError != null) {
                          setState(() => _nameError = null);
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
                label: context.l10n.lbl_ruleDescription,
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: context.l10n.hint_describeApprovalRule,
                  ),
                  maxLines: 3,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Status Section
          InfoSection(
            title: context.l10n.section_status,
            titleSpacing: 16,
            children: [
              SwitchListTile(
                value: _active,
                onChanged: (value) => setState(() => _active = value),
                title: Text(context.l10n.lbl_active),
                subtitle: Text(
                  _active
                      ? context.l10n.desc_ruleActive
                      : context.l10n.desc_ruleInactive,
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
            title: context.l10n.section_activityTypeFilter,
            titleSpacing: 16,
            children: [
              LabeledField(
                label: context.l10n.lbl_activityType,
                child: DropdownButtonFormField<ActivityType?>(
                  initialValue: _selectedActivityType,
                  decoration: InputDecoration(
                    hintText: context.l10n.hint_allActivityTypes,
                  ),
                  items: [
                    DropdownMenuItem<ActivityType?>(
                      value: null,
                      child: Text(context.l10n.hint_allActivityTypes),
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
              if (_showBipra) ...[
                const SizedBox(height: 16),
                LabeledField(
                  label: context.l10n.lbl_bipra,
                  child: DropdownButtonFormField<Bipra?>(
                    initialValue: _selectedBipra,
                    decoration: InputDecoration(
                      hintText: context.l10n.hint_allBipra,
                    ),
                    items: [
                      DropdownMenuItem<Bipra?>(
                        value: null,
                        child: Text(context.l10n.hint_allBipra),
                      ),
                      ...Bipra.values.map((bipra) {
                        return DropdownMenuItem<Bipra?>(
                          value: bipra,
                          child: Text(bipra.displayName),
                        );
                      }),
                    ],
                    onChanged: _onBipraChanged,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.desc_bipraFilter,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                context.l10n.desc_activityTypeFilter,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Financial Type Section
          InfoSection(
            title: context.l10n.section_financialFilter,
            titleSpacing: 16,
            children: [
              LabeledField(
                label: context.l10n.lbl_financialType,
                child: DropdownButtonFormField<FinanceType?>(
                  initialValue: _selectedFinancialType,
                  decoration: InputDecoration(
                    hintText: context.l10n.hint_noFinancialFilter,
                  ),
                  items: [
                    DropdownMenuItem<FinanceType?>(
                      value: null,
                      child: Text(context.l10n.hint_noFinancialFilter),
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
              const SizedBox(height: 8),
              Text(
                context.l10n.desc_financialFilter,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Positions Section
          InfoSection(
            title: context.l10n.section_requiredApprovers,
            titleSpacing: 16,
            children: [
              LabeledField(
                label: context.l10n.lbl_positions,
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
                              context.l10n.noData_positions,
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
                                if (_positionsError != null) {
                                  _positionsError = null;
                                }
                              });
                            },
                            availablePositions: _allPositions,
                            hintText:
                                context.l10n.hint_selectPositionsToApprove,
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
      footer: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 420) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_isNew && widget.onDelete != null) ...[
                  FilledButton.tonal(
                    onPressed: _deleteRule,
                    child: Text(context.l10n.btn_delete),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  onPressed: _saveChanges,
                  child: Text(
                    _isNew ? context.l10n.btn_create : context.l10n.btn_save,
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              if (!_isNew && widget.onDelete != null) ...[
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: _deleteRule,
                    child: Text(context.l10n.btn_delete),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: FilledButton(
                  onPressed: _saveChanges,
                  child: Text(
                    _isNew ? context.l10n.btn_create : context.l10n.btn_save,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
