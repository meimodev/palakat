import 'package:flutter/material.dart';
import 'package:palakat/app/modules/calendar/calendar_screen.dart';
import 'package:palakat/app/modules/dashboard/dashboard_screen.dart';
import 'package:palakat/app/modules/songs/songs_screen.dart';
import 'package:palakat/app/widgets/bottom_navbar.dart';
import 'package:palakat/app/widgets/screen_wrapper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int activeIndex = 0;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        setState(() {
          activeIndex = tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TabBarView(
              controller: tabController,
              physics: const BouncingScrollPhysics(),
              children: const [
                DashboardScreen(),
                CalendarScreen(),
                SongsScreen(),
              ],
            ),
          ),
          BottomNavbar(
            tabController: tabController,
            activeIndex: activeIndex,
          ),
        ],
      ),
    );
  }
}
