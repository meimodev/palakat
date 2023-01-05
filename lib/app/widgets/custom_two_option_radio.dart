import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palakat/shared/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTwoOptionRadio extends StatefulWidget {
  const CustomTwoOptionRadio({
    Key? key,
    required this.onChangedOption, required this.actionText,
  }) : super(key: key);

  final Function(int activeIndex, String activeTitle) onChangedOption;
  final String actionText;

  @override
  State<CustomTwoOptionRadio> createState() => _CustomTwoOptionRadioState();
}

class _CustomTwoOptionRadioState extends State<CustomTwoOptionRadio> {
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Palette.cardForeground,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildOption(
              title: "Belum ${widget.actionText.capitalizeFirst!}",
              index: 0,
              active: activeIndex == 0,
            ),
          ),
          Expanded(
            child: _buildOption(
              title: widget.actionText.capitalizeFirst!,
              index: 1,
              active: activeIndex == 1,
            ),
          ),
        ],
      ),
    );
  }

  _buildOption({bool active = false, required String title, required index}) =>
      Material(
        color: active ? Palette.primary : Palette.cardForeground,
        // borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: () {
            setState(() {
              activeIndex = index;
              widget.onChangedOption(index, title);
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Insets.small.w,
              vertical: Insets.small.h * 1.25,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: active ? Palette.cardForeground : Palette.primary,
                      fontSize: 14.sp,
                    ),
                  ),
                  active ? const SizedBox(width: 6) : const SizedBox(),
                  active
                      ? Icon(
                          Icons.check,
                          color: Palette.cardForeground,
                          size: 15.sp,
                        )
                      : const SizedBox()
                ],
              ),
            ),
          ),
        ),
      );
}
