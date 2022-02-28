import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiffy/jiffy.dart';
import 'package:palakat/app/blocs/event_bloc.dart';
import 'package:palakat/app/blocs/user_cubit.dart';
import 'package:palakat/app/modules/home/home_screen.dart';
import 'package:palakat/data/models/model_mock.dart';
import 'package:palakat/shared/routes.dart';
import 'package:palakat/shared/theme.dart';

void main() async {
  await Jiffy.locale('id');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(_) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: () => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => EventBloc()
              ..add(
                LoadEvents(
                  events: ModelMock.events,
                ),
              ),
          ),
          BlocProvider(
            create: (_) => UserCubit(),
          )
        ],
        child: MaterialApp(
          title: "GEREJA APP",
          home: const HomeScreen(),
          theme: appThemeData,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: Routes.generateRoute,
          builder: (context, widget) {
            ScreenUtil.setContext(context);
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: widget!,
            );
          },
        ),
      ),
    );
  }
}