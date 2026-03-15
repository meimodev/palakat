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
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.teal[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
        side: BorderSide(color: BaseColor.teal[100]!, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: padding ?? EdgeInsets.all(BaseSize.w20),
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
                    style: BaseTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: BaseColor.primaryText,
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
                      style: BaseTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BaseColor.primaryText,
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
    final size = centered ? BaseSize.w56 : BaseSize.w40;
    final iconSize = centered ? BaseSize.w24 : BaseSize.w18;
    final radius = centered ? BaseSize.radiusLg : BaseSize.radiusMd;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: BaseColor.teal[100],
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: BaseColor.teal[200]!.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: FaIcon(icon, size: iconSize, color: BaseColor.teal[700]),
    );
  }
}
