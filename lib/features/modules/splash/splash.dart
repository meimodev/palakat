import 'package:flutter/material.dart';
import 'package:palakat/app/widgets/screen_wrapper.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ScreenWrapper(
      child: Center(
        child: Text('Splash Screen'),
      ),
    );
  }
}