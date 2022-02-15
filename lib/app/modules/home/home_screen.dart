import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/app/widgets/screen_wrapper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Column(
        children: [
          Text(
            'Home',
            style: Theme.of(context).textTheme.headline1,
          ),
          Container(
            child: Column(
              children: const [Text('text')],
            ),
          )
        ],
      ),
    );
  }
}