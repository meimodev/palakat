import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/validation.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_admin/models.dart' as cm show Column;
import 'package:palakat_admin/features/church/church.dart';

class ColumnEditDrawer extends ConsumerStatefulWidget {
  final Function(cm.Column) onSave;
  final Future<void> Function()? onDelete;
  final VoidCallback onClose;
  final int? columnId;
  final int churchId;

  const ColumnEditDrawer({
    super.key,
    required this.onSave,
    this.onDelete,
    required this.onClose,
    this.columnId,
    required this.churchId,
  });

  @override
  ConsumerState<ColumnEditDrawer> createState() => _ColumnEditDrawerState();
}

class _ColumnEditDrawerState extends ConsumerState<ColumnEditDrawer> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  ColumnDetail? _columnDetail; // latest column copy (fetched)
  bool _loading = false;
  bool _deleting = false;
  bool _saving = false;
  List<ColumnDetailMembership> _memberships = const [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Only fetch when editing an existing column
    if (widget.columnId != null) {
      _fetchColumnAndMemberships();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _fetchColumnAndMemberships() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final latest = await ref
          .read(churchControllerProvider.notifier)
          .fetchColumn(widget.columnId!);

      setState(() {
        _loading = false;
        _errorMessage = null;
        _columnDetail = latest;
        _memberships = latest.memberships;
        _nameController.text = latest.name.toCamelCase;
      });
    } catch (e) {
      // Surface error inline but keep drawer open
      setState(() {
        _errorMessage = context.l10n.err_loadFailed;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final column = cm.Column(
      id: widget.columnId,
      name: _nameController.text.trim().toCamelCase,
      createdAt: _columnDetail?.createdAt ?? DateTime.now(),
      updatedAt: _columnDetail?.updatedAt,
      churchId: widget.churchId,
    );

    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      await widget.onSave(column);
      if (!mounted) return;
      widget.onClose();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = context.l10n.msg_saveFailed;
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _deleteColumn() {
    if (widget.onDelete != null) {
      final l10n = context.l10n;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.dlg_deleteColumn_title),
          content: Text(l10n.dlg_deleteColumn_content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.btn_cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // close confirm dialog
                setState(() {
                  _deleting = true;
                  _errorMessage = null;
                });
                try {
                  await widget.onDelete!();
                  if (!mounted) return;
                  widget.onClose();
                } catch (e) {
                  // Surface error inline; parent shows snackbar too
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
      title: widget.columnId == null
          ? l10n.drawer_addColumn_title
          : l10n.drawer_editColumn_title,
      subtitle: widget.columnId == null
          ? l10n.drawer_addColumn_subtitle
          : l10n.drawer_editColumn_subtitle,
      onClose: widget.onClose,
      isLoading: (widget.columnId != null && _loading) || _deleting || _saving,
      loadingMessage: _deleting
          ? l10n.loading_deleting
          : _saving
          ? l10n.loading_saving
          : l10n.loading_data,
      errorMessage: _errorMessage,
      onRetry: widget.columnId != null && !_deleting
          ? _fetchColumnAndMemberships
          : null,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information Section
            InfoSection(
              title: l10n.section_basicInformation,
              titleSpacing: 16,
              children: [
                // Show ID field only when editing existing column
                if (_columnDetail != null) ...[
                  LabeledField(
                    label: l10n.lbl_columnId,
                    child: Text(
                      l10n.lbl_hashId(_columnDetail!.id.toString()),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                LabeledField(
                  label: l10n.lbl_columnName,
                  child: TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: l10n.hint_enterColumnName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    maxLength: 20,
                    validator: (value) => ChurchValidators.columnName()
                        .asFormFieldValidator(value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Memberships listing (read-only)
            if (_columnDetail != null)
              InfoSection(
                title: l10n.section_registeredMembers(_memberships.length),
                titleSpacing: 16,
                children: [
                  if (_memberships.isEmpty)
                    Text(
                      l10n.noData_members,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    ..._memberships.map(
                      (m) => Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.lbl_memberWithId(
                                  m.membershipId.toString(),
                                  m.name,
                                ),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
      footer: Row(
        children: [
          if (widget.onDelete != null && widget.columnId != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _deleteColumn,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
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
              child: Text(
                widget.columnId == null ? l10n.btn_create : l10n.btn_save,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
