import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palakat/core/constants/constants.dart';

class AuthSurfaceCard extends StatelessWidget {
  const AuthSurfaceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.centeredHeader = false,
    this.padding,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final bool centeredHeader;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      elevation: 1,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: AppColors.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: AppColors.secondary, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: padding ?? EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (centeredHeader)
              Column(
                children: [
                  _AuthHeaderIcon(icon: icon, centered: true),
                  Gap.h16,
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            else
              Row(
                children: [
                  _AuthHeaderIcon(icon: icon),
                  Gap.w12,
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            Gap.h16,
            child,
          ],
        ),
      ),
    );
  }
}

class _AuthHeaderIcon extends StatelessWidget {
  const _AuthHeaderIcon({required this.icon, this.centered = false});

  final IconData icon;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final size = centered ? 56.0 : 40.0;
    final iconSize = centered ? 24.0 : 18.0;
    final radius = centered ? 16.0 : 8.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: SanctuaryDepth.ambient(opacity: 0.02, blur: 10),
      ),
      alignment: Alignment.center,
      child: FaIcon(icon, size: iconSize, color: AppColors.secondary),
    );
  }
}
