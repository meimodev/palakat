import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:palakat/app/widgets/custom_two_option_radio.dart';
import 'package:palakat/app/widgets/dialog_select_church.dart';
import 'package:palakat/app/widgets/next_button.dart';
import 'package:palakat/app/widgets/screen_title.dart';
import 'package:palakat/app/widgets/screen_wrapper.dart';
import 'package:palakat/app/widgets/text_field_wrapper.dart';
import 'package:palakat/shared/theme.dart';

import 'membership_controller.dart';

class MembershipScreen extends GetView<MembershipController> {
  const MembershipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Padding(
        padding: EdgeInsets.only(
          left: Insets.medium.w,
          right: Insets.medium.w,
          bottom: Insets.small.h,
        ),
        child: Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: controller.loading.isTrue
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Palette.primary,
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            SizedBox(height: Insets.large.h),
                            const ScreenTitle(title: 'Membership'),
                            SizedBox(height: Insets.medium.h),
                            TextFieldWrapper(
                              textEditingController:
                                  controller.textEditingControllerChurch,
                              labelText: 'Church',
                              description: "Identify your active church",
                              endIconData: Icons.church_outlined,
                              readOnly: true,
                              onPressed: (text) {
                                if (controller.user.membership == null) {
                                  _showChurchSelectionDialog(context);
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Contact admin to change church",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: Insets.small.h),
                            TextFieldWrapper(
                              textEditingController:
                                  controller.textEditingControllerColumn,
                              labelText: 'Column',
                              description: "Identify your current column",
                              endIconData: Icons.other_houses_outlined,
                              textInputType: TextInputType.number,
                            ),
                            SizedBox(height: Insets.small.h),
                            Text(
                              "Your current baptize status",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w300,
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(height: Insets.small.h * .5),
                            CustomTwoOptionRadio(
                              actionText: 'Baptis',
                              initValue: controller.baptizeStatus,
                              onChangedOption:
                                  (int activeIndex, String activeTitle) {
                                controller.baptizeStatus = activeTitle;
                              },
                            ),
                            SizedBox(height: Insets.small.h),
                            Text(
                              "Your current sidi status",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w300,
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(height: Insets.small.h * .5),
                            CustomTwoOptionRadio(
                              actionText: 'Sidi',
                              initValue: controller.sidiStatus,
                              onChangedOption:
                                  (int activeIndex, String activeTitle) {
                                controller.sidiStatus = activeTitle;
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                      NextButton(
                        end: true,
                        title: 'Finish - Save',
                        onPressedPositive: controller.onPressedNextButton,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  _showChurchSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => DialogSelectChurch(
        churches: controller.churches ?? [],
        onSelectedChurch: controller.onSelectChurch,
      ),
    );
  }
}
