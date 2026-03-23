import 'package:palakat_shared/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:palakat_shared/constants.dart';
import 'package:palakat_shared/theme.dart';

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
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 6.0,
          ),
          child: Row(
            children: [
              Gap.w12,
              SizedBox(
                height: 40.0,
                child: Center(
                  child: Text(reminder.name, style: Theme.of(context).textTheme.titleMedium!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
