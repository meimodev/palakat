import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_admin/core/services/church_change_version_poller.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SanctuaryWebShell(
      sidebar: const AppSidebar(),
      mobileTitle: Text(context.l10n.appTitle_admin),
      mobileActions: [_AvatarMenu(onProfile: () => context.go('/account'))],
      footer: const _AppFooter(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StaleDataBanner(),
          child,
        ],
      ),
    );
  }
}

/// Phase 5 §9.5: shown when the change-version poll finds church data newer
/// than the admin has acknowledged. Tapping marks it seen, which drives the
/// mounted data controller to re-read (§9.4 — a change signal never refetches
/// on its own; the admin's tap is the read).
class _StaleDataBanner extends ConsumerWidget {
  const _StaleDataBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(hasStaleDataProvider)) {
      return const SizedBox.shrink(key: ValueKey('content_placeholder'));
    }
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.secondaryContainer,
      child: InkWell(
        onTap: () {
          ref
              .read(seenChangeVersionProvider.notifier)
              .set(ref.read(latestChangeVersionProvider));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.sync, size: 18, color: scheme.onSecondaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Data has changed — tap to refresh',
                  style: TextStyle(color: scheme.onSecondaryContainer),
                ),
              ),
              Text(
                'Refresh',
                style: TextStyle(
                  color: scheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarMenu extends ConsumerWidget {
  const _AvatarMenu({required this.onProfile});
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final auth = ref.watch(authControllerProvider).asData?.value?.account;
    final displayName = auth?.name.trim().isNotEmpty == true
        ? auth!.name.trim()
        : l10n.lbl_adminUser;
    return PopupMenuButton<String>(
      icon: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.primaryContainer,
        child: Text(
          displayName.initials,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(l10n.nav_account),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.btn_signOut),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'profile') onProfile();
        if (value == 'logout') _showSignOutConfirmation(context, ref);
      },
    );
  }

  void _showSignOutConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.dlg_signOut_title),
        content: Text(l10n.dlg_signOut_content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.btn_cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(authControllerProvider.notifier).signOut();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(l10n.btn_signOut),
          ),
        ],
      ),
    );
  }
}

class _AppFooter extends StatelessWidget {
  const _AppFooter();

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final color = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.6);
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SurfaceCard(
          child: Center(
            child: Text(
              l10n.footer_copyright(year),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            context.l10n.appTitle_admin,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
