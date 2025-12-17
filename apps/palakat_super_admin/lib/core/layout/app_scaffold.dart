import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/super_admin_auth_controller.dart';
import 'super_admin_sidebar.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmall = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: isSmall
          ? AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Palakat'),
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text('SUPER ADMIN'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Sign out',
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
            )
          : null,
      drawer: isSmall
          ? const _AnimatedDrawer(sidebar: SuperAdminSidebar())
          : null,
      drawerEnableOpenDragGesture: true,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSmall) const _SidebarContainer(child: SuperAdminSidebar()),
          Expanded(
            child: _AnimatedContent(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDrawer extends StatelessWidget {
  const _AnimatedDrawer({required this.sidebar});
  final Widget sidebar;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        drawerTheme: const DrawerThemeData(
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      child: Drawer(
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: sidebar,
        ),
      ),
    );
  }
}

class _SidebarContainer extends StatefulWidget {
  const _SidebarContainer({required this.child});
  final Widget child;

  @override
  State<_SidebarContainer> createState() => _SidebarContainerState();
}

class _SidebarContainerState extends State<_SidebarContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -20.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: FadeTransition(
            opacity: _controller,
            child: SizedBox(
              width: 280,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.shadow.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedContent extends StatefulWidget {
  const _AnimatedContent({required this.child});
  final Widget child;

  @override
  State<_AnimatedContent> createState() => _AnimatedContentState();
}

class _AnimatedContentState extends State<_AnimatedContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child.key != widget.child.key) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _controller, child: widget.child);
  }
}
