import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/church/church.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

class PermissionPolicyEditDrawer extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const PermissionPolicyEditDrawer({super.key, required this.onClose});

  @override
  ConsumerState<PermissionPolicyEditDrawer> createState() =>
      _PermissionPolicyEditDrawerState();
}

class _PermissionPolicyEditDrawerState
    extends ConsumerState<PermissionPolicyEditDrawer> {
  bool _loading = false;
  bool _saving = false;
  String? _errorMessage;

  ChurchPermissionPolicyRecord? _record;
  bool _policyApplied = false;

  final Map<String, List<MemberPosition>> _selected = {
    'ops.members.invite': <MemberPosition>[],
    'ops.report.generate': <MemberPosition>[],
    'ops.finance.revenue.create': <MemberPosition>[],
    'ops.finance.expense.create': <MemberPosition>[],
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(churchPermissionPolicyRepositoryProvider);
      final res = await repo.fetchMyPolicy();

      res.when(
        onSuccess: (record) {
          _record = record;
          _policyApplied = false;
        },
        onFailure: (failure) {
          _errorMessage = failure.message;
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = context.l10n.err_loadFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _applyPolicyToSelections(
    Map<String, dynamic> policy,
    List<MemberPosition> availablePositions,
  ) {
    final grants = policy['grants'];
    if (grants is! Map) return;

    final byId = {
      for (final p in availablePositions)
        if (p.id != null) p.id!: p,
    };

    void setForKey(String key) {
      final grant = grants[key];
      if (grant is! Map) return;
      final raw = grant['positionIds'];
      final ids = (raw is List)
          ? raw
                .map((e) => e is int ? e : int.tryParse('${e ?? ''}'))
                .whereType<int>()
                .toList(growable: false)
          : const <int>[];

      _selected[key] = ids
          .map((id) => byId[id])
          .whereType<MemberPosition>()
          .toList(growable: true);
    }

    setForKey('ops.members.invite');
    setForKey('ops.report.generate');
    setForKey('ops.finance.revenue.create');
    setForKey('ops.finance.expense.create');
  }

  Map<String, dynamic> _buildPolicyPayload() {
    List<int> ids(String key) => (_selected[key] ?? const <MemberPosition>[])
        .map((p) => p.id)
        .whereType<int>()
        .toList(growable: false);

    return {
      'version': 1,
      'grants': {
        'ops.activity.create': {'mode': 'member'},
        'ops.members.read': {'mode': 'member'},
        'ops.members.invite': {
          'mode': 'positionsAny',
          'positionIds': ids('ops.members.invite'),
        },
        'ops.report.generate': {
          'mode': 'positionsAny',
          'positionIds': ids('ops.report.generate'),
        },
        'ops.finance.revenue.create': {
          'mode': 'positionsAny',
          'positionIds': ids('ops.finance.revenue.create'),
        },
        'ops.finance.expense.create': {
          'mode': 'positionsAny',
          'positionIds': ids('ops.finance.expense.create'),
        },
      },
    };
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(churchPermissionPolicyRepositoryProvider);
      final payload = _buildPolicyPayload();
      final res = await repo.updateMyPolicy(policy: payload);

      res.when(
        onSuccess: (record) {
          _record = record;
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
    } catch (e) {
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

    final churchState = ref.watch(churchControllerProvider);
    final availablePositions =
        churchState.positions.value ?? const <MemberPosition>[];

    if (!_policyApplied && _record != null && availablePositions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_policyApplied) return;
        setState(() {
          _applyPolicyToSelections(_record!.policy, availablePositions);
          _policyApplied = true;
        });
      });
    }

    final content = _loading
        ? const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoSection(
                title: 'Publishing',
                titleSpacing: 16,
                children: [
                  Text(
                    'All members can publish activities (service/event/announcement).',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              InfoSection(
                title: 'Membership',
                titleSpacing: 16,
                children: [
                  Text(
                    'Viewing members and birthdays is open to all members.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PositionSelector(
                    label: 'Invite member',
                    availablePositions: availablePositions,
                    selectedPositions:
                        _selected['ops.members.invite'] ??
                        const <MemberPosition>[],
                    onPositionsChanged: (positions) {
                      setState(() {
                        _selected['ops.members.invite'] = positions;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              InfoSection(
                title: 'Reports',
                titleSpacing: 16,
                children: [
                  PositionSelector(
                    label: 'Generate reports',
                    availablePositions: availablePositions,
                    selectedPositions:
                        _selected['ops.report.generate'] ??
                        const <MemberPosition>[],
                    onPositionsChanged: (positions) {
                      setState(() {
                        _selected['ops.report.generate'] = positions;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              InfoSection(
                title: 'Finance',
                titleSpacing: 16,
                children: [
                  PositionSelector(
                    label: 'Add income',
                    availablePositions: availablePositions,
                    selectedPositions:
                        _selected['ops.finance.revenue.create'] ??
                        const <MemberPosition>[],
                    onPositionsChanged: (positions) {
                      setState(() {
                        _selected['ops.finance.revenue.create'] = positions;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  PositionSelector(
                    label: 'Add expense',
                    availablePositions: availablePositions,
                    selectedPositions:
                        _selected['ops.finance.expense.create'] ??
                        const <MemberPosition>[],
                    onPositionsChanged: (positions) {
                      setState(() {
                        _selected['ops.finance.expense.create'] = positions;
                      });
                    },
                  ),
                ],
              ),
            ],
          );

    return SideDrawer(
      title: 'Operations access control',
      subtitle: 'Configure which positions can access Operations features',
      onClose: widget.onClose,
      isLoading: _loading || _saving,
      loadingMessage: _saving
          ? context.l10n.loading_saving
          : context.l10n.loading_data,
      errorMessage: _errorMessage,
      onRetry: _loading ? _load : null,
      content: content,
      footer: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _saving || _loading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: Text(context.l10n.btn_saveChanges),
            ),
          ),
        ],
      ),
    );
  }
}
