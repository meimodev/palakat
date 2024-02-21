import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class GuaranteeTypeCardWidget extends StatelessWidget {
  const GuaranteeTypeCardWidget({
    super.key,
    required this.label,
    this.onTap,
    this.isSelected = false,
  });

  final void Function()? onTap;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      onTap: onTap,
      borderColor: isSelected ? BaseColor.primary3 : BaseColor.neutral.shade20,
      backgroundColor: isSelected ? BaseColor.primary1 : BaseColor.white,
      content: [
        Text(
          label,
          style: TypographyTheme.textLSemiBold.toNeutral80,
        ),
      ],
    );
  }
}
