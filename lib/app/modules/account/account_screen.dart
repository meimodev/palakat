import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:palakat/app/modules/account/account_controller.dart';
import 'package:palakat/app/widgets/custom_two_option_radio.dart';
import 'package:palakat/app/widgets/next_button.dart';
import 'package:palakat/app/widgets/screen_title.dart';
import 'package:palakat/app/widgets/screen_wrapper.dart';
import 'package:palakat/app/widgets/text_field_wrapper.dart';
import 'package:palakat/shared/theme.dart';

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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  SizedBox(height: Insets.large.h),
                  const ScreenTitle(title: 'Account'),
                  SizedBox(height: Insets.medium.h),
                  TextFieldWrapper(
                    textEditingController:
                        controller.textEditingControllerPhone,
                    labelText: 'Phone Number',
                    description:
                        "active phone to receive authentication messages",
                    textInputType: TextInputType.phone,
                    endIconData: Icons.call_outlined,
                    maxLength: 13,
                  ),
                  SizedBox(height: Insets.small.h),
                  TextFieldWrapper(
                    textEditingController: controller.textEditingControllerName,
                    labelText: 'Full Name',
                    description: "use to identify your church membership",
                    endIconData: Icons.person_outline,
                  ),
                  SizedBox(height: Insets.small.h),
                  TextFieldWrapper(
                    textEditingController: controller.textEditingControllerDob,
                    labelText: 'Date of Birth',
                    description: "use to determine your BIPRA membership",
                    endIconData: Icons.calendar_month_outlined,
                    readOnly: true,
                    onPressed: () {
                      _showDatePicker(context);
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
                    onChangedOption: (int activeIndex, String activeTitle) {
                      controller.maritalStatus = activeTitle;
                    },
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
    );
  }

  _showDatePicker(BuildContext context) {
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
      currentTime: Jiffy().dateTime,
      locale: LocaleType.id,
      onChanged: (date) {
        String s = Jiffy(date).format("dd MMMM y");
        controller.textEditingControllerDob.text = s;
      },
    );
  }
}
