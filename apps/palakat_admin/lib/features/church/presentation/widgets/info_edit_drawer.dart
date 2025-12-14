import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/church/church.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

class InfoEditDrawer extends ConsumerStatefulWidget {
  final Church church;
  final Future<void> Function(Church) onSave;
  final VoidCallback onClose;

  const InfoEditDrawer({
    super.key,
    required this.church,
    required this.onSave,
    required this.onClose,
  });

  @override
  ConsumerState<InfoEditDrawer> createState() => _InfoEditDrawerState();
}

class _InfoEditDrawerState extends ConsumerState<InfoEditDrawer> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _descriptionController;
  bool _saving = false;
  String? _errorMessage;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.church.name);
    _phoneController = TextEditingController(
      text: widget.church.phoneNumber ?? '',
    );
    _emailController = TextEditingController(text: widget.church.email ?? '');
    _descriptionController = TextEditingController(
      text: widget.church.description ?? '',
    );
    _fetchLatestChurch();
  }

  Future<void> _fetchLatestChurch() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final latest = await ref
          .read(churchControllerProvider.notifier)
          .fetchChurchDetail(widget.church.id!);
      if (!mounted) return;
      _nameController.text = latest.name;
      _phoneController.text = latest.phoneNumber ?? '';
      _emailController.text = latest.email ?? '';
      _descriptionController.text = latest.description ?? '';
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = context.l10n.error_loadingChurch;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    final updatedChurch = widget.church.copyWith(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      await widget.onSave(updatedChurch);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SideDrawer(
      title: l10n.drawer_editChurchInfo_title,
      subtitle: l10n.drawer_editChurchInfo_subtitle,
      onClose: widget.onClose,
      isLoading: _saving || _loading,
      loadingMessage: _loading ? l10n.loading_church : l10n.loading_saving,
      errorMessage: _errorMessage,
      onRetry: _loading ? _fetchLatestChurch : null,
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
                LabeledField(
                  label: l10n.lbl_churchName,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: l10n.hint_enterChurchName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    validator: (value) => ChurchValidators.churchName()
                        .asFormFieldValidator(value),
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: l10n.lbl_phoneNumberOptional,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 13,
                    decoration: InputDecoration(
                      hintText: l10n.hint_enterPhoneNumber,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    validator: (value) => Validators.optionalPhoneMinDigits(
                      12,
                    ).asFormFieldValidator(value),
                  ),
                ),
                const SizedBox(height: 16),

                LabeledField(
                  label: l10n.lbl_emailOptional,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: l10n.hint_enterEmailAddress,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    validator: (value) =>
                        Validators.email().asFormFieldValidator(value),
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: l10n.lbl_descriptionOptional,
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: l10n.hint_describeYourChurch,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      alignLabelWithHint: true,
                    ),
                    validator: (_) => null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: Text(l10n.btn_saveChanges),
          ),
        ],
      ),
    );
  }
}
