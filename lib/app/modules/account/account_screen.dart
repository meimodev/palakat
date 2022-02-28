import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiffy/jiffy.dart';
import 'package:palakat/app/blocs/user_cubit.dart';
import 'package:palakat/app/widgets/dialog_select_church.dart';
import 'package:palakat/app/widgets/screen_wrapper.dart';
import 'package:palakat/data/models/church.dart';
import 'package:palakat/data/models/model_mock.dart';
import 'package:palakat/data/models/user.dart';
import 'package:palakat/shared/theme.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  TextEditingController textEditingControllerName = TextEditingController();
  TextEditingController textEditingControllerDob = TextEditingController();
  TextEditingController textEditingControllerPhone = TextEditingController();

  TextEditingController textEditingControllerColumn = TextEditingController();
  TextEditingController textEditingControllerChurchName =
      TextEditingController();
  TextEditingController textEditingControllerChurchLocation =
      TextEditingController();

  @override
  void dispose() {
    textEditingControllerName.dispose();
    textEditingControllerDob.dispose();
    textEditingControllerPhone.dispose();
    textEditingControllerColumn.dispose();
    textEditingControllerChurchName.dispose();
    textEditingControllerChurchLocation.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // textEditingControllerName.text = widget.user.name;
    // textEditingControllerDob.text = widget.user.dob;
    // textEditingControllerPhone.text = widget.user.phone;
    //
    // textEditingControllerColumn.text = widget.user.column;
    // textEditingControllerChurchName.text = widget.user.church.name;
    // textEditingControllerChurchLocation.text = widget.user.church.location;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Insets.small.w,
          vertical: Insets.medium.h,
        ),
        child: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            if (state is UserLoaded) {
              _fillFields(state.user);
              return ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Text(
                    'About Account',
                    style: Theme.of(context).textTheme.headline1?.copyWith(
                          fontSize: 36.sp,
                        ),
                  ),
                  SizedBox(height: Insets.small.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Insets.small.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: textEditingControllerName,
                          enableSuggestions: false,
                          autocorrect: false,
                          maxLines: 1,
                          cursorColor: Palette.primary,
                          keyboardType: TextInputType.text,
                          style:
                              Theme.of(context).textTheme.headline1?.copyWith(
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
                          controller: textEditingControllerDob,
                          enableSuggestions: false,
                          autocorrect: false,
                          maxLines: 1,
                          cursorColor: Palette.primary,
                          keyboardType: TextInputType.text,
                          style:
                              Theme.of(context).textTheme.headline1?.copyWith(
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
                          controller: textEditingControllerPhone,
                          enableSuggestions: false,
                          autocorrect: false,
                          maxLines: 1,
                          enabled: false,
                          cursorColor: Palette.primary,
                          keyboardType: TextInputType.text,
                          style:
                              Theme.of(context).textTheme.headline1?.copyWith(
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
                    'About  Membership',
                    style: Theme.of(context).textTheme.headline1?.copyWith(
                          fontSize: 36.sp,
                        ),
                  ),
                  SizedBox(height: Insets.small.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Insets.small.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: textEditingControllerColumn,
                          enableSuggestions: false,
                          autocorrect: false,
                          maxLines: 1,
                          cursorColor: Palette.primary,
                          keyboardType: TextInputType.number,
                          style:
                              Theme.of(context).textTheme.headline1?.copyWith(
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
                          controller: textEditingControllerChurchName,
                          enableSuggestions: false,
                          autocorrect: false,
                          maxLines: 1,
                          cursorColor: Palette.primary,
                          keyboardType: TextInputType.text,
                          style:
                              Theme.of(context).textTheme.headline1?.copyWith(
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
                          controller: textEditingControllerChurchLocation,
                          enableSuggestions: false,
                          autocorrect: false,
                          maxLines: 1,
                          cursorColor: Palette.primary,
                          keyboardType: TextInputType.text,
                          style:
                              Theme.of(context).textTheme.headline1?.copyWith(
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
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
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
          textEditingControllerChurchName.text = church.name;
          textEditingControllerChurchLocation.text = church.location;
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
        textEditingControllerDob.text = s;
      },
    );
  }

  _buildButtonsConfirm({
    required BuildContext context,
    required VoidCallback onPressedPositive,
    required VoidCallback onPressedNegative,
  }) {
    _buildButton(bool isConfirm, VoidCallback onPressed) {
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
                  Icons.delete,
                  color: isConfirm ? Palette.cardForeground : Palette.primary,
                  size: 15.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  isConfirm ? 'Confirm' : 'Cancel',
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
        _buildButton(false, onPressedNegative),
        _buildButton(true, onPressedPositive),
      ],
    );
  }

  _validateInputs(BuildContext context) {
    final String name = textEditingControllerName.text;
    final String dob = textEditingControllerDob.text;
    final String phone = textEditingControllerPhone.text;
    final String column = textEditingControllerColumn.text;
    final String cName = textEditingControllerChurchName.text;
    final String cLocation = textEditingControllerChurchLocation.text;

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
    context.read<UserCubit>().loadUser(
          User(
            dob: dob,
            phone: phone,
            column: column,
            id: 123,
            name: name,
            church: Church(
              id: '123',
              name: cName,
              location: cLocation,
            ),
          ),
        );
    Navigator.pop(context);
  }

  void _fillFields(User user) {
    textEditingControllerName.text = user.name;
    textEditingControllerDob.text = user.dob;
    textEditingControllerPhone.text = user.phone;

    textEditingControllerColumn.text = user.column;
    textEditingControllerChurchName.text = user.church.name;
    textEditingControllerChurchLocation.text = user.church.location;
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
        width: 210.w,
        color: Palette.scaffold,
        padding: EdgeInsets.symmetric(
          vertical: Insets.medium.h,
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
                    fontSize: 14.sp,
                  ),
            ),
            SizedBox(height: Insets.medium.h),
          ],
        ),
      ),
    );
  }
}