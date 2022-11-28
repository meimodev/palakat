import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/shared/theme.dart';

class CheckboxDialogNewEvent extends StatefulWidget {
  const CheckboxDialogNewEvent({
    Key? key,
    required this.text,
    required this.onChanged,
    this.checked,
  }) : super(key: key);

  final String text;
  final Function(bool isChecked, String text) onChanged;
  final bool? checked;

  @override
  State<CheckboxDialogNewEvent> createState() => _CheckboxDialogNewEventState();
}

class _CheckboxDialogNewEventState extends State<CheckboxDialogNewEvent> {
  bool isChecked = false;

  @override
  void initState() {

    super.initState();
    if (widget.checked !=null) {
      isChecked = widget.checked!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Palette.cardForeground,
      child: InkWell(
        onTap: () {
          setState(() {
            isChecked = !isChecked;
          });
          widget.onChanged(isChecked, widget.text);
        },
        child: Row(
          children: [
            Checkbox(
              activeColor: Palette.primary,
              side: const BorderSide(color: Colors.grey, width: 2),
              visualDensity: VisualDensity.compact,
              value: isChecked,
              onChanged: (bool? value) {
                setState(() {
                  isChecked = !isChecked;
                });
                widget.onChanged(isChecked, widget.text);
              },
            ),
            Text(
              widget.text,
              style: Theme.of(context).textTheme.bodyText1?.copyWith(
                    color: isChecked ? Palette.primary : Colors.grey,
                    fontSize: 12.sp,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}