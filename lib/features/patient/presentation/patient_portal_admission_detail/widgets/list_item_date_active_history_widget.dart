import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class ListItemDateActiveHistoryWidget extends StatelessWidget {
  const ListItemDateActiveHistoryWidget({
    super.key,
    required this.onTap,
    required this.date,
    this.hideDivider = false,
  });

  final void Function() onTap;
  final String date;
  final bool hideDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        hideDivider
            ? const SizedBox()
            : Divider(
                color: BaseColor.neutral.shade10,
              ),
        Gap.h20,
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  date,
                  style: TypographyTheme.textMSemiBold,
                ),
              ),
              Assets.icons.line.activityHistory.svg(
                width: BaseSize.customWidth(24),
                height: BaseSize.customWidth(24),
                colorFilter: BaseColor.primary3.filterSrcIn,
              ),
            ],
          ),
        ),
        Gap.h20,
      ],
    );
  }
}
