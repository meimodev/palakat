import 'package:flutter/material.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';

import '../../domain/cash_account.dart';

class CashTransferDrawer extends StatefulWidget {
  const CashTransferDrawer({
    super.key,
    required this.accounts,
    required this.onTransfer,
    required this.onClose,
  });

  final List<CashAccount> accounts;
  final Future<void> Function({
    required int fromAccountId,
    required int toAccountId,
    required int amount,
    required DateTime happenedAt,
    String? note,
  })
  onTransfer;

  final VoidCallback onClose;

  @override
  State<CashTransferDrawer> createState() => _CashTransferDrawerState();
}

class _CashTransferDrawerState extends State<CashTransferDrawer> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  int? _fromAccountId;
  int? _toAccountId;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  DateTime _happenedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _happenedAt,
    );
    if (date == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_happenedAt),
    );
    if (!mounted) return;

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? _happenedAt.hour,
      time?.minute ?? _happenedAt.minute,
    );

    setState(() => _happenedAt = picked);
  }

  Future<void> _handleTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fromAccountId == null || _toAccountId == null) return;

    setState(() => _isLoading = true);

    try {
      final amount = int.parse(_amountController.text.trim());
      await widget.onTransfer(
        fromAccountId: _fromAccountId!,
        toAccountId: _toAccountId!,
        amount: amount,
        happenedAt: _happenedAt,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      if (mounted) {
        final l10n = context.l10n;
        widget.onClose();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.msg_created)));
      }
    } catch (e) {
      if (mounted) {
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.churchRequest_errorWithDetail('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SideDrawer(
      title: '${l10n.paymentMethod_cash} ${l10n.btn_transfer}',
      subtitle: '${l10n.paymentMethod_cash} ${l10n.financialSubtype_mutation}',
      onClose: widget.onClose,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.lbl_from,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _fromAccountId,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: widget.accounts
                  .map(
                    (a) =>
                        DropdownMenuItem<int>(value: a.id, child: Text(a.name)),
                  )
                  .toList(),
              validator: (value) {
                if (value == null) return l10n.validation_required;
                return null;
              },
              onChanged: (value) => setState(() => _fromAccountId = value),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.lbl_to,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _toAccountId,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: widget.accounts
                  .map(
                    (a) =>
                        DropdownMenuItem<int>(value: a.id, child: Text(a.name)),
                  )
                  .toList(),
              validator: (value) {
                if (value == null) return l10n.validation_required;
                if (_fromAccountId != null && value == _fromAccountId) {
                  return l10n.validation_accountsMustBeDifferent;
                }
                return null;
              },
              onChanged: (value) => setState(() => _toAccountId = value),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.tbl_amount,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validation_required;
                }
                final parsed = int.tryParse(value.trim());
                if (parsed == null || parsed <= 0) {
                  return l10n.validation_invalidNumber;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              l10n.lbl_activityDateTime,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(Icons.date_range),
              label: Text(_happenedAt.toDateTimeString()),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.lbl_note,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              maxLines: 3,
            ),
          ],
        ),
      ),
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : widget.onClose,
              child: Text(l10n.btn_cancel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _isLoading ? null : _handleTransfer,
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : Text(l10n.btn_confirm),
            ),
          ),
        ],
      ),
    );
  }
}
