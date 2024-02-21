import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class HealthArticleItemWidget extends StatelessWidget {
  const HealthArticleItemWidget(
      {Key? key,
      required this.title,
      required this.onTap,
      required this.image,
      required this.tags})
      : super(key: key);

  final String image;
  final String title;
  final List<String> tags;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: BaseColor.neutral.shade20),
                borderRadius:
                    BorderRadius.all(Radius.circular(BaseSize.radiusLg))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(BaseSize.radiusLg),
                        topRight: Radius.circular(BaseSize.radiusLg)),
                    child: Stack(
                      children: <Widget>[
                        Image.network(image,
                            fit: BoxFit.cover,
                            width: BaseSize.customWidth(288),
                            height: BaseSize.customHeight(170)),
                      ],
                    )),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: BaseSize.w16, vertical: BaseSize.h16),
                  child: Column(children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TypographyTheme.textMSemiBold
                          .fontColor(BaseColor.neutral.shade80),
                    ),
                    Gap.customGapHeight(9),
                    Row(
                        children: tags.fold(
                            [],
                            (arr, item) => [
                                  ...arr,
                                  Container(
                                    decoration: BoxDecoration(
                                        color: BaseColor.primary1,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                BaseSize.radiusSm))),
                                    padding: EdgeInsets.symmetric(
                                        vertical: BaseSize.customWidth(6),
                                        horizontal: BaseSize.w12),
                                    child: Text(
                                      item,
                                      style: TypographyTheme.textSRegular
                                          .fontColor(BaseColor.primary3),
                                    ),
                                  ),
                                  Gap.w12
                                ]))
                  ]),
                )
              ],
            )));
  }
}
