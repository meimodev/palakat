import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/extension/string_extension.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = GoRouterState.of(context).uri.toString();
    final l10n = context.l10n;
    // TODO: Implement auth controller in consuming app
    // final auth = ref.watch(authControllerProvider).asData?.value;
    // final account = auth?.account;
    final displayName = 'Admin User'; // account?.name ?? 'Admin User';

    // final church = ref
    //     .read(authControllerProvider)
    //     .value
    //     ?.account
    //     .membership
    //     ?.church;
    String? churchName;

    return Drawer(
      elevation: 0,
      child: SafeArea(
        child: Material(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.church,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Palakat Admin',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    _NavItem(
                      icon: Icons.dashboard_outlined,
                      label: l10n.nav_dashboard,
                      selected: route.startsWith('/dashboard'),
                      onTap: () => context.go('/dashboard'),
                      color: Colors.indigo,
                    ),
                    _NavItem(
                      icon: Icons.group_outlined,
                      label: l10n.nav_members,
                      selected: route.startsWith('/member'),
                      onTap: () => context.go('/member'),
                      color: Colors.teal,
                    ),
                    _NavItem(
                      icon: Icons.event_note,
                      label: l10n.nav_activity,
                      selected: route.startsWith('/activity'),
                      onTap: () => context.go('/activity'),
                      color: Colors.deepOrange,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                      child: Text(
                        l10n.nav_section_report,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    _NavItem(
                      icon: Icons.attach_money,
                      label: l10n.nav_revenue,
                      selected: route.startsWith('/revenue'),
                      onTap: () => context.go('/revenue'),
                      color: Colors.green,
                    ),
                    _NavItem(
                      icon: Icons.credit_card,
                      label: l10n.nav_expense,
                      selected: route.startsWith('/expense'),
                      onTap: () => context.go('/expense'),
                      color: Colors.purple,
                    ),
                    _NavItem(
                      icon: Icons.insert_drive_file_outlined,
                      label: l10n.nav_report,
                      selected: route.startsWith('/report'),
                      onTap: () => context.go('/report'),
                      color: Colors.orange,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                      child: Text(
                        l10n.nav_section_administration,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    _NavItem(
                      icon: Icons.account_balance,
                      label: l10n.nav_church,
                      selected: route.startsWith('/church'),
                      onTap: () => context.go('/church'),
                      color: Colors.red,
                    ),
                    _NavItem(
                      icon: Icons.description_outlined,
                      label: l10n.nav_document,
                      selected: route.startsWith('/document'),
                      onTap: () => context.go('/document'),
                      color: Colors.orange,
                    ),
                    _NavItem(
                      icon: Icons.check_box_outlined,
                      label: l10n.nav_approval,
                      selected: route.startsWith('/approval'),
                      onTap: () => context.go('/approval'),
                      color: Colors.cyan,
                    ),
                    _NavItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: l10n.nav_financial,
                      selected: route.startsWith('/financial'),
                      onTap: () => context.go('/financial'),
                      color: Colors.amber,
                    ),
                    _NavItem(
                      icon: Icons.receipt_long,
                      label: l10n.nav_billing,
                      selected: route.startsWith('/billing'),
                      onTap: () => context.go('/billing'),
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    displayName.initials,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(displayName),
                subtitle: Text(
                  churchName ?? '',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                onTap: () => context.go('/account'),
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
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _iconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
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
                      ? theme.colorScheme.primary.withValues(alpha: 0.08)
                      : _isHovered
                      ? theme.colorScheme.primary.withValues(alpha: 0.04)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isHovered && !widget.selected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
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
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                            color: widget.selected
                                ? theme.colorScheme.primary
                                : _isHovered
                                ? widget.color.withValues(alpha: 0.2)
                                : widget.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            widget.icon,
                            size: 18,
                            color: widget.selected
                                ? theme.colorScheme.onPrimary
                                : widget.color,
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
                          ? theme.colorScheme.primary
                          : _isHovered
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    child: Text(widget.label),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    if (theme.platform == TargetPlatform.iOS ||
                        theme.platform == TargetPlatform.android) {
                      // Note: You might want to add haptic feedback here
                      // HapticFeedback.lightImpact();
                    }
                    widget.onTap();
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
