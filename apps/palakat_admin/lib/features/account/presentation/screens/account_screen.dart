import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  late Account _currentAccount;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _positionController;

  @override
  void initState() {
    super.initState();
    // Mock current account data
    _currentAccount = Account(
      id: 1,
      name: 'Admin User',
      email: 'admin@palakat.com',
      phone: '+62 812-3456-7890',
      dob: DateTime.now(),
      membership: Membership(
        id: 0,
        baptize: false,
        sidi: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        membershipPositions: const [],
      ),
    );

    _initializeControllers();
  }

  Future<void> _showSideDrawer({
    required String title,
    String? subtitle,
    required Widget content,
    Widget? footer,
    double width = 420,
  }) async {
    DrawerUtils.showDrawer(
      context: context,
      drawer: SideDrawer(
        title: title,
        subtitle: subtitle,
        width: width,
        onClose: () => DrawerUtils.closeDrawer(context),
        content: content,
        footer: footer,
      ),
    );
  }

  void _openEditAccountDrawer() {
    final l10n = context.l10n;
    final nameCtrl = TextEditingController(text: _currentAccount.name);
    final phoneCtrl = TextEditingController(text: _currentAccount.phone);
    final posCtrl = TextEditingController(
      text:
          _currentAccount.membership?.membershipPositions
              .map((mp) => mp.name)
              .join(' - ') ??
          '',
    );

    final theme = Theme.of(context);

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
            decoration: InputDecoration(
              hintText: l10n.hint_enterFullName,
              border: const OutlineInputBorder(),
            ),
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
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.lbl_position,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: posCtrl,
            decoration: InputDecoration(
              hintText: l10n.hint_enterYourPosition,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.btn_cancel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: () {
                setState(() {
                  _currentAccount = _currentAccount.copyWith(
                    name: nameCtrl.text,
                    phone: phoneCtrl.text,
                    membership: _currentAccount.membership?.copyWith(
                      membershipPositions: [
                        ..._currentAccount.membership?.membershipPositions ??
                            [],
                        MemberPosition(
                          name: posCtrl.text,
                          id: 0,
                          churchId: 0,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                      ],
                    ),
                  );
                });
                Navigator.of(context).pop();
                AppSnackbars.showSuccess(
                  context,
                  title: l10n.msg_saved,
                  message: l10n.msg_accountUpdated,
                );
              },
              child: Text(l10n.btn_saveChanges),
            ),
          ),
        ],
      ),
    );
  }

  void _openChangePasswordDrawer() {
    final l10n = context.l10n;
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final theme = Theme.of(context);

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
              border: const OutlineInputBorder(),
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
            decoration: InputDecoration(
              hintText: l10n.hint_enterNewPassword,
              border: const OutlineInputBorder(),
            ),
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
            decoration: InputDecoration(
              hintText: l10n.hint_reEnterNewPassword,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.btn_cancel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: () {
                final newPass = newCtrl.text.trim();
                final confirmPass = confirmCtrl.text.trim();
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
                // Note: Password change API integration pending.
                Navigator.of(context).pop();
                AppSnackbars.showSuccess(
                  context,
                  title: l10n.msg_updated,
                  message: l10n.msg_passwordChanged,
                );
              },
              child: Text(l10n.btn_updatePassword),
            ),
          ),
        ],
      ),
    );
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: _currentAccount.name);
    _phoneController = TextEditingController(text: _currentAccount.phone);
    _positionController = TextEditingController(
      text:
          _currentAccount.membership?.membershipPositions
              .map((mp) => mp.name)
              .join(' - ') ??
          '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  // Helper method to get name initials
  String _getNameInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  // Helper method to build info field widgets
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
              Icon(icon, color: Colors.green, size: 16),
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
            onPressed: () {
              Navigator.of(context).pop();
              // Note: Admin sign out flow integration pending.
              AppSnackbars.showSuccess(
                context,
                title: l10n.msg_saved,
                message: l10n.msg_signedOut,
              );
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

            // Account Information Card
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
                  // Profile Overview Section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          _getNameInitials(_currentAccount.name),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentAccount.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  _currentAccount.phone,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Account Information Fields
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoField(
                          theme,
                          l10n.lbl_fullName,
                          _currentAccount.name,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildInfoField(
                          theme,
                          l10n.lbl_position,
                          _currentAccount.membership?.membershipPositions
                                  .map((mp) => mp.name)
                                  .join(' - ') ??
                              '-',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Security Settings Card
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

            // Language Settings Card - Requirements: 6.2
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

            // Account Actions Card
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
                          const Icon(Icons.logout, color: Colors.red),
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
