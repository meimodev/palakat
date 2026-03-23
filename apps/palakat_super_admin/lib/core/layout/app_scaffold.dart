import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

import '../../features/auth/application/super_admin_auth_controller.dart';
import 'super_admin_sidebar.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return SanctuaryWebShell(
      sidebar: const SuperAdminSidebar(),
      mobileTitle: Text(
        l10n.app_superAdminTitle,
        overflow: TextOverflow.ellipsis,
      ),
      mobileActions: [
        IconButton(
          tooltip: l10n.btn_signOut,
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await ref.read(superAdminAuthControllerProvider.notifier).signOut();
            if (context.mounted) {
              context.go('/signin');
            }
          },
        ),
      ],
      footer: const _AppFooter(),
      child: child,
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
            l10n.app_superAdminTitle,
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
