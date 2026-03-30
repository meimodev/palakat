import 'package:flutter/material.dart';
import 'package:palakat_shared/core/theme/theme.dart';

class ExpandableSurfaceCard extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final bool initiallyExpanded;

  const ExpandableSurfaceCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.initiallyExpanded = false,
  });

  @override
  State<ExpandableSurfaceCard> createState() => _ExpandableSurfaceCardState();
}

class _ExpandableSurfaceCardState extends State<ExpandableSurfaceCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final radius = BorderRadius.circular(SanctuaryLayout.radiusLarge);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: radius,
        boxShadow: SanctuaryDepth.ambient(opacity: 0.035, blur: 28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (always visible)
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(SanctuaryLayout.radiusLarge),
              bottom: Radius.circular(
                _isExpanded ? 0 : SanctuaryLayout.radiusLarge,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final titleBlock = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.title != null)
                        Text(
                          widget.title!,
                          style: theme.textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (widget.subtitle != null)
                        Text(
                          widget.subtitle!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  );

                  final expandIcon = AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );

                  // if (widget.trailing == null || constraints.maxWidth >= 560) {
                  //   return Row(
                  //     mainAxisSize: MainAxisSize.max,
                  //     children: [
                  //       Expanded(child: titleBlock),
                  //       Flexible(
                  //         child: Row(
                  //           mainAxisSize: MainAxisSize.max,
                  //           children: [
                  //             if (widget.trailing != null) widget.trailing!,
                  //             const SizedBox(width: 8),
                  //             expandIcon,
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   );
                  // }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: titleBlock),
                      const SizedBox(width: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (widget.trailing != null) widget.trailing!,
                          expandIcon,
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Expandable content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
