import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class BiometricTile extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final bool switchValue;
  final Function(bool val) switchOnChange;

  const BiometricTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.switchValue,
    required this.switchOnChange,
  });

  @override
  Widget build(BuildContext context) {
    return RippleTouch(
      onTap: () => switchOnChange(!switchValue),
      child: TileWidget(
        leading: icon,
        padding: horizontalPadding,
        margin: EdgeInsets.symmetric(vertical: BaseSize.h12),
        title: Text(
          title,
          style: TypographyTheme.bodyRegular.toNeutral80.w500,
        ),
        subtitle: Text(
          subtitle,
          style: TypographyTheme.textSRegular.toNeutral60,
        ),
        trailing: SwitchWidget.primary(
          value: switchValue,
          onChanged: switchOnChange,
        ),
      ),
    );
  }
}
