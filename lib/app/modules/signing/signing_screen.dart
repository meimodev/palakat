import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:palakat/app/widgets/screen_wrapper.dart';
import 'package:palakat/app/widgets/text_field_wrapper.dart';
import 'package:palakat/shared/shared.dart';
import 'package:rive/rive.dart';

import 'signing_controller.dart';

class SigningScreen extends GetView<SigningController> {
  const SigningScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Padding(
        padding: EdgeInsets.only(
          left: Insets.medium.w,
          right: Insets.medium.w,
          bottom: Insets.small.h,
        ),
        child: _BuildBody(
          controller: controller,
        ),
      ),
    );
  }
}

class _BuildBody extends StatelessWidget {
  const _BuildBody({Key? key, required this.controller}) : super(key: key);

  final SigningController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: RiveLoading(onInitRive: controller.onInitLoading)),
        SizedBox(
          height: 140.h,
          child: Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: controller.loading.isTrue
                  ? const SizedBox()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        controller.state == SigningState.enterPhone
                            ? TextFieldWrapper(
                                labelText: 'Phone',
                                endIconData: Icons.phone_outlined,
                                textInputType: TextInputType.phone,
                                textEditingController: controller.tecPhone,
                              )
                            : const SizedBox(),
                        controller.state == SigningState.enterCode
                            ? TextFieldWrapper(
                                labelText: 'Code',
                                endIconData: Icons.dialpad_outlined,
                                textInputType: TextInputType.phone,
                                outlineColor: Palette.primary,
                                textEditingController: controller.tecCode,
                              )
                            : const SizedBox(),
                        SizedBox(
                          height: 15,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: controller.errorText.isNotEmpty
                                ? Padding(
                                    padding: EdgeInsets.only(
                                      left: Insets.small.w,
                                      right: Insets.small.w,
                                    ),
                                    child:  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        controller.errorText.value,
                                        style: const TextStyle(
                                          letterSpacing: .5,
                                          color: Palette.negative,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                        ),
                        SizedBox(height: Insets.small.h),
                        SizedBox(
                          width: 100.w,
                          child: Material(
                            clipBehavior: Clip.hardEdge,
                            borderRadius: BorderRadius.circular(12),
                            color: Palette.primary,
                            child: InkWell(
                              onTap: controller.onPressedNext,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: Insets.small.h,
                                ),
                                child: Center(
                                  child: Text(
                                    "Next",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Palette.accent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                      ],
                    ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "meimo",
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 10.sp,
            ),
          ),
        ),
      ],
    );
  }
}

class RiveLoading extends StatefulWidget {
  const RiveLoading({Key? key, required this.onInitRive}) : super(key: key);

  final void Function(SMIBool loading, SMITrigger show) onInitRive;

  @override
  State<RiveLoading> createState() => _RiveLoadingState();
}

class _RiveLoadingState extends State<RiveLoading> {
  late SMIBool loading;

  late SMITrigger show;

  late StateMachineController controller;

  void _onRiveInit(Artboard artBoard) {
    controller =
        StateMachineController.fromArtboard(artBoard, 'State Machine 1')!;
    artBoard.addController(controller);
    loading = (controller.findInput<bool>('Loading') as SMIBool);
    show = (controller.findInput<bool>('Show') as SMITrigger);

    widget.onInitRive(loading, show);
  }

  void initiateLoading() {
    if (!loading.value) {
      loading.value = true;
      show.fire();
    } else {
      loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // initiateLoading();
      },
      child: SizedBox(
        child: RiveAnimation.asset(
          "assets/animations/ball_loader.riv",
          fit: BoxFit.cover,
          onInit: _onRiveInit,
        ),
      ),
    );
  }
}
