import 'package:flutter/material.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/widgets.dart';

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
        widget.onClose();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Account number updated successfully'
                  : 'Account number created successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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

    return SideDrawer(
      title: isEditMode ? 'Edit Account Number' : 'Add Account Number',
      subtitle: isEditMode
          ? 'Update the account number details'
          : 'Create a new financial account number',
      onClose: widget.onClose,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Account Number Field
            Text(
              'Account Number',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _accountNumberController,
              decoration: const InputDecoration(
                hintText: 'Enter account number',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Account number is required';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 24),

            // Type Field
            Text(
              'Type',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<FinanceType>(
              segments: [
                ButtonSegment<FinanceType>(
                  value: FinanceType.revenue,
                  label: const Text('Revenue'),
                  icon: Icon(FinanceType.revenue.icon),
                ),
                ButtonSegment<FinanceType>(
                  value: FinanceType.expense,
                  label: const Text('Expense'),
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
              'Description (Optional)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Enter description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : widget.onClose,
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _isLoading ? null : _handleSave,
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Text(isEditMode ? 'Update' : 'Create'),
            ),
          ),
        ],
      ),
    );
  }
}
