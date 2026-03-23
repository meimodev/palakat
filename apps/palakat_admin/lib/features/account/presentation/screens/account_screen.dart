import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  late Account _currentAccount;

  @override
  void initState() {
    super.initState();
    _currentAccount = Account(
      name: '',
      email: null,
      phone: null,
      dob: DateTime.now(),
      membership: const Membership(membershipPositions: []),
    );

    final cachedAccount = ref
        .read(authControllerProvider)
        .asData
        ?.value
        ?.account;
    if (cachedAccount != null) {
      _currentAccount = cachedAccount;
    }
  }

  Future<void> _showSideDrawer({
    required String title,
    String? subtitle,
    required Widget content,
    Widget? footer,
    double width = 420,
  }) async {
    final screenWidth = MediaQuery.of(context).size.width;
    DrawerUtils.showDrawer(
      context: context,
      drawer: SideDrawer(
        title: title,
        subtitle: subtitle,
        width: screenWidth < 520 ? screenWidth - 24 : width,
        onClose: () => DrawerUtils.closeDrawer(context),
        content: content,
        footer: footer,
      ),
    );
  }

  String _displayAccountName(BuildContext context, Account account) {
    final name = account.name.trim();
    return name.isEmpty ? context.l10n.lbl_adminUser : name;
  }

  String _displayValue(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? '-' : normalized;
  }

  String _membershipPositionsText(Account account) {
    final positions = account.membership?.membershipPositions ?? const [];
    if (positions.isEmpty) {
      return '-';
    }
    return positions.map((mp) => mp.name).join(' - ');
  }

  void _closeSideDrawer() {
    DrawerUtils.closeDrawer(context);
  }

  void _handleAccountUpdateSuccess(Account updatedAccount) {
    final l10n = context.l10n;
    setState(() {
      _currentAccount = updatedAccount;
    });
    DrawerUtils.closeDrawer(context);
    AppSnackbars.showSuccess(
      context,
      title: l10n.msg_saved,
      message: l10n.msg_accountUpdated,
    );
  }

  void _handlePasswordChangeSuccess() {
    final l10n = context.l10n;
    DrawerUtils.closeDrawer(context);
    AppSnackbars.showSuccess(
      context,
      title: l10n.msg_updated,
      message: l10n.msg_passwordChanged,
    );
  }

  void _openEditAccountDrawer() {
    final l10n = context.l10n;
    final currentAccount =
        ref.read(authControllerProvider).asData?.value?.account ??
        _currentAccount;
    final nameCtrl = TextEditingController(
      text: _displayAccountName(context, currentAccount),
    );
    final phoneCtrl = TextEditingController(text: currentAccount.phone ?? '');
    final emailCtrl = TextEditingController(text: currentAccount.email ?? '');
    final posCtrl = TextEditingController(
      text: _membershipPositionsText(currentAccount),
    );
    final theme = Theme.of(context);
    final isSaving = ValueNotifier<bool>(false);

    _showSideDrawer(
      title: l10n.drawer_editAccountInfo_title,
      subtitle: l10n.drawer_editAccountInfo_subtitle,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.lbl_fullName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(hintText: l10n.hint_enterFullName),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.lbl_phone,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: phoneCtrl,
            decoration: InputDecoration(
              hintText: l10n.hint_enterYourPhoneNumber,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.lbl_email,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(controller: emailCtrl, decoration: const InputDecoration()),
          const SizedBox(height: 16),
          Text(
            l10n.lbl_positions,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: posCtrl,
            readOnly: true,
            decoration: InputDecoration(hintText: l10n.hint_enterYourPosition),
          ),
        ],
      ),
      footer: ValueListenableBuilder<bool>(
        valueListenable: isSaving,
        builder: (context, saving, _) => LayoutBuilder(
          builder: (context, constraints) {
            final cancelButton = OutlinedButton(
              onPressed: saving ? null : _closeSideDrawer,
              child: Text(l10n.btn_cancel),
            );
            final saveButton = FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      final accountId = currentAccount.id;
                      if (accountId == null) {
                        AppSnackbars.showError(
                          this.context,
                          title: l10n.err_error,
                          message: l10n.msg_operationFailed,
                        );
                        return;
                      }

                      isSaving.value = true;
                      final result = await ref
                          .read(membershipRepositoryProvider)
                          .updateAccount(
                            accountId: accountId,
                            update: {
                              'name': nameCtrl.text.trim(),
                              'phone': phoneCtrl.text.trim().isEmpty
                                  ? null
                                  : phoneCtrl.text.trim(),
                              'email': emailCtrl.text.trim().isEmpty
                                  ? null
                                  : emailCtrl.text.trim(),
                            },
                          );

                      if (!context.mounted) {
                        return;
                      }

                      final currentContext = this.context;
                      final currentL10n = currentContext.l10n;
                      Account? updatedAccount;
                      Failure? failure;
                      result.when(
                        onSuccess: (data) {
                          updatedAccount = data;
                          return null;
                        },
                        onFailure: (error) {
                          failure = error;
                        },
                      );

                      if (updatedAccount != null) {
                        await ref
                            .read(authControllerProvider.notifier)
                            .updateCachedAccount(updatedAccount!);
                        if (!mounted) {
                          return;
                        }
                        _handleAccountUpdateSuccess(updatedAccount!);
                      } else {
                        AppSnackbars.showError(
                          currentContext,
                          title: currentL10n.err_error,
                          message: failure?.message.isNotEmpty == true
                              ? failure!.message
                              : currentL10n.msg_operationFailed,
                        );
                      }

                      isSaving.value = false;
                    },
              child: saving
                  ? const CompactLoadingWidget(size: 18)
                  : Text(l10n.btn_saveChanges),
            );

            if (constraints.maxWidth < 420) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  cancelButton,
                  const SizedBox(height: 12),
                  saveButton,
                ],
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
      ),
    );
  }

  void _openChangePasswordDrawer() {
    final l10n = context.l10n;
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final theme = Theme.of(context);
    final isSaving = ValueNotifier<bool>(false);

    _showSideDrawer(
      title: l10n.drawer_changePassword_title,
      subtitle: l10n.drawer_changePassword_subtitle,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.lbl_currentPassword,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: currentCtrl,
            obscureText: true,
            decoration: InputDecoration(
              hintText: l10n.hint_enterCurrentPassword,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.lbl_newPassword,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: newCtrl,
            obscureText: true,
            decoration: InputDecoration(hintText: l10n.hint_enterNewPassword),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.lbl_confirmNewPassword,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: confirmCtrl,
            obscureText: true,
            decoration: InputDecoration(hintText: l10n.hint_reEnterNewPassword),
          ),
        ],
      ),
      footer: ValueListenableBuilder<bool>(
        valueListenable: isSaving,
        builder: (context, saving, _) => LayoutBuilder(
          builder: (context, constraints) {
            final cancelButton = OutlinedButton(
              onPressed: saving ? null : _closeSideDrawer,
              child: Text(l10n.btn_cancel),
            );
            final submitButton = FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      final currentPass = currentCtrl.text;
                      final newPass = newCtrl.text;
                      final confirmPass = confirmCtrl.text;

                      if (currentPass.isEmpty) {
                        AppSnackbars.showError(
                          this.context,
                          title: l10n.err_error,
                          message: l10n.hint_enterCurrentPassword,
                        );
                        return;
                      }
                      if (newPass.length < 6) {
                        AppSnackbars.showError(
                          context,
                          title: l10n.err_error,
                          message: l10n.msg_invalidPassword,
                        );
                        return;
                      }
                      if (newPass != confirmPass) {
                        AppSnackbars.showError(
                          context,
                          title: l10n.err_error,
                          message: l10n.msg_passwordMismatch,
                        );
                        return;
                      }

                      isSaving.value = true;
                      final result = await ref
                          .read(authControllerProvider.notifier)
                          .changePassword(
                            currentPassword: currentPass,
                            newPassword: newPass,
                          );

                      if (!context.mounted) {
                        return;
                      }

                      result.when(
                        onSuccess: (_) => _handlePasswordChangeSuccess(),
                        onFailure: (failure) {
                          AppSnackbars.showError(
                            context,
                            title: l10n.err_error,
                            message: failure.message,
                          );
                        },
                      );

                      isSaving.value = false;
                    },
              child: saving
                  ? const CompactLoadingWidget(size: 18)
                  : Text(l10n.btn_updatePassword),
            );

            if (constraints.maxWidth < 420) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  cancelButton,
                  const SizedBox(height: 12),
                  submitButton,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: cancelButton),
                const SizedBox(width: 12),
                Expanded(child: submitButton),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getNameInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'U';
    }
    final words = trimmed.split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  Widget _buildInfoField(
    ThemeData theme,
    String label,
    String value, {
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 6),
              Icon(icon, color: AppColors.success, size: 16),
            ],
          ],
        ),
      ],
    );
  }

  void _signOut() {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dlg_signOut_title),
        content: Text(l10n.dlg_signOut_content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.btn_cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authControllerProvider.notifier).signOut();
            },
            child: Text(l10n.btn_signOut),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final auth = ref.watch(authControllerProvider);
    final activeAccount = auth.asData?.value?.account ?? _currentAccount;
    final displayName = _displayAccountName(context, activeAccount);

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.admin_account_title,
              style: theme.textTheme.headlineMedium,
            ),
            Text(
              l10n.admin_account_subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            SurfaceCard(
              title: l10n.card_accountInfo_title,
              subtitle: l10n.card_accountInfo_subtitle,
              trailing: FilledButton.icon(
                onPressed: _openEditAccountDrawer,
                icon: const Icon(Icons.edit),
                label: Text(l10n.btn_edit),
              ),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 640;

                      final avatar = CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          _getNameInitials(displayName),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );

                      final textBlock = Column(
                        crossAxisAlignment: compact
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            textAlign: compact
                                ? TextAlign.center
                                : TextAlign.start,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _displayValue(activeAccount.phone),
                            textAlign: compact
                                ? TextAlign.center
                                : TextAlign.start,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      );

                      if (compact) {
                        return Column(
                          children: [
                            avatar,
                            const SizedBox(height: 16),
                            textBlock,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          avatar,
                          const SizedBox(width: 20),
                          Expanded(child: textBlock),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final firstRow = [
                        Expanded(
                          child: _buildInfoField(
                            theme,
                            l10n.lbl_fullName,
                            displayName,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildInfoField(
                            theme,
                            l10n.lbl_phone,
                            _displayValue(activeAccount.phone),
                          ),
                        ),
                      ];
                      final secondRow = [
                        Expanded(
                          child: _buildInfoField(
                            theme,
                            l10n.lbl_email,
                            _displayValue(activeAccount.email),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildInfoField(
                            theme,
                            l10n.lbl_positions,
                            _membershipPositionsText(activeAccount),
                          ),
                        ),
                      ];

                      if (constraints.maxWidth < 640) {
                        return Column(
                          children: [
                            _buildInfoField(
                              theme,
                              l10n.lbl_fullName,
                              displayName,
                            ),
                            const SizedBox(height: 24),
                            _buildInfoField(
                              theme,
                              l10n.lbl_phone,
                              _displayValue(activeAccount.phone),
                            ),
                            const SizedBox(height: 24),
                            _buildInfoField(
                              theme,
                              l10n.lbl_email,
                              _displayValue(activeAccount.email),
                            ),
                            const SizedBox(height: 24),
                            _buildInfoField(
                              theme,
                              l10n.lbl_positions,
                              _membershipPositionsText(activeAccount),
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          Row(children: firstRow),
                          const SizedBox(height: 24),
                          Row(children: secondRow),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              title: l10n.card_securitySettings_title,
              subtitle: l10n.card_securitySettings_subtitle,
              child: Column(
                children: [
                  InkWell(
                    onTap: _openChangePasswordDrawer,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.lock, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.lbl_changePassword,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  l10n.lbl_changePasswordDesc,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              title: l10n.card_languageSettings_title,
              subtitle: l10n.card_languageSettings_subtitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.lbl_language,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const LanguageSelector(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              title: l10n.card_accountActions_title,
              subtitle: l10n.card_accountActions_subtitle,
              child: Column(
                children: [
                  InkWell(
                    onTap: _signOut,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: theme.colorScheme.error),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.btn_signOut,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  l10n.lbl_signOutDesc,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
