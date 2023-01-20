import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:palakat/app/modules/account/account_controller.dart';
import 'package:palakat/app/widgets/custom_two_option_radio.dart';
import 'package:palakat/app/widgets/dialog_simple_confirm.dart';
import 'package:palakat/app/widgets/next_button.dart';
import 'package:palakat/app/widgets/screen_title.dart';
import 'package:palakat/app/widgets/screen_wrapper.dart';
import 'package:palakat/app/widgets/text_field_wrapper.dart';
import 'package:palakat/shared/shared.dart';

class AccountScreen extends GetView<AccountController> {
  const AccountScreen({Key? key}) : super(key: key);

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
                            ScreenTitle(
                              title: 'Account',
                              onPressedBack: () async {
                                return await Get.dialog<bool>(
                                      const DialogSimpleConfirm(
                                        description:
                                            "Any changes you've made won't be save, continue ?",
                                      ),
                                    ) ??
                                    false;
                              },
                            ),
                            SizedBox(height: Insets.medium.h),
                            TextFieldWrapper(
                              readOnly: controller.user != null,
                              textEditingController:
                                  controller.textEditingControllerPhone,
                              labelText: 'Phone Number',
                              description:
                                  "active phone to receive authentication messages",
                              textInputType: TextInputType.phone,
                              endIconData: Icons.call_outlined,
                              maxLength: 13,
                              onPressed: (_) {
                                if (controller.user == null) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Contact admin to change number",
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
                                  controller.textEditingControllerName,
                              labelText: 'Full Name',
                              description:
                                  "use to identify your church membership",
                              endIconData: Icons.person_outline,
                            ),
                            SizedBox(height: Insets.small.h),
                            TextFieldWrapper(
                              textEditingController:
                                  controller.textEditingControllerDob,
                              labelText: 'Date of Birth',
                              description:
                                  "use to determine your BIPRA membership",
                              endIconData: Icons.calendar_month_outlined,
                              readOnly: true,
                              onPressed: (text) {
                                _showDatePicker(context, text);
                              },
                            ),
                            SizedBox(height: Insets.small.h),
                            Text(
                              "use to determine your BIPRA membership ( WKI/PKB )",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w300,
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(height: Insets.small.h * .5),
                            CustomTwoOptionRadio(
                              onChangedOption:
                                  (int activeIndex, String activeTitle) {
                                controller.maritalStatus = activeTitle;
                              },
                              initValue: controller.maritalStatus,
                              actionText: 'Menikah',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                      NextButton(
                        title: 'Next',
                        onPressedPositive: controller.onPressedNextButton,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  _showDatePicker(BuildContext context, String dateText) {
    DatePicker.showDatePicker(
      context,
      showTitleActions: false,
      theme: DatePickerTheme(
        backgroundColor: Palette.scaffold,
        headerColor: Palette.primary,
        itemStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
              color: Palette.primary,
              fontSize: 14.sp,
            ),
      ),
      minTime: Jiffy().subtract(years: 100).dateTime,
      maxTime: Jiffy().dateTime,
      currentTime: dateText.isEmpty
          ? Jiffy().dateTime
          : Jiffy(dateText, Values.dobPickerFormat).dateTime,
      locale: LocaleType.en,
      onChanged: (date) {
        String s = date.format(Values.dobPickerFormat);
        controller.textEditingControllerDob.text = s;
      },
    );
  }
}
