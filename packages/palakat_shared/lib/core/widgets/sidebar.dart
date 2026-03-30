import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/extension/string_extension.dart';
import 'package:palakat_shared/core/models/auth_response.dart';
import 'package:palakat_shared/core/services/local_storage_service_provider.dart';
import 'package:palakat_shared/core/theme/theme.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = GoRouterState.of(context).uri.toString();
    final l10n = context.l10n;
    final localStorage = ref.watch(localStorageServiceProvider);
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
                          Icons.church_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sanctuary Admin',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.appTitle_admin,
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
                      icon: Icons.dashboard_outlined,
                      label: l10n.nav_dashboard,
                      selected: route.startsWith('/dashboard'),
                      onTap: () => context.go('/dashboard'),
                      color: AppColors.primary,
                    ),
                    _NavItem(
                      icon: Icons.group_outlined,
                      label: l10n.nav_members,
                      selected: route.startsWith('/member'),
                      onTap: () => context.go('/member'),
                      color: AppColors.primary,
                    ),
                    _NavItem(
                      icon: Icons.event_note,
                      label: l10n.nav_activity,
                      selected: route.startsWith('/activity'),
                      onTap: () => context.go('/activity'),
                      color: AppColors.primary,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
                      child: Text(
                        l10n.nav_section_report,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    _NavItem(
                      icon: Icons.account_balance_wallet,
                      label: l10n.nav_finance,
                      selected: route.startsWith('/finance'),
                      onTap: () => context.go('/finance'),
                      color: AppColors.primary,
                    ),
                    _NavItem(
                      icon: Icons.insert_drive_file_outlined,
                      label: l10n.nav_report,
                      selected: route.startsWith('/report'),
                      onTap: () => context.go('/report'),
                      color: AppColors.primary,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
                      child: Text(
                        l10n.nav_section_administration,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    _NavItem(
                      icon: Icons.account_balance,
                      label: l10n.nav_church,
                      selected: route.startsWith('/church'),
                      onTap: () => context.go('/church'),
                      color: AppColors.primary,
                    ),
                    _NavItem(
                      icon: Icons.description_outlined,
                      label: l10n.nav_document,
                      selected: route.startsWith('/document'),
                      onTap: () => context.go('/document'),
                      color: AppColors.primary,
                    ),
                    _NavItem(
                      icon: Icons.check_box_outlined,
                      label: l10n.nav_approval,
                      selected: route.startsWith('/approval'),
                      onTap: () => context.go('/approval'),
                      color: AppColors.primary,
                    ),
                    _NavItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: l10n.nav_financial,
                      selected: route.startsWith('/financial'),
                      onTap: () => context.go('/financial'),
                      color: AppColors.primary,
                    ),
                    _NavItem(
                      icon: Icons.receipt_long,
                      label: l10n.nav_billing,
                      selected: route.startsWith('/billing'),
                      onTap: () => context.go('/billing'),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: ValueListenableBuilder<AuthResponse?>(
                  valueListenable: localStorage.currentAuthListenable,
                  builder: (context, auth, _) {
                    final account = auth?.account;
                    final membership =
                        localStorage.currentMembership ?? account?.membership;
                    final church = membership?.church;
                    final displayNameValue = (account?.name ?? '').trim();
                    final displayName = displayNameValue.isEmpty
                        ? l10n.lbl_adminUser
                        : displayNameValue;
                    final phoneValue = (account?.phone ?? '').trim();
                    final phone = phoneValue.isEmpty ? '-' : phoneValue;
                    final churchNameValue = (church?.name ?? '').trim();
                    final churchName = churchNameValue.isEmpty
                        ? l10n.lbl_churchNotAvailable
                        : churchNameValue;
                    final churchId =
                        church?.id?.toString() ??
                        membership?.column?.churchId.toString() ??
                        '-';

                    return InkWell(
                      borderRadius: BorderRadius.circular(
                        SanctuaryLayout.radiusLarge,
                      ),
                      onTap: () => context.go('/account'),
                      child: Ink(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(
                            SanctuaryLayout.radiusLarge,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  AppColors.surfaceContainerHighest,
                              child: Text(
                                displayName.initials,
                                style: theme.textTheme.labelMedium?.copyWith(
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
                                  Text(
                                    displayName,
                                    style: theme.textTheme.titleSmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    phone,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    churchName,
                                    style: theme.textTheme.labelMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l10n.lbl_hashId(churchId),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.01,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _iconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
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
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? AppColors.surfaceContainerHighest
                      : _isHovered
                      ? AppColors.surfaceContainerHighest
                      : AppColors.surfaceContainerLow,
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
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
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
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
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
                    child: Text(widget.label),
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
