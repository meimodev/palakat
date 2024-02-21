import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/ripple_touch/ripple_touch_widget.dart';
import 'package:halo_hermina/core/widgets/tile/tile_widget.dart';

class AccountMenuTile extends StatelessWidget {
  final SvgGenImage icon;
  final String title;
  final String? routeName;
  final Function()? onTap;

  const AccountMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.routeName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RippleTouch(
      onTap: () => routeName != null ? context.pushNamed(routeName!) : onTap!(),
      child: TileWidget(
        padding: horizontalPadding,
        leading: icon.svg(
          width: BaseSize.w24,
          height: BaseSize.w24,
          colorFilter: BaseColor.primary3.filterSrcIn,
        ),
        title: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: BaseSize.h24),
          child: Text(
            title,
            style: TypographyTheme.textLRegular.toNeutral80,
          ),
        ),
      ),
    );
  }
}
