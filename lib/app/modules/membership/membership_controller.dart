import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palakat/app/widgets/custom_simple_dialog.dart';
import 'package:palakat/data/models/church.dart';
import 'package:palakat/data/models/membership.dart';
import 'package:palakat/data/models/user_app.dart';
import 'package:palakat/data/repos/church_repo.dart';
import 'package:palakat/data/repos/membership_repo.dart';
import 'package:palakat/shared/shared.dart';

class MembershipController extends GetxController {
  final churchRepo = Get.find<ChurchRepo>();

  final textEditingControllerChurch = TextEditingController();
  final textEditingControllerColumn = TextEditingController();

  late UserApp user;
  String baptizeStatus = false.statusBoolToString("Baptis");
  String sidiStatus = false.statusBoolToString("Sidi");
  Church? selectedChurch;

  RxBool loading = true.obs;

  List<Church>? churches;

  final membershipRepo = MembershipRepo();

  @override
  void dispose() {
    textEditingControllerChurch.dispose();
    textEditingControllerColumn.dispose();
    super.dispose();
  }

  @override
  void onInit() {
    super.onInit();

    user = Get.arguments;

    if (user.membership != null) {
      selectedChurch = user.membership!.church;
      textEditingControllerColumn.text = user.membership!.column;
      textEditingControllerChurch.text =
          "${selectedChurch!.name}, ${selectedChurch!.location}";

      baptizeStatus = user.membership!.baptize.statusBoolToString("Baptis");
      sidiStatus = user.membership!.sidi.statusBoolToString("Sidi");
    }

    //fetch churches
    fetchChurches();
  }

  void fetchChurches() async {
    churches = await churchRepo.readRegisteredChurches();
    loading.value = false;
  }

  Future<void> onPressedNextButton() async {
    // validate inputs
    if (selectedChurch == null) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Church is not selected yet",
        ),
      );
    }

    final column = textEditingControllerColumn.text;

    if (column.isEmpty) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Column cannot be empty",
        ),
      );
      return;
    }
    if (!column.isNumericOnly) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Column consist of number 0 - 9",
        ),
      );
      return;
    }
    if (column.startsWith("0")) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Column number consist only 1 - 99",
        ),
      );
      return;
    }
    if (column.length > 2) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Column number consist only 1 - 99",
        ),
      );
      return;
    }

    if (user.membership != null) {
      await _editMembership();
      return;
    }

    await _createMembership();
  }

  Future<void> _editMembership() async {
    //check if changed occurred
    final currentBaptizeStatus =
        user.membership!.baptize.statusBoolToString("Baptis");
    final currentSidiStatus = user.membership!.sidi.statusBoolToString("Sidi");
    final currentColumn = user.membership!.column;

    if (selectedChurch!.id == user.membership!.church!.id &&
        currentColumn == textEditingControllerColumn.text &&
        currentBaptizeStatus == baptizeStatus &&
        currentSidiStatus == sidiStatus) {
      Get.offNamedUntil(
        Routes.home,
        (route) => route.settings.name == Routes.home,
      );
      return;
    }

    final updatedMembership =
        await membershipRepo.updateMembership(user.membership!.copyWith(
      church: selectedChurch,
      column: textEditingControllerColumn.text,
      baptize: baptizeStatus.statusStringToBool(),
      sidi: sidiStatus.statusStringToBool(),
    ));
    user.membership = updatedMembership;
    Get.offNamedUntil(
      Routes.home,
      (route) => route.settings.name == Routes.home,
      arguments: user,
    );
  }

  Future<void> _createMembership() async {
    final createdMembership = await membershipRepo.createMembership(
      membership: Membership(
        church: selectedChurch,
        column: textEditingControllerColumn.text,
        baptize: baptizeStatus.statusStringToBool(),
        sidi: sidiStatus.statusStringToBool(),
        churchId: selectedChurch!.id,
      ),
      userId: user.id!,
    );

    user.membership = createdMembership;

    Get.offNamedUntil(
      Routes.home,
      (route) => route.settings.name == Routes.home,
      arguments: user,
    );
  }

  void onSelectChurch(Church church) {
    selectedChurch = church;
    textEditingControllerChurch.text =
        "${selectedChurch!.name}, ${selectedChurch!.location}";
  }
}
