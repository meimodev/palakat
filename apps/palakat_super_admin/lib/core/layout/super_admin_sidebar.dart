import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

import '../../features/auth/application/super_admin_auth_controller.dart';

class SuperAdminSidebar extends ConsumerWidget {
  const SuperAdminSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = GoRouterState.of(context).uri.toString();
    const displayName = 'Super Admin';
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Drawer(
      elevation: 0,
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Material(
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(
                      SanctuaryLayout.radiusLarge,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(
                            SanctuaryLayout.radius,
                          ),
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sanctuary Control',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.app_superAdminTitle,
                              style: theme.textTheme.titleLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  children: [
                    _NavItem(
                      icon: Icons.church_outlined,
                      label: l10n.churchRequest_title,
                      selected: route.startsWith('/church-requests'),
                      onTap: () => context.go('/church-requests'),
                      color: AppColors.primary,
                    ),
                    _NavItem(
                      icon: Icons.apartment_outlined,
                      label: l10n.nav_church,
                      selected: route.startsWith('/churches'),
                      onTap: () => context.go('/churches'),
                      color: AppColors.primary,
                    ),
                    _NavItem(
                      icon: Icons.article_outlined,
                      label: l10n.nav_articles,
                      selected: route.startsWith('/articles'),
                      onTap: () => context.go('/articles'),
                      color: AppColors.primary,
                    ),
                    _NavItem(
                      icon: Icons.library_music_outlined,
                      label: l10n.nav_songs,
                      selected: route.startsWith('/songs'),
                      onTap: () => context.go('/songs'),
                      color: AppColors.primary,
                    ),
                    _NavItem(
                      icon: Icons.mail_outline,
                      label: l10n.dashboard_membershipInvitation_title,
                      selected: route.startsWith('/membership-invitations'),
                      onTap: () => context.go('/membership-invitations'),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Ink(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(
                      SanctuaryLayout.radiusLarge,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.surfaceContainerHighest,
                        child: Text(
                          displayName.initials,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.app_superAdminTitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.btn_signOut,
                        icon: const Icon(Icons.logout),
                        onPressed: () async {
                          await ref
                              .read(superAdminAuthControllerProvider.notifier)
                              .signOut();
                          if (context.mounted) {
                            context.go('/signin');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconScaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.01,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _iconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered && !widget.selected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: MouseRegion(
              onEnter: (_) => _handleHover(true),
              onExit: (_) => _handleHover(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? AppColors.surfaceContainerHighest
                      : _isHovered
                      ? AppColors.surfaceContainerLow
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    SanctuaryLayout.radiusLarge,
                  ),
                  boxShadow: _isHovered && !widget.selected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(
                              alpha: 0.04,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: ListTile(
                  leading: AnimatedBuilder(
                    animation: _iconScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _iconScaleAnimation.value,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            color: widget.selected || _isHovered
                                ? widget.color.withValues(alpha: 0.12)
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(
                              SanctuaryLayout.radius,
                            ),
                          ),
                          child: Icon(
                            widget.icon,
                            size: 18,
                            color: widget.selected
                                ? widget.color
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                  title: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: widget.selected
                          ? FontWeight.w600
                          : _isHovered
                          ? FontWeight.w500
                          : FontWeight.normal,
                      color: widget.selected
                          ? widget.color
                          : _isHovered
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      SanctuaryLayout.radiusLarge,
                    ),
                  ),
                  onTap: widget.onTap,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
