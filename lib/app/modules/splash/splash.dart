import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/app/widgets/screen_wrapper.dart';
import 'package:palakat/shared/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Container(
        child: Center(
          child: Text('Splash Screen'),
        ),
      ),
    );
  }
}