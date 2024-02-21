import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class OurHospitalItemWidget extends StatelessWidget {
  const OurHospitalItemWidget(
      {Key? key, required this.title, required this.onTap, required this.image})
      : super(key: key);

  final String image;
  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        highlightColor: Colors.amber,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius:
                    BorderRadius.all(Radius.circular(BaseSize.radiusLg)),
                child: Stack(
                  children: <Widget>[
                    Image.network(image,
                        fit: BoxFit.cover,
                        width: BaseSize.customWidth(100),
                        height: BaseSize.customWidth(100)),
                  ],
                )),
            Gap.h8,
            Text(
              title,
              style: TypographyTheme.textSSemiBold
                  .fontColor(BaseColor.neutral.shade80),
            )
          ],
        ));
  }
}
