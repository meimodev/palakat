import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/church/church.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

class PositionEditDrawer extends ConsumerStatefulWidget {
  final int? positionId;
  final Function(MemberPosition) onSave;
  final Future<void> Function()? onDelete;
  final VoidCallback onClose;
  final int churchId;

  const PositionEditDrawer({
    super.key,
    this.positionId,
    required this.onSave,
    this.onDelete,
    required this.onClose,
    required this.churchId,
  });

  @override
  ConsumerState<PositionEditDrawer> createState() => _PositionEditDrawerState();
}

class _PositionEditDrawerState extends ConsumerState<PositionEditDrawer> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;
  MemberPositionDetail? _positionDetail;
  bool _deleting = false;

  bool get adding => widget.positionId == null;

  @override
  void initState() {
    super.initState();

    if (!adding) {
      _fetchPositionAndMembers();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _fetchPositionAndMembers() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      // Fetch latest position by ID
      final latest = await ref
          .read(churchControllerProvider.notifier)
          .fetchPosition(widget.positionId!);

      setState(() {
        _loading = false;
        _errorMessage = null;
        _positionDetail = latest;
        _nameController.text = latest.name.toCamelCase;
      });
    } catch (e) {
      setState(() {
        _errorMessage = context.l10n.err_loadFailed;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final l10n = context.l10n;
      final position = MemberPosition(
        id: widget.positionId,
        churchId: _positionDetail?.churchId ?? widget.churchId,
        name: _nameController.text.trim().toCamelCase,
        createdAt: _positionDetail?.createdAt ?? DateTime.now(),
        updatedAt: _positionDetail?.updatedAt,
      );

      widget.onSave(position);
      widget.onClose();

      AppSnackbars.showSuccess(
        context,
        title: l10n.msg_saved,
        message: adding ? l10n.msg_created : l10n.msg_updated,
      );
    }
  }

  void _deletePosition() {
    if (widget.onDelete != null) {
      final l10n = context.l10n;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.dlg_deletePosition_title),
          content: Text(l10n.dlg_deletePosition_content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.btn_cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
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
                    _errorMessage = context.l10n.msg_deleteFailed;
                  });
                } finally {
                  if (mounted) setState(() => _deleting = false);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(l10n.btn_delete),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SideDrawer(
      title: adding
          ? l10n.drawer_addPosition_title
          : l10n.drawer_editPosition_title,
      subtitle: adding
          ? l10n.drawer_addPosition_subtitle
          : l10n.drawer_editPosition_subtitle,
      onClose: widget.onClose,
      isLoading: (!adding && _loading) || _deleting,
      loadingMessage: _deleting ? l10n.loading_deleting : l10n.loading_data,
      errorMessage: !adding ? _errorMessage : null,
      onRetry: !adding && !_deleting ? _fetchPositionAndMembers : null,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoSection(
              title: l10n.section_positionInformation,
              titleSpacing: 16,
              children: [
                if (_positionDetail != null) ...[
                  LabeledField(
                    label: l10n.lbl_positionId,
                    child: Text(
                      l10n.lbl_hashId(_positionDetail!.id.toString()),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                LabeledField(
                  label: l10n.lbl_positionName,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: l10n.hint_enterPositionName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    maxLength: 20,
                    validator: (value) => ChurchValidators.positionName()
                        .asFormFieldValidator(value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (!adding) ...[
              InfoSection(
                title: l10n.section_memberInThisPosition,
                titleSpacing: 16,
                children: [
                  if ((_positionDetail?.positions ?? []).isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.noData_members,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(7),
                                topRight: Radius.circular(7),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _positionDetail?.accountName ?? '',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ..._positionDetail!.positions.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final member = entry.value;
                            final isLast =
                                index == _positionDetail!.positions.length - 1;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: isLast
                                    ? null
                                    : Border(
                                        bottom: BorderSide(
                                          color:
                                              theme.colorScheme.outlineVariant,
                                          width: 0.5,
                                        ),
                                      ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    child: Text(
                                      member
                                          .split(' ')
                                          .map((n) => n[0])
                                          .take(2)
                                          .join(),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      member,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
      footer: Row(
        children: [
          if (widget.onDelete != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _deletePosition,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                ),
                child: Text(l10n.btn_delete),
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
              child: Text(adding ? l10n.btn_create : l10n.btn_save),
            ),
          ),
        ],
      ),
    );
  }
}
