import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_admin/core/extension/extension.dart';

class ImageNetworkWidget extends StatelessWidget {
  const ImageNetworkWidget(
      {super.key, required this.imageUrl, this.height, this.width, this.fit});
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: BaseColor.neutral.shade20),

      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: BaseColor.neutral.shade20),
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w24),
          child: Assets.icons.fill.error
              .svg(colorFilter: BaseColor.error.filterSrcIn),
        ),
      ),
      width: width,
      height: height,
      fit: fit,
    );
  }
}
