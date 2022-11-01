import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiffy/jiffy.dart';
import 'package:palakat/shared/routes.dart';
import 'package:palakat/shared/theme.dart';
import 'package:get/get.dart';

void main() async {
  await Jiffy.locale('id');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (context, _) => GetMaterialApp(
        title: "EVENT NOTIFIER APP",
        theme: appThemeData,
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.home,
        getPages: Routes.getRoutes(),
        builder: (context, widget) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: widget!,
          );
        },
      ),
    );
  }
}