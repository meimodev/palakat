import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_shared/widgets.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key, required this.child});
  final Widget child;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: isSmall
          ? AppBar(
              title: const Text('Palakat Admin'),
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: [_AvatarMenu(onProfile: () => context.go('/account'))],
            )
          : null,
      drawer: isSmall ? _AnimatedDrawer(sidebar: const AppSidebar()) : null,
      drawerEnableOpenDragGesture: true,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSmall) _SidebarContainer(child: const AppSidebar()),
          Expanded(
            child: _AnimatedContent(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Page content
                    SizedBox.shrink(key: ValueKey('content_placeholder')),
                    widget.child,
                    const _AppFooter(),
                  ],
                ),
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
      duration: const Duration(milliseconds: 400), // Reduced duration
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -20.0, // Less dramatic slide
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

    // Animate in the sidebar on app start with less delay
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
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300), // Much faster
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start immediately - no delay needed
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fadeAnimation, child: widget.child);
  }
}

class _AvatarMenu extends ConsumerWidget {
  const _AvatarMenu({required this.onProfile});
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage('https://placehold.co/100x100.png'),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log out'),
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
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authControllerProvider.notifier).signOut();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 32),
        const Divider(height: 16, color: Colors.black54),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '© '
            '$year'
            ' Palakat. All rights reserved.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
