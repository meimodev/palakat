import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:palakat/shared/theme.dart';

import 'songs_controller.dart';

class SongsScreen extends GetView<SongsController> {
  const SongsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: Insets.small.w,
        right: Insets.small.w,
        top: Insets.small.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Song book',
            style: Theme.of(context).textTheme.headline1?.copyWith(
                  fontSize: 36.sp,
                ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Coming soon ...',
                style: Theme.of(context)
                    .textTheme
                    .headline1
                    ?.copyWith(fontSize: 16.sp, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}