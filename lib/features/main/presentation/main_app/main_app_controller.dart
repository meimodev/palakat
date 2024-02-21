import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/features/main/presentation/main_app/main_app_state.dart';
import 'package:halo_hermina/features/shared/application/shared_service.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class MainAppController extends StateNotifier<MainAppState> {
  MainAppController(this.sharedService) : super(MainAppState());

  final SharedService sharedService;
  DateTime? currentBackPressTime;
  List<TargetFocus> targets = [];
  TutorialCoachMark? tutorialCoachMark;
  final GlobalKey globalKeyOne = GlobalKey();
  final GlobalKey globalKeyTwo = GlobalKey();
  final GlobalKey globalKeyThree = GlobalKey();
  final GlobalKey globalKeyFour = GlobalKey();

  bool getTutorialStatus() {
    return sharedService.getTutorialStatus();
  }

  Future<void> setTutorialStatus(bool status) async {
    await sharedService.setTutorialStatus(status);
  }
}

final mainAppControllerProvider =
    StateNotifierProvider.autoDispose<MainAppController, MainAppState>((ref) {
  return MainAppController(
    ref.read(sharedServiceProvider),
  );
});
