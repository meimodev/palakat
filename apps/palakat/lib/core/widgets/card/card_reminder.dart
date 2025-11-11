import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

class CardReminder extends StatelessWidget {
  const CardReminder({
    super.key,
    required this.reminder,
    required this.onPressed,
  });

  final Reminder reminder;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: BaseColor.cardBackground1,
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.w12,
            vertical: BaseSize.h6,
          ),
          child: Row(
            children: [
              Gap.w12,
              SizedBox(
                  height: BaseSize.h40,
                  child: Center(
                    child: Text(
                      reminder.name,
                      style: BaseTypography.titleMedium,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
