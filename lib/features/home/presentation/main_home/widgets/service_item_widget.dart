import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class ServiceItemWidget extends StatelessWidget {
  const ServiceItemWidget(
      {Key? key, required this.icon, required this.title, required this.onTap})
      : super(key: key);

  final SvgGenImage icon;
  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                clipBehavior: Clip.hardEdge,
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    color: BaseColor.primary1),
                child: icon.svg(width: 34, height: 34, fit: BoxFit.none)),
            Gap.h8,
            Text(
              title,
              textAlign: TextAlign.center,
              style: TypographyTheme.textXSRegular.toNeutral70,
            )
          ],
        ));
  }
}
