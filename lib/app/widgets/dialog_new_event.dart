import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:palakat/app/widgets/button_confirm_dialog.dart';
import 'package:palakat/app/widgets/card_event_item.dart';
import 'package:palakat/app/widgets/checkbox_dialog_new_event.dart';
import 'package:palakat/app/widgets/custom_simple_dialog.dart';
import 'package:palakat/app/widgets/text_field_wrapper.dart';
import 'package:palakat/data/models/event.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:palakat/shared/shared.dart';

class DialogNewEvent extends StatefulWidget {
  DialogNewEvent({
    Key? key,
    required this.onPressedPositive,
    this.event,
  }) : super(key: key);

  @override
  State<DialogNewEvent> createState() => _DialogNewEventState();

  final void Function(
    String title,
    String location,
    DateTime dateTime,
    List<String> reminders,
  ) onPressedPositive;

  final List<String> hintTitles = [
    "Ibadah Pemuda Jemaat",
    "Ibadah Gabungan Pemuda Remaja Kolom 5, 6 & 7",
    "Ibadah Natal Remaja Jemaat",
    "Latihan Paduan Suara PKB Jemaat",
    "Rapat Panitia HRG Jemaat",
  ];
  final List<String> hintLocations = [
    "Gedung Gereja",
    "Kel. Abcd - Efgh, Kolom 4",
    "Sdr. Abcd Efgh, Kolom 1",
    "Taman Getsemani",
  ];

  final Event? event;
}

class _DialogNewEventState extends State<DialogNewEvent> {
  TextEditingController textEditingControllerTitle = TextEditingController();
  TextEditingController textEditingControllerLocation = TextEditingController();
  TextEditingController textEditingControllerDateTime = TextEditingController();
  List<String> reminders = [];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      textEditingControllerTitle.text = widget.event!.title;
      textEditingControllerLocation.text = widget.event!.location;
      textEditingControllerDateTime.text =
          widget.event!.eventDateTimeStamp.format(Values.eventDateTimeFormat);

      setState(() {
        reminders = widget.event!.reminders;
      });
    }
  }

  @override
  void dispose() {
    textEditingControllerTitle.dispose();
    textEditingControllerLocation.dispose();
    textEditingControllerDateTime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Insets.medium.w,
          vertical: Insets.medium.h,
        ),
        color: Palette.scaffold,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          primary: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Event Info',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                ),
              ),
              SizedBox(height: Insets.medium.h),
              TextFieldWrapper(
                textEditingController: textEditingControllerTitle,
                labelText: "Title",
                endIconData: Icons.title,
                hintText: widget.hintLocations[
                    Random().nextInt(widget.hintTitles.length - 1)],
              ),
              SizedBox(
                height: Insets.small.h,
              ),
              TextFieldWrapper(
                textEditingController: textEditingControllerLocation,
                labelText: "Location",
                endIconData: Icons.map_outlined,
                hintText: widget.hintLocations[
                    Random().nextInt(widget.hintLocations.length - 1)],
              ),
              SizedBox(
                height: Insets.small.h,
              ),
              TextFieldWrapper(
                textEditingController: textEditingControllerDateTime,
                labelText: 'Date & Time',
                endIconData: Icons.calendar_month_outlined,
                readOnly: true,
                onPressed: (text) {
                  _showDatePicker(context);
                },
              ),
              SizedBox(
                height: Insets.small.h,
              ),
              // _BuildCardDateTime(
              //   dateTime: dateTime,
              //   onChangedValue: (String value) {
              //     dateTime = value;
              //   },
              // ),
              // SizedBox(
              //   height: Insets.small.h,
              // ),
              CardEventItem(
                text: 'Reminders',
                icon: Icons.notifications_outlined,
                builder: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: Insets.small.h * .5),
                    CheckboxDialogNewEvent(
                      text: 'On Time',
                      checked: reminders.contains('On Time'),
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
                      checked: reminders.contains('30 Minute Before'),
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
                      checked: reminders.contains('1 Hour Before'),
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
                      color: Palette.negative,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  ButtonConfirmDialog(
                    icon: Icon(
                      Icons.check,
                      size: 15.sp,
                      color: Palette.positive,
                    ),
                    onPressed: () {
                      if (!_validateInput(context)) {
                        return;
                      }

                      String title = textEditingControllerTitle.text;
                      String location = textEditingControllerLocation.text;
                      String dateTime = textEditingControllerDateTime.text;
                      widget.onPressedPositive(
                        title,
                        location,
                        Jiffy(dateTime, Values.eventDateTimeFormat).dateTime,
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
      ),
    );
  }

  _validateInput(BuildContext context) {
    if (textEditingControllerTitle.text.isEmpty) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Title cannot be empty",
        ),
      );
      return false;
    }
    if (textEditingControllerLocation.text.isEmpty) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Location cannot be empty",
        ),
      );
      return false;
    }

    if (textEditingControllerDateTime.text.isEmpty) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Date & Time cannot be empty",
        ),
      );
      return false;
    }

    if (reminders.isEmpty) {
      Get.dialog(
        const CustomSimpleDialog(
          title: "Warning",
          description: "Reminders cannot be empty",
        ),
      );
      return false;
    }
    return true;
  }

  _showDatePicker(BuildContext context) {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: false,
      theme: DatePickerTheme(
        backgroundColor: Palette.scaffold,
        headerColor: Palette.primary,
        itemStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Palette.primary,
              fontSize: 14.sp,
            ),
      ),
      minTime: Jiffy().subtract(minutes: 5). dateTime,
      maxTime: Jiffy().add(years: 20).dateTime,
      currentTime: Jiffy().dateTime,
      onConfirm: (date) {
        String s = Jiffy(date).format(Values.eventDateTimeFormat);
        textEditingControllerDateTime.text = s;
      },      locale: LocaleType.id,
      onChanged: (date) {
        String s = Jiffy(date).format(Values.eventDateTimeFormat);
        textEditingControllerDateTime.text = s;
      },
    );
  }
}
