import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/l10n/generated/app_localizations.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

class OperationPermissionDefinition {
  final String key;
  final String category;
  final String title;
  final String description;

  const OperationPermissionDefinition({
    required this.key,
    required this.category,
    required this.title,
    required this.description,
  });
}

List<OperationPermissionDefinition> buildOperationPermissionDefinitions(
  AppLocalizations l10n,
) {
  return [
    OperationPermissionDefinition(
      key: 'ops.activity.create',
      category: l10n.operationsCategory_publishing,
      title: l10n.churchOperationsPermission_publishActivities_title,
      description: l10n.churchOperationsPermission_publishActivities_desc,
    ),
    OperationPermissionDefinition(
      key: 'ops.members.read',
      category: l10n.operationsCategory_membership,
      title: l10n.operationsItem_view_members_title,
      description: l10n.operationsItem_view_members_desc,
    ),
    OperationPermissionDefinition(
      key: 'ops.members.invite',
      category: l10n.operationsCategory_membership,
      title: l10n.operationsItem_invite_member_title,
      description: l10n.operationsItem_invite_member_desc,
    ),
    OperationPermissionDefinition(
      key: 'ops.report.generate',
      category: l10n.operationsCategory_reports,
      title: l10n.operationsItem_generate_report_title,
      description: l10n.operationsItem_generate_report_desc,
    ),
    OperationPermissionDefinition(
      key: 'ops.finance.revenue.create',
      category: l10n.operationsCategory_financial,
      title: l10n.operationsItem_add_income_title,
      description: l10n.operationsItem_add_income_desc,
    ),
    OperationPermissionDefinition(
      key: 'ops.finance.expense.create',
      category: l10n.operationsCategory_financial,
      title: l10n.operationsItem_add_expense_title,
      description: l10n.operationsItem_add_expense_desc,
    ),
  ];
}

Map<String, List<MemberPosition>> resolvePermissionSelections({
  required Map<String, dynamic>? policy,
  required List<MemberPosition> availablePositions,
}) {
  final grants = policy?['grants'];
  final byId = {
    for (final position in availablePositions)
      if (position.id != null) position.id!: position,
  };

  List<MemberPosition> resolveForKey(String key) {
    if (grants is! Map) {
      return <MemberPosition>[];
    }

    final grant = grants[key];
    if (grant is! Map) {
      return <MemberPosition>[];
    }

    final ids =
        (grant['positionIds'] as List?)
            ?.map((value) => value is int ? value : int.tryParse('$value'))
            .whereType<int>()
            .toList(growable: false) ??
        const <int>[];

    return ids
        .map((id) => byId[id])
        .whereType<MemberPosition>()
        .toList(growable: true);
  }

  return {
    for (final definition in [
      'ops.activity.create',
      'ops.members.read',
      'ops.members.invite',
      'ops.report.generate',
      'ops.finance.revenue.create',
      'ops.finance.expense.create',
    ])
      definition: resolveForKey(definition),
  };
}

Map<String, dynamic> buildPermissionPolicyPayload(
  Map<String, List<MemberPosition>> selections,
) {
  List<int> ids(String key) => (selections[key] ?? const <MemberPosition>[])
      .map((position) => position.id)
      .whereType<int>()
      .toList(growable: false);

  return {
    'version': 1,
    'grants': {
      for (final key in [
        'ops.activity.create',
        'ops.members.read',
        'ops.members.invite',
        'ops.report.generate',
        'ops.finance.revenue.create',
        'ops.finance.expense.create',
      ])
        key: {'mode': 'positionsAny', 'positionIds': ids(key)},
    },
  };
}

String formatPermissionAssignmentSummary(
  List<MemberPosition> positions,
  AppLocalizations l10n,
) {
  if (positions.isEmpty) {
    return l10n.churchOperationsAccess_noPositionsAssigned;
  }

  if (positions.length <= 2) {
    return positions.map((position) => position.name).join(', ');
  }

  final visible = positions.take(2).map((position) => position.name).join(', ');
  return l10n.churchOperationsAccess_moreSummary(visible, positions.length - 2);
}

class PermissionPolicyEditDrawer extends ConsumerStatefulWidget {
  final OperationPermissionDefinition definition;
  final ChurchPermissionPolicyRecord record;
  final List<MemberPosition> availablePositions;
  final ValueChanged<ChurchPermissionPolicyRecord> onSaved;
  final VoidCallback onClose;

  const PermissionPolicyEditDrawer({
    super.key,
    required this.definition,
    required this.record,
    required this.availablePositions,
    required this.onSaved,
    required this.onClose,
  });

  @override
  ConsumerState<PermissionPolicyEditDrawer> createState() =>
      _PermissionPolicyEditDrawerState();
}

class _PermissionPolicyEditDrawerState
    extends ConsumerState<PermissionPolicyEditDrawer> {
  bool _saving = false;
  String? _errorMessage;
  late List<MemberPosition> _selectedPositions;

  @override
  void initState() {
    super.initState();
    _selectedPositions =
        resolvePermissionSelections(
          policy: widget.record.policy,
          availablePositions: widget.availablePositions,
        )[widget.definition.key] ??
        <MemberPosition>[];
  }

  Future<void> _save() async {
    if (_selectedPositions.isEmpty) {
      setState(() {
        _errorMessage = context.l10n.churchOperationsAccess_selectPositionError;
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(churchPermissionPolicyRepositoryProvider);
      final selections = resolvePermissionSelections(
        policy: widget.record.policy,
        availablePositions: widget.availablePositions,
      );
      selections[widget.definition.key] = _selectedPositions;

      final res = await repo.updateMyPolicy(
        policy: buildPermissionPolicyPayload(selections),
      );

      res.when(
        onSuccess: (record) {
          widget.onSaved(record);
          AppSnackbars.showSuccess(
            context,
            title: context.l10n.msg_saved,
            message: context.l10n.msg_updated,
          );
          widget.onClose();
        },
        onFailure: (failure) {
          setState(() {
            _errorMessage = failure.message;
          });
        },
      );
    } catch (_) {
      setState(() {
        _errorMessage = context.l10n.msg_saveFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAvailablePositions = widget.availablePositions.isNotEmpty;

    return SideDrawer(
      title: widget.definition.title,
      subtitle: widget.definition.description,
      onClose: widget.onClose,
      isLoading: _saving,
      loadingMessage: context.l10n.loading_saving,
      errorMessage: _errorMessage,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.definition.category,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.churchOperationsAccess_onlySelectedPositions,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (hasAvailablePositions)
            PositionSelector(
              label:
                  context.l10n.churchOperationsAccess_assignedPositionsColumn,
              availablePositions: widget.availablePositions,
              selectedPositions: _selectedPositions,
              onPositionsChanged: (positions) {
                setState(() {
                  _selectedPositions = positions;
                });
              },
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.l10n.churchOperationsAccess_emptyPositions,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: _saving || !hasAvailablePositions ? null : _save,
              child: Text(context.l10n.btn_saveChanges),
            ),
          ),
        ],
      ),
    );
  }
}
