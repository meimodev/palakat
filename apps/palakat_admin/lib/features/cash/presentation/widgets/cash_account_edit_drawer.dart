import 'package:flutter/material.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/widgets.dart';

import '../../domain/cash_account.dart';

class CashAccountEditDrawer extends StatefulWidget {
  const CashAccountEditDrawer({
    super.key,
    this.account,
    required this.onSave,
    required this.onClose,
  });

  final CashAccount? account;
  final Future<void> Function(
    String name,
    String? currency,
    int? openingBalance,
  )
  onSave;
  final VoidCallback onClose;

  @override
  State<CashAccountEditDrawer> createState() => _CashAccountEditDrawerState();
}

class _CashAccountEditDrawerState extends State<CashAccountEditDrawer> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _currencyController;
  late final TextEditingController _openingBalanceController;
  bool _isLoading = false;

  bool get isEditMode => widget.account != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _currencyController = TextEditingController(
      text: widget.account?.currency ?? 'IDR',
    );
    _openingBalanceController = TextEditingController(
      text: (widget.account?.openingBalance ?? 0).toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currencyController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final opening = int.tryParse(_openingBalanceController.text.trim());
      await widget.onSave(
        _nameController.text.trim(),
        _currencyController.text.trim().isEmpty
            ? null
            : _currencyController.text.trim(),
        opening,
      );
      if (mounted) {
        final l10n = context.l10n;
        widget.onClose();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? l10n.msg_updated : l10n.msg_created),
          ),
        );
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

    final title = '${l10n.paymentMethod_cash} ${l10n.nav_account}';

    return SideDrawer(
      title: isEditMode ? l10n.btn_update : l10n.btn_create,
      subtitle: title,
      onClose: widget.onClose,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.lbl_name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validation_required;
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.lbl_currency,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _currencyController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.lbl_openingBalance,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _openingBalanceController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final parsed = int.tryParse(value.trim());
                if (parsed == null || parsed < 0) {
                  return l10n.validation_invalidNumber;
                }
                return null;
              },
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
              child: Text(l10n.btn_cancel),
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
                  : Text(isEditMode ? l10n.btn_update : l10n.btn_create),
            ),
          ),
        ],
      ),
    );
  }
}
