import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiffy/jiffy.dart';
import 'package:palakat/app/widgets/button_confirm_dialog.dart';
import 'package:palakat/app/widgets/card_event_item.dart';
import 'package:palakat/app/widgets/checkbox_dialog_new_event.dart';
import 'package:palakat/shared/theme.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class DialogNewEvent extends StatefulWidget {
  const DialogNewEvent({
    Key? key,
    required this.onPressedPositive,
  }) : super(key: key);

  @override
  State<DialogNewEvent> createState() => _DialogNewEventState();

  final void Function(
    String title,
    String location,
    String dateTime,
    List<String> reminders,
  ) onPressedPositive;
}

class _DialogNewEventState extends State<DialogNewEvent> {
  TextEditingController textEditingControllerTitle = TextEditingController();
  TextEditingController textEditingControllerLocation = TextEditingController();
  String dateTime = '';
  List<String> reminders = [];

  @override
  void dispose() {
    textEditingControllerTitle.dispose();
    textEditingControllerLocation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(24.sp),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Insets.medium.w,
          vertical: Insets.medium.h,
        ),
        color: Palette.scaffold,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: textEditingControllerTitle,
              enableSuggestions: false,
              autocorrect: false,
              maxLines: 1,
              cursorColor: Palette.primary,
              keyboardType: TextInputType.text,
              style: Theme.of(context).textTheme.headline1?.copyWith(
                    fontSize: 24.sp,
                    color: Palette.primary,
                  ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(0),
                isDense: true,
                border: InputBorder.none,
                labelText: 'Title',
                labelStyle: Theme.of(context).textTheme.headline1?.copyWith(
                      fontSize: 24.sp,
                      color: Colors.grey,
                    ),
              ),
            ),
            SizedBox(
              height: Insets.small.h * .5,
            ),
            TextField(
              controller: textEditingControllerLocation,
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
                labelText: 'Location',
                labelStyle: Theme.of(context).textTheme.headline1?.copyWith(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
              ),
            ),
            SizedBox(
              height: Insets.small.h,
            ),
            _BuildCardDateTime(
              onChangedValue: (String value) {
                dateTime = value;
              },
            ),
            SizedBox(
              height: Insets.small.h,
            ),
            CardEventItem(
              text: 'Reminder',
              builder: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: Insets.small.h * .5),
                  CheckboxDialogNewEvent(
                    text: 'On Time',
                    onChanged: (isChecked, text) {
                      if (isChecked) {
                        reminders.add(text);
                      } else {
                        reminders.remove(text);
                      }
                    },
                  ),
                  CheckboxDialogNewEvent(
                    text: '30 Minute Before',
                    onChanged: (isChecked, text) {
                      if (isChecked) {
                        reminders.add(text);
                      } else {
                        reminders.remove(text);
                      }
                    },
                  ),
                  CheckboxDialogNewEvent(
                    text: '1 Hour Before',
                    onChanged: (isChecked, text) {
                      if (isChecked) {
                        reminders.add(text);
                      } else {
                        reminders.remove(text);
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: Insets.medium.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ButtonConfirmDialog(
                  invertColor: true,
                  icon: Icon(
                    Icons.close,
                    size: 15.sp,
                    color: Palette.primary,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                ButtonConfirmDialog(
                  icon: Icon(
                    Icons.check,
                    size: 15.sp,
                    color: Palette.cardForeground,
                  ),
                  onPressed: () {
                    if (!_validateInput(context)) {
                      return;
                    }

                    String title = textEditingControllerTitle.text;
                    String location = textEditingControllerLocation.text;
                    widget.onPressedPositive(
                      title,
                      location,
                      dateTime,
                      reminders,
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _validateInput(BuildContext context) {
    if (textEditingControllerTitle.text.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title cannot be empty'),
        ),
      );
      return false;
    }
    if (textEditingControllerLocation.text.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location cannot be empty'),
        ),
      );
      return false;
    }

    if (dateTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Date & Time cannot be empty'),
        ),
      );
      return false;
    }

    if (reminders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder cannot be none'),
        ),
      );
      return false;
    }
    return true;
  }
}

class _BuildCardDateTime extends StatefulWidget {
  const _BuildCardDateTime({
    Key? key,
    required this.onChangedValue,
  }) : super(key: key);

  final Function(String value) onChangedValue;

  @override
  State<_BuildCardDateTime> createState() => _BuildCardDateTimeState();
}

class _BuildCardDateTimeState extends State<_BuildCardDateTime> {
  String dateTime = 'Date & Time';
  bool isValue = false;

  @override
  Widget build(BuildContext context) {
    return CardEventItem(
      isValue: isValue,
      text: dateTime,
      onPressed: () {
        DatePicker.showDateTimePicker(
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
          minTime: DateTime.now(),
          maxTime: DateTime(2019, 6, 7),
          currentTime: DateTime.now(),
          locale: LocaleType.id,
          onChanged: (date) {
            String s = Jiffy(date).format("EEEE, dd/MM/y HH:mm");
            setState(() {
              isValue = true;
              dateTime = s;
            });
            widget.onChangedValue(s);
          },
        );
      },
      icon: Icons.alarm,
    );
  }
}
