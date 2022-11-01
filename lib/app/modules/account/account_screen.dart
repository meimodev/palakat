import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:palakat/app/modules/account/account_controller.dart';
import 'package:palakat/app/widgets/dialog_select_church.dart';
import 'package:palakat/app/widgets/screen_wrapper.dart';
import 'package:palakat/data/models/church.dart';
import 'package:palakat/data/models/model_mock.dart';
import 'package:palakat/shared/theme.dart';

class AccountScreen extends GetView<AccountController> {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Insets.medium.w,
          vertical: Insets.small.h,
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Text(
              'About',
              style: Theme.of(context).textTheme.headline1?.copyWith(
                    fontSize: 36.sp,
                  ),
            ),
            SizedBox(height: Insets.medium.h),
            Text(
              'Account',
              style: Theme.of(context).textTheme.headline1?.copyWith(
                    fontSize: 21.sp,
                  ),
            ),
            SizedBox(height: Insets.small.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.small.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: controller.textEditingControllerName,
                    enableSuggestions: false,
                    autocorrect: false,
                    maxLines: 1,
                    cursorColor: Palette.primary,
                    keyboardType: TextInputType.text,
                    style: Theme.of(context).textTheme.headline1?.copyWith(
                          fontSize: 14.sp,
                          color: Palette.primary,
                        ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(0.sp),
                      isDense: true,
                      border: InputBorder.none,
                      labelText: 'Name',
                      labelStyle:
                          Theme.of(context).textTheme.headline1?.copyWith(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                    ),
                  ),
                  SizedBox(height: Insets.small.h),
                  TextField(
                    controller: controller.textEditingControllerDob,
                    enableSuggestions: false,
                    autocorrect: false,
                    maxLines: 1,
                    cursorColor: Palette.primary,
                    keyboardType: TextInputType.text,
                    style: Theme.of(context).textTheme.headline1?.copyWith(
                          fontSize: 14.sp,
                          color: Palette.primary,
                        ),
                    readOnly: true,
                    onTap: () {
                      _showDatePicker(context);
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(0.sp),
                      isDense: true,
                      border: InputBorder.none,
                      labelText: 'Date of Birth',
                      labelStyle:
                          Theme.of(context).textTheme.headline1?.copyWith(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                    ),
                  ),
                  SizedBox(height: Insets.small.h),
                  TextField(
                    controller: controller.textEditingControllerPhone,
                    enableSuggestions: false,
                    autocorrect: false,
                    maxLines: 1,
                    enabled: false,
                    cursorColor: Palette.primary,
                    keyboardType: TextInputType.text,
                    style: Theme.of(context).textTheme.headline1?.copyWith(
                          fontSize: 14.sp,
                          color: Palette.primary,
                        ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(0.sp),
                      isDense: true,
                      border: InputBorder.none,
                      labelText: 'Phone',
                      labelStyle:
                          Theme.of(context).textTheme.headline1?.copyWith(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Insets.medium.h),
            Text(
              'Membership',
              style: Theme.of(context).textTheme.headline1?.copyWith(
                    fontSize: 21.sp,
                  ),
            ),
            SizedBox(height: Insets.small.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Insets.small.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: controller.textEditingControllerColumn,
                    enableSuggestions: false,
                    autocorrect: false,
                    maxLines: 1,
                    cursorColor: Palette.primary,
                    keyboardType: TextInputType.number,
                    style: Theme.of(context).textTheme.headline1?.copyWith(
                          fontSize: 14.sp,
                          color: Palette.primary,
                        ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(0.sp),
                      isDense: true,
                      border: InputBorder.none,
                      labelText: 'Church Column',
                      labelStyle:
                          Theme.of(context).textTheme.headline1?.copyWith(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                    ),
                  ),
                  SizedBox(height: Insets.small.h),
                  TextField(
                    controller: controller.textEditingControllerChurchName,
                    enableSuggestions: false,
                    autocorrect: false,
                    maxLines: 1,
                    cursorColor: Palette.primary,
                    keyboardType: TextInputType.text,
                    style: Theme.of(context).textTheme.headline1?.copyWith(
                          fontSize: 14.sp,
                          color: Palette.primary,
                        ),
                    readOnly: true,
                    onTap: () {
                      _showChurchSelectionDialog(context);
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(0.sp),
                      isDense: true,
                      border: InputBorder.none,
                      labelText: 'Church Name',
                      labelStyle:
                          Theme.of(context).textTheme.headline1?.copyWith(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                    ),
                  ),
                  SizedBox(height: Insets.small.h),
                  TextField(
                    controller: controller.textEditingControllerChurchLocation,
                    enableSuggestions: false,
                    autocorrect: false,
                    maxLines: 1,
                    cursorColor: Palette.primary,
                    keyboardType: TextInputType.text,
                    style: Theme.of(context).textTheme.headline1?.copyWith(
                          fontSize: 14.sp,
                          color: Palette.primary,
                        ),
                    readOnly: true,
                    onTap: () {
                      _showChurchSelectionDialog(context);
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(0.sp),
                      isDense: true,
                      border: InputBorder.none,
                      labelText: 'Church Location',
                      labelStyle:
                          Theme.of(context).textTheme.headline1?.copyWith(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Insets.medium.h * 1.5),
            _buildButtonsConfirm(
              context: context,
              onPressedNegative: () {
                Navigator.pop(context);
              },
              onPressedPositive: () {
                _validateInputs(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  _showChurchSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => DialogSelectChurch(
        churches: ModelMock.churches,
        onSelectedChurch: (Church church) {
          controller.textEditingControllerChurchName.text = church.name;
          controller.textEditingControllerChurchLocation.text = church.location;
        },
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
      minTime: Jiffy().subtract(years: 80).dateTime,
      maxTime: Jiffy().subtract(years: 5).dateTime,
      currentTime: Jiffy().subtract(years: 5).dateTime,
      locale: LocaleType.id,
      onChanged: (date) {
        String s = Jiffy(date).format("dd MMMM y");
        controller.textEditingControllerDob.text = s;
      },
    );
  }

  _buildButtonsConfirm({
    required BuildContext context,
    required VoidCallback onPressedPositive,
    required VoidCallback onPressedNegative,
  }) {
    buildButton(bool isConfirm, VoidCallback onPressed) {
      return Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(9.sp),
        color: isConfirm ? Palette.primary : Palette.cardForeground,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Insets.small.w,
              vertical: Insets.small.h,
            ),
            child: Row(
              children: [
                Icon(
                  isConfirm ? Icons.check : Icons.arrow_back,
                  color: isConfirm ? Palette.cardForeground : Palette.primary,
                  size: 15.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  isConfirm ? 'Confirm' : 'Back',
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(
                      fontWeight: FontWeight.w300,
                      fontSize: 15.sp,
                      color:
                          isConfirm ? Palette.cardForeground : Palette.primary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildButton(false, onPressedNegative),
        buildButton(true, onPressedPositive),
      ],
    );
  }

  _validateInputs(BuildContext context) {
    final String name = controller.textEditingControllerName.text;
    final String dob = controller.textEditingControllerDob.text;
    final String phone = controller.textEditingControllerPhone.text;
    final String column = controller.textEditingControllerColumn.text;
    final String cName = controller.textEditingControllerChurchName.text;
    final String cLocation =
        controller.textEditingControllerChurchLocation.text;

    if (name.isEmpty ||
        dob.isEmpty ||
        phone.isEmpty ||
        column.isEmpty ||
        cName.isEmpty ||
        cLocation.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) => const _SimpleDialog(
          title: 'Warning',
          description: 'No field can be empty',
        ),
      );
      return;
    }

    Navigator.pop(context);
  }
}

class _SimpleDialog extends StatelessWidget {
  const _SimpleDialog({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.hardEdge,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Container(
        color: Palette.scaffold,
        padding: EdgeInsets.symmetric(
          vertical: Insets.small.h,
          horizontal: Insets.medium.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    fontSize: 24.sp,
                  ),
            ),
            SizedBox(height: Insets.small.h),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    fontSize: 13.sp,
                fontWeight: FontWeight.w300,
                  ),
            ),
            SizedBox(height: Insets.medium.h),
          ],
        ),
      ),
    );
  }
}
