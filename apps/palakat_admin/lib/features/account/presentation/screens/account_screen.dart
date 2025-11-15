import 'package:flutter/material.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/utils.dart';
import 'package:palakat_admin/widgets.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
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
      title: 'Edit Account Information',
      subtitle: 'Update your profile details',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Full Name',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              hintText: 'Enter your full name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Phone Number',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: phoneCtrl,
            decoration: const InputDecoration(
              hintText: 'Enter your phone number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Position',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: posCtrl,
            decoration: const InputDecoration(
              hintText: 'Enter your position',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
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
                  title: 'Saved',
                  message: 'Account information updated successfully',
                );
              },
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  void _openChangePasswordDrawer() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final theme = Theme.of(context);

    _showSideDrawer(
      title: 'Change Password',
      subtitle: 'Keep your account secure with a strong password',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Password',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: currentCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Enter current password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'New Password',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: newCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Enter new password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Confirm New Password',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: confirmCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Re-enter new password',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
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
                    title: 'Invalid password',
                    message: 'Password must be at least 6 characters',
                  );
                  return;
                }
                if (newPass != confirmPass) {
                  AppSnackbars.showError(
                    context,
                    title: 'Mismatch',
                    message: 'New password and confirmation do not match',
                  );
                  return;
                }
                // TODO: Integrate with backend password change
                Navigator.of(context).pop();
                AppSnackbars.showSuccess(
                  context,
                  title: 'Updated',
                  message: 'Password updated successfully',
                );
              },
              child: const Text('Update Password'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement actual sign out logic
              AppSnackbars.showSuccess(
                context,
                title: 'Signed out',
                message: 'Signed out successfully',
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account', style: theme.textTheme.headlineMedium),
            Text(
              'Manage your account information and settings',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Account Information Card
            SurfaceCard(
              title: 'Account Information',
              subtitle: 'Manage your profile and personal information',
              trailing: FilledButton.icon(
                onPressed: _openEditAccountDrawer,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
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
                          'Full Name',
                          _currentAccount.name,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildInfoField(
                          theme,
                          'Position',
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
              title: 'Security Settings',
              subtitle: 'Manage your account security',
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
                                  'Change Password',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Update your password regularly for security',
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

            // Account Actions Card
            SurfaceCard(
              title: 'Account Actions',
              subtitle: 'Manage your account session',
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
                                  'Sign Out',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Sign out from your current session',
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
