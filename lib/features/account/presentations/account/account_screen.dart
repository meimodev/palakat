import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitleWidget.primary(
            title: "Account",
            leadIcon: Assets.icons.line.chevronBackOutline,
            leadIconColor: Colors.black,
            onPressedLeadIcon: context.pop,
          ),
          Gap.h48,
          InputWidget.text(
            hint: "Phone Number",
            label: "active phone to receive authentication message",
          ),
          Gap.h12,
          InputWidget.text(
            hint: "Full Name",
            label: "use to identify your church membership Withour Degree",
          ),
          Gap.h12,
          InputWidget.dropdown(
            label: "use to determine your BIPRA membership",
            hint: "Date Of Birth",
            onPressedWithResult: () async {
              print("dob");
              return "result";
            }, onChanged: print,
          ),
          Gap.h12,
          InputWidget.binaryOption(
            currentInputValue: "Male",
            options: ["Male", "Female"],
            label: "use to determine your BIPRA membership",
            onChanged: print,
          ),
          Gap.h12,
          InputWidget.binaryOption(
            currentInputValue: "Married",
            options: ["Married", "Not Married"],
            label: "use to determine your BIPRA membership",
            onChanged: print,
          ),
          Gap.h48,
          ButtonWidget.primary(text: "Submit", onTap: () {}),
        ],
      ),
    );
  }
}
