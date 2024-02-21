import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/home/presentation/main_home/widgets/coach_mark_widget.dart';
import 'package:halo_hermina/features/main/presentation/main_app/main_app_controller.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({
    Key? key,
  }) : super(key: key);

  static const String _key = 'home_page';
  static const Key widgetKey = Key(_key);
  static const Key marketKey = Key('${_key}_market');

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final String txtNext = LocaleKeys.text_continue.tr();
  final String txtSkip = LocaleKeys.text_skip.tr();
  final String txtFinish = LocaleKeys.text_finish.tr();

  @override
  void initState() {
    super.initState();
  }

  List<TargetFocus> _initTarget(
    GlobalKey globalKeyOne,
    GlobalKey globalKeyTwo,
    GlobalKey globalKeyThree,
    GlobalKey globalKeyFour,
  ) {
    return [
      TargetFocus(
        identify: "bookdoctor-key",
        keyTarget: globalKeyOne,
        color: BaseColor.neutral.shade90,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                next: txtNext,
                skip: txtSkip,
                step: "1/4",
                title: LocaleKeys.text_bookDoctor.tr(),
                description: LocaleKeys.text_makeAnAppointmentWith.tr(),
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
              );
            },
          )
        ],
      ),

      // health features
      TargetFocus(
        identify: "healthfeature-key",
        keyTarget: globalKeyTwo,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CoachmarkDesc(
                next: txtNext,
                skip: txtSkip,
                step: "2/4",
                title: LocaleKeys.text_topHealthFeatures.tr(),
                description: LocaleKeys.text_accessToVariousHealthFeature.tr(),
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
              );
            },
          )
        ],
      ),

      // patient portal
      TargetFocus(
        identify: "patientportal-key",
        keyTarget: globalKeyThree,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return CoachmarkDesc(
                next: txtNext,
                skip: txtSkip,
                step: "3/4",
                title: LocaleKeys.text_patientPortal.tr(),
                description: LocaleKeys.text_accessYourMedicalData.tr(),
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
              );
            },
          )
        ],
      ),

      // notifications
      TargetFocus(
        identify: "notification-key",
        keyTarget: globalKeyFour,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return CoachmarkDesc(
                next: txtFinish,
                skip: "",
                step: "4/4",
                title: LocaleKeys.text_notification.tr(),
                description:
                    LocaleKeys.text_informationAboutTransactionAndYour.tr(),
                onNext: () {
                  controller.next();
                },
              );
            },
          )
        ],
      ),
    ];
  }

  void _showTutorialCoachmark(
    List<TargetFocus> targets,
    TutorialCoachMark? tutorialCoachMark,
    GlobalKey globalKeyOne,
    GlobalKey globalKeyTwo,
    GlobalKey globalKeyThree,
    GlobalKey globalKeyFour,
  ) {
    if (targets.isNotEmpty) {
      tutorialCoachMark = TutorialCoachMark(
        targets: targets,
        pulseEnable: true,
        pulseAnimationDuration: const Duration(milliseconds: 1000),
        colorShadow: BaseColor.neutral.shade90,
        paddingFocus: 4,
        onClickTarget: (target) {
          print("${target.identify}");
        },
        hideSkip: true,
        onFinish: () {
          print("Finish");
        },
      )..show(context: context, rootOverlay: true);
    }
  }

  void _showTutorialCoachmarkFirstTime(
    List<TargetFocus> targets,
    TutorialCoachMark? tutorialCoachMark,
    GlobalKey globalKeyOne,
    GlobalKey globalKeyTwo,
    GlobalKey globalKeyThree,
    GlobalKey globalKeyFour,
  ) async {
    final mainController = ref.read(mainAppControllerProvider.notifier);

    if (!mainController.getTutorialStatus()) {
      _showTutorialCoachmark(
        targets,
        tutorialCoachMark,
        globalKeyOne,
        globalKeyTwo,
        globalKeyThree,
        globalKeyFour,
      );

      await mainController.setTutorialStatus(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(bottomNavBarProvider.notifier);
    final navbarState = ref.watch(bottomNavBarProvider);
    final mainController = ref.watch(mainAppControllerProvider.notifier);
    var currentBackPressTime = mainController.currentBackPressTime;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mainController.getTutorialStatus()) {
        Future.delayed(const Duration(seconds: 3), () {
          _showTutorialCoachmarkFirstTime(
            _initTarget(
              mainController.globalKeyOne,
              mainController.globalKeyTwo,
              mainController.globalKeyThree,
              mainController.globalKeyFour,
            ),
            mainController.tutorialCoachMark,
            mainController.globalKeyOne,
            mainController.globalKeyTwo,
            mainController.globalKeyThree,
            mainController.globalKeyFour,
          );
        });
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: WillPopScope(
        onWillPop: () async {
          if (navbarState.selectedIndex != 0) {
            controller.navigateTo(0);
            return Future.value(false);
          } else {
            DateTime now = DateTime.now();

            if (currentBackPressTime == null ||
                now.difference(currentBackPressTime!) >
                    const Duration(seconds: 2)) {
              currentBackPressTime = now;
              Fluttertoast.showToast(
                msg: LocaleKeys.text_pressAgainToExit.tr(),
              );
              return Future.value(false);
            }
            return Future.value(true);
          }
        },
        child: PageView(
          key: MainScreen.widgetKey,
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            HomeScreen(
              tutorialStatus: mainController.getTutorialStatus(),
              globalKeyOne: mainController.globalKeyOne,
              globalKeyTwo: mainController.globalKeyTwo,
            ),
            AppointmentScreen(),
            PatientPortalScreen(),
            MainNotificationScreen(),
            AccountScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        globalKeyThree: mainController.globalKeyThree,
        globalKeyFour: mainController.globalKeyFour,
        currentIndex: navbarState.selectedIndex,
        onPressedItem: (index) {
          controller.navigateTo(index);
        },
      ),
    );
  }
}
