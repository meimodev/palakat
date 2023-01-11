import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:palakat/app/widgets/screen_wrapper.dart';
import 'package:palakat/data/models/song_part.dart';
import 'package:palakat/shared/theme.dart';

import 'song_detail_controller.dart';

class SongDetailScreen extends GetView<SongDetailController> {
  const SongDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.song == null) {
      return const ScreenWrapper(
          child: Center(
        child: CircularProgressIndicator(
          color: Palette.primary,
        ),
      ));
    }
    return ScreenWrapper(
      child: Padding(
        padding: EdgeInsets.only(
          left: Insets.medium.w,
          right: Insets.medium.w,
        ),
        child: Column(
          children: [
            SizedBox(height: Insets.large.h),
            Stack(
              children: [
                Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: GestureDetector(
                        child: Icon(
                          Icons.arrow_back,
                          size: 36.sp,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    )),
                Center(
                  child: Text(
                    controller.song!.book,
                    style: TextStyle(
                      fontSize: 36.sp,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              controller.song!.title,
              style: TextStyle(fontSize: 20.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Insets.medium.h),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  for (SongPart part in controller.song!.songParts)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          part.type,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Insets.small,
                          ),
                          child: Text(
                            part.content,
                            style: TextStyle(
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        const SizedBox(height: Insets.small),
                      ],
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
