import 'package:flutter/material.dart' hide Column;
import 'package:flutter/material.dart' as material;
import 'package:palakat_shared/palakat_shared.dart' hide Column;

class FinancialAccountEditDrawer extends StatefulWidget {
  const FinancialAccountEditDrawer({
    super.key,
    this.account,
    required this.onSave,
    required this.onClose,
  });

  final FinancialAccountNumber? account;
  final Future<void> Function(
    String accountNumber,
    FinanceType type,
    String? description,
  )
  onSave;
  final VoidCallback onClose;

  @override
  State<FinancialAccountEditDrawer> createState() =>
      _FinancialAccountEditDrawerState();
}

class _FinancialAccountEditDrawerState
    extends State<FinancialAccountEditDrawer> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _accountNumberController;
  late final TextEditingController _descriptionController;
  late FinanceType _selectedType;
  bool _isLoading = false;

  bool get isEditMode => widget.account != null;

  @override
  void initState() {
    super.initState();
    _accountNumberController = TextEditingController(
      text: widget.account?.accountNumber ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.account?.description ?? '',
    );
    _selectedType = widget.account?.type ?? FinanceType.revenue;
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.onSave(
        _accountNumberController.text.trim(),
        _selectedType,
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
      if (mounted) {
        final l10n = context.l10n;
        widget.onClose();
        AppSnackbars.showSuccess(
          context,
          message: isEditMode ? l10n.msg_updated : l10n.msg_created,
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = context.l10n;
        AppSnackbars.showError(
          context,
          message: l10n.churchRequest_errorWithDetail('$e'),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SideDrawer(
      title: isEditMode
          ? l10n.drawer_editAccountNumber_title
          : l10n.drawer_addAccountNumber_title,
      subtitle: isEditMode
          ? l10n.drawer_editAccountNumber_subtitle
          : l10n.drawer_addAccountNumber_subtitle,
      onClose: widget.onClose,
      content: Form(
        key: _formKey,
        child: material.Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Account Number Field
            Text(
              l10n.lbl_accountNumber,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _accountNumberController,
              decoration: InputDecoration(
                hintText: l10n.hint_enterAccountNumber,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validation_required;
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 24),

            // Type Field
            Text(
              l10n.lbl_type,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<FinanceType>(
              segments: [
                ButtonSegment<FinanceType>(
                  value: FinanceType.revenue,
                  label: Text(FinanceType.revenue.displayName),
                  icon: Icon(FinanceType.revenue.icon),
                ),
                ButtonSegment<FinanceType>(
                  value: FinanceType.expense,
                  label: Text(FinanceType.expense.displayName),
                  icon: Icon(FinanceType.expense.icon),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<FinanceType> selected) {
                setState(() => _selectedType = selected.first);
              },
            ),
            const SizedBox(height: 24),

            // Description Field
            Text(
              l10n.lbl_descriptionOptional,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(hintText: l10n.hint_enterDescription),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
      footer: LayoutBuilder(
        builder: (context, constraints) {
          final cancelButton = OutlinedButton(
            onPressed: _isLoading ? null : widget.onClose,
            child: Text(l10n.btn_cancel),
          );
          final saveButton = FilledButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const CompactLoadingWidget(size: 20)
                : Text(isEditMode ? l10n.btn_update : l10n.btn_create),
          );

          if (constraints.maxWidth < 420) {
            return material.Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [cancelButton, const SizedBox(height: 12), saveButton],
            );
          }

          return Row(
            children: [
              Expanded(child: cancelButton),
              const SizedBox(width: 12),
              Expanded(child: saveButton),
            ],
          );
        },
      ),
    );
  }
}
