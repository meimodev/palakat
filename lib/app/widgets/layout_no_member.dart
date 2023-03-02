import 'package:flutter/material.dart';
import 'package:palakat/app/widgets/button_new_event.dart';
import 'package:palakat/shared/shared.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LayoutNoMember extends StatelessWidget {
  const LayoutNoMember({
    Key? key,
    this.caption,
    required this.onFinishRegister,
  }) : super(key: key);

  final String? caption;
  final void Function() onFinishRegister;

  void onPressedRegister(BuildContext context) async {
    //await the registering process
    await Navigator.pushNamed(context, Routes.account);
    onFinishRegister();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            caption ?? "Register to see your local church published activity",
            style: TextStyle(
              fontSize: 24.sp,
            ),
          ),
          SizedBox(height: Insets.small.h),
          ButtonNewEvent(
            onPressed: () => onPressedRegister(context),
            title: "Register",
          ),
        ],
      ),
    );
  }
}
