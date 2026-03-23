import 'package:flutter/material.dart';
import 'package:palakat_shared/core/theme/theme.dart';


class SanctuaryWebShell extends StatelessWidget {
  const SanctuaryWebShell({
    super.key,
    required this.child,
    required this.sidebar,
    required this.mobileTitle,
    this.mobileActions = const <Widget>[],
    this.footer,
  });

  final Widget child;
  final Widget sidebar;
  final Widget mobileTitle;
  final List<Widget> mobileActions;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 960;
    final drawerWidth = width < 420 ? width - 24 : 320.0;
    final horizontalPadding = SanctuaryLayout.horizontalPadding(width);

    return Scaffold(
      appBar: isSmall
          ? AppBar(
              title: mobileTitle,
              titleSpacing: 8,
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              actions: mobileActions,
            )
          : null,
      drawer: isSmall
          ? _SanctuaryDrawer(sidebar: sidebar, width: drawerWidth)
          : null,
      drawerEnableOpenDragGesture: true,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSmall) _SidebarContainer(child: sidebar),
          Expanded(
            child: _AnimatedContent(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 24,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: SanctuaryLayout.desktopContentMaxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        child,
                        if (footer != null) ...[
                          const SizedBox(height: 32),
                          footer!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SanctuaryDrawer extends StatelessWidget {
  const _SanctuaryDrawer({required this.sidebar, this.width});

  final Widget sidebar;
  final double? width;

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
        width: width,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            boxShadow: SanctuaryDepth.ambient(opacity: 0.06, blur: 28),
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
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 360),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -16.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
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
              width: SanctuaryLayout.desktopSidebarWidth,
              child: Container(
                margin: const EdgeInsets.fromLTRB(24, 24, 0, 24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(
                    SanctuaryLayout.radiusLarge,
                  ),
                  boxShadow: SanctuaryDepth.ambient(opacity: 0.04, blur: 32),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    SanctuaryLayout.radiusLarge,
                  ),
                  child: widget.child,
                ),
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
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    )..forward();
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
