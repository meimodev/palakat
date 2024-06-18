import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

class CardBipra extends StatelessWidget {
  const CardBipra({
    super.key,
    required this.bipra,
    required this.onPressed,
  });

  final Bipra bipra;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: BaseColor.cardBackground1,
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.w12,
            vertical: BaseSize.h6,
          ),
          child: Row(
            children: [
              SizedBox(
                width: BaseSize.customWidth(60),
                height: BaseSize.w40,
                child: Center(
                  child: Text(
                    bipra.abv,
                    style: BaseTypography.bodyMedium.bold,
                  ),
                ),
              ),
              Gap.w12,
              Expanded(
                child: Text(
                  bipra.name,
                  style: BaseTypography.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
